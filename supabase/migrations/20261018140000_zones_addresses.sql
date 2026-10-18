-- Zones desservies, règles tarifaires et adresses (Inc-2, docs/data-model.md §4 et plan H-02 à H-04).

create extension if not exists postgis with schema extensions;

create type public.order_type as enum ('food', 'parcel');

create table public.zones (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 2 and 60),
  city text not null check (char_length(btrim(city)) between 2 and 60),
  country_code text not null default 'CI' check (country_code ~ '^[A-Z]{2}$'),
  currency text not null default 'XOF' check (currency ~ '^[A-Z]{3}$'),
  timezone text not null default 'Africa/Abidjan',
  center_lat double precision not null check (center_lat between -90 and 90),
  center_lng double precision not null check (center_lng between -180 and 180),
  center extensions.geography(Point, 4326)
    generated always as (extensions.st_point(center_lng, center_lat, 4326)::extensions.geography) stored,
  radius_m integer not null check (radius_m between 500 and 100000),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index zones_center_idx on public.zones using gist (center);
create trigger zones_updated_at before update on public.zones
  for each row execute function private.set_updated_at();

-- Montants en unités de la devise (XOF : sans décimales).
create table public.pricing_rules (
  zone_id uuid not null references public.zones (id) on delete cascade,
  service public.order_type not null,
  base_fee integer not null check (base_fee >= 0),
  per_km_fee integer not null check (per_km_fee >= 0),
  min_fee integer not null check (min_fee >= 0),
  max_fee integer not null,
  detour_factor numeric(3, 2) not null default 1.30 check (detour_factor between 1 and 3),
  rounding_step integer not null default 25 check (rounding_step between 1 and 1000),
  courier_base integer not null check (courier_base >= 0),
  courier_per_km integer not null check (courier_per_km >= 0),
  updated_at timestamptz not null default now(),
  primary key (zone_id, service),
  check (min_fee <= max_fee)
);
create trigger pricing_rules_updated_at before update on public.pricing_rules
  for each row execute function private.set_updated_at();

create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  zone_id uuid not null references public.zones (id),
  city text not null,
  label text not null default 'Maison' check (char_length(btrim(label)) between 1 and 30),
  district text not null check (char_length(btrim(district)) between 2 and 80),
  landmark text not null check (char_length(btrim(landmark)) between 3 and 160),
  instructions text check (char_length(instructions) <= 300),
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  location extensions.geography(Point, 4326)
    generated always as (extensions.st_point(longitude, latitude, 4326)::extensions.geography) stored,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index addresses_user_idx on public.addresses (user_id);
create unique index addresses_one_default_idx on public.addresses (user_id) where is_default;
create trigger addresses_updated_at before update on public.addresses
  for each row execute function private.set_updated_at();

-- Zone active qui contient le point ; la plus proche si plusieurs se chevauchent.
create function private.zone_at(lat double precision, lng double precision)
returns public.zones
language sql
stable
security definer
set search_path = ''
as $$
  select z.*
    from public.zones z
   where z.is_active
     and extensions.st_dwithin(z.center, extensions.st_point(lng, lat, 4326)::extensions.geography, z.radius_m)
   order by extensions.st_distance(z.center, extensions.st_point(lng, lat, 4326)::extensions.geography)
   limit 1;
$$;
-- Utilisée par le déclencheur des adresses, exécuté avec les droits de l'utilisateur.
grant execute on function private.zone_at(double precision, double precision) to authenticated;

-- Zone et ville déduites de la position (jamais saisies) ; adresse hors zone refusée (ADR-03).
-- La première adresse devient l'adresse par défaut ; une nouvelle adresse par défaut remplace l'ancienne (ADR-05).
create function private.prepare_address()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  zone public.zones;
begin
  if tg_op = 'INSERT' or (new.latitude, new.longitude) is distinct from (old.latitude, old.longitude) then
    zone := private.zone_at(new.latitude, new.longitude);
    if zone.id is null then
      raise exception 'address_out_of_zone' using errcode = 'P0001';
    end if;
    new.zone_id := zone.id;
    new.city := zone.city;
  end if;
  if tg_op = 'INSERT' and not exists (select 1 from public.addresses where user_id = new.user_id) then
    new.is_default := true;
  end if;
  if new.is_default and (tg_op = 'INSERT' or not old.is_default) then
    update public.addresses set is_default = false where user_id = new.user_id and is_default and id <> new.id;
  end if;
  return new;
