-- Livreurs, validation par l'admin, suspension des comptes, journal d'audit (Inc-3, docs/data-model.md §4).

create type public.vehicle_type as enum ('motorbike', 'bicycle', 'car', 'on_foot');
create type public.courier_status as enum ('pending', 'approved', 'rejected', 'suspended');

create table public.couriers (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  zone_id uuid not null references public.zones (id),
  vehicle_type public.vehicle_type not null,
  plate_number text check (char_length(btrim(plate_number)) between 3 and 20),
  -- Chemin de la photo dans le bucket privé « couriers » : <user_id>/…
  photo_path text not null,
  status public.courier_status not null default 'pending',
  status_reason text,
  approved_at timestamptz,
  is_online boolean not null default false,
  online_since timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (vehicle_type in ('bicycle', 'on_foot') or plate_number is not null),
  check (status in ('rejected', 'suspended') = (status_reason is not null)),
  check (photo_path like user_id::text || '/%')
);
create index couriers_status_idx on public.couriers (status);
create trigger couriers_updated_at before update on public.couriers
  for each row execute function private.set_updated_at();

create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles (id) on delete set null, -- l'historique survit à la suppression du compte
  action text not null,
  target_type text not null,
  target_id uuid,
  details jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index audit_log_target_idx on public.audit_log (target_type, target_id);

alter table public.couriers enable row level security;
alter table public.audit_log enable row level security;

create policy "livreur : lu par lui-même ou un admin" on public.couriers
  for select to authenticated using (user_id = auth.uid() or private.is_admin());
revoke insert, update, delete on public.couriers from anon, authenticated;

create policy "audit : lu par les admins" on public.audit_log
  for select to authenticated using (private.is_admin());
revoke insert, update, delete on public.audit_log from anon, authenticated;

create function private.audit(p_action text, p_target_type text, p_target_id uuid, p_details jsonb default '{}')
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.audit_log (actor_id, action, target_type, target_id, details)
  values (auth.uid(), p_action, p_target_type, p_target_id, p_details);
$$;

-- COU-01 / COU-02 : création ou mise à jour du profil livreur, qui repasse « en attente ».
-- Un livreur approuvé qui change de moyen de transport ou d'immatriculation est revalidé (L-10).
create function public.submit_courier_profile(
  p_zone_id uuid,
  p_vehicle_type public.vehicle_type,
  p_plate_number text,
  p_photo_path text
)
returns public.couriers
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_row public.couriers;
  result public.couriers;
  plate text := nullif(btrim(p_plate_number), '');
begin
  if auth.uid() is null or exists (select 1 from public.profiles where id = auth.uid() and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.zones where id = p_zone_id and is_active) then
    raise exception 'zone_unavailable' using errcode = 'P0001';
  end if;
  select * into current_row from public.couriers where user_id = auth.uid() for update;
  if current_row.status = 'suspended' then
    raise exception 'courier_suspended' using errcode = 'P0001';
  end if;
  if current_row.status = 'approved'
     and (current_row.vehicle_type, current_row.plate_number, current_row.zone_id)
         is not distinct from (p_vehicle_type, plate, p_zone_id)
  then
    -- Approuvé : seule la photo change, pas de nouvelle validation.
    update public.couriers set photo_path = p_photo_path where user_id = auth.uid() returning * into result;
    return result;
  end if;
  insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path)
  values (auth.uid(), p_zone_id, p_vehicle_type, plate, p_photo_path)
  on conflict (user_id) do update
    set zone_id = excluded.zone_id, vehicle_type = excluded.vehicle_type, plate_number = excluded.plate_number,
        photo_path = excluded.photo_path, status = 'pending', status_reason = null, approved_at = null,
        is_online = false, online_since = null
  returning * into result;
  return result;
end;
$$;
revoke all on function public.submit_courier_profile(uuid, public.vehicle_type, text, text) from public, anon;
grant execute on function public.submit_courier_profile(uuid, public.vehicle_type, text, text) to authenticated;

-- COU-04 : décision de l'admin ; refus et suspension exigent un motif, transmis au livreur.
create function public.admin_set_courier_status(p_user_id uuid, p_status public.courier_status, p_reason text default null)
returns public.couriers
language plpgsql
security definer
set search_path = ''
as $$
declare
  reason text := nullif(btrim(p_reason), '');
  result public.couriers;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if p_status in ('rejected', 'suspended') and reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  update public.couriers
     set status = p_status,
         status_reason = case when p_status in ('rejected', 'suspended') then reason end,
         approved_at = case when p_status = 'approved' then now() end,
         is_online = is_online and p_status = 'approved',
         online_since = case when p_status = 'approved' then online_since end
   where user_id = p_user_id
  returning * into result;
  if result.user_id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  perform private.audit('courier_status', 'courier', p_user_id, jsonb_build_object('status', p_status, 'reason', reason));
  return result;
end;
$$;
revoke all on function public.admin_set_courier_status(uuid, public.courier_status, text) from public, anon;
grant execute on function public.admin_set_courier_status(uuid, public.courier_status, text) to authenticated;

-- ADM-02 : suspension d'un compte (le blocage de connexion est appliqué par la fonction serveur admin-users).
create function public.admin_set_user_suspended(p_user_id uuid, p_suspended boolean, p_reason text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  reason text := nullif(btrim(p_reason), '');
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'cannot_target_self' using errcode = 'P0001';
  end if;
  if p_suspended and reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  update public.profiles
     set is_suspended = p_suspended, suspension_reason = case when p_suspended then reason end
   where id = p_user_id;
  if not found then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  update public.couriers set is_online = false, online_since = null where user_id = p_user_id and p_suspended;
  perform private.audit(case when p_suspended then 'user_suspended' else 'user_reactivated' end,
                        'user', p_user_id, jsonb_build_object('reason', reason));
end;
$$;
revoke all on function public.admin_set_user_suspended(uuid, boolean, text) from public, anon;
grant execute on function public.admin_set_user_suspended(uuid, boolean, text) to authenticated;

-- Rôles du compte : ajout du statut livreur (aiguillage de l'app Livreur, AUTH-09).
create or replace function public.my_roles()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'is_admin', private.is_admin(),
    'courier_status', (select status from public.couriers where user_id = auth.uid())
  );
$$;

-- Photos des livreurs : bucket privé, chacun écrit dans son dossier ; lues par leur titulaire et les admins.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('couriers', 'couriers', false, 2097152, array['image/jpeg', 'image/png', 'image/webp']);

create policy "photos livreurs : dépôt dans son dossier" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'couriers' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos livreurs : remplacement dans son dossier" on storage.objects
  for update to authenticated
  using (bucket_id = 'couriers' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos livreurs : lecture par le titulaire ou un admin" on storage.objects
  for select to authenticated
  using (bucket_id = 'couriers' and ((storage.foldername(name))[1] = auth.uid()::text or private.is_admin()));
