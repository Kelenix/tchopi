-- Comptes : profils, capacité admin, rôles du compte (Inc-1, docs/data-model.md §4 « Comptes »).

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  first_name text check (char_length(btrim(first_name)) between 1 and 60),
  last_name text check (char_length(btrim(last_name)) between 1 and 60),
  -- Téléphone de contact au format international E.164 (indispensable pour joindre le client à la livraison).
  phone text check (phone ~ '^\+[1-9][0-9]{7,14}$'),
  city text check (char_length(btrim(city)) between 2 and 60),
  is_suspended boolean not null default false,
  suspension_reason text,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_updated_at before update on public.profiles
  for each row execute function private.set_updated_at();

create table public.admins (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.admins enable row level security;

-- Les politiques RLS appellent des aides du schéma private : les utilisateurs connectés doivent pouvoir le traverser,
-- mais aucune fonction n'y est exécutable sans autorisation explicite. Le schéma n'est pas exposé par l'API.
grant usage on schema private to authenticated;
alter default privileges in schema private revoke execute on functions from public;
revoke execute on all functions in schema private from public;

-- Aide RLS : SECURITY DEFINER pour lire admins sans dépendre de ses propres politiques.
create function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
grant execute on function private.is_admin() to authenticated;

create policy "profil : lecture par son titulaire ou un admin" on public.profiles
  for select to authenticated
  using (id = auth.uid() or private.is_admin());

create policy "profil : modification par son titulaire" on public.profiles
  for update to authenticated
  using (id = auth.uid() and not is_suspended and deleted_at is null)
  with check (id = auth.uid());

-- Seuls les champs d'identité sont modifiables depuis les apps (suspension et suppression : serveur uniquement).
revoke insert, update, delete on public.profiles from anon, authenticated;
grant update (first_name, last_name, phone, city) on public.profiles to authenticated;

create policy "admin : chacun voit son propre statut" on public.admins
  for select to authenticated
  using (user_id = auth.uid() or private.is_admin());
revoke insert, update, delete on public.admins from anon, authenticated;

-- Profil créé à l'inscription ; le numéro d'inscription (stocké sans « + » par Auth) devient le téléphone de contact.
create function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, phone)
  values (new.id, case when coalesce(new.phone, '') <> '' then '+' || new.phone end);
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function private.handle_new_user();

-- Rôles du compte, pour l'aiguillage des apps. S'enrichit avec les livreurs (Inc-3) et les restaurants (Inc-4).
create function public.my_roles()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object('is_admin', private.is_admin());
$$;
revoke all on function public.my_roles() from public, anon;
grant execute on function public.my_roles() to authenticated;

-- Anonymisation à la suppression du compte (AUTH-08). Appelée uniquement par la fonction serveur account-delete.
create function public.anonymize_account(target uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles
     set first_name = null, last_name = null, phone = null, city = null, deleted_at = now()
   where id = target;
  delete from public.admins where user_id = target;
end;
$$;
revoke all on function public.anonymize_account(uuid) from public, anon, authenticated;
grant execute on function public.anonymize_account(uuid) to service_role;
