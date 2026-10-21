-- Annuaire des livreurs (ADR-058, révisé) : tous les livreurs validés, toutes villes ; la ville est affichée et le
-- restaurant choisit. Ceux de sa ville d'abord.
create or replace function public.restaurant_available_couriers(p_restaurant_id uuid)
returns table (courier_id uuid, first_name text, last_name text, phone text, vehicle_type public.vehicle_type,
               zone_name text, is_online boolean, deliveries bigint, affiliation text)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  home uuid := (select zone_id from public.restaurants where id = p_restaurant_id);
begin
  if not (private.is_member_of(p_restaurant_id) or private.is_admin()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  return query
  select c.user_id, p.first_name, p.last_name, p.phone, c.vehicle_type, z.city, c.is_online,
         (select count(*) from public.orders o where o.courier_id = c.user_id and o.status = 'delivered'),
         rc.status
    from public.couriers c
    join public.profiles p on p.id = c.user_id and p.deleted_at is null and not p.is_suspended
    join public.zones z on z.id = c.zone_id
    left join public.restaurant_couriers rc on rc.restaurant_id = p_restaurant_id and rc.courier_id = c.user_id
   where c.status = 'approved'
     and coalesce(rc.status, '') not in ('approved', 'suspended')
   order by c.zone_id = home desc, c.is_online desc, p.first_name;
end;
$$;
