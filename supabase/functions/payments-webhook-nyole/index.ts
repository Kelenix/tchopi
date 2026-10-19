// Webhooks nyole (PAY-03, PAY-05) : signature vérifiée, puis statut relu chez nyole avant toute écriture.
// Rejoué sans effet ; une erreur rend 500 pour que nyole réessaie (10 fois sur 72 h).
import { createClient } from '@supabase/supabase-js';
import { nyole, verifyNyoleSignature } from '../_shared/nyole.ts';
import { handleWebhook } from '../_shared/payments.ts';

const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: { persistSession: false, autoRefreshToken: false },
});

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('method_not_allowed', { status: 405 });
  const raw = await req.text();
  if (!(await verifyNyoleSignature(raw, req.headers.get('X-Afriflow-Signature')))) {
    return new Response('signature invalide', { status: 400 });
  }
  const event = JSON.parse(raw) as { event?: string; data?: { metadata?: { transaction_id?: string } } };
  return handleWebhook(admin, nyole, event.event, event.data?.metadata?.transaction_id);
});
