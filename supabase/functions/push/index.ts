// Envoi des notifications en attente (NOT-01 à NOT-03) par Firebase Cloud Messaging (ADR-007, ADR-025).
// Appelée par la base (pg_net) avec la clé de service. Sans compte de service FCM (secret FCM_SERVICE_ACCOUNT),
// les notifications sont marquées « not_configured » : les écrans ouverts restent à jour par le temps réel.
import { createClient } from '@supabase/supabase-js';
import { json } from '../_shared/http.ts';

const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const admin = createClient(Deno.env.get('SUPABASE_URL')!, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});
const account = Deno.env.get('FCM_SERVICE_ACCOUNT');

type Pending = {
  id: number;
  user_id: string;
  order_id: string | null;
  kind: string;
  title: string;
  body: string;
  route: string;
  attempts: number;
};
type ServiceAccount = { project_id: string; client_email: string; private_key: string };

// Offres et missions : notification prioritaire et sonore (NOT-02).
const URGENT = new Set(['offer', 'mission_assigned', 'mission_cancelled', 'new_order']);

Deno.serve(async (req) => {
  if (req.headers.get('Authorization') !== `Bearer ${serviceKey}`) return json({ code: 'unauthorized' }, 401);

  const { data, error } = await admin
    .from('notifications')
    .select('id, user_id, order_id, kind, title, body, route, attempts')
    .is('sent_at', null)
    .lt('attempts', 5)
    .order('id')
    .limit(100);
  if (error) return json({ code: 'read_failed' }, 500);
  const pending = (data ?? []) as Pending[];
  if (pending.length === 0) return json({ sent: 0 });

  if (!account) {
    await close(pending.map((n) => n.id), 'not_configured');
    return json({ sent: 0, skipped: pending.length });
  }
  const sa = JSON.parse(account) as ServiceAccount;
  const accessToken = await googleAccessToken(sa);
  const { data: devices } = await admin
    .from('push_tokens')
    .select('token, user_id')
    .in('user_id', [...new Set(pending.map((n) => n.user_id))]);

  let sent = 0;
  for (const n of pending) {
    const tokens = (devices ?? []).filter((d) => d.user_id === n.user_id).map((d) => d.token as string);
    let delivered = false;
    let failure: string | null = null;
    for (const token of tokens) {
      const res = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: message(token, n) }),
      });
      const detail = res.ok ? '' : await res.text();
      if (res.ok) {
        delivered = true;
      } else if (res.status === 404 || detail.includes('UNREGISTERED')) {
        // Application désinstallée ou compte déconnecté : l'appareil est oublié.
        await admin.from('push_tokens').delete().eq('token', token);
      } else {
        failure = `fcm_${res.status}`;
      }
    }
    if (failure && !delivered) {
      await admin.from('notifications').update({ attempts: n.attempts + 1, error: failure }).eq('id', n.id);
    } else {
      await close([n.id], delivered ? null : 'no_device');
      if (delivered) sent++;
    }
  }
  return json({ sent });
});

async function close(ids: number[], error: string | null) {
  await admin.from('notifications').update({ sent_at: new Date().toISOString(), error }).in('id', ids);
}

function message(token: string, n: Pending) {
  const urgent = URGENT.has(n.kind);
  return {
    token,
    notification: { title: n.title, body: n.body },
    data: { route: n.route, kind: n.kind, order_id: n.order_id ?? '' },
    android: { priority: urgent ? 'HIGH' : 'NORMAL', notification: { sound: 'default' } },
    apns: { payload: { aps: { sound: 'default' } } },
  };
}

// Jeton d'accès Google (OAuth 2, assertion JWT signée RS256 avec la clé du compte de service).
async function googleAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const encode = (value: unknown) => base64url(new TextEncoder().encode(JSON.stringify(value)));
  const unsigned = `${encode({ alg: 'RS256', typ: 'JWT' })}.${encode({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  })}`;
  const der = Uint8Array.from(atob(sa.private_key.replace(/-----[^-]+-----|\s/g, '')), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(unsigned)),
  );
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${unsigned}.${base64url(signature)}`,
    }),
  });
  if (!res.ok) throw new Error(`oauth_${res.status}`);
  return (await res.json()).access_token as string;
}

function base64url(bytes: Uint8Array): string {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
