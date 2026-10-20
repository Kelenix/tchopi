// Client Stripe (carte bancaire, ADR-034) : sessions Checkout hébergées (3-D Secure compris), statut faisant foi,
// remboursements. Clés (STRIPE_SECRET_KEY « sk_test_… » / « sk_live_… », STRIPE_WEBHOOK_SECRET « whsec_… »)
// uniquement côté serveur ; PAYMENT_RETURN_URL : page affichée après le paiement (fonction payments-return).
import type { Provider } from './payments.ts';
import { verifySignature } from './signature.ts';

const api = (Deno.env.get('STRIPE_API_URL') ?? 'https://api.stripe.com').replace(/\/$/, '');
const secret = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? '';
const returnUrl = Deno.env.get('PAYMENT_RETURN_URL') ?? '';

type Session = {
  id: string;
  url: string;
  status: 'open' | 'complete' | 'expired';
  payment_status: 'paid' | 'unpaid' | 'no_payment_required';
  amount_total: number;
  currency: string;
  payment_intent: string | null;
};

/// Paramètres en formulaire (API Stripe) ; la même clé d'idempotence rend le même objet.
async function call<T>(path: string, params?: Record<string, string>, idempotencyKey?: string): Promise<T> {
  const response = await fetch(`${api}${path}`, {
    method: params ? 'POST' : 'GET',
    headers: {
      Authorization: `Bearer ${secret}`,
      ...(params ? { 'Content-Type': 'application/x-www-form-urlencoded' } : {}),
      ...(idempotencyKey ? { 'Idempotency-Key': idempotencyKey } : {}),
    },
    body: params ? new URLSearchParams(params) : undefined,
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(`stripe ${path} : ${response.status} ${body.error?.message ?? ''}`);
  return body as T;
}

export const stripe: Provider = {
  configured: () => secret !== '' && webhookSecret !== '' && returnUrl !== '',
  async open(checkout, attempt, returnTo) {
    // Durée minimale imposée par Stripe (30 min), arrondie aux 10 min suivantes pour qu'un double envoi garde les
    // mêmes paramètres. Payée après l'annulation de la commande, la session est remboursée automatiquement.
    const expiresAt = Math.ceil((Date.now() / 1000 + 30 * 60) / 600) * 600;
    const session = await call<Session>(
      '/v1/checkout/sessions',
      {
        mode: 'payment',
        'payment_method_types[0]': 'card',
        'line_items[0][quantity]': '1',
        'line_items[0][price_data][currency]': checkout.currency.toLowerCase(),
        // Le franc CFA n'a pas de décimales chez Stripe : le montant est en francs.
        'line_items[0][price_data][unit_amount]': String(checkout.amount),
        'line_items[0][price_data][product_data][name]': `Tchopi · Commande ${checkout.order_number}`,
        client_reference_id: checkout.transaction_id,
        'metadata[transaction_id]': checkout.transaction_id,
        'metadata[order_number]': checkout.order_number,
        'payment_intent_data[metadata][transaction_id]': checkout.transaction_id,
        locale: 'fr',
        success_url: returnTo ?? returnUrl,
        cancel_url: returnTo ?? returnUrl,
        expires_at: String(expiresAt),
      },
      `${checkout.transaction_id}-${attempt}`,
    );
    return { id: session.id, url: session.url };
  },
  async status(id) {
    const session = await call<Session>(`/v1/checkout/sessions/${encodeURIComponent(id)}`);
    return {
      status:
        session.status === 'complete' && session.payment_status === 'paid'
          ? 'SUCCESS'
          : session.status === 'expired'
            ? 'CANCELLED'
            : 'PENDING',
      amount: session.amount_total,
      currency: session.currency,
      reference: session.payment_intent ?? undefined,
    };
  },
};

/// Remboursement intégral d'un paiement ; la clé d'idempotence empêche tout second remboursement.
export const refundPayment = (transactionId: string, paymentIntent: string) =>
  call<{ id: string; status: string }>(
    '/v1/refunds',
    { payment_intent: paymentIntent, 'metadata[transaction_id]': transactionId },
    `refund-${transactionId}`,
  );

/// Remboursement relu chez Stripe (un webhook n'est jamais cru sur parole).
export const getRefund = (id: string) =>
  call<{ id: string; status: string; metadata?: { transaction_id?: string } }>(`/v1/refunds/${encodeURIComponent(id)}`);

export const verifyStripeSignature = (rawBody: string, header: string | null) =>
  verifySignature(rawBody, header, webhookSecret);
