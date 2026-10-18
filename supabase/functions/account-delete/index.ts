// Suppression du compte de l'appelant (AUTH-08) : anonymisation du profil puis suppression « douce »
// du compte d'authentification (identifiants effacés, historique des commandes conservé sans donnée identifiante).
import { createClient } from '@supabase/supabase-js';
import { corsHeaders, json } from '../_shared/http.ts';

const admin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  { auth: { persistSession: false, autoRefreshToken: false } },
);

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ code: 'method_not_allowed' }, 405);

  const token = req.headers.get('Authorization')?.replace(/^Bearer\s+/i, '') ?? '';
  const { data: { user }, error: authError } = await admin.auth.getUser(token);
  if (authError || !user) return json({ code: 'unauthorized' }, 401);

  const { error: anonymizeError } = await admin.rpc('anonymize_account', { target: user.id });
  if (anonymizeError) {
    // Les refus métier (ex. commande en cours, à partir de l'Inc-5) remontent avec leur code stable.
    const code = anonymizeError.code === 'P0001' ? anonymizeError.message : 'account_delete_failed';
    console.error('anonymize_account', anonymizeError.code);
    return json({ code }, code === 'account_delete_failed' ? 500 : 409);
  }

  const { error: deleteError } = await admin.auth.admin.deleteUser(user.id, true);
  if (deleteError) {
    console.error('deleteUser', deleteError.status);
    return json({ code: 'account_delete_failed' }, 500);
  }
  return json({ ok: true });
});
