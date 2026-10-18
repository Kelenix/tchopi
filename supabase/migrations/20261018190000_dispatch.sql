-- Mise en ligne des livreurs, attribution automatique et manuelle, supervision, paramètres (Inc-7,
-- docs/data-model.md §4, §5, §8 ; ADR-023).

-- ADM-05 : paramètres de la plateforme (ligne unique), lus par tous les comptes, modifiés par les admins (tracé).
create table public.settings (
  id boolean primary key default true check (id),
  offer_timeout_s integer not null default 45 check (offer_timeout_s between 15 and 300),
  restaurant_timeout_s integer not null default 600 check (restaurant_timeout_s between 120 and 3600),
  payment_timeout_s integer not null default 900 check (payment_timeout_s between 300 and 3600),
  dispatch_alert_s integer not null default 600 check (dispatch_alert_s between 120 and 3600),
  dispatch_cancel_s integer not null default 1800 check (dispatch_cancel_s between 300 and 14400),
  location_fresh_s integer not null default 120 check (location_fresh_s between 30 and 600),
  support_phone text check (support_phone ~ '^\+[1-9][0-9]{7,14}$'),
  updated_at timestamptz not null default now(),
  check (dispatch_cancel_s > dispatch_alert_s)
);
insert into public.settings default values;
alter table public.settings enable row level security;
create policy "paramètres : lus par tous les comptes" on public.settings
  for select to authenticated using (true);
create policy "paramètres : modifiés par les admins" on public.settings
  for update to authenticated using (private.is_admin()) with check (private.is_admin());
revoke all on public.settings from anon;
revoke insert, delete on public.settings from authenticated;

create function private.audit_settings()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.updated_at := now();
  perform private.audit('settings_updated', 'settings', null, jsonb_build_object(
    'before', to_jsonb(old) - 'id' - 'updated_at', 'after', to_jsonb(new) - 'id' - 'updated_at'));
  return new;
end;
$$;
create trigger settings_audit before update on public.settings
  for each row execute function private.audit_settings();

-- Délai de réponse du restaurant désormais réglable (ORD-08).
create or replace function private.reject_unanswered_orders()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  rejected integer;
begin
  with expired as (
    update public.orders
       set status = 'rejected', closed_at = now(), close_reason = 'no_response'
     where status = 'pending'
       and created_at < now() - make_interval(secs => (select restaurant_timeout_s from public.settings))
    returning id
  ), events as (
    insert into public.order_events (order_id, status, actor_role, reason)
    select id, 'rejected', 'system', 'no_response' from expired
  )
  select count(*) into rejected from expired;
  return rejected;
end;
$$;

-- COU-05 : dernière position d'un livreur en ligne (effacée quand il passe hors ligne).
create table public.courier_locations (
  courier_id uuid primary key references public.couriers (user_id) on delete cascade,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  location extensions.geography(Point, 4326)
    generated always as (extensions.st_point(longitude, latitude, 4326)::extensions.geography) stored,
  accuracy_m real check (accuracy_m >= 0),
  recorded_at timestamptz not null default now()
);
create index courier_locations_location_idx on public.courier_locations using gist (location);
alter table public.courier_locations enable row level security;
create policy "positions : lues par le livreur lui-même et les admins" on public.courier_locations
  for select to authenticated using (courier_id = auth.uid() or private.is_admin());
revoke all on public.courier_locations from anon;
revoke insert, update, delete on public.courier_locations from authenticated;

alter table public.orders
  add column assigned_at timestamptz,
  -- Livreur figé à l'attribution : prénom, téléphone, moyen de transport, immatriculation, photo.
  add column courier_info jsonb,
  add column dispatch_started_at timestamptz,
  add column dispatch_alerted_at timestamptz;
create index orders_courier_idx on public.orders (courier_id) where courier_id is not null;
create index orders_dispatch_idx on public.orders (dispatch_started_at)
  where courier_id is null and status in ('preparing', 'ready', 'searching_courier');
create policy "commandes : le livreur assigné" on public.orders
  for select to authenticated using (courier_id = auth.uid());

