// Client nyole (Mobile Money, ADR-028) : sessions de paiement, statut faisant foi, signature des webhooks.
// Clé secrète (NYOLE_SECRET_KEY, « af_test_sec_… » ou « af_live_sec_… ») uniquement côté serveur.
import type { SupabaseClient } from '@supabase/supabase-js';

const api = (Deno.env.get('NYOLE_API_URL') ?? 'https://app.nyole.com/api').replace(/\/$/, '');
const secret = Deno.env.get('NYOLE_SECRET_KEY') ?? '';
const encoder = new TextEncoder();

export const nyoleConfigured = () => secret !== '';

export type Session = { id: string; url: string; order_id?: string };
export type SessionStatus = {
  status: 'PENDING' | 'SUCCESS' | 'FAILED' | 'CANCELLED' | 'REFUNDED';
  amount: number;
  currency: string;
  order_id?: string;
  provider_reference?: string;
};

async function call<T>(path: string, init: RequestInit = {}): Promise<T> {
  const response = await fetch(`${api}${path}`, {
    ...init,
    headers: { Authorization: `Bearer ${secret}`, 'Content-Type': 'application/json', ...init.headers },
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(`nyole ${path} : ${response.status} ${body.error ?? ''}`);
  return body as T;
}

/// La même clé d'idempotence rend la session déjà créée (double toucher, reprise réseau).
export const createSession = (payload: Record<string, unknown>, idempotencyKey: string) =>
  call<Session>('/v1/checkout/sessions', {
    method: 'POST',
    body: JSON.stringify(payload),
    headers: { 'Idempotency-Key': idempotencyKey },
  });

export const sessionStatus = (id: string) =>
  call<SessionStatus>(`/v1/checkout/sessions/${encodeURIComponent(id)}/status`);

/// Statut lu chez nyole (jamais celui annoncé par le webhook ou l'app) appliqué à la transaction.
export async function settle(admin: SupabaseClient, transactionId: string, sessionId: string) {
  const status = await sessionStatus(sessionId);
  const { data, error } = await admin.rpc('apply_payment_status', {
    p_transaction_id: transactionId,
    p_status: status.status,
    p_amount: status.amount,
    p_currency: status.currency,
    p_reference: status.order_id ?? null,
  });
  if (error) throw error;
  return { provider: status.status, result: data as string };
}

const hex = (bytes: ArrayBuffer) => [...new Uint8Array(bytes)].map((b) => b.toString(16).padStart(2, '0')).join('');

/// En-tête « t=<horodatage>,v1=<HMAC-SHA256 hex> » sur « <horodatage>.<corps brut> » ; 5 minutes de tolérance.
export async function verifySignature(rawBody: string, header: string | null, now = Date.now()): Promise<boolean> {
  const parts = Object.fromEntries(
    (header ?? '').split(',').map((part) => part.trim().split('=', 2) as [string, string]),
  );
  const timestamp = Number(parts.t);
  if (!secret || !parts.v1 || !Number.isFinite(timestamp) || Math.abs(now / 1000 - timestamp) > 300) return false;
  const key = await crypto.subtle.importKey('raw', encoder.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, [
    'sign',
  ]);
  const expected = hex(await crypto.subtle.sign('HMAC', key, encoder.encode(`${parts.t}.${rawBody}`)));
  if (expected.length !== parts.v1.length) return false;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) diff |= expected.charCodeAt(i) ^ parts.v1.charCodeAt(i);
  return diff === 0;
}
