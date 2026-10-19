// Paiement Mobile Money d'une commande (PAY-03) : ouvre la session nyole, ou rend celle en cours pour un nouvel
// essai ; un paiement déjà confirmé chez nyole est appliqué tout de suite (webhook perdu ou en retard).
import { createClient } from '@supabase/supabase-js';
import { corsHeaders, json } from '../_shared/http.ts';
import { createSession, nyoleConfigured, sessionStatus, settle } from '../_shared/nyole.ts';

const url = Deno.env.get('SUPABASE_URL')!;
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
const admin = createClient(url, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: { persistSession: false, autoRefreshToken: false },
});
// Page où nyole renvoie le client après paiement ou abandon (facultative : l'app suit le statut en direct).
const returnUrl = Deno.env.get('NYOLE_RETURN_URL');

type Checkout = {
  transaction_id: string;
  amount: number;
  currency: string;
  order_number: string;
  customer_name: string | null;
  customer_phone: string | null;
  session_id: string | null;
  checkout_url: string | null;
  attempt: number;
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ code: 'method_not_allowed' }, 405);
  if (!nyoleConfigured()) return json({ code: 'payment_unavailable' }, 503);

  const { order_id: orderId } = (await req.json().catch(() => ({}))) as { order_id?: string };
  if (!orderId) return json({ code: 'invalid_request' }, 400);
  // Vérifié au nom du client : seule sa commande, en attente de paiement.
  const asCaller = createClient(url, anonKey, {
    global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
  });
  const { data, error } = await asCaller.rpc('begin_mobile_money', { p_order_id: orderId });
  if (error) return error.code === 'P0001' ? json({ code: error.message }, 409) : json({ code: 'unauthorized' }, 401);
  const checkout = data as Checkout;

  try {
    let attempt = checkout.attempt;
    if (checkout.session_id) {
      const current = await sessionStatus(checkout.session_id);
      if (current.status === 'SUCCESS') {
        await settle(admin, checkout.transaction_id, checkout.session_id);
        return json({ status: 'succeeded' });
      }
      if (current.status === 'PENDING' || current.status === 'FAILED') {
        await record(checkout, checkout.session_id, checkout.checkout_url!, null, attempt);
        return json({ status: 'pending', url: checkout.checkout_url });
      }
      // Session annulée chez nyole : une nouvelle est ouverte.
      attempt += 1;
    }
    const session = await createSession(
      {
        amount: checkout.amount,
        currency: checkout.currency,
        customer_name: checkout.customer_name ?? undefined,
        customer_phone: checkout.customer_phone ?? undefined,
        description: `Commande ${checkout.order_number}`,
        merchant_name: 'Tchopi',
        metadata: { transaction_id: checkout.transaction_id, order_number: checkout.order_number },
        ...(returnUrl ? { success_url: returnUrl, cancel_url: returnUrl } : {}),
      },
      `${checkout.transaction_id}-${attempt}`,
    );
    await record(checkout, session.id, session.url, session.order_id ?? null, attempt);
    return json({ status: 'pending', url: session.url });
  } catch (e) {
    console.error(e);
    return json({ code: 'payment_provider_error' }, 502);
  }
});

async function record(checkout: Checkout, sessionId: string, sessionUrl: string, reference: string | null, attempt: number) {
  const { error } = await admin.rpc('record_checkout_session', {
    p_transaction_id: checkout.transaction_id,
    p_session_id: sessionId,
    p_url: sessionUrl,
    p_reference: reference,
    p_attempt: attempt,
  });
  if (error) throw error;
}
