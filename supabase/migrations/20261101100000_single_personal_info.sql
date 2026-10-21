-- Informations personnelles uniques (ADR-059) : le livreur n'a plus d'adresse de résidence à part ; sa ville est celle de
-- son compte (profils), modifiée dans « Mon compte ». Le dossier livreur ne garde que le professionnel.
update public.profiles p set city = c.residence
  from public.couriers c
 where c.user_id = p.id and c.residence is not null and coalesce(btrim(p.city), '') = '';

create or replace function public.submit_courier_profile(
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
  -- Ville de résidence : une seule information personnelle, celle du compte (anciennes versions de l'app).
  if nullif(btrim(p_residence), '') is not null then
    update public.profiles set city = btrim(p_residence) where id = auth.uid();
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
    -- Approuvé : seule la photo change, pas de nouvelle validation.
    update public.couriers set photo_path = p_photo_path where user_id = auth.uid() returning * into result;
    return result;
  end if;
  insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path, id_type, id_number)
  values (auth.uid(), p_zone_id, p_vehicle_type, plate, p_photo_path, id_type, id_number)
  on conflict (user_id) do update
    set zone_id = excluded.zone_id, vehicle_type = excluded.vehicle_type, plate_number = excluded.plate_number,
        photo_path = excluded.photo_path, id_type = excluded.id_type, id_number = excluded.id_number,
        status = 'pending', status_reason = null, approved_at = null,
        is_online = false, online_since = null
  returning * into result;
  return result;
end;
$$;

alter table public.couriers drop column residence;
