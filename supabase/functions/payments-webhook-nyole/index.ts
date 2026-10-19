// Webhooks nyole (PAY-03, PAY-05) : signature vérifiée, puis statut relu chez nyole avant toute écriture.
// Rejoué sans effet ; une erreur rend 500 pour que nyole réessaie (10 fois sur 72 h).
import { createClient } from '@supabase/supabase-js';
import { settle, verifySignature } from '../_shared/nyole.ts';

const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: { persistSession: false, autoRefreshToken: false },
});
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('method_not_allowed', { status: 405 });
  const raw = await req.text();
  if (!(await verifySignature(raw, req.headers.get('X-Afriflow-Signature')))) {
    return new Response('signature invalide', { status: 400 });
  }
  const event = JSON.parse(raw) as { event?: string; data?: { metadata?: { transaction_id?: string } } };
  const transactionId = event.data?.metadata?.transaction_id;
  // Événement sans transaction Tchopi (lien de paiement, autre outil) : rien à faire.
  if (!transactionId || !UUID.test(transactionId)) return new Response('ok');

  const { data: transaction } = await admin
    .from('transactions')
    .select('id, checkout_session_id')
    .eq('id', transactionId)
    .maybeSingle();
  if (!transaction?.checkout_session_id) return new Response('ok');
  try {
    const { provider, result } = await settle(admin, transaction.id, transaction.checkout_session_id);
    console.log(`${event.event} ${transaction.id} : ${provider} → ${result}`);
    return new Response('ok');
  } catch (e) {
    console.error(e);
    return new Response('retry', { status: 500 });
  }
});