-- DIS-01 / DIS-02 : offres de mission, une seule en attente par livreur et par commande.
create type public.offer_status as enum ('pending', 'accepted', 'declined', 'expired', 'cancelled');
create table public.delivery_offers (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  courier_id uuid not null references public.couriers (user_id) on delete cascade,
  status public.offer_status not null default 'pending',
  -- Ce que voit le livreur avant d'accepter : type, gain, distances, quartiers et repères, espèces à encaisser.
  summary jsonb not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  responded_at timestamptz
);
create unique index delivery_offers_courier_pending_idx on public.delivery_offers (courier_id) where status = 'pending';
create unique index delivery_offers_order_pending_idx on public.delivery_offers (order_id) where status = 'pending';
create index delivery_offers_order_idx on public.delivery_offers (order_id, courier_id);
alter table public.delivery_offers enable row level security;
create policy "offres : lues par le livreur concerné et les admins" on public.delivery_offers
  for select to authenticated using (courier_id = auth.uid() or private.is_admin());
revoke all on public.delivery_offers from anon;
revoke insert, update, delete on public.delivery_offers from authenticated;

-- Une commande occupe son livreur de l'attribution à la clôture.
create function private.courier_busy(p_courier_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.orders
     where courier_id = p_courier_id
       and status in ('accepted', 'preparing', 'ready', 'courier_assigned', 'picked_up', 'in_transit')
  );
$$;

-- Livreur joignable : approuvé, en ligne, position récente, dans la zone et, pour un colis, avec un moyen adapté.
create function private.couriers_online(p_zone_id uuid, p_vehicles public.vehicle_type[] default null)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
      from public.couriers c
      join public.courier_locations l on l.courier_id = c.user_id
      join public.profiles p on p.id = c.user_id
     where c.zone_id = p_zone_id and c.status = 'approved' and c.is_online and not p.is_suspended
       and l.recorded_at > now() - make_interval(secs => (select location_fresh_s from public.settings))
       and (p_vehicles is null or c.vehicle_type = any (p_vehicles))
  );
$$;

