// Client nyole (Mobile Money, ADR-028) : sessions de paiement, statut faisant foi, signature des webhooks.
// Clé secrète (NYOLE_SECRET_KEY, « af_test_sec_… » ou « af_live_sec_… ») uniquement côté serveur.
import type { Provider, ProviderStatus } from './payments.ts';
import { verifySignature } from './signature.ts';

const api = (Deno.env.get('NYOLE_API_URL') ?? 'https://app.nyole.com/api').replace(/\/$/, '');
const secret = Deno.env.get('NYOLE_SECRET_KEY') ?? '';
// Page où nyole renvoie le client après paiement ou abandon (facultative : l'app suit le statut en direct).
const returnUrl = Deno.env.get('NYOLE_RETURN_URL');

async function call<T>(path: string, init: RequestInit = {}): Promise<T> {
  const response = await fetch(`${api}${path}`, {
    ...init,
    headers: { Authorization: `Bearer ${secret}`, 'Content-Type': 'application/json', ...init.headers },
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(`nyole ${path} : ${response.status} ${body.error ?? ''}`);
  return body as T;
}

export const nyole: Provider = {
  configured: () => secret !== '',
  async open(checkout, attempt) {
    const session = await call<{ id: string; url: string; order_id?: string }>('/v1/checkout/sessions', {
      method: 'POST',
      body: JSON.stringify({
        amount: checkout.amount,
        currency: checkout.currency,
        customer_name: checkout.customer_name ?? undefined,
        customer_phone: checkout.customer_phone ?? undefined,
        description: `Commande ${checkout.order_number}`,
        merchant_name: 'Tchopi',
        metadata: { transaction_id: checkout.transaction_id, order_number: checkout.order_number },
        ...(returnUrl ? { success_url: returnUrl, cancel_url: returnUrl } : {}),
      }),
      headers: { 'Idempotency-Key': `${checkout.transaction_id}-${attempt}` },
    });
    return { id: session.id, url: session.url, reference: session.order_id };
  },
  async status(id) {
    const status = await call<Omit<ProviderStatus, 'reference'> & { order_id?: string }>(
      `/v1/checkout/sessions/${encodeURIComponent(id)}/status`,
    );
    return { status: status.status, amount: status.amount, currency: status.currency, reference: status.order_id };
  },
};

export const verifyNyoleSignature = (rawBody: string, header: string | null) =>
  verifySignature(rawBody, header, secret);
