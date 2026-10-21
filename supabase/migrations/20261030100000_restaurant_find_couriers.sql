-- Annuaire des livreurs pour les établissements (ADR-058) : livreurs validés par l'admin dans la zone du restaurant,
-- avec leur contact, pour les recruter ; le restaurant peut les ajouter directement à ses affiliés (livreur prévenu).
create function public.restaurant_available_couriers(p_restaurant_id uuid)
returns table (courier_id uuid, first_name text, last_name text, phone text, vehicle_type public.vehicle_type,
               zone_name text, is_online boolean, deliveries bigint, affiliation text)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not (private.is_member_of(p_restaurant_id) or private.is_admin()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  return query
  select c.user_id, p.first_name, p.last_name, p.phone, c.vehicle_type, z.name, c.is_online,
         (select count(*) from public.orders o where o.courier_id = c.user_id and o.status = 'delivered'),
         rc.status
    from public.couriers c
    join public.profiles p on p.id = c.user_id and p.deleted_at is null and not p.is_suspended
    join public.zones z on z.id = c.zone_id
    left join public.restaurant_couriers rc on rc.restaurant_id = p_restaurant_id and rc.courier_id = c.user_id
   where c.status = 'approved'
     and c.zone_id = (select zone_id from public.restaurants where id = p_restaurant_id)
     and coalesce(rc.status, '') not in ('approved', 'suspended')
   order by c.is_online desc, p.first_name;
end;
$$;
revoke all on function public.restaurant_available_couriers(uuid) from public, anon;
grant execute on function public.restaurant_available_couriers(uuid) to authenticated;

create function public.restaurant_add_courier(p_restaurant_id uuid, p_courier_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not (private.is_member_of(p_restaurant_id) or private.is_admin()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.couriers where user_id = p_courier_id and status = 'approved') then
    raise exception 'courier_not_approved' using errcode = 'P0001';
  end if;
  insert into public.restaurant_couriers (restaurant_id, courier_id, status)
  values (p_restaurant_id, p_courier_id, 'approved')
  on conflict (restaurant_id, courier_id) do update set status = 'approved';
  perform private.audit('affiliation_approved', 'restaurant', p_restaurant_id, jsonb_build_object('courier_id', p_courier_id));
  perform private.notify(p_courier_id, null, 'affiliation_approved', 'Nouveau restaurant partenaire',
    (select name from public.restaurants where id = p_restaurant_id) || ' vous a ajouté à ses livreurs : vous recevrez ses commandes prêtes.',
    '/courier');
end;
$$;
revoke all on function public.restaurant_add_courier(uuid, uuid) from public, anon;
grant execute on function public.restaurant_add_courier(uuid, uuid) to authenticated;
