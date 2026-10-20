-- Espace Établissement (ADR-049, 050) : profil complet modifiable par les gérants, désactivation demandée par le
-- responsable, statistiques par période calculées par le serveur, affiliations des livreurs avec candidature.

-- 1. Profil : logo, et nom / adresse / position modifiables par les gérants (dans le rayon de leur zone).
alter table public.restaurants add column logo_path text;
grant update (logo_path) on public.restaurants to authenticated;

create function public.restaurant_update_profile(
  p_id uuid, p_name text, p_description text, p_category text, p_phone text, p_district text, p_landmark text,
  p_latitude double precision, p_longitude double precision, p_prep_time_min integer
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  z public.zones;
begin
  if not (private.is_member_of(p_id) or private.is_admin()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  select z2.* into z from public.zones z2 join public.restaurants r on r.zone_id = z2.id where r.id = p_id;
  if extensions.st_distance(z.center, extensions.st_point(p_longitude, p_latitude, 4326)::extensions.geography)
     > z.radius_m then
    raise exception 'address_out_of_zone' using errcode = 'P0001';
  end if;
  -- Les contraintes de la table valident longueurs, téléphone et délai de préparation.
  update public.restaurants
     set name = btrim(p_name), description = nullif(btrim(p_description), ''), category = nullif(btrim(p_category), ''),
         phone = p_phone, district = btrim(p_district), landmark = btrim(p_landmark),
         latitude = p_latitude, longitude = p_longitude, prep_time_min = p_prep_time_min
   where id = p_id;
  perform private.audit('restaurant_profile_updated', 'restaurant', p_id);
end;
$$;
revoke all on function public.restaurant_update_profile(uuid, text, text, text, text, text, text, double precision,
  double precision, integer) from public, anon;
grant execute on function public.restaurant_update_profile(uuid, text, text, text, text, text, text, double precision,
  double precision, integer) to authenticated;

-- Désactivation demandée par un gérant : refusée avec des commandes en cours ; l'établissement disparaît des clients,
-- l'historique (commandes, paiements) est conservé ; les admins sont prévenus (suppression éventuelle par eux,
-- seulement sans commande : admin_delete_restaurant).
create function public.restaurant_request_deactivation(p_id uuid, p_reason text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_member_of(p_id) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.orders where restaurant_id = p_id
              and status not in ('delivered', 'rejected', 'cancelled', 'failed')) then
    raise exception 'orders_in_progress' using errcode = 'P0001';
  end if;
  update public.restaurants set is_active = false where id = p_id;
  perform private.audit('restaurant_deactivation_requested', 'restaurant', p_id,
    jsonb_build_object('reason', nullif(btrim(p_reason), '')));
  perform private.notify(a.user_id, null, 'restaurant_deactivated', 'Établissement désactivé',
    (select name from public.restaurants where id = p_id) || ' a été désactivé par son responsable.', '/admin')
    from public.admins a;
end;
$$;
revoke all on function public.restaurant_request_deactivation(uuid, text) from public, anon;
grant execute on function public.restaurant_request_deactivation(uuid, text) to authenticated;

-- 2. Statistiques d'un établissement sur une période (mêmes règles que l'écran mobile : ventes = commandes ni
-- refusées, ni annulées, ni en attente de paiement ; montant des produits).
create function public.restaurant_stats(p_restaurant_id uuid, p_from timestamptz, p_to timestamptz, p_bucket text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if not (private.is_member_of(p_restaurant_id) or private.is_admin()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  perform private.check_period(p_from, p_to, p_bucket);
  with period as (
    select o.*, date_trunc(p_bucket, o.created_at at time zone 'Africa/Abidjan') as b,
           o.status not in ('rejected', 'cancelled', 'awaiting_payment') as counted
      from public.orders o
     where o.restaurant_id = p_restaurant_id and o.created_at >= p_from and o.created_at < p_to
  ), buckets as (
    select g as b
      from generate_series(date_trunc(p_bucket, p_from at time zone 'Africa/Abidjan'),
                           (p_to at time zone 'Africa/Abidjan') - interval '1 second',
                           ('1 ' || p_bucket)::interval) g
  )
  select jsonb_build_object(
    'orders', (select count(*) from period where counted),
    'delivered', (select count(*) from period where status = 'delivered'),
    'cancelled', (select count(*) from period where status in ('rejected', 'cancelled', 'failed')),
    'sales', (select coalesce(sum(subtotal), 0) from period where counted),
    'commission', (select coalesce(sum(commission_amount), 0) from period where counted),
    'average_basket', (select coalesce(round(avg(subtotal)), 0) from period where counted),
    'by_status', coalesce((select jsonb_object_agg(status, n)
                             from (select status, count(*) n from period group by status) s), '{}'::jsonb),
    'by_method', coalesce((select jsonb_object_agg(payment_method, n)
                             from (select payment_method, count(*) n from period where counted
                                    group by payment_method) s), '{}'::jsonb),
    'top_products', coalesce((select jsonb_agg(jsonb_build_object('name', name, 'quantity', q, 'amount', a)
                                               order by q desc, a desc)
                                from (select regexp_replace(i.name, ' \(.*\)$', '') as name, sum(i.quantity) q,
                                             sum(i.line_total) a
                                        from public.order_items i join period p on p.id = i.order_id
                                       where p.status = 'delivered'
                                       group by 1 order by 2 desc limit 8) t), '[]'::jsonb),
    'series', (select coalesce(jsonb_agg(jsonb_build_object(
                         'bucket', to_char(bk.b, 'YYYY-MM-DD"T"HH24:MI'),
                         'orders', coalesce(s.n, 0), 'sales', coalesce(s.sales, 0)) order by bk.b), '[]'::jsonb)
                 from buckets bk
                 left join (select b, count(*) n, sum(subtotal) sales from period where counted group by b) s
                   on s.b = bk.b)
  ) into result;
  return result;
end;
$$;
revoke all on function public.restaurant_stats(uuid, timestamptz, timestamptz, text) from public, anon;
grant execute on function public.restaurant_stats(uuid, timestamptz, timestamptz, text) to authenticated;

-- 3. Affiliations (ADR-050) : le livreur validé par l'admin postule, le restaurant accepte ou refuse, suspend ou met
-- fin. Une ligne par couple restaurant / livreur (pas de doublon), historique dans le journal d'audit. Seules les
-- affiliations approuvées comptent pour l'attribution des commandes.
alter table public.restaurant_couriers
  add column status text not null default 'approved'
    check (status in ('pending', 'approved', 'rejected', 'suspended', 'ended')),
  add column message text check (char_length(message) <= 300),
  add column updated_at timestamptz not null default now();
create trigger restaurant_couriers_updated_at before update on public.restaurant_couriers
  for each row execute function private.set_updated_at();

create or replace function private.eligible_couriers(p_order public.orders)
returns table (courier_id uuid, straight_m double precision)
language sql
stable
security definer
set search_path = ''
as $$
  select c.user_id,
         extensions.st_distance(l.location,
           extensions.st_point(p_order.pickup_lng, p_order.pickup_lat, 4326)::extensions.geography)
    from public.couriers c
    join public.courier_locations l on l.courier_id = c.user_id
    join public.profiles p on p.id = c.user_id
   where c.status = 'approved' and c.is_online and not p.is_suspended
     and l.recorded_at > now() - make_interval(secs => (select location_fresh_s from public.settings))
     and not private.courier_busy(c.user_id)
     and (p_order.parcel_type_id is null
          or exists (select 1 from public.parcel_types t
                      where t.id = p_order.parcel_type_id and c.vehicle_type = any (t.allowed_vehicles)))
     and case
           when exists (select 1 from public.restaurant_couriers r
                         where r.restaurant_id = p_order.restaurant_id and r.status = 'approved')
             then exists (select 1 from public.restaurant_couriers r
                           where r.restaurant_id = p_order.restaurant_id and r.courier_id = c.user_id
                             and r.status = 'approved')
           else c.zone_id = p_order.zone_id
         end;
$$;

-- Choix de l'admin (inchangé pour l'app mobile) : les livreurs listés deviennent affiliés, les autres affiliés finis.
create or replace function public.admin_set_restaurant_couriers(p_restaurant_id uuid, p_courier_ids uuid[])
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  update public.restaurant_couriers set status = 'ended'
   where restaurant_id = p_restaurant_id and status = 'approved' and courier_id <> all (coalesce(p_courier_ids, '{}'));
  insert into public.restaurant_couriers (restaurant_id, courier_id)
  select p_restaurant_id, c.user_id from public.couriers c where c.user_id = any (coalesce(p_courier_ids, '{}'))
  on conflict (restaurant_id, courier_id) do update set status = 'approved';
  perform private.audit('restaurant_couriers', 'restaurant', p_restaurant_id,
    jsonb_build_object('couriers', to_jsonb(coalesce(p_courier_ids, '{}'))));
end;
$$;

create function public.courier_request_affiliation(p_restaurant_id uuid, p_message text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_status text;
begin
  if not exists (select 1 from public.couriers where user_id = auth.uid() and status = 'approved') then
    raise exception 'courier_not_approved' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.restaurants where id = p_restaurant_id and is_active) then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  select status into current_status from public.restaurant_couriers
   where restaurant_id = p_restaurant_id and courier_id = auth.uid() for update;
  if current_status in ('pending', 'approved', 'suspended') then
    raise exception 'already_submitted' using errcode = 'P0001';
  end if;
  insert into public.restaurant_couriers (restaurant_id, courier_id, status, message)
  values (p_restaurant_id, auth.uid(), 'pending', nullif(btrim(p_message), ''))
  on conflict (restaurant_id, courier_id) do update set status = 'pending', message = excluded.message;
  perform private.audit('affiliation_requested', 'restaurant', p_restaurant_id);
  perform private.notify(m.user_id, null, 'affiliation_requested', 'Nouvelle candidature de livreur',
    'Un livreur souhaite livrer vos commandes.', '/restaurant')
    from public.restaurant_members m where m.restaurant_id = p_restaurant_id;
end;
$$;
revoke all on function public.courier_request_affiliation(uuid, text) from public, anon;
grant execute on function public.courier_request_affiliation(uuid, text) to authenticated;

-- Décision du restaurant (ou de l'admin). Transitions : candidature → approuvée / refusée ; approuvée ⇄ suspendue ;
-- approuvée ou suspendue → terminée. Un livreur non validé par l'admin ne peut pas être approuvé.
create function public.restaurant_set_affiliation(p_restaurant_id uuid, p_courier_id uuid, p_status text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_status text;
  restaurant_name text := (select name from public.restaurants where id = p_restaurant_id);
begin
  if not (private.is_member_of(p_restaurant_id) or private.is_admin()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  select status into current_status from public.restaurant_couriers
   where restaurant_id = p_restaurant_id and courier_id = p_courier_id for update;
  if current_status is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if not ((current_status = 'pending' and p_status in ('approved', 'rejected'))
          or (current_status = 'approved' and p_status in ('suspended', 'ended'))
          or (current_status = 'suspended' and p_status in ('approved', 'ended'))) then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  if p_status = 'approved'
     and not exists (select 1 from public.couriers where user_id = p_courier_id and status = 'approved') then
    raise exception 'courier_not_approved' using errcode = 'P0001';
  end if;
  update public.restaurant_couriers set status = p_status
   where restaurant_id = p_restaurant_id and courier_id = p_courier_id;
  perform private.audit('affiliation_' || p_status, 'restaurant', p_restaurant_id,
    jsonb_build_object('courier_id', p_courier_id));
  perform private.notify(p_courier_id, null, 'affiliation_' || p_status,
    case p_status when 'approved' then 'Affiliation acceptée' when 'rejected' then 'Candidature refusée'
                  when 'suspended' then 'Affiliation suspendue' else 'Affiliation terminée' end,
    case p_status when 'approved' then restaurant_name || ' vous propose désormais ses commandes.'
                  when 'rejected' then restaurant_name || ' n''a pas retenu votre candidature.'
                  when 'suspended' then restaurant_name || ' a suspendu votre affiliation.'
                  else restaurant_name || ' a mis fin à votre affiliation.' end,
    '/courier');
end;
$$;
revoke all on function public.restaurant_set_affiliation(uuid, uuid, text) from public, anon;
grant execute on function public.restaurant_set_affiliation(uuid, uuid, text) to authenticated;

-- Livreurs d'un établissement (candidats compris), pour ses gérants : identité, contact, véhicule, zone, disponibilité,
-- livraisons faites pour lui.
create function public.restaurant_couriers_list(p_restaurant_id uuid)
returns table (courier_id uuid, first_name text, last_name text, phone text, vehicle_type public.vehicle_type,
               zone_name text, courier_status public.courier_status, status text, message text, is_online boolean,
               deliveries bigint, updated_at timestamptz)
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
  select rc.courier_id, p.first_name, p.last_name, p.phone, c.vehicle_type, z.name, c.status, rc.status, rc.message,
         c.is_online and c.status = 'approved',
         (select count(*) from public.orders o
           where o.restaurant_id = p_restaurant_id and o.courier_id = rc.courier_id and o.status = 'delivered'),
         rc.updated_at
    from public.restaurant_couriers rc
    join public.couriers c on c.user_id = rc.courier_id
    join public.profiles p on p.id = rc.courier_id
    join public.zones z on z.id = c.zone_id
   where rc.restaurant_id = p_restaurant_id
   order by rc.status = 'pending' desc, rc.updated_at desc;
end;
$$;
revoke all on function public.restaurant_couriers_list(uuid) from public, anon;
grant execute on function public.restaurant_couriers_list(uuid) to authenticated;