end;
$$;
create trigger addresses_prepare before insert or update on public.addresses
  for each row execute function private.prepare_address();

-- Suppression de l'adresse par défaut : la plus récente restante prend le relais (ADR-04).
create function private.promote_default_address()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.is_default then
    update public.addresses set is_default = true
     where id = (select id from public.addresses where user_id = old.user_id order by created_at desc limit 1);
  end if;
  return null;
end;
$$;
create trigger addresses_promote_default after delete on public.addresses
  for each row execute function private.promote_default_address();

alter table public.zones enable row level security;
alter table public.pricing_rules enable row level security;
alter table public.addresses enable row level security;

create policy "zones : actives visibles par tous les comptes, toutes par les admins" on public.zones
  for select to authenticated using (is_active or private.is_admin());
create policy "zones : gérées par les admins" on public.zones
  for all to authenticated using (private.is_admin()) with check (private.is_admin());

create policy "tarifs : gérés par les admins" on public.pricing_rules
  for all to authenticated using (private.is_admin()) with check (private.is_admin());

create policy "adresses : lues par leur titulaire ou un admin" on public.addresses
  for select to authenticated using (user_id = auth.uid() or private.is_admin());
create policy "adresses : créées par leur titulaire" on public.addresses
  for insert to authenticated with check (user_id = auth.uid());
create policy "adresses : modifiées par leur titulaire" on public.addresses
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "adresses : supprimées par leur titulaire" on public.addresses
  for delete to authenticated using (user_id = auth.uid());

-- Zone et ville sont calculées par la base : non modifiables depuis les apps.
revoke insert, update on public.addresses from anon, authenticated;
grant insert (label, district, landmark, instructions, latitude, longitude, is_default) on public.addresses to authenticated;
grant update (label, district, landmark, instructions, latitude, longitude, is_default) on public.addresses to authenticated;
revoke all on public.zones, public.pricing_rules, public.addresses from anon;

-- Calcul des frais (H-03, H-04) : distance de référence = vol d'oiseau × détour ; frais arrondis au pas supérieur
-- puis bornés ; rémunération du livreur arrondie au même pas. Seule source de vérité des montants de livraison.
create function private.price_delivery(p_zone_id uuid, p_service public.order_type, p_straight_m double precision)
returns table (distance_m integer, delivery_fee integer, courier_earning integer)
language sql
stable
security definer
set search_path = ''
as $$
  select d.distance_m,
         least(r.max_fee, greatest(r.min_fee,
           (ceil((r.base_fee + r.per_km_fee * d.distance_m / 1000.0) / r.rounding_step) * r.rounding_step)::integer)),
         (ceil((r.courier_base + r.courier_per_km * d.distance_m / 1000.0) / r.rounding_step) * r.rounding_step)::integer
    from public.pricing_rules r
   cross join lateral (select round(p_straight_m * r.detour_factor)::integer as distance_m) d
   where r.zone_id = p_zone_id and r.service = p_service;
$$;

-- Simulateur de l'écran Zones et tarifs (A-08) : vérifier une règle avant de l'appliquer.
create function public.admin_simulate_fee(p_zone_id uuid, p_service public.order_type, p_straight_km numeric)
returns table (distance_m integer, delivery_fee integer, courier_earning integer)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  return query select * from private.price_delivery(p_zone_id, p_service, p_straight_km * 1000);
end;
$$;
revoke all on function public.admin_simulate_fee(uuid, public.order_type, numeric) from public, anon;
grant execute on function public.admin_simulate_fee(uuid, public.order_type, numeric) to authenticated;
