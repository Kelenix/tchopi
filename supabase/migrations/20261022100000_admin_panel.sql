-- Panneau d'administration (ADR-046 à 048) : frais de livraison sur la distance routière réelle, indicateurs et
-- statistiques de paiement calculés sur les données réelles, actions d'administration manquantes.

-- 1. Frais de livraison = base + distance routière (km) × prix au km (ADR-046).
-- Distance donnée par le serveur de trajets (OSRM, ADR-038) ; repli sur vol d'oiseau × détour s'il ne répond pas.
create extension if not exists http with schema extensions;

-- Réglages internes, jamais exposés à l'API (adresse du serveur de trajets, posée par server.sh deploy).
create table private.config (
  key text primary key,
  value text not null
);
revoke all on private.config from public, anon, authenticated;

create function private.road_distance_m(p_from extensions.geography, p_to extensions.geography)
returns integer
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  base text := (select value from private.config where key = 'routing_url');
  res extensions.http_response;
begin
  if base is null then
    return null;
  end if;
  perform extensions.http_set_curlopt('CURLOPT_TIMEOUT_MS', '2500');
  res := extensions.http_get(format('%s/route/v1/driving/%s,%s;%s,%s?overview=false', base,
    round(extensions.st_x(p_from::extensions.geometry)::numeric, 6), round(extensions.st_y(p_from::extensions.geometry)::numeric, 6),
    round(extensions.st_x(p_to::extensions.geometry)::numeric, 6), round(extensions.st_y(p_to::extensions.geometry)::numeric, 6)));
  if res.status <> 200 then
    return null;
  end if;
  return round((res.content::jsonb #>> '{routes,0,distance}')::numeric)::integer;
exception when others then
  return null;
end;
$$;
revoke all on function private.road_distance_m(extensions.geography, extensions.geography) from public, anon, authenticated;

create function private.price_delivery(p_zone_id uuid, p_service public.order_type,
                                       p_from extensions.geography, p_to extensions.geography)
returns table (distance_m integer, delivery_fee integer, courier_earning integer, road boolean)
language sql
volatile
security definer
set search_path = ''
as $$
  select d.distance_m,
         least(r.max_fee, greatest(r.min_fee,
           (ceil((r.base_fee + r.per_km_fee * d.distance_m / 1000.0) / r.rounding_step) * r.rounding_step)::integer)),
         (ceil((r.courier_base + r.courier_per_km * d.distance_m / 1000.0) / r.rounding_step) * r.rounding_step)::integer,
         d.road
    from public.pricing_rules r
   cross join lateral (select private.road_distance_m(p_from, p_to) as m) rd
   cross join lateral (select coalesce(rd.m, round(extensions.st_distance(p_from, p_to) * r.detour_factor)::integer)
                                as distance_m,
                              rd.m is not null as road) d
   where r.zone_id = p_zone_id and r.service = p_service;
$$;
revoke all on function private.price_delivery(uuid, public.order_type, extensions.geography, extensions.geography)
  from public, anon, authenticated;

-- Grille demandée : 500 F + 100 F par km routier, arrondi à 5 F (plus petite pièce), sans plafond pratique.
alter table public.pricing_rules
  alter column base_fee set default 500,
  alter column per_km_fee set default 100,
  alter column min_fee set default 500,
  alter column max_fee set default 50000,
  alter column rounding_step set default 5;
update public.pricing_rules
   set base_fee = 500, per_km_fee = 100, min_fee = 500, max_fee = 50000, rounding_step = 5
 where service = 'food';

-- Devis repas : même règle qu'avant (20261020120000_web_platform), frais sur la distance routière ; la source de la
-- distance (« road » ou « estimate ») est renvoyée pour l'affichage du récapitulatif.
create or replace function private.food_quote(p_restaurant_id uuid, p_address_id uuid, p_items jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  r public.restaurants;
  a public.addresses;
  fee record;
  lines jsonb;
  issues jsonb := '[]'::jsonb;
  subtotal integer;
begin
  if auth.uid() is null or exists (select 1 from public.profiles where id = auth.uid() and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  select * into a from public.addresses where id = p_address_id and user_id = auth.uid();
  select * into r from public.restaurants where id = p_restaurant_id and is_active;
  if a.id is null or r.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if jsonb_typeof(p_items) is distinct from 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'cart_empty' using errcode = 'P0001';
  end if;
  if a.zone_id <> r.zone_id then
    raise exception 'address_out_of_zone' using errcode = 'P0001';
  end if;
  if exists (select 1 from jsonb_to_recordset(p_items) as i (product_id uuid, quantity integer)
              where i.quantity is null or i.quantity not between 1 and 50) then
    raise exception 'invalid_quantity' using errcode = 'P0001';
  end if;

  with items as (
    select n, i.product_id, i.quantity, coalesce(i.options, '[]'::jsonb) as option_ids
      from jsonb_array_elements(p_items) with ordinality e (item, n)
     cross join lateral jsonb_to_record(e.item) as i (product_id uuid, quantity integer, options jsonb)
  ),
  chosen as (
    select it.n, o.id, o.name, o.price_delta, o.is_available, g.id as group_id, g.name as group_name
      from items it
     cross join lateral jsonb_array_elements_text(it.option_ids) c (option_id)
      left join public.product_options o on o.id = c.option_id::uuid
      left join public.product_option_groups g on g.id = o.group_id and g.product_id = it.product_id
  ),
  priced as (
    select it.n, it.product_id, it.quantity, p.id as found_id, p.name, p.is_available,
           p.price + coalesce((select sum(c.price_delta) from chosen c where c.n = it.n and c.group_id is not null), 0)
             as unit_price,
           coalesce((select jsonb_agg(jsonb_build_object('group', c.group_name, 'name', c.name,
                                                         'price_delta', c.price_delta) order by c.group_name, c.name)
                       from chosen c where c.n = it.n and c.group_id is not null), '[]'::jsonb) as options,
           exists (select 1 from chosen c where c.n = it.n and (c.group_id is null or not c.is_available))
             as option_unavailable,
           exists (select 1 from public.product_option_groups g where g.product_id = it.product_id
                     and (select count(*) from chosen c where c.n = it.n and c.group_id = g.id)
                         not between g.min_choices and g.max_choices) as options_required
      from items it
      left join public.products p
        on p.id = it.product_id and p.restaurant_id = r.id and p.archived_at is null
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'product_id', product_id, 'name', name, 'unit_price', unit_price, 'quantity', quantity,
           'line_total', coalesce(unit_price, 0) * quantity, 'options', options,
           'available', found_id is not null and is_available,
           'option_issue', case when option_unavailable then 'option_unavailable'
                                when options_required then 'options_required' end) order by n), '[]'::jsonb),
         coalesce(sum(unit_price * quantity) filter (where is_available), 0)
    into lines, subtotal
    from priced;

  if not public.is_open(r) then
    issues := issues || jsonb_build_object('issue', 'restaurant_closed');
  end if;
  issues := issues || coalesce((
    select jsonb_agg(jsonb_build_object(
             'issue', case when not (l->>'available')::boolean then 'product_unavailable' else l->>'option_issue' end,
             'product_id', l->>'product_id', 'name', l->>'name'))
      from jsonb_array_elements(lines) l
     where not (l->>'available')::boolean or l->>'option_issue' is not null), '[]'::jsonb);

  select * into fee from private.price_delivery(r.zone_id, 'food', r.location, a.location);
  if fee is null then
    raise exception 'zone_unavailable' using errcode = 'P0001';
  end if;

  return jsonb_build_object(
    'currency', (select currency from public.zones where id = r.zone_id),
    'items', (select coalesce(jsonb_agg(l - 'option_issue'), '[]'::jsonb) from jsonb_array_elements(lines) l),
    'subtotal', subtotal,
    'delivery_fee', fee.delivery_fee,
    'total', subtotal + fee.delivery_fee,
    'distance_m', fee.distance_m,
    'distance_source', case when fee.road then 'road' else 'estimate' end,
    'courier_earning', fee.courier_earning,
    'issues', issues
  );
end;
$$;

-- 2. Tableau de bord (ADR-047) : indicateurs d'une période, série temporelle (heure, jour, semaine ou mois, heure
-- d'Abidjan), répartitions par moyen de paiement et par ville. Uniquement des données réelles.
create function private.check_period(p_from timestamptz, p_to timestamptz, p_bucket text)
returns void
language plpgsql
immutable
set search_path = ''
as $$
begin
  if p_bucket not in ('hour', 'day', 'week', 'month') or p_from >= p_to then
    raise exception 'invalid_period' using errcode = 'P0001';
  end if;
  if (extract(epoch from p_to - p_from) / extract(epoch from ('1 ' || p_bucket)::interval)) > 400 then
    raise exception 'period_too_long' using errcode = 'P0001';
  end if;
end;
$$;

create function public.admin_dashboard(p_from timestamptz, p_to timestamptz, p_bucket text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  perform private.check_period(p_from, p_to, p_bucket);
  with period as (
    select o.*, date_trunc(p_bucket, o.created_at at time zone 'Africa/Abidjan') as b
      from public.orders o where o.created_at >= p_from and o.created_at < p_to
  ), buckets as (
    select g as b
      from generate_series(date_trunc(p_bucket, p_from at time zone 'Africa/Abidjan'),
                           (p_to at time zone 'Africa/Abidjan') - interval '1 second',
                           ('1 ' || p_bucket)::interval) g
  )
  select jsonb_build_object(
    'users', jsonb_build_object(
      'total', (select count(*) from public.profiles where deleted_at is null),
      'new', (select count(*) from public.profiles where deleted_at is null and created_at >= p_from and created_at < p_to),
      'suspended', (select count(*) from public.profiles where deleted_at is null and is_suspended)),
    'restaurants', jsonb_build_object(
      'total', (select count(*) from public.restaurants),
      'active', (select count(*) from public.restaurants where is_active and review_status = 'approved'),
      'pending', (select count(*) from public.restaurants where review_status = 'pending')),
    'couriers', jsonb_build_object(
      'total', (select count(*) from public.couriers),
      'approved', (select count(*) from public.couriers where status = 'approved'),
      'pending', (select count(*) from public.couriers where status = 'pending'),
      'online', (select count(*) from public.couriers c
                   join public.courier_locations l on l.courier_id = c.user_id
                  where c.is_online and c.status = 'approved'
                    and l.recorded_at > now() - make_interval(secs => (select location_fresh_s from public.settings)))),
    'orders', jsonb_build_object(
      'total', (select count(*) from period),
      'in_progress', (select count(*) from period
                       where status not in ('awaiting_payment', 'delivered', 'rejected', 'cancelled', 'failed')),
      'delivered', (select count(*) from period where status = 'delivered'),
      'cancelled', (select count(*) from period where status in ('rejected', 'cancelled', 'failed')),
      'by_status', coalesce((select jsonb_object_agg(status, n)
                               from (select status, count(*) n from period group by status) s), '{}'::jsonb)),
    'money', (select jsonb_build_object(
                'revenue', coalesce(sum(total), 0),
                'subtotal', coalesce(sum(subtotal), 0),
                'delivery_fees', coalesce(sum(delivery_fee), 0),
                'commissions', coalesce(sum(commission_amount), 0),
                'courier_earnings', coalesce(sum(courier_earning), 0),
                'platform', coalesce(sum(platform_amount), 0),
                'average_basket', coalesce(round(avg(total)), 0),
                'average_distance_m', coalesce(round(avg(distance_m)), 0))
                from period where status = 'delivered'),
    'by_method', coalesce((select jsonb_agg(jsonb_build_object('method', payment_method, 'orders', n, 'amount', amount)
                                            order by amount desc)
                             from (select payment_method, count(*) n, sum(total) amount
                                     from period where status = 'delivered' group by payment_method) m), '[]'::jsonb),
    'by_zone', coalesce((select jsonb_agg(jsonb_build_object('zone_id', z.id, 'city', z.city, 'name', z.name,
                                                            'orders', s.n, 'delivered', s.delivered, 'revenue', s.revenue)
                                          order by s.n desc)
                           from (select zone_id, count(*) n, count(*) filter (where status = 'delivered') delivered,
                                        coalesce(sum(total) filter (where status = 'delivered'), 0) revenue
                                   from period group by zone_id) s
                           join public.zones z on z.id = s.zone_id), '[]'::jsonb),
    'top_restaurants', coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'name', r.name, 'orders', s.n,
                                                                    'revenue', s.revenue) order by s.revenue desc)
                                   from (select restaurant_id, count(*) n, sum(subtotal) revenue
                                           from period where status = 'delivered' and restaurant_id is not null
                                          group by restaurant_id order by sum(subtotal) desc limit 5) s
                                   join public.restaurants r on r.id = s.restaurant_id), '[]'::jsonb),
    'series', (select coalesce(jsonb_agg(jsonb_build_object(
                         'bucket', to_char(bk.b, 'YYYY-MM-DD"T"HH24:MI'),
                         'orders', coalesce(s.n, 0), 'delivered', coalesce(s.delivered, 0),
                         'cancelled', coalesce(s.cancelled, 0), 'revenue', coalesce(s.revenue, 0)) order by bk.b), '[]'::jsonb)
                 from buckets bk
                 left join (select b, count(*) n,
                                   count(*) filter (where status = 'delivered') delivered,
                                   count(*) filter (where status in ('rejected', 'cancelled', 'failed')) cancelled,
                                   coalesce(sum(total) filter (where status = 'delivered'), 0) revenue
                              from period group by b) s on s.b = bk.b),
    'todo', jsonb_build_object(
      'cash_to_reconcile', coalesce((select sum(case when type = 'collected' then amount else -amount end)
                                       from public.cash_ledger), 0),
      'refunds_pending', (select count(*) from public.orders where payment_status = 'refund_pending'))
  ) into result;
  return result;
