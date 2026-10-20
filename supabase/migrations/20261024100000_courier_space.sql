-- Espace livreur (ADR-051) : identité ou immatriculation vérifiées automatiquement, adresse de résidence, historique
-- des livraisons filtré par le serveur, suppression du profil livreur (le compte client reste).

-- 1. Formats officiels reconnus, modifiables par les admins (référentiel, pas de code à changer). Contrôle de forme
-- seulement : l'authenticité reste vérifiée par l'admin à la validation du dossier (photo, pièce).
create table public.identity_formats (
  code text primary key,
  kind text not null check (kind in ('id', 'plate')),
  label text not null,
  pattern text not null,
  example text not null,
  is_active boolean not null default true
);
alter table public.identity_formats enable row level security;
create policy "formats : lus par tous les comptes" on public.identity_formats for select to authenticated using (true);
create policy "formats : gérés par les admins" on public.identity_formats for all to authenticated
  using (private.is_admin()) with check (private.is_admin());
revoke all on public.identity_formats from anon;

-- Numéros comparés sans espaces, tirets ni points, en majuscules.
insert into public.identity_formats (code, kind, label, pattern, example) values
  ('cni', 'id', 'Carte nationale d''identité (biométrique)', '^CI[0-9]{9,10}$', 'CI0012345678'),
  ('cni_old', 'id', 'Carte nationale d''identité (ancien modèle)', '^C[0-9]{10}$', 'C0012345678'),
  ('passport', 'id', 'Passeport ivoirien', '^[0-9]{2}[A-Z]{2}[0-9]{5}$', '20AD12345'),
  ('residence', 'id', 'Carte de résident', '^[A-Z]{1,3}[0-9]{6,10}$', 'CR12345678'),
  ('plate', 'plate', 'Immatriculation ivoirienne', '^[0-9]{1,4}[A-Z]{2}[0-9]{2}$', '1234 AB 01'),
  ('plate_temp', 'plate', 'Immatriculation provisoire (WW)', '^[0-9]{1,4}WW[0-9]{2}$', '1234 WW 01');

create function private.normalize_identity(p text)
returns text
language sql
immutable
set search_path = ''
as $$
  select nullif(upper(regexp_replace(coalesce(p, ''), '[\s.\-/]', '', 'g')), '');
$$;

-- Format reconnu pour ce type de pièce (code), ou pour une plaque.
create function private.identity_valid(p_kind text, p_code text, p_number text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.identity_formats f
                  where f.kind = p_kind and f.is_active and (p_code is null or f.code = p_code)
                    and private.normalize_identity(p_number) ~ f.pattern);
$$;

-- À pied ou à vélo (sans plaque) : pièce d'identité obligatoire ; sinon immatriculation au format ivoirien.
alter table public.couriers
  add column id_type text references public.identity_formats (code),
  add column id_number text,
  add column residence text check (char_length(btrim(residence)) between 3 and 160);
-- Les dossiers existants restent valides ; les règles s'appliquent à chaque soumission (submit_courier_profile).

drop function public.submit_courier_profile(uuid, public.vehicle_type, text, text);
-- COU-01 / COU-02 : création ou mise à jour du profil livreur. Un changement de moyen de transport, de plaque, de
-- pièce d'identité ou de zone repasse le dossier « en attente » (revalidation) ; photo et adresse non.
create function public.submit_courier_profile(
  p_zone_id uuid,
  p_vehicle_type public.vehicle_type,
  p_plate_number text,
  p_photo_path text,
  p_id_type text default null,
  p_id_number text default null,
  p_residence text default null
)
returns public.couriers
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_row public.couriers;
  result public.couriers;
  needs_plate boolean := p_vehicle_type not in ('bicycle', 'on_foot');
  plate text;
  id_number text := case when not needs_plate then private.normalize_identity(p_id_number) end;
  id_type text := case when not needs_plate then p_id_type end;
begin
  if auth.uid() is null or exists (select 1 from public.profiles where id = auth.uid() and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.zones where id = p_zone_id and is_active) then
    raise exception 'zone_unavailable' using errcode = 'P0001';
  end if;
  if needs_plate then
    if not private.identity_valid('plate', null, p_plate_number) then
      raise exception 'invalid_plate' using errcode = 'P0001';
    end if;
    -- Forme lisible enregistrée : « 1234 AB 01 ».
    plate := regexp_replace(private.normalize_identity(p_plate_number), '^([0-9]+)([A-Z]{2})([0-9]{2})$', '\1 \2 \3');
  elsif not private.identity_valid('id', id_type, id_number) or id_type is null then
    raise exception 'invalid_id_number' using errcode = 'P0001';
  end if;
  select * into current_row from public.couriers where user_id = auth.uid() for update;
  if current_row.status = 'suspended' then
    raise exception 'courier_suspended' using errcode = 'P0001';
  end if;
  if current_row.status = 'approved'
     and (current_row.vehicle_type, current_row.plate_number, current_row.zone_id, current_row.id_type,
          current_row.id_number)
         is not distinct from (p_vehicle_type, plate, p_zone_id, id_type, id_number)
  then
    -- Approuvé : seules la photo et l'adresse changent, pas de nouvelle validation.
    update public.couriers set photo_path = p_photo_path, residence = nullif(btrim(p_residence), '')
     where user_id = auth.uid() returning * into result;
    return result;
  end if;
  insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path, id_type, id_number, residence)
  values (auth.uid(), p_zone_id, p_vehicle_type, plate, p_photo_path, id_type, id_number, nullif(btrim(p_residence), ''))
  on conflict (user_id) do update
    set zone_id = excluded.zone_id, vehicle_type = excluded.vehicle_type, plate_number = excluded.plate_number,
        photo_path = excluded.photo_path, id_type = excluded.id_type, id_number = excluded.id_number,
        residence = excluded.residence, status = 'pending', status_reason = null, approved_at = null,
        is_online = false, online_since = null
  returning * into result;
  return result;
