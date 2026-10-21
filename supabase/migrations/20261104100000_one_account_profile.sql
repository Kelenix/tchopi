-- Un seul compte, un seul profil pour le web et le mobile (ADR-062).
-- Cause corrigée : le mobile exige un profil complet (prénom, nom, téléphone, ville) alors que le web ne le
-- demandait jamais ; un compte créé sur le web repassait donc par l'inscription sur le mobile. Inversement, un
-- compte créé sur le mobile n'était jamais marqué « orienté » et le web lui reproposait l'onboarding.
-- Règle commune, tenue par le serveur : profil complet = les quatre champs renseignés. Aucune donnée supprimée.

create function private.profile_complete(p public.profiles)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select coalesce(trim(p.first_name), '') <> '' and coalesce(trim(p.last_name), '') <> ''
    and coalesce(trim(p.phone), '') <> '' and coalesce(trim(p.city), '') <> '';
$$;

-- À l'inscription : prénom et nom fournis par Google (ou autre fournisseur), numéro de connexion comme téléphone.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  full_name text := nullif(trim(coalesce(meta->>'full_name', meta->>'name', '')), '');
begin
  insert into public.profiles (id, phone, first_name, last_name)
  values (
    new.id,
    case when coalesce(new.phone, '') <> '' then '+' || new.phone end,
    left(coalesce(nullif(trim(meta->>'given_name'), ''), split_part(full_name, ' ', 1)), 60),
    left(coalesce(nullif(trim(meta->>'family_name'), ''), nullif(trim(substr(full_name, length(split_part(full_name, ' ', 1)) + 1)), '')), 60)
  );
  return new;
end;
$$;

-- Comptes existants : seuls les champs vides sont complétés, à partir de ce que le compte a déjà fourni.
update public.profiles p
set first_name = coalesce(nullif(trim(p.first_name), ''), left(nullif(coalesce(
      nullif(trim(u.raw_user_meta_data->>'given_name'), ''),
      split_part(trim(coalesce(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', '')), ' ', 1)), ''), 60)),
    last_name = coalesce(nullif(trim(p.last_name), ''), left(coalesce(
      nullif(trim(u.raw_user_meta_data->>'family_name'), ''),
      nullif(trim(substr(trim(coalesce(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', '')),
        length(split_part(trim(coalesce(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', '')), ' ', 1)) + 1)), '')), 60)),
    phone = coalesce(nullif(trim(p.phone), ''), case when coalesce(u.phone, '') <> '' then '+' || u.phone end)
from auth.users u
where u.id = p.id and p.deleted_at is null;

-- Ville : celle de l'établissement géré, à défaut.
update public.profiles p
set city = z.city
from public.restaurant_members m
join public.restaurants r on r.id = m.restaurant_id
join public.zones z on z.id = r.zone_id
where m.user_id = p.id and coalesce(trim(p.city), '') = '' and p.deleted_at is null;

-- Comptes créés sur le mobile avec un profil complet : leur parcours est choisi (espace client par défaut).
update public.profiles p set onboarded_at = now()
where p.onboarded_at is null and private.profile_complete(p);

-- Rôles du compte, plus l'état du profil (même règle pour le web et le mobile).
create or replace function public.my_roles()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'is_admin', private.is_admin(),
    'courier_status', (select status from public.couriers where user_id = auth.uid()),
    'restaurant_ids', coalesce(
      (select jsonb_agg(restaurant_id order by created_at) from public.restaurant_members where user_id = auth.uid()),
      '[]'::jsonb
    ),
    'onboarded', (select onboarded_at is not null from public.profiles where id = auth.uid()),
    'profile_complete', (select private.profile_complete(p) from public.profiles p where p.id = auth.uid())
  );
$$;
