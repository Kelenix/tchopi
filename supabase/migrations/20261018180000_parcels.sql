-- Livraison de colis (Inc-6, docs/data-model.md §4, §5 et §7) et codes de livraison (PAR-04, MIS-06).

create table public.parcel_types (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  label text not null,
  max_weight_kg numeric(4, 1) not null check (max_weight_kg > 0),
  allowed_vehicles public.vehicle_type[] not null,
  position integer not null default 0,
  is_active boolean not null default true
);
alter table public.parcel_types enable row level security;
create policy "types de colis : lus par tous les comptes" on public.parcel_types
  for select to authenticated using (true);
create policy "types de colis : gérés par les admins" on public.parcel_types
  for all to authenticated using (private.is_admin()) with check (private.is_admin());
revoke all on public.parcel_types from anon;

insert into public.parcel_types (code, label, max_weight_kg, allowed_vehicles, position) values
  ('documents', 'Documents', 1, '{motorbike,bicycle,car,on_foot}', 0),
  ('small', 'Petit colis (5 kg max.)', 5, '{motorbike,bicycle,car}', 1),
  ('medium', 'Colis moyen (15 kg max.)', 15, '{motorbike,car}', 2);

alter table public.orders
  add column parcel_type_id uuid references public.parcel_types (id),
  add column parcel_description text check (char_length(parcel_description) <= 300),
  add constraint orders_parcel_check check (
    type <> 'parcel'
    or (restaurant_id is null and parcel_type_id is not null
        and status not in ('pending', 'accepted', 'preparing', 'ready', 'rejected'))
  );

-- Code à 4 chiffres remis au livreur par le destinataire ; lisible seulement par le client et l'admin.
create table public.delivery_codes (
  order_id uuid primary key references public.orders (id) on delete cascade,
  code text not null check (code ~ '^[0-9]{4}$'),
  failed_attempts integer not null default 0,
  locked_at timestamptz
);
alter table public.delivery_codes enable row level security;
create policy "codes : lus par le client de la commande et l'admin" on public.delivery_codes
  for select to authenticated using (
    private.is_admin()
    or exists (select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid())
  );
revoke all on public.delivery_codes from anon;
revoke insert, update, delete on public.delivery_codes from authenticated;

create function private.create_delivery_code()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.delivery_codes (order_id, code)
  values (new.id, lpad((floor(random() * 10000))::integer::text, 4, '0'));
  return new;
end;
$$;
create trigger orders_delivery_code after insert on public.orders
  for each row execute function private.create_delivery_code();
insert into public.delivery_codes (order_id, code)
select id, lpad((floor(random() * 10000))::integer::text, 4, '0') from public.orders;

