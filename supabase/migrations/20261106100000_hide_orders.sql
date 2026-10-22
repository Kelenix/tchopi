-- Historique désencombré (ADR-065) : le client et le livreur masquent leurs commandes terminées, une par une ou
-- toutes à la fois. Rien n'est supprimé : reçus, paiements, gains et support gardent chaque commande.
alter table public.orders
  add column customer_hidden_at timestamptz,
  add column courier_hidden_at timestamptz;

-- p_order_ids : commandes à masquer ; null = tout l'historique terminé du compte. Retourne le nombre masqué.
create function public.hide_orders(p_order_ids uuid[] default null)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  as_customer integer;
  as_courier integer;
begin
  if auth.uid() is null then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  update public.orders o set customer_hidden_at = now()
   where o.customer_id = auth.uid() and o.customer_hidden_at is null
     and o.status in ('delivered', 'rejected', 'cancelled', 'failed')
     and (p_order_ids is null or o.id = any (p_order_ids));
  get diagnostics as_customer = row_count;
  update public.orders o set courier_hidden_at = now()
   where o.courier_id = auth.uid() and o.courier_hidden_at is null
     and o.status in ('delivered', 'rejected', 'cancelled', 'failed')
     and (p_order_ids is null or o.id = any (p_order_ids));
  get diagnostics as_courier = row_count;
  return as_customer + as_courier;
end;
$$;
revoke all on function public.hide_orders(uuid[]) from public, anon;
grant execute on function public.hide_orders(uuid[]) to authenticated;

-- Historique du livreur : les missions masquées sortent de la liste ; le résumé de la période (gains, distance) reste
-- complet.
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
     where courier_hidden_at is null
       and (p_status is null or grp = p_status)
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
