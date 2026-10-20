// Webhooks Stripe (PAY-04, PAY-05, ADR-039) : signature vérifiée, puis objet relu chez Stripe avant toute écriture.
// Événements à activer : checkout.session.completed, checkout.session.expired, refund.failed, refund.updated.
import { createClient } from '@supabase/supabase-js';
import { handleWebhook } from '../_shared/payments.ts';
import { getRefund, stripe, verifyStripeSignature } from '../_shared/stripe.ts';

const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: { persistSession: false, autoRefreshToken: false },
});

type StripeObject = { id?: string; object?: string; metadata?: { transaction_id?: string } };

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('method_not_allowed', { status: 405 });
  const raw = await req.text();
  if (!(await verifyStripeSignature(raw, req.headers.get('Stripe-Signature')))) {
    return new Response('signature invalide', { status: 400 });
  }
  const event = JSON.parse(raw) as { type?: string; data?: { object?: StripeObject } };
  const object = event.data?.object;
  if (object?.object === 'refund' && object.id) return refundEvent(object.id);
  return handleWebhook(admin, stripe, event.type, object?.metadata?.transaction_id);
});

/// Remboursement refusé après coup par la banque : la commande repasse « à rembourser » et l'admin est alerté.
async function refundEvent(id: string): Promise<Response> {
  try {
    const refund = await getRefund(id);
    const transactionId = refund.metadata?.transaction_id;
    if (transactionId && (refund.status === 'failed' || refund.status === 'canceled')) {
      const { data, error } = await admin.rpc('record_refund_failure', {
        p_transaction_id: transactionId,
        p_reference: refund.id,
      });
      if (error) throw error;
      console.log(`remboursement ${refund.id} : ${refund.status} → ${data}`);
    }
    return new Response('ok');
  } catch (e) {
    console.error(e);
    return new Response('retry', { status: 500 });
  }
}
