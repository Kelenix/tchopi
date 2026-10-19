// Remboursements par carte (TRX-03, ADR-031) : appelée par la base (tâche planifiée) quand un paiement Stripe est
// « à rembourser ». Stripe rembourse le paiement entier, une seule fois (clé d'idempotence) ; un échec laisse le
// remboursement en attente : nouvel essai 10 min plus tard, ou remboursement manuel par l'admin.
import { createClient } from '@supabase/supabase-js';
import { json } from '../_shared/http.ts';
import { refundPayment, stripe } from '../_shared/stripe.ts';

const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const admin = createClient(Deno.env.get('SUPABASE_URL')!, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

Deno.serve(async (req) => {
  if (req.headers.get('Authorization') !== `Bearer ${serviceKey}`) return json({ code: 'unauthorized' }, 401);
  if (!stripe.configured()) return json({ code: 'payment_unavailable' }, 503);

  const { data, error } = await admin
    .from('transactions')
    .select('id, provider_reference, order:orders!inner(payment_status)')
    .eq('provider', 'stripe')
    .eq('status', 'succeeded')
    .eq('order.payment_status', 'refund_pending');
  if (error) return json({ code: 'unknown' }, 500);

  let refunded = 0;
  for (const transaction of data) {
    try {
      const refund = await refundPayment(transaction.id, transaction.provider_reference);
      if (refund.status !== 'succeeded' && refund.status !== 'pending') {
        console.error(`remboursement ${refund.id} : ${refund.status}`);
        continue;
      }
      const { error: recordError } = await admin.rpc('record_provider_refund', {
        p_transaction_id: transaction.id,
        p_reference: refund.id,
      });
      if (recordError) throw recordError;
      refunded++;
    } catch (e) {
      console.error(e);
    }
  }
  return json({ refunded });
});
