// Paiement en ligne d'une commande (PAY-03 Mobile Money, PAY-04 carte) : ouvre la session chez le fournisseur de la
// transaction, ou rend celle en cours pour un nouvel essai ; un paiement déjà confirmé chez le fournisseur est
// appliqué tout de suite (webhook perdu ou en retard).
import { createClient } from '@supabase/supabase-js';
import { corsHeaders, json } from '../_shared/http.ts';
import { nyole } from '../_shared/nyole.ts';
import { type Checkout, type Provider, settle } from '../_shared/payments.ts';
import { stripe } from '../_shared/stripe.ts';

const url = Deno.env.get('SUPABASE_URL')!;
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
const admin = createClient(url, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: { persistSession: false, autoRefreshToken: false },
});
const providers: Record<string, Provider> = { nyole, stripe };

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ code: 'method_not_allowed' }, 405);

  const { order_id: orderId } = (await req.json().catch(() => ({}))) as { order_id?: string };
  if (!orderId) return json({ code: 'invalid_request' }, 400);
  // Vérifié au nom du client : seule sa commande, en attente de paiement.
  const asCaller = createClient(url, anonKey, {
    global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
  });
  const { data, error } = await asCaller.rpc('begin_online_payment', { p_order_id: orderId });
  if (error) return error.code === 'P0001' ? json({ code: error.message }, 409) : json({ code: 'unauthorized' }, 401);
  const checkout = data as Checkout;
  const provider = providers[checkout.provider];
  if (!provider?.configured()) return json({ code: 'payment_unavailable' }, 503);

  try {
    let attempt = checkout.attempt;
    if (checkout.session_id) {
      const current = await provider.status(checkout.session_id);
      if (current.status === 'SUCCESS') {
        await settle(admin, provider, checkout.transaction_id, checkout.session_id);
        return json({ status: 'succeeded' });
      }
      if (current.status === 'PENDING' || current.status === 'FAILED') {
        await record(checkout, checkout.session_id, checkout.checkout_url!, null, attempt);
        return json({ status: 'pending', url: checkout.checkout_url });
      }
      // Session annulée ou expirée chez le fournisseur : une nouvelle est ouverte.
      attempt += 1;
    }
    const session = await provider.open(checkout, attempt);
    await record(checkout, session.id, session.url, session.reference ?? null, attempt);
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
