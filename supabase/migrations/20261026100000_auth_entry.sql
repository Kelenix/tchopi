-- Écran d'accès mobile (ADR-053) : bannière promotionnelle et vérification WhatsApp administrables, lisibles avant
-- la connexion (aucune autre donnée exposée).
alter table public.settings
  add column auth_banner_title text check (char_length(btrim(auth_banner_title)) between 3 and 60),
  add column auth_banner_body text check (char_length(btrim(auth_banner_body)) between 3 and 120),
  -- À n'activer qu'une fois l'envoi WhatsApp configuré chez le fournisseur SMS (Twilio).
  add column whatsapp_otp_enabled boolean not null default false;

create function public.public_auth_config()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'banner_title', auth_banner_title,
    'banner_body', auth_banner_body,
    'whatsapp', whatsapp_otp_enabled)
    from public.settings;
$$;
revoke all on function public.public_auth_config() from public;
grant execute on function public.public_auth_config() to anon, authenticated;