end;
$$;
revoke all on function public.submit_courier_profile(uuid, public.vehicle_type, text, text, text, text, text)
  from public, anon;
grant execute on function public.submit_courier_profile(uuid, public.vehicle_type, text, text, text, text, text)
  to authenticated;

-- 2. Livraisons du livreur connecté, filtrées et paginées par le serveur ; journée et périodes à l'heure d'Abidjan
-- (bornes envoyées par l'app). Groupes de statut : en attente (attribuée, pas encore récupérée), en cours, livrée,
-- annulée (annulée ou échouée).
create function public.courier_deliveries(
  p_from timestamptz, p_to timestamptz, p_status text default null, p_query text default null,
  p_limit integer default 20, p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if auth.uid() is null or not exists (select 1 from public.couriers where user_id = auth.uid()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  with mine as (
    select o.*,
           case when o.status = 'courier_assigned' then 'pending'
                when o.status in ('picked_up', 'in_transit') then 'in_progress'
                when o.status = 'delivered' then 'delivered'
                when o.status in ('cancelled', 'failed', 'rejected') then 'cancelled'
                else 'in_progress' end as grp
      from public.orders o
     where o.courier_id = auth.uid() and o.assigned_at >= p_from and o.assigned_at < p_to
  ), filtered as (
    select * from mine
     where (p_status is null or grp = p_status)
       and (nullif(btrim(p_query), '') is null or number ilike '%' || btrim(p_query) || '%')
  )
  select jsonb_build_object(
    'summary', jsonb_build_object(
      'total', (select count(*) from mine),
      'pending', (select count(*) from mine where grp = 'pending'),
      'in_progress', (select count(*) from mine where grp = 'in_progress'),
      'delivered', (select count(*) from mine where grp = 'delivered'),
      'cancelled', (select count(*) from mine where grp = 'cancelled'),
      'earnings', (select coalesce(sum(courier_earning), 0) from mine where grp = 'delivered'),
      'distance_m', (select coalesce(sum(distance_m), 0) from mine where grp = 'delivered')),
    'total', (select count(*) from filtered),
    'rows', coalesce((select jsonb_agg(jsonb_build_object(
               'id', id, 'number', number, 'type', type, 'status', status, 'group', grp,
               'pickup_name', pickup_name, 'pickup_district', pickup_district, 'pickup_landmark', pickup_landmark,
               'dropoff_district', dropoff_district, 'dropoff_landmark', dropoff_landmark,
               'distance_m', distance_m, 'courier_earning', courier_earning, 'payment_method', payment_method,
               'total', total, 'assigned_at', assigned_at, 'picked_up_at', picked_up_at,
               'delivered_at', delivered_at, 'closed_at', closed_at) order by assigned_at desc)
                       from (select * from filtered order by assigned_at desc
                              limit least(greatest(p_limit, 1), 100) offset greatest(p_offset, 0)) page), '[]'::jsonb)
  ) into result;
  return result;
end;
$$;
revoke all on function public.courier_deliveries(timestamptz, timestamptz, text, text, integer, integer)
  from public, anon;
grant execute on function public.courier_deliveries(timestamptz, timestamptz, text, text, integer, integer)
  to authenticated;

-- 3. Suppression du profil livreur à sa demande : refusée avec une mission en cours ou des espèces non reversées.
-- Le compte et son espace client restent ; missions et gains restent sur les commandes, les mouvements d'espèces
-- (rattachés désormais au compte, plus à la fiche livreur) sont conservés.
alter table public.cash_ledger drop constraint cash_ledger_courier_id_fkey;
alter table public.cash_ledger add constraint cash_ledger_courier_id_fkey
  foreign key (courier_id) references public.profiles (id);

create function public.delete_courier_profile()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from public.couriers where user_id = auth.uid()) then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.orders where courier_id = auth.uid()
              and status in ('courier_assigned', 'picked_up', 'in_transit')) then
    raise exception 'mission_in_progress' using errcode = 'P0001';
  end if;
  if (select coalesce(sum(case when type = 'collected' then amount else -amount end), 0)
        from public.cash_ledger where courier_id = auth.uid()) > 0 then
    raise exception 'cash_due' using errcode = 'P0001';
  end if;
  -- Offres en attente, position et affiliations disparaissent avec la fiche (cascade).
  delete from public.couriers where user_id = auth.uid();
  perform private.audit('courier_profile_deleted', 'courier', auth.uid());
end;
$$;
revoke all on function public.delete_courier_profile() from public, anon;
grant execute on function public.delete_courier_profile() to authenticated;
