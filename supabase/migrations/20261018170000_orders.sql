-- Commandes de repas (Inc-5, docs/data-model.md §4 « Commandes », §5 machine à états, §7 API).
-- Les colonnes et statuts des colis et des livreurs sont prévus ici ; leurs actions arrivent avec les Inc-6 à 8.

create type public.order_status as enum (
  'awaiting_payment', 'pending', 'accepted', 'preparing', 'ready', 'searching_courier', 'courier_assigned',
  'picked_up', 'in_transit', 'delivered', 'rejected', 'cancelled', 'failed'
);
create type public.payment_method as enum ('cash', 'mobile_money', 'card');
create type public.order_payment_status as enum ('unpaid', 'paid', 'refund_pending', 'refunded');
create type public.actor_role as enum ('customer', 'restaurant', 'courier', 'admin', 'system');

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  number text not null unique,
  type public.order_type not null,
  status public.order_status not null,
  customer_id uuid not null references public.profiles (id),
  zone_id uuid not null references public.zones (id),
  currency text not null,
  restaurant_id uuid references public.restaurants (id),
  courier_id uuid references public.profiles (id),
  -- Retrait et destination figés au moment de la commande (repas : le restaurant, puis le client).
  pickup_lat double precision not null,
  pickup_lng double precision not null,
  pickup_name text not null,
  pickup_phone text,
  pickup_district text not null,
  pickup_landmark text not null,
  pickup_instructions text,
  dropoff_lat double precision not null,
  dropoff_lng double precision not null,
  recipient_name text not null,
  recipient_phone text,
  dropoff_district text not null,
  dropoff_landmark text not null,
  dropoff_instructions text,
  -- Montants figés, en unités de la devise.
  subtotal integer not null check (subtotal >= 0),
  delivery_fee integer not null check (delivery_fee >= 0),
  total integer not null,
  commission_amount integer not null check (commission_amount >= 0),
  courier_earning integer not null check (courier_earning >= 0),
  platform_amount integer not null,
  distance_m integer not null check (distance_m >= 0),
  payment_method public.payment_method not null,
  payment_status public.order_payment_status not null default 'unpaid',
  idempotency_key uuid not null,
  created_at timestamptz not null default now(),
  accepted_at timestamptz,
  ready_at timestamptz,
  picked_up_at timestamptz,
  delivered_at timestamptz,
  closed_at timestamptz,
  close_reason text,
  updated_at timestamptz not null default now(),
  unique (customer_id, idempotency_key),
  check (total = subtotal + delivery_fee),
  check (platform_amount = delivery_fee - courier_earning + commission_amount),
  check (type <> 'food' or (restaurant_id is not null and status not in ('searching_courier', 'courier_assigned')))
);
create index orders_customer_idx on public.orders (customer_id, created_at desc);
create index orders_restaurant_idx on public.orders (restaurant_id, created_at desc);
create index orders_pending_idx on public.orders (created_at) where status = 'pending';
create trigger orders_updated_at before update on public.orders
  for each row execute function private.set_updated_at();

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_id uuid not null references public.products (id),
  name text not null,
  unit_price integer not null check (unit_price > 0),
  quantity integer not null check (quantity between 1 and 50),
  line_total integer not null,
  check (line_total = unit_price * quantity)
);
create index order_items_order_idx on public.order_items (order_id);

-- Chronologie (TRK-03) : une ligne par changement, écrite dans la même transaction que le changement.
create table public.order_events (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders (id) on delete cascade,
  kind text not null default 'status_changed',
  status public.order_status,
  actor_id uuid,
  actor_role public.actor_role not null,
  reason text,
  created_at timestamptz not null default now()
);
create index order_events_order_idx on public.order_events (order_id, created_at);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_events enable row level security;

-- Le restaurant ne voit pas une commande dont le paiement n'est pas confirmé.
create policy "commandes : le client, le restaurant (hors paiement en attente) et l'admin" on public.orders
  for select to authenticated using (
    customer_id = auth.uid()
    or (status <> 'awaiting_payment' and private.is_member_of(restaurant_id))
    or private.is_admin()
  );
-- Les politiques des lignes s'appuient sur celle des commandes (la sous-requête est soumise à la RLS).
create policy "lignes : visibles avec la commande" on public.order_items
  for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id));
create policy "chronologie : visible avec la commande" on public.order_events
  for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id));
-- Aucune écriture directe : uniquement par les fonctions ci-dessous.
revoke all on public.orders, public.order_items, public.order_events from anon;
revoke insert, update, delete on public.orders, public.order_items, public.order_events from authenticated;

