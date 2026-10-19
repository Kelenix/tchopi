// Webhooks Stripe (PAY-04, PAY-05) : signature vérifiée, puis statut de la session relu chez Stripe avant toute
// écriture. Événements à activer : checkout.session.completed, checkout.session.expired.
import { createClient } from '@supabase/supabase-js';
import { handleWebhook } from '../_shared/payments.ts';
import { stripe, verifyStripeSignature } from '../_shared/stripe.ts';

const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: { persistSession: false, autoRefreshToken: false },
});

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('method_not_allowed', { status: 405 });
  const raw = await req.text();
  if (!(await verifyStripeSignature(raw, req.headers.get('Stripe-Signature')))) {
    return new Response('signature invalide', { status: 400 });
  }
  const event = JSON.parse(raw) as { type?: string; data?: { object?: { metadata?: { transaction_id?: string } } } };
  return handleWebhook(admin, stripe, event.type, event.data?.object?.metadata?.transaction_id);
});
