-- Offres refusées (ADR-060) : le livreur retrouve ses refus des 7 derniers jours et peut revenir dessus tant que la
-- commande attend encore un livreur ; les refus comptent dans ses statistiques.

create function public.courier_declined_offers()
returns table (id uuid, order_id uuid, summary jsonb, responded_at timestamptz, reopenable boolean)
language sql
stable
security definer
set search_path = ''
as $$
  select f.id, f.order_id, f.summary, f.responded_at,
         o.courier_id is null and o.status in ('ready', 'searching_courier')
           and not exists (select 1 from public.delivery_offers g
                            where g.order_id = f.order_id and g.courier_id = f.courier_id and g.status = 'pending')
    from public.delivery_offers f
    join public.orders o on o.id = f.order_id
   where f.courier_id = auth.uid() and f.status = 'declined' and f.responded_at > now() - interval '7 days'
   order by f.responded_at desc;
$$;
revoke all on function public.courier_declined_offers() from public, anon;
grant execute on function public.courier_declined_offers() to authenticated;

-- Revenir sur un refus : l'offre redevient « en attente » et s'accepte comme les autres (respond_to_offer).
create function public.courier_reconsider_offer(p_offer_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  f public.delivery_offers;
  o public.orders;
begin
  select * into f from public.delivery_offers where id = p_offer_id and courier_id = auth.uid() for update;
  if f.id is null or f.status <> 'declined' then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  select * into o from public.orders where id = f.order_id for update;
  if o.courier_id is not null or o.status not in ('ready', 'searching_courier') then
    raise exception 'offer_unavailable' using errcode = 'P0001';
  end if;
  update public.delivery_offers set status = 'pending', responded_at = null, expires_at = null where id = f.id;
end;
$$;
revoke all on function public.courier_reconsider_offer(uuid) from public, anon;
grant execute on function public.courier_reconsider_offer(uuid) to authenticated;

-- Statistiques : nombre de refus sur la période.
create or replace function public.courier_deliveries(
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
      'distance_m', (select coalesce(sum(distance_m), 0) from mine where grp = 'delivered'),
      'declined', (select count(*) from public.delivery_offers f
                    where f.courier_id = auth.uid() and f.status = 'declined'
                      and f.responded_at >= p_from and f.responded_at < p_to)),
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