-- Numéro court lisible (« R-48K2Q ») ; alphabet sans caractères ambigus (0/O, 1/I).
create function private.new_order_number(p_prefix text)
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  alphabet constant text := '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  candidate text;
begin
  loop
    candidate := p_prefix || '-' || (
      select string_agg(substr(alphabet, 1 + floor(random() * length(alphabet))::integer, 1), '')
        from generate_series(1, 5)
    );
    exit when not exists (select 1 from public.orders where number = candidate);
  end loop;
  return candidate;
end;
$$;

create function private.log_order_event(
  p_order_id uuid, p_status public.order_status, p_role public.actor_role, p_reason text default null
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.order_events (order_id, status, actor_id, actor_role, reason)
  values (p_order_id, p_status, auth.uid(), p_role, p_reason);
$$;

-- Devis d'un panier (ORD-06, ORD-07) : prix et disponibilités actuels, frais selon la zone. Ne lève une erreur que
-- pour une requête invalide ; les écarts (restaurant fermé, produit indisponible) sont rendus dans « issues ».
-- p_items : [{"product_id": "…", "quantity": 2}, …]
create function private.food_quote(p_restaurant_id uuid, p_address_id uuid, p_items jsonb)
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

  select coalesce(jsonb_agg(jsonb_build_object(
           'product_id', i.product_id, 'name', p.name, 'unit_price', p.price, 'quantity', i.quantity,
           'line_total', coalesce(p.price, 0) * i.quantity,
           'available', p.id is not null and p.is_available) order by p.name), '[]'::jsonb),
         coalesce(sum(p.price * i.quantity) filter (where p.is_available), 0)
    into lines, subtotal
    from jsonb_to_recordset(p_items) as i (product_id uuid, quantity integer)
    left join public.products p
      on p.id = i.product_id and p.restaurant_id = r.id and p.archived_at is null;
  if exists (select 1 from jsonb_to_recordset(p_items) as i (product_id uuid, quantity integer)
              where i.quantity is null or i.quantity not between 1 and 50) then
    raise exception 'invalid_quantity' using errcode = 'P0001';
  end if;

  if not public.is_open(r) then
    issues := issues || jsonb_build_object('issue', 'restaurant_closed');
  end if;
  issues := issues || coalesce((
    select jsonb_agg(jsonb_build_object('issue', 'product_unavailable', 'product_id', l->>'product_id',
                                        'name', l->>'name'))
      from jsonb_array_elements(lines) l
     where not (l->>'available')::boolean), '[]'::jsonb);

  select * into fee from private.price_delivery(r.zone_id, 'food',
    extensions.st_distance(r.location, a.location));
  if fee is null then
    raise exception 'zone_unavailable' using errcode = 'P0001';
  end if;

  return jsonb_build_object(
    'currency', (select currency from public.zones where id = r.zone_id),
    'items', lines,
    'subtotal', subtotal,
    'delivery_fee', fee.delivery_fee,
    'total', subtotal + fee.delivery_fee,
    'distance_m', fee.distance_m,
    'courier_earning', fee.courier_earning,
    'issues', issues
  );
end;
$$;

create function public.quote_food_order(p_restaurant_id uuid, p_address_id uuid, p_items jsonb)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select private.food_quote(p_restaurant_id, p_address_id, p_items) - 'courier_earning';
$$;
revoke all on function public.quote_food_order(uuid, uuid, jsonb) from public, anon;
grant execute on function public.quote_food_order(uuid, uuid, jsonb) to authenticated;

-- ORD-07 : création après revérification complète. Une même clé d'idempotence rend la commande déjà créée
-- (double toucher, coupure réseau). Espèces : transmise au restaurant tout de suite ; Mobile Money et carte : Inc-11 / 12.
-- La vérification « livreurs en ligne » arrive avec la mise en ligne des livreurs (Inc-7, ADR-020).
create function public.place_food_order(
  p_restaurant_id uuid,
  p_address_id uuid,
  p_items jsonb,
  p_payment_method public.payment_method,
  p_expected_total integer,
  p_idempotency_key uuid
)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  existing public.orders;
  result public.orders;
  q jsonb;
  r public.restaurants;
  a public.addresses;
  me public.profiles;
  commission integer;
begin
  select * into existing from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
  if existing.id is not null then
    return existing;
  end if;
  if p_payment_method <> 'cash' then
    raise exception 'payment_unavailable' using errcode = 'P0001';
  end if;

  q := private.food_quote(p_restaurant_id, p_address_id, p_items);
  if jsonb_array_length(q->'issues') > 0 then
    raise exception 'cart_changed' using errcode = 'P0001';
  end if;
  if (q->>'total')::integer <> p_expected_total then
    raise exception 'price_changed' using errcode = 'P0001';
  end if;

  select * into r from public.restaurants where id = p_restaurant_id;
  select * into a from public.addresses where id = p_address_id;
  select * into me from public.profiles where id = auth.uid();
  commission := round((q->>'subtotal')::integer * r.commission_rate / 100)::integer;

  insert into public.orders (
    number, type, status, customer_id, zone_id, currency, restaurant_id,
    pickup_lat, pickup_lng, pickup_name, pickup_phone, pickup_district, pickup_landmark,
    dropoff_lat, dropoff_lng, recipient_name, recipient_phone, dropoff_district, dropoff_landmark, dropoff_instructions,
    subtotal, delivery_fee, total, commission_amount, courier_earning, platform_amount, distance_m,
    payment_method, idempotency_key
  ) values (
    private.new_order_number('R'), 'food', 'pending', auth.uid(), r.zone_id, q->>'currency', r.id,
    r.latitude, r.longitude, r.name, r.phone, r.district, r.landmark,
    a.latitude, a.longitude, coalesce(nullif(btrim(concat_ws(' ', me.first_name, me.last_name)), ''), 'Client'),
    me.phone, a.district, a.landmark, a.instructions,
    (q->>'subtotal')::integer, (q->>'delivery_fee')::integer, (q->>'total')::integer, commission,
    (q->>'courier_earning')::integer,
    (q->>'delivery_fee')::integer - (q->>'courier_earning')::integer + commission,
    (q->>'distance_m')::integer, p_payment_method, p_idempotency_key
  )
  on conflict (customer_id, idempotency_key) do nothing
  returning * into result;
  if result.id is null then
    -- Requête concurrente avec la même clé : elle a déjà créé la commande.
    select * into result from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
    return result;
  end if;

  insert into public.order_items (order_id, product_id, name, unit_price, quantity, line_total)
  select result.id, (l->>'product_id')::uuid, l->>'name', (l->>'unit_price')::integer, (l->>'quantity')::integer,
         (l->>'line_total')::integer
    from jsonb_array_elements(q->'items') l;
  perform private.log_order_event(result.id, 'pending', 'customer');
  return result;
end;
$$;
revoke all on function public.place_food_order(uuid, uuid, jsonb, public.payment_method, integer, uuid)
  from public, anon;
grant execute on function public.place_food_order(uuid, uuid, jsonb, public.payment_method, integer, uuid)
  to authenticated;

-- ORD-11 : le client annule tant que le restaurant n'a pas accepté ; l'admin annule ensuite, avec un motif.
create function public.cancel_order(p_order_id uuid, p_reason text default null)
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
  if o.status in ('pending', 'awaiting_payment') then
    null;
  elsif admin and o.status in ('accepted', 'preparing', 'ready') then
    if reason is null then
      raise exception 'reason_required' using errcode = 'P0001';
    end if;
  elsif o.status in ('accepted', 'preparing', 'ready') then
    raise exception 'already_accepted' using errcode = 'P0001';
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
revoke all on function public.cancel_order(uuid, text) from public, anon;
grant execute on function public.cancel_order(uuid, text) to authenticated;

-- ORD-09, ORD-10 : actions du restaurant (et de l'admin). La remise au livreur (ready → picked_up) arrive à l'Inc-8.
create function public.transition_order(p_order_id uuid, p_to_status public.order_status, p_reason text default null)
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
    ('accepted', 'preparing'), ('preparing', 'ready')
  ) then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  if p_to_status = 'rejected' and reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  update public.orders
     set status = p_to_status,
         accepted_at = case when p_to_status = 'accepted' then now() else accepted_at end,
         ready_at = case when p_to_status = 'ready' then now() else ready_at end,
         closed_at = case when p_to_status = 'rejected' then now() else closed_at end,
         close_reason = case when p_to_status = 'rejected' then reason else close_reason end
   where id = o.id
  returning * into o;
  perform private.log_order_event(o.id, p_to_status, case when admin and not private.is_member_of(o.restaurant_id)
                                                          then 'admin' else 'restaurant' end::public.actor_role, reason);
  return o;
end;
$$;
revoke all on function public.transition_order(uuid, public.order_status, text) from public, anon;
grant execute on function public.transition_order(uuid, public.order_status, text) to authenticated;

-- ORD-08 : refus automatique après 10 minutes sans réponse du restaurant (tâche planifiée chaque minute).
create function private.reject_unanswered_orders()
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
     where status = 'pending' and created_at < now() - interval '10 minutes'
    returning id
  ), events as (
    insert into public.order_events (order_id, status, actor_role, reason)
    select id, 'rejected', 'system', 'no_response' from expired
  )
  select count(*) into rejected from expired;
  return rejected;
end;
$$;

create extension if not exists pg_cron;
select cron.schedule('reject-unanswered-orders', '* * * * *', 'select private.reject_unanswered_orders()');

-- Temps réel : nouvelles commandes côté restaurant, suivi côté client (filtré par la RLS).
alter publication supabase_realtime add table public.orders, public.order_events;