create function private.log_order_kind(
  p_order_id uuid, p_kind text, p_status public.order_status, p_role public.actor_role, p_reason text default null
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.order_events (order_id, kind, status, actor_id, actor_role, reason)
  values (p_order_id, p_kind, p_status, auth.uid(), p_role, p_reason);
$$;

-- Offre au livreur éligible le plus proche du retrait (DIS-01) : approuvé, en ligne, position récente, même zone,
-- moyen adapté au colis, sans mission ni offre en attente, jamais sollicité pour cette commande.
-- Verrou « SKIP LOCKED » : deux recherches simultanées ne visent pas le même livreur.
create function private.dispatch(p_order_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  vehicles public.vehicle_type[];
  chosen record;
  offer_id uuid;
begin
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null or o.courier_id is not null or o.dispatch_started_at is null
     or o.status not in ('preparing', 'ready', 'searching_courier')
     or exists (select 1 from public.delivery_offers where order_id = o.id and status = 'pending')
  then
    return null;
  end if;
  select allowed_vehicles into vehicles from public.parcel_types where id = o.parcel_type_id;

  select c.user_id,
         extensions.st_distance(l.location,
           extensions.st_point(o.pickup_lng, o.pickup_lat, 4326)::extensions.geography) as straight_m
    into chosen
    from public.couriers c
    join public.courier_locations l on l.courier_id = c.user_id
    join public.profiles p on p.id = c.user_id
   where c.zone_id = o.zone_id and c.status = 'approved' and c.is_online and not p.is_suspended
     and l.recorded_at > now() - make_interval(secs => (select location_fresh_s from public.settings))
     and (vehicles is null or c.vehicle_type = any (vehicles))
     and not private.courier_busy(c.user_id)
     and not exists (select 1 from public.delivery_offers f
                      where f.courier_id = c.user_id and (f.status = 'pending' or f.order_id = o.id))
   order by straight_m
   limit 1
   for update of c skip locked;
  if chosen.user_id is null then
    return null;
  end if;

  insert into public.delivery_offers (order_id, courier_id, expires_at, summary)
  values (o.id, chosen.user_id, now() + make_interval(secs => (select offer_timeout_s from public.settings)),
    jsonb_build_object(
      'number', o.number,
      'type', o.type,
      'pickup_name', case when o.type = 'food' then o.pickup_name end,
      'pickup_district', o.pickup_district,
      'pickup_landmark', o.pickup_landmark,
      'recipient_name', o.recipient_name,
      'dropoff_district', o.dropoff_district,
      'dropoff_landmark', o.dropoff_landmark,
      'parcel_type', (select label from public.parcel_types where id = o.parcel_type_id),
      'earning', o.courier_earning,
      'to_pickup_m', round(chosen.straight_m * coalesce(
        (select detour_factor from public.pricing_rules where zone_id = o.zone_id and service = o.type), 1.3))::integer,
      'trip_m', o.distance_m,
      'cash_amount', case when o.payment_method = 'cash' then o.total else 0 end,
      'currency', o.currency
    ))
  returning id into offer_id;
  return offer_id;
exception
  when unique_violation then
    -- Course avec une autre recherche : la tâche planifiée relancera.
    return null;
end;
$$;

-- Attribution (offre acceptée ou admin) : livreur figé sur la commande ; un colis passe « Livreur assigné ».
create function private.assign_courier(
  p_order_id uuid, p_courier_id uuid, p_role public.actor_role, p_reason text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  new_status public.order_status;
begin
  update public.orders o
     set courier_id = p_courier_id,
         assigned_at = now(),
         courier_info = (
           select jsonb_build_object('first_name', p.first_name, 'phone', p.phone, 'vehicle_type', c.vehicle_type,
                                     'plate_number', c.plate_number, 'photo_path', c.photo_path)
             from public.couriers c join public.profiles p on p.id = c.user_id
            where c.user_id = p_courier_id),
         status = case when o.status = 'searching_courier' then 'courier_assigned' else o.status end
   where o.id = p_order_id
  returning o.status into new_status;
  perform private.log_order_kind(p_order_id, 'courier_assigned',
    case when new_status = 'courier_assigned' then new_status end, p_role, p_reason);
end;
$$;

-- Aucune commande sans livreur en ligne (ORD-07, PAR-03) ; la recherche démarre quand un repas passe
-- « En préparation » ou qu'un colis est confirmé (DIS-01).
create function private.prepare_order_dispatch()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' and not private.couriers_online(new.zone_id,
       (select allowed_vehicles from public.parcel_types where id = new.parcel_type_id))
  then
    raise exception 'no_courier_available' using errcode = 'P0001';
  end if;
  if new.status in ('preparing', 'searching_courier') and new.courier_id is null and new.dispatch_started_at is null then
    new.dispatch_started_at := now();
  end if;
  return new;
end;
$$;
create trigger orders_prepare_dispatch before insert or update of status on public.orders
  for each row execute function private.prepare_order_dispatch();

-- Offres retirées quand la commande est attribuée ou close ; recherche lancée ou relancée (livreur retiré).
create function private.after_order_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.courier_id is not null or new.status in ('delivered', 'rejected', 'cancelled', 'failed') then
    update public.delivery_offers set status = 'cancelled', responded_at = now()
     where order_id = new.id and status = 'pending';
  end if;
  if new.courier_id is null and new.dispatch_started_at is not null
     and new.status in ('preparing', 'ready', 'searching_courier')
     and (tg_op = 'INSERT' or old.dispatch_started_at is null or old.courier_id is not null)
  then
    perform private.dispatch(new.id);
  end if;
  return null;
end;
$$;
create trigger orders_after_change after insert or update on public.orders
  for each row execute function private.after_order_change();

-- COU-05 : en ligne seulement si approuvé ; hors ligne refusé pendant une mission. Hors ligne : l'offre en
-- attente passe au livreur suivant et la position n'est plus conservée.
create function public.set_courier_online(p_online boolean)
returns public.couriers
language plpgsql
security definer
set search_path = ''
as $$
declare
  result public.couriers;
  r record;
begin
  if not exists (select 1 from public.couriers c join public.profiles p on p.id = c.user_id
                  where c.user_id = auth.uid() and c.status = 'approved' and not p.is_suspended) then
    raise exception 'courier_not_approved' using errcode = 'P0001';
  end if;
  if not p_online and private.courier_busy(auth.uid()) then
    raise exception 'mission_in_progress' using errcode = 'P0001';
  end if;
  update public.couriers
     set is_online = p_online, online_since = case when p_online then coalesce(online_since, now()) end
   where user_id = auth.uid()
  returning * into result;
  if not p_online then
    for r in select order_id from public.delivery_offers where courier_id = auth.uid() and status = 'pending' loop
      perform 1 from public.orders where id = r.order_id for update;
      update public.delivery_offers set status = 'declined', responded_at = now()
       where courier_id = auth.uid() and order_id = r.order_id and status = 'pending';
      perform private.dispatch(r.order_id);
    end loop;
    delete from public.courier_locations where courier_id = auth.uid();
  end if;
  return result;
end;
$$;
revoke all on function public.set_courier_online(boolean) from public, anon;
grant execute on function public.set_courier_online(boolean) to authenticated;

create function public.report_location(p_lat double precision, p_lng double precision, p_accuracy_m real default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from public.couriers where user_id = auth.uid() and status = 'approved' and is_online) then
    raise exception 'courier_offline' using errcode = 'P0001';
  end if;
  insert into public.courier_locations (courier_id, latitude, longitude, accuracy_m, recorded_at)
  values (auth.uid(), p_lat, p_lng, p_accuracy_m, now())
  on conflict (courier_id) do update
    set latitude = excluded.latitude, longitude = excluded.longitude, accuracy_m = excluded.accuracy_m,
        recorded_at = excluded.recorded_at;
end;
$$;
revoke all on function public.report_location(double precision, double precision, real) from public, anon;
grant execute on function public.report_location(double precision, double precision, real) to authenticated;

-- DIS-02 : accepter (une mission à la fois) ou refuser ; refus → livreur suivant, l'offre n'est plus reproposée.
-- Verrou de la commande d'abord, comme l'annulation et la tâche planifiée.
create function public.respond_to_offer(p_offer_id uuid, p_accept boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  f public.delivery_offers;
begin
  select * into f from public.delivery_offers where id = p_offer_id and courier_id = auth.uid();
  if f.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  perform 1 from public.orders where id = f.order_id for update;
  select * into f from public.delivery_offers where id = p_offer_id for update;
  if f.status <> 'pending' or f.expires_at <= now() then
    raise exception 'offer_unavailable' using errcode = 'P0001';
  end if;
  if p_accept and not exists (select 1 from public.couriers c join public.profiles p on p.id = c.user_id
                               where c.user_id = auth.uid() and c.status = 'approved' and not p.is_suspended) then
    raise exception 'courier_not_approved' using errcode = 'P0001';
  end if;
  if p_accept and private.courier_busy(auth.uid()) then
    raise exception 'courier_busy' using errcode = 'P0001';
  end if;
  update public.delivery_offers
     set status = case when p_accept then 'accepted' else 'declined' end::public.offer_status, responded_at = now()
   where id = f.id;
  if p_accept then
    perform private.assign_courier(f.order_id, auth.uid(), 'courier');
  else
    perform private.dispatch(f.order_id);
  end if;
end;
$$;
revoke all on function public.respond_to_offer(uuid, boolean) from public, anon;
grant execute on function public.respond_to_offer(uuid, boolean) to authenticated;

-- DIS-04 : livreurs en ligne de la zone, triés par distance du retrait, avec leur état.
create function public.admin_dispatch_candidates(p_order_id uuid)
returns table (
  user_id uuid, first_name text, last_name text, phone text, vehicle_type public.vehicle_type, plate_number text,
  distance_m integer, location_age_s integer, busy boolean, offer_pending boolean
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  return query
  select c.user_id, p.first_name, p.last_name, p.phone, c.vehicle_type, c.plate_number,
         round(extensions.st_distance(l.location,
           extensions.st_point(o.pickup_lng, o.pickup_lat, 4326)::extensions.geography))::integer,
         extract(epoch from now() - l.recorded_at)::integer,
         private.courier_busy(c.user_id),
         exists (select 1 from public.delivery_offers f where f.courier_id = c.user_id and f.status = 'pending')
    from public.orders o
    join public.couriers c on c.zone_id = o.zone_id and c.status = 'approved' and c.is_online
    join public.profiles p on p.id = c.user_id and not p.is_suspended
    left join public.courier_locations l on l.courier_id = c.user_id
   where o.id = p_order_id
   order by 7 nulls last;
end;
$$;
revoke all on function public.admin_dispatch_candidates(uuid) from public, anon;
grant execute on function public.admin_dispatch_candidates(uuid) to authenticated;

-- DIS-04 : attribution ou réattribution manuelle, avec motif ; l'ancien livreur est retiré (chronologie).
create function public.admin_assign_courier(p_order_id uuid, p_courier_id uuid, p_reason text)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  reason text := nullif(btrim(p_reason), '');
  r record;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if o.status not in ('accepted', 'preparing', 'ready', 'searching_courier', 'courier_assigned') then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  if o.courier_id = p_courier_id then
    return o;
  end if;
  if not exists (select 1 from public.couriers c join public.profiles p on p.id = c.user_id
                  where c.user_id = p_courier_id and c.zone_id = o.zone_id and c.status = 'approved'
                    and c.is_online and not p.is_suspended) then
    raise exception 'courier_unavailable' using errcode = 'P0001';
  end if;
  if private.courier_busy(p_courier_id) then
    raise exception 'courier_busy' using errcode = 'P0001';
  end if;
  -- Offre en attente du livreur pour une autre commande : retirée, cette commande passe au suivant.
  for r in select order_id from public.delivery_offers
            where courier_id = p_courier_id and status = 'pending' and order_id <> o.id loop
    perform 1 from public.orders where id = r.order_id for update;
    update public.delivery_offers set status = 'cancelled', responded_at = now()
     where courier_id = p_courier_id and order_id = r.order_id and status = 'pending';
    perform private.dispatch(r.order_id);
  end loop;
  if o.courier_id is not null then
    perform private.log_order_kind(o.id, 'courier_released', null, 'admin', reason);
  end if;
  perform private.assign_courier(o.id, p_courier_id, 'admin', reason);
  select * into o from public.orders where id = o.id;
  return o;
end;
$$;
revoke all on function public.admin_assign_courier(uuid, uuid, text) from public, anon;
grant execute on function public.admin_assign_courier(uuid, uuid, text) to authenticated;

-- PAR-01 : types de colis transportables par les livreurs en ligne autour du point de départ.
create function public.available_parcel_types(p_lat double precision, p_lng double precision)
returns setof public.parcel_types
language sql
stable
security definer
set search_path = ''
as $$
  select t.*
    from public.parcel_types t
   where t.is_active and private.couriers_online((private.zone_at(p_lat, p_lng)).id, t.allowed_vehicles)
   order by t.position;
$$;
revoke all on function public.available_parcel_types(double precision, double precision) from public, anon;
grant execute on function public.available_parcel_types(double precision, double precision) to authenticated;

-- Devis : présence de livreurs en ligne, pour prévenir avant la confirmation (ORD-07, PAR-03).
create or replace function public.quote_food_order(p_restaurant_id uuid, p_address_id uuid, p_items jsonb)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select private.food_quote(p_restaurant_id, p_address_id, p_items) - 'courier_earning'
         || jsonb_build_object('couriers_available',
              private.couriers_online((select zone_id from public.restaurants where id = p_restaurant_id)));
$$;

create or replace function public.quote_parcel(
  p_pickup_lat double precision,
  p_pickup_lng double precision,
  p_dropoff_lat double precision,
  p_dropoff_lng double precision,
  p_parcel_type_id uuid
)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select q - 'courier_earning' - 'zone_id'
         || jsonb_build_object('couriers_available', private.couriers_online((q->>'zone_id')::uuid,
              (select allowed_vehicles from public.parcel_types where id = p_parcel_type_id)))
    from private.parcel_quote(p_pickup_lat, p_pickup_lng, p_dropoff_lat, p_dropoff_lng, p_parcel_type_id) q;
$$;

-- ORD-11, PAR-05, DIS-03 : le client peut aussi annuler un repas accepté quand aucun livreur n'est trouvé
-- après le délai d'alerte. Les offres en attente sont retirées par le déclencheur des commandes.
create or replace function public.cancel_order(p_order_id uuid, p_reason text default null)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  admin boolean := private.is_admin();
  reason text := nullif(btrim(p_reason), '');
begin
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null or not (o.customer_id = auth.uid() or admin) then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if o.status in ('pending', 'awaiting_payment', 'searching_courier', 'courier_assigned') then
    null;
  elsif o.status in ('accepted', 'preparing', 'ready') then
    if admin then
      if reason is null then
        raise exception 'reason_required' using errcode = 'P0001';
      end if;
    elsif o.dispatch_alerted_at is null or o.courier_id is not null then
      raise exception 'already_accepted' using errcode = 'P0001';
    end if;
  elsif o.status in ('picked_up', 'in_transit') then
    raise exception 'already_picked_up' using errcode = 'P0001';
  else
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  update public.orders
     set status = 'cancelled', closed_at = now(), close_reason = coalesce(reason, 'cancelled_by_customer')
   where id = o.id
  returning * into o;
  perform private.log_order_event(o.id, 'cancelled', case when admin and o.customer_id <> auth.uid()
                                                           then 'admin' else 'customer' end::public.actor_role, reason);
  return o;
end;
$$;

-- Tâche planifiée unique (toutes les 10 s) : offres expirées → livreur suivant, recherches en attente relancées,
-- alerte puis annulation sans livreur (DIS-03), refus des commandes sans réponse du restaurant (ORD-08).
create function private.tick()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  s public.settings;
  r record;
begin
  select * into s from public.settings;
  for r in select distinct order_id from public.delivery_offers where status = 'pending' and expires_at <= now() loop
    perform 1 from public.orders where id = r.order_id for update;
    update public.delivery_offers set status = 'expired'
     where order_id = r.order_id and status = 'pending' and expires_at <= now();
    perform private.dispatch(r.order_id);
  end loop;

  for r in select o.id from public.orders o
            where o.courier_id is null and o.dispatch_started_at is not null
              and o.status in ('preparing', 'ready', 'searching_courier')
              and not exists (select 1 from public.delivery_offers f where f.order_id = o.id and f.status = 'pending')
  loop
    perform private.dispatch(r.id);
  end loop;

  with alerted as (
    update public.orders
       set dispatch_alerted_at = now()
     where courier_id is null and dispatch_alerted_at is null
       and status in ('preparing', 'ready', 'searching_courier')
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_alert_s)
    returning id
  )
  insert into public.order_events (order_id, kind, actor_role)
  select id, 'dispatch_alert', 'system' from alerted;

  with abandoned as (
    update public.orders
       set status = 'cancelled', closed_at = now(), close_reason = 'no_courier'
     where courier_id is null
       and status in ('preparing', 'ready', 'searching_courier')
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_cancel_s)
    returning id
  )
  insert into public.order_events (order_id, status, actor_role, reason)
  select id, 'cancelled', 'system', 'no_courier' from abandoned;

  perform private.reject_unanswered_orders();
end;
$$;

select cron.unschedule('reject-unanswered-orders');
select cron.schedule('tick', '10 seconds', 'select private.tick()');

-- Temps réel : offres reçues par le livreur (filtrées par la RLS).
alter publication supabase_realtime add table public.delivery_offers;
