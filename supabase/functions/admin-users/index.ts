// Actions admin sur les comptes (ADM-02) : suspension avec blocage de la connexion, réactivation,
// changement d'identifiant de connexion, suppression (profil anonymisé, historique conservé). Chaque action est
// vérifiée (admin) et tracée.
import { createClient } from '@supabase/supabase-js';
import { corsHeaders, json } from '../_shared/http.ts';

const url = Deno.env.get('SUPABASE_URL')!;
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
const admin = createClient(url, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const FOREVER = '876000h'; // ~100 ans : la suspension dure jusqu'à réactivation
const EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/;
const PHONE = /^\+[1-9][0-9]{7,14}$/;

type Body = { action?: string; user_id?: string; reason?: string; email?: string; phone?: string };

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ code: 'method_not_allowed' }, 405);

  const authorization = req.headers.get('Authorization') ?? '';
  const token = authorization.replace(/^Bearer\s+/i, '');
  const { data: { user }, error: authError } = await admin.auth.getUser(token);
  if (authError || !user) return json({ code: 'unauthorized' }, 401);
  const { data: isAdmin } = await admin.from('admins').select('user_id').eq('user_id', user.id).maybeSingle();
  if (!isAdmin) return json({ code: 'forbidden' }, 403);

  const body = (await req.json().catch(() => ({}))) as Body;
  if (!body.user_id) return json({ code: 'invalid_request' }, 400);
  // Les règles SQL sont appelées au nom de l'admin pour que le journal d'audit nomme son auteur.
  const asCaller = createClient(url, anonKey, { global: { headers: { Authorization: authorization } } });

  switch (body.action) {
    case 'suspend':
    case 'reactivate': {
      const suspended = body.action === 'suspend';
      const { error } = await asCaller.rpc('admin_set_user_suspended', {
        p_user_id: body.user_id,
        p_suspended: suspended,
        p_reason: body.reason ?? null,
      });
      if (error) return json({ code: error.code === 'P0001' ? error.message : 'admin_action_failed' }, 409);
      const { error: banError } = await admin.auth.admin.updateUserById(body.user_id, {
        ban_duration: suspended ? FOREVER : 'none',
      });
      if (banError) return json({ code: 'admin_action_failed' }, 500);
      return json({ ok: true });
    }
    case 'update_login': {
      const email = body.email?.trim().toLowerCase();
      const phone = body.phone?.trim();
      if (email ? !EMAIL.test(email) : !(phone && PHONE.test(phone))) return json({ code: 'invalid_identifier' }, 400);
      const { error } = await admin.auth.admin.updateUserById(
        body.user_id,
        email ? { email, email_confirm: true } : { phone, phone_confirm: true },
      );
      if (error) return json({ code: error.code === 'email_exists' || error.code === 'phone_exists' ? 'user_already_exists' : 'admin_action_failed' }, 409);
      await admin.from('audit_log').insert({
        actor_id: user.id,
        action: 'login_changed',
        target_type: 'user',
        target_id: body.user_id,
        details: email ? { channel: 'email' } : { channel: 'phone' },
      });
      return json({ ok: true });
    }
    case 'delete': {
      // Règles (pas soi-même ni un admin, aucune commande en cours) et anonymisation dans la base, puis suppression
      // « douce » du compte de connexion, comme la suppression demandée par l'utilisateur (account-delete).
      const { error } = await asCaller.rpc('admin_delete_account', { p_user_id: body.user_id });
      if (error) return json({ code: error.code === 'P0001' ? error.message : 'admin_action_failed' }, 409);
      const { error: deleteError } = await admin.auth.admin.deleteUser(body.user_id, true);
      if (deleteError) return json({ code: 'admin_action_failed' }, 500);
      return json({ ok: true });
    }
    default:
      return json({ code: 'invalid_request' }, 400);
  }
});