end;
$$;
revoke all on function public.admin_dashboard(timestamptz, timestamptz, text) from public, anon;
grant execute on function public.admin_dashboard(timestamptz, timestamptz, text) to authenticated;

-- Paiements d'une période, par commande (espèces comprises) : réussi = encaissé, remboursé = remboursement demandé
-- ou fait, échoué = jamais payé et commande terminée sans livraison, en attente = le reste. Les tentatives en ligne
-- (Mobile Money, carte) et le suivi des espèces encaissées par les livreurs complètent le tableau.
create function public.admin_payment_stats(p_from timestamptz, p_to timestamptz, p_bucket text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  perform private.check_period(p_from, p_to, p_bucket);
  with period as (
    select o.payment_method as method, o.total,
           date_trunc(p_bucket, o.created_at at time zone 'Africa/Abidjan') as b,
           case when o.payment_status = 'paid' then 'succeeded'
                when o.payment_status in ('refund_pending', 'refunded') then 'refunded'
                when o.status in ('rejected', 'cancelled', 'failed') then 'failed'
                else 'pending' end as outcome
      from public.orders o where o.created_at >= p_from and o.created_at < p_to
  ), buckets as (
    select g as b
      from generate_series(date_trunc(p_bucket, p_from at time zone 'Africa/Abidjan'),
                           (p_to at time zone 'Africa/Abidjan') - interval '1 second',
                           ('1 ' || p_bucket)::interval) g
  ), attempts as (
    select * from public.transactions where created_at >= p_from and created_at < p_to
  )
  select jsonb_build_object(
    'count', (select count(*) from period),
    'amount', (select coalesce(sum(total), 0) from period),
    'collected', (select coalesce(sum(total), 0) from period where outcome = 'succeeded'),
    'by_outcome', (select jsonb_object_agg(k, jsonb_build_object('count', coalesce(s.n, 0), 'amount', coalesce(s.amount, 0)))
                     from unnest(array['succeeded', 'pending', 'failed', 'refunded']) k
                     left join (select outcome, count(*) n, sum(total) amount from period group by outcome) s
                       on s.outcome = k),
    'by_method', (select jsonb_agg(jsonb_build_object('method', k, 'count', coalesce(s.n, 0),
                                                      'amount', coalesce(s.amount, 0), 'collected', coalesce(s.collected, 0),
                                                      'succeeded', coalesce(s.succeeded, 0)))
                    from unnest(array['cash', 'mobile_money', 'card']) k
                    left join (select method::text, count(*) n, sum(total) amount,
                                      coalesce(sum(total) filter (where outcome = 'succeeded'), 0) collected,
                                      count(*) filter (where outcome = 'succeeded') succeeded
                                 from period group by method) s on s.method = k),
    'series', (select coalesce(jsonb_agg(jsonb_build_object(
                         'bucket', to_char(bk.b, 'YYYY-MM-DD"T"HH24:MI'),
                         'cash', coalesce(s.cash, 0), 'mobile_money', coalesce(s.mobile_money, 0),
                         'card', coalesce(s.card, 0)) order by bk.b), '[]'::jsonb)
                 from buckets bk
                 left join (select b,
                                   sum(total) filter (where method = 'cash') cash,
                                   sum(total) filter (where method = 'mobile_money') mobile_money,
                                   sum(total) filter (where method = 'card') card
                              from period where outcome = 'succeeded' group by b) s on s.b = bk.b),
    'online', jsonb_build_object(
      'attempts', (select count(*) from attempts),
      'succeeded', (select count(*) from attempts where status in ('succeeded', 'refunded')),
      'failed', (select count(*) from attempts where status in ('failed', 'cancelled')),
      'pending', (select count(*) from attempts where status = 'pending')),
    'cash', jsonb_build_object(
      'collected', (select coalesce(sum(amount), 0) from public.cash_ledger
                     where type = 'collected' and created_at >= p_from and created_at < p_to),
      'remitted', (select coalesce(sum(amount), 0) from public.cash_ledger
                    where type = 'remitted' and created_at >= p_from and created_at < p_to),
      'outstanding', (select coalesce(sum(case when type = 'collected' then amount else -amount end), 0)
                        from public.cash_ledger))
  ) into result;
  return result;
end;
$$;
revoke all on function public.admin_payment_stats(timestamptz, timestamptz, text) from public, anon;
grant execute on function public.admin_payment_stats(timestamptz, timestamptz, text) to authenticated;

-- 3. Actions d'administration manquantes (ADR-048).
-- Fiche d'un compte : nom et prénom corrigés par un admin, tracés.
create function public.admin_update_profile(p_user_id uuid, p_first_name text, p_last_name text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  update public.profiles
     set first_name = nullif(btrim(p_first_name), ''), last_name = nullif(btrim(p_last_name), '')
   where id = p_user_id and deleted_at is null;
  if not found then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  perform private.audit('profile_updated', 'user', p_user_id);
end;
$$;
revoke all on function public.admin_update_profile(uuid, text, text) from public, anon;
grant execute on function public.admin_update_profile(uuid, text, text) to authenticated;

-- Suppression d'un compte par un admin : refusée pour soi-même, un autre admin ou un compte engagé dans une commande
-- en cours (client ou livreur). Le profil est anonymisé (historique conservé) ; la fonction admin-users supprime
-- ensuite le compte de connexion.
create function public.admin_delete_account(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if p_user_id = auth.uid() or exists (select 1 from public.admins where user_id = p_user_id) then
    raise exception 'cannot_delete_admin' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.orders
              where (customer_id = p_user_id or courier_id = p_user_id)
                and status not in ('delivered', 'rejected', 'cancelled', 'failed')) then
    raise exception 'account_busy' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.profiles where id = p_user_id and deleted_at is null) then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  update public.couriers set is_online = false, online_since = null where user_id = p_user_id;
  delete from public.restaurant_members where user_id = p_user_id;
  perform public.anonymize_account(p_user_id);
  perform private.audit('account_deleted', 'user', p_user_id);
end;
$$;
revoke all on function public.admin_delete_account(uuid) from public, anon;
grant execute on function public.admin_delete_account(uuid) to authenticated;

-- Suppression d'un établissement sans aucune commande (inscription erronée, doublon) ; sinon, le désactiver.
create function public.admin_delete_restaurant(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.orders where restaurant_id = p_id) then
    raise exception 'restaurant_has_orders' using errcode = 'P0001';
  end if;
  delete from public.restaurants where id = p_id;
  if not found then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  perform private.audit('restaurant_deleted', 'restaurant', p_id);
end;
$$;
revoke all on function public.admin_delete_restaurant(uuid) from public, anon;
grant execute on function public.admin_delete_restaurant(uuid) to authenticated;
