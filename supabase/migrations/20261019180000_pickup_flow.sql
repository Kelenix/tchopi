-- Prise en charge des commandes (ADR-037) : le client commande même sans livreur en ligne. Un repas est proposé aux
-- livreurs quand le restaurant le marque « Prête » (un colis dès sa confirmation), à tous les livreurs éligibles à
-- la fois — affiliés au restaurant s'il en a, sinon ceux de la zone ; le premier qui accepte l'obtient. Sans
-- preneur, la commande reste proposée : tout livreur qui devient disponible la reçoit. Restaurant alerté si l'attente
-- se prolonge ; désistement du livreur avant le retrait → commande reproposée.

-- Un repas pris par un livreur passe « Livreur en route vers le retrait », comme un colis.
alter table public.orders drop constraint orders_check2;
alter table public.orders add constraint orders_food_check check (
  type <> 'food' or (restaurant_id is not null and status <> 'searching_courier'));

-- Livreurs affiliés à un restaurant (choisis par l'admin). Sans affiliation, les livreurs de la zone sont éligibles.
create table public.restaurant_couriers (
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  courier_id uuid not null references public.couriers (user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (restaurant_id, courier_id)
);
create index restaurant_couriers_courier_idx on public.restaurant_couriers (courier_id);
alter table public.restaurant_couriers enable row level security;
create policy "affiliations : admins, gérants du restaurant, livreur concerné" on public.restaurant_couriers
  for select to authenticated
  using (private.is_admin() or private.is_member_of(restaurant_id) or courier_id = auth.uid());
revoke insert, update, delete on public.restaurant_couriers from anon, authenticated;

create function public.admin_set_restaurant_couriers(p_restaurant_id uuid, p_courier_ids uuid[])
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  delete from public.restaurant_couriers
   where restaurant_id = p_restaurant_id and courier_id <> all (coalesce(p_courier_ids, '{}'));
  insert into public.restaurant_couriers (restaurant_id, courier_id)
  select p_restaurant_id, c.user_id from public.couriers c where c.user_id = any (coalesce(p_courier_ids, '{}'))
  on conflict do nothing;
  perform private.audit('restaurant_couriers', 'restaurant', p_restaurant_id,
    jsonb_build_object('couriers', to_jsonb(coalesce(p_courier_ids, '{}'))));
end;
$$;
revoke all on function public.admin_set_restaurant_couriers(uuid, uuid[]) from public, anon;
grant execute on function public.admin_set_restaurant_couriers(uuid, uuid[]) to authenticated;

-- Offres envoyées à plusieurs livreurs à la fois, sans limite de temps (une seule offre en attente par livreur et
-- par commande) ; chaque livreur peut en voir plusieurs.
drop index public.delivery_offers_courier_pending_idx;
drop index public.delivery_offers_order_pending_idx;
create unique index delivery_offers_pending_idx on public.delivery_offers (order_id, courier_id) where status = 'pending';
alter table public.delivery_offers alter column expires_at drop not null;

-- Livreurs éligibles pour une commande : approuvés, en ligne, position récente, sans mission en cours, moyen adapté
-- au colis ; repas : affiliés au restaurant, ou de la zone si le restaurant n'a pas d'affiliés.
create function private.eligible_couriers(p_order public.orders)
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
           when exists (select 1 from public.restaurant_couriers r where r.restaurant_id = p_order.restaurant_id)
             then exists (select 1 from public.restaurant_couriers r
                           where r.restaurant_id = p_order.restaurant_id and r.courier_id = c.user_id)
           else c.zone_id = p_order.zone_id
         end;
$$;

-- Propose la commande à chaque livreur éligible qui ne l'a ni en attente, ni refusée, ni déjà prise.
create or replace function private.dispatch(p_order_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  first_offer uuid;
begin
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null or o.courier_id is not null or o.dispatch_started_at is null
     or o.status not in ('ready', 'searching_courier') then
    return null;
  end if;
  with sent as (
    insert into public.delivery_offers (order_id, courier_id, summary)
    select o.id, e.courier_id, jsonb_build_object(
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
             'to_pickup_m', round(e.straight_m * coalesce(
               (select detour_factor from public.pricing_rules where zone_id = o.zone_id and service = o.type), 1.3))::integer,
             'trip_m', o.distance_m,
             'cash_amount', case when o.payment_method = 'cash' then o.total else 0 end,
             'currency', o.currency)
      from private.eligible_couriers(o) e
     where not exists (select 1 from public.delivery_offers f
                        where f.order_id = o.id and f.courier_id = e.courier_id
                          and f.status in ('pending', 'declined', 'accepted'))
    returning id
  )
  select id into first_offer from sent limit 1;
  return first_offer;
end;
$$;

-- Plus de refus faute de livreur ; la recherche démarre quand un repas est « Prête » ou qu'un colis est confirmé.
create or replace function private.prepare_order_dispatch()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.courier_id is null and new.dispatch_started_at is null
     and ((new.type = 'food' and new.status = 'ready') or new.status = 'searching_courier') then
    new.dispatch_started_at := now();
  end if;
  return new;
end;
$$;

-- Offres retirées quand la commande est attribuée ou close ; proposée dès qu'elle devient disponible.
create or replace function private.after_order_change()
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
     and new.status in ('ready', 'searching_courier')
     and (tg_op = 'INSERT' or old.status is distinct from new.status or old.courier_id is not null)
  then
    perform private.dispatch(new.id);
  end if;
  return null;
end;
$$;

-- Attribution : « Livreur en route vers le retrait » ; ses autres offres sont retirées (une mission à la fois).
create or replace function private.assign_courier(
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
         status = case when o.status in ('searching_courier', 'ready') then 'courier_assigned' else o.status end
   where o.id = p_order_id
  returning o.status into new_status;
  update public.delivery_offers set status = 'cancelled', responded_at = now()
   where courier_id = p_courier_id and status = 'pending' and order_id <> p_order_id;
  perform private.log_order_kind(p_order_id, 'courier_assigned',
    case when new_status = 'courier_assigned' then new_status end, p_role, p_reason);
end;
$$;

-- DIS-02 : le premier livreur qui accepte obtient la commande ; refuser la laisse aux autres.
create or replace function public.respond_to_offer(p_offer_id uuid, p_accept boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  f public.delivery_offers;
  o public.orders;
begin
  select * into f from public.delivery_offers where id = p_offer_id and courier_id = auth.uid();
  if f.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  select * into o from public.orders where id = f.order_id for update;
  select * into f from public.delivery_offers where id = p_offer_id for update;
  if f.status <> 'pending' or f.expires_at <= now() then
    raise exception 'offer_unavailable' using errcode = 'P0001';
  end if;
  if not p_accept then
    update public.delivery_offers set status = 'declined', responded_at = now() where id = f.id;
    return;
  end if;
  if o.courier_id is not null or o.status not in ('ready', 'searching_courier') then
    raise exception 'offer_unavailable' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.couriers c join public.profiles p on p.id = c.user_id
                  where c.user_id = auth.uid() and c.status = 'approved' and not p.is_suspended) then
    raise exception 'courier_not_approved' using errcode = 'P0001';
  end if;
  if private.courier_busy(auth.uid()) then
    raise exception 'courier_busy' using errcode = 'P0001';
  end if;
  update public.delivery_offers set status = 'accepted', responded_at = now() where id = f.id;
  perform private.assign_courier(o.id, auth.uid(), 'courier');
end;
$$;

-- Hors ligne : ses offres en attente sont retirées (reproposées quand il revient en ligne).
create or replace function public.set_courier_online(p_online boolean)
returns public.couriers
language plpgsql
security definer
set search_path = ''
as $$
declare
  result public.couriers;
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
    update public.delivery_offers set status = 'cancelled', responded_at = now()
     where courier_id = auth.uid() and status = 'pending';
    delete from public.courier_locations where courier_id = auth.uid();
  end if;
  return result;
end;
$$;

-- PAR-01 : tous les types de colis actifs, qu'un livreur soit en ligne ou non.
create or replace function public.available_parcel_types(p_lat double precision, p_lng double precision)
returns setof public.parcel_types
language sql
stable
security definer
set search_path = ''
as $$
  select t.* from public.parcel_types t where t.is_active order by t.position;
$$;

-- ORD-10 : remise au livreur déclarée par le restaurant, livreur arrivé (« Prête » ou livreur en route).
create or replace function public.transition_order(p_order_id uuid, p_to_status public.order_status, p_reason text default null)
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
  if o.id is null or o.status = 'awaiting_payment' or not (admin or private.is_member_of(o.restaurant_id)) then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.profiles where id = auth.uid() and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if (o.status, p_to_status) not in (
    ('pending'::public.order_status, 'accepted'::public.order_status), ('pending', 'rejected'),
    ('accepted', 'preparing'), ('preparing', 'ready'), ('ready', 'picked_up'), ('courier_assigned', 'picked_up')
  ) then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  if p_to_status = 'picked_up' and o.courier_id is null then
    raise exception 'no_courier' using errcode = 'P0001';
  end if;
  if p_to_status = 'rejected' and reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  update public.orders
     set status = p_to_status,
         accepted_at = case when p_to_status = 'accepted' then now() else accepted_at end,
         ready_at = case when p_to_status = 'ready' then now() else ready_at end,
         picked_up_at = case when p_to_status = 'picked_up' then now() else picked_up_at end,
         closed_at = case when p_to_status = 'rejected' then now() else closed_at end,
         close_reason = case when p_to_status = 'rejected' then reason else close_reason end
   where id = o.id
  returning * into o;
  perform private.log_order_event(o.id, p_to_status, case when admin and not private.is_member_of(o.restaurant_id)
                                                          then 'admin' else 'restaurant' end::public.actor_role, reason);
  return o;
end;
$$;

-- MIS-08 : désistement avant le retrait ; un repas redevient « Prête », un colis « Recherche d'un livreur ».
create or replace function public.release_mission(p_order_id uuid, p_reason text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders := private.my_mission(p_order_id);
  reason text := nullif(btrim(p_reason), '');
begin
  if reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  if o.status not in ('accepted', 'preparing', 'ready', 'courier_assigned') then
    raise exception 'already_picked_up' using errcode = 'P0001';
  end if;
  perform private.log_order_kind(o.id, 'courier_released', null, 'courier', reason);
  update public.orders
     set courier_id = null, courier_info = null, assigned_at = null,
         status = case when status <> 'courier_assigned' then status
                       when type = 'food' then 'ready' else 'searching_courier' end::public.order_status,
         dispatch_started_at = case when dispatch_started_at is null then null else now() end,
         dispatch_alerted_at = null
   where id = o.id;
end;
$$;

-- ORD-11 : un repas prêt et pris en charge ne s'annule plus côté client ; un colis tant qu'il n'est pas retiré.
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
  if o.status in ('pending', 'awaiting_payment', 'searching_courier')
     or (o.status = 'courier_assigned' and o.type = 'parcel') then
    null;
  elsif o.status in ('accepted', 'preparing', 'ready', 'courier_assigned') then
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

-- Qui est prévenu de quoi : le restaurant suit aussi la prise en charge (livreur en route, désistement, attente).
create or replace function private.notify_order_event()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  customer_route text;
  courier_name text;
  member uuid;
  title text;
  body text;
  kind text;
begin
  select * into o from public.orders where id = new.order_id;
  customer_route := '/orders/' || o.id;
  courier_name := coalesce(o.courier_info->>'first_name', 'Votre livreur');

  -- Client
  if new.actor_role <> 'customer' then
    case
      when new.status = 'accepted' then
        perform private.notify(o.customer_id, o, 'order_accepted', 'Commande acceptée',
          o.pickup_name || ' prépare votre commande ' || o.number || '.', customer_route);
      when new.status = 'rejected' then
        perform private.notify(o.customer_id, o, 'order_rejected', 'Commande refusée',
          'Le restaurant ne peut pas préparer votre commande ' || o.number || '.', customer_route);
      when new.status = 'ready' and o.courier_id is null then
        perform private.notify(o.customer_id, o, 'order_ready', 'Commande prête',
          'Votre commande ' || o.number || ' est prête : un livreur va la récupérer.', customer_route);
      when new.kind = 'courier_assigned' then
        perform private.notify(o.customer_id, o, 'courier_assigned', 'Livreur en route',
          courier_name || ' va récupérer votre commande ' || o.number || '.', customer_route);
      when new.kind = 'courier_released' then
        perform private.notify(o.customer_id, o, 'courier_released', 'Changement de livreur',
          'Votre livreur a dû annuler, nous en cherchons un autre.', customer_route);
      when new.kind = 'dispatch_alert' then
        perform private.notify(o.customer_id, o, 'dispatch_alert', 'Nous cherchons encore un livreur',
          'Votre commande ' || o.number || ' sera prise en charge dès qu''un livreur est disponible.', customer_route);
      when new.status = 'picked_up' then
        perform private.notify(o.customer_id, o, 'picked_up', 'Commande récupérée',
          courier_name || ' a récupéré votre commande ' || o.number || '.', customer_route);
      when new.status = 'in_transit' then
        perform private.notify(o.customer_id, o, 'in_transit', 'Votre livreur est en route',
          courier_name || ' arrive avec votre commande ' || o.number || '.', customer_route);
      when new.status = 'delivered' then
        perform private.notify(o.customer_id, o, 'delivered',
          case when o.type = 'parcel' then 'Colis livré' else 'Commande livrée' end,
          'Merci d''avoir commandé avec Tchopi.', customer_route);
      when new.status = 'cancelled' then
        perform private.notify(o.customer_id, o, 'cancelled', 'Commande annulée',
          'Votre commande ' || o.number || ' a été annulée.', customer_route);
      when new.status = 'failed' then
        perform private.notify(o.customer_id, o, 'failed', 'Échec de livraison',
          'L''équipe vous contacte pour la suite de la commande ' || o.number || '.', customer_route);
      else
        null;
    end case;
  end if;

  -- Livreur : mission attribuée par l'admin, commande prête, mission annulée.
  if o.courier_id is not null and new.actor_role <> 'courier' then
    if new.kind = 'courier_assigned' and new.actor_role = 'admin' then
      perform private.notify(o.courier_id, o, 'mission_assigned', 'Mission attribuée',
        o.number || ' : retrait à ' || o.pickup_district || '.', '/courier/missions/' || o.id);
    elsif new.status = 'ready' then
      perform private.notify(o.courier_id, o, 'order_ready', 'Commande prête',
        o.number || ' vous attend chez ' || o.pickup_name || '.', '/courier/missions/' || o.id);
    elsif new.status = 'cancelled' then
      perform private.notify(o.courier_id, o, 'mission_cancelled', 'Mission annulée',
        'La commande ' || o.number || ' a été annulée.', '/courier');
    end if;
  end if;

  -- Restaurant : nouvelle commande, annulation, prise en charge par un livreur, désistement, attente prolongée.
  if o.restaurant_id is not null and new.actor_role <> 'restaurant' then
    title := null;
    kind := new.kind;
    if new.status = 'pending' then
      title := 'Nouvelle commande';
      kind := 'new_order';
      body := o.number || ' · à accepter dans les 10 minutes.';
    elsif new.status = 'cancelled' then
      title := 'Commande annulée';
      kind := 'order_cancelled';
      body := o.number || ' a été annulée.';
    elsif new.kind = 'courier_assigned' then
      title := 'Livreur en route';
      body := courier_name || ' vient chercher la commande ' || o.number || '.';
    elsif new.kind = 'courier_released' then
      title := 'Livreur désisté';
      body := 'La commande ' || o.number || ' est reproposée aux livreurs.';
    elsif new.kind = 'dispatch_alert' then
      title := 'Toujours sans livreur';
      body := 'La commande ' || o.number || ' attend un livreur ; l''équipe est prévenue.';
    end if;
    if title is not null then
      for member in select user_id from public.restaurant_members
                     where restaurant_id = o.restaurant_id and user_id is not null loop
        perform private.notify(member, o, kind, title, body, '/restaurant/orders');
      end loop;
    end if;
  end if;
  return null;
end;
$$;

-- Notification de nouvelle commande à prendre (repas prêt ou colis), pour chaque livreur sollicité.
create or replace function private.notify_offer()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
begin
  select * into o from public.orders where id = new.order_id;
  perform private.notify(new.courier_id, o, 'offer',
    case when o.type = 'food' then 'Commande prête à récupérer' else 'Colis à récupérer' end,
    coalesce(o.pickup_name || ' · ', '') || o.pickup_district || ' → ' || o.dropoff_district
      || ' · +' || replace(to_char(o.courier_earning, 'FM999,999'), ',', ' ') || ' F', '/courier');
  return null;
end;
$$;

-- Tâche planifiée (10 s) : commandes en attente reproposées aux livreurs devenus disponibles, alerte après le délai,
-- annulation des seuls colis restés sans livreur (un repas prêt attend), puis les tâches existantes.
create or replace function private.tick()
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
  for r in select o.id from public.orders o
            where o.courier_id is null and o.dispatch_started_at is not null
              and o.status in ('ready', 'searching_courier')
  loop
    perform private.dispatch(r.id);
  end loop;

  with alerted as (
    update public.orders
       set dispatch_alerted_at = now()
     where courier_id is null and dispatch_alerted_at is null
       and status in ('ready', 'searching_courier')
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_alert_s)
    returning id
  )
  insert into public.order_events (order_id, kind, actor_role)
  select id, 'dispatch_alert', 'system' from alerted;

  with abandoned as (
    update public.orders
       set status = 'cancelled', closed_at = now(), close_reason = 'no_courier'
     where courier_id is null and type = 'parcel' and status = 'searching_courier'
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_cancel_s)
    returning id
  )
  insert into public.order_events (order_id, status, actor_role, reason)
  select id, 'cancelled', 'system', 'no_courier' from abandoned;

  perform private.reject_unanswered_orders();
  perform private.expire_payments();
  perform private.request_refunds();
  perform private.flush_notifications();
end;
$$;
