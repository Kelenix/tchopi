// Signature des webhooks (nyole, Stripe) : en-tête « t=<horodatage>,v1=<HMAC-SHA256 hex> » calculé sur
// « <horodatage>.<corps brut> » ; 5 minutes de tolérance. Plusieurs v1 possibles (rotation du secret chez Stripe).
const encoder = new TextEncoder();

const hex = (bytes: ArrayBuffer) => [...new Uint8Array(bytes)].map((b) => b.toString(16).padStart(2, '0')).join('');

function sameText(a: string, b: string) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

export async function verifySignature(
  rawBody: string,
  header: string | null,
  secret: string,
  now = Date.now(),
): Promise<boolean> {
  const parts = (header ?? '').split(',').map((part) => part.trim().split('=', 2));
  const timestamp = parts.find(([name]) => name === 't')?.[1];
  const signatures = parts.filter(([name]) => name === 'v1').map(([, value]) => value ?? '');
  if (!secret || !timestamp || signatures.length === 0) return false;
  if (!Number.isFinite(Number(timestamp)) || Math.abs(now / 1000 - Number(timestamp)) > 300) return false;
  const key = await crypto.subtle.importKey('raw', encoder.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, [
    'sign',
  ]);
  const expected = hex(await crypto.subtle.sign('HMAC', key, encoder.encode(`${timestamp}.${rawBody}`)));
  return signatures.some((signature) => sameText(expected, signature));
}