-- PAR-01 / PAR-02 : départ et arrivée distincts (100 m au moins, l'arrivée part du départ sur la carte),
-- dans une même zone active ; frais selon les règles « colis ».
create function private.parcel_quote(
  p_pickup_lat double precision,
  p_pickup_lng double precision,
  p_dropoff_lat double precision,
  p_dropoff_lng double precision,
  p_parcel_type_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  pickup_zone public.zones;
  dropoff_zone public.zones;
  straight_m double precision;
  fee record;
begin
  if auth.uid() is null or exists (select 1 from public.profiles where id = auth.uid() and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.parcel_types where id = p_parcel_type_id and is_active) then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  pickup_zone := private.zone_at(p_pickup_lat, p_pickup_lng);
  dropoff_zone := private.zone_at(p_dropoff_lat, p_dropoff_lng);
  if pickup_zone.id is null or dropoff_zone.id is null then
    raise exception 'address_out_of_zone' using errcode = 'P0001';
  end if;
  if pickup_zone.id <> dropoff_zone.id then
    raise exception 'different_zones' using errcode = 'P0001';
  end if;
  straight_m := extensions.st_distance(
    extensions.st_point(p_pickup_lng, p_pickup_lat, 4326)::extensions.geography,
    extensions.st_point(p_dropoff_lng, p_dropoff_lat, 4326)::extensions.geography);
  if straight_m < 100 then
    raise exception 'same_location' using errcode = 'P0001';
  end if;
  select * into fee from private.price_delivery(pickup_zone.id, 'parcel', straight_m);
  if fee is null then
    raise exception 'zone_unavailable' using errcode = 'P0001';
  end if;
  return jsonb_build_object(
    'zone_id', pickup_zone.id,
    'currency', pickup_zone.currency,
    'subtotal', 0,
    'delivery_fee', fee.delivery_fee,
    'total', fee.delivery_fee,
    'distance_m', fee.distance_m,
    'courier_earning', fee.courier_earning,
    'issues', '[]'::jsonb
  );
end;
$$;

create function public.quote_parcel(
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
  select private.parcel_quote(p_pickup_lat, p_pickup_lng, p_dropoff_lat, p_dropoff_lng, p_parcel_type_id)
         - 'courier_earning' - 'zone_id';
$$;
revoke all on function public.quote_parcel(double precision, double precision, double precision, double precision, uuid)
  from public, anon;
grant execute on function public.quote_parcel(double precision, double precision, double precision, double precision, uuid)
  to authenticated;

-- PAR-03 : demande enregistrée telle qu'affichée ; même clé d'idempotence = même demande. Espèces : payées au livreur
-- à la récupération. La vérification des livreurs en ligne arrive avec l'Inc-7 (ADR-020).
-- p_pickup / p_dropoff : {"lat", "lng", "district", "landmark", "instructions"}.
create function public.place_parcel_order(
  p_pickup jsonb,
  p_dropoff jsonb,
  p_recipient_name text,
  p_recipient_phone text,
  p_parcel_type_id uuid,
  p_description text,
  p_rules_accepted boolean,
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
  me public.profiles;
  recipient text := nullif(btrim(p_recipient_name), '');
  description text := nullif(btrim(p_description), '');
begin
  select * into existing from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
  if existing.id is not null then
    return existing;
  end if;
  if p_payment_method <> 'cash' then
    raise exception 'payment_unavailable' using errcode = 'P0001';
  end if;
  if not coalesce(p_rules_accepted, false) then
    raise exception 'rules_not_accepted' using errcode = 'P0001';
  end if;
  if recipient is null or char_length(recipient) > 80 or coalesce(p_recipient_phone, '') !~ '^\+[1-9][0-9]{7,14}$' then
    raise exception 'invalid_recipient' using errcode = 'P0001';
  end if;
  if char_length(btrim(coalesce(p_pickup->>'district', ''))) < 2 or char_length(btrim(coalesce(p_pickup->>'landmark', ''))) < 3
     or char_length(btrim(coalesce(p_dropoff->>'district', ''))) < 2 or char_length(btrim(coalesce(p_dropoff->>'landmark', ''))) < 3
  then
    raise exception 'invalid_address' using errcode = 'P0001';
  end if;

  q := private.parcel_quote((p_pickup->>'lat')::double precision, (p_pickup->>'lng')::double precision,
                            (p_dropoff->>'lat')::double precision, (p_dropoff->>'lng')::double precision,
                            p_parcel_type_id);
  if (q->>'total')::integer <> p_expected_total then
    raise exception 'price_changed' using errcode = 'P0001';
  end if;
  select * into me from public.profiles where id = auth.uid();

  insert into public.orders (
    number, type, status, customer_id, zone_id, currency, parcel_type_id, parcel_description,
    pickup_lat, pickup_lng, pickup_name, pickup_phone, pickup_district, pickup_landmark, pickup_instructions,
    dropoff_lat, dropoff_lng, recipient_name, recipient_phone, dropoff_district, dropoff_landmark, dropoff_instructions,
    subtotal, delivery_fee, total, commission_amount, courier_earning, platform_amount, distance_m,
    payment_method, idempotency_key
  ) values (
    private.new_order_number('C'), 'parcel', 'searching_courier', auth.uid(), (q->>'zone_id')::uuid, q->>'currency',
    p_parcel_type_id, description,
    (p_pickup->>'lat')::double precision, (p_pickup->>'lng')::double precision,
    coalesce(nullif(btrim(concat_ws(' ', me.first_name, me.last_name)), ''), 'Expéditeur'), me.phone,
    btrim(p_pickup->>'district'), btrim(p_pickup->>'landmark'), nullif(btrim(p_pickup->>'instructions'), ''),
    (p_dropoff->>'lat')::double precision, (p_dropoff->>'lng')::double precision, recipient, p_recipient_phone,
    btrim(p_dropoff->>'district'), btrim(p_dropoff->>'landmark'), nullif(btrim(p_dropoff->>'instructions'), ''),
    0, (q->>'delivery_fee')::integer, (q->>'total')::integer, 0, (q->>'courier_earning')::integer,
    (q->>'delivery_fee')::integer - (q->>'courier_earning')::integer, (q->>'distance_m')::integer,
    p_payment_method, p_idempotency_key
  )
  on conflict (customer_id, idempotency_key) do nothing
  returning * into result;
  if result.id is null then
    select * into result from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
    return result;
  end if;
  perform private.log_order_event(result.id, 'searching_courier', 'customer');
  return result;
end;
$$;
revoke all on function public.place_parcel_order(jsonb, jsonb, text, text, uuid, text, boolean, public.payment_method,
  integer, uuid) from public, anon;
grant execute on function public.place_parcel_order(jsonb, jsonb, text, text, uuid, text, boolean, public.payment_method,
  integer, uuid) to authenticated;

-- ORD-11 et PAR-05 : le client annule un repas avant acceptation et un colis avant récupération ;
-- l'admin annule ensuite, avec un motif. Les offres et missions des livreurs seront retirées à l'Inc-7.
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
  elsif admin and o.status in ('accepted', 'preparing', 'ready') then
    if reason is null then
      raise exception 'reason_required' using errcode = 'P0001';
    end if;
  elsif o.status in ('accepted', 'preparing', 'ready') then
    raise exception 'already_accepted' using errcode = 'P0001';
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
