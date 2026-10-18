-- Restaurants partenaires, gérants, horaires, catalogue (Inc-4, docs/data-model.md §4 « Restaurants et catalogue »).

create table public.restaurants (
  id uuid primary key default gen_random_uuid(),
  zone_id uuid not null references public.zones (id),
  name text not null check (char_length(btrim(name)) between 2 and 80),
  description text check (char_length(description) <= 500),
  category text check (char_length(btrim(category)) between 2 and 40), -- ex. « Maquis ivoirien »
  cover_path text,
  phone text not null check (phone ~ '^\+[1-9][0-9]{7,14}$'),
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  location extensions.geography(Point, 4326)
    generated always as (extensions.st_point(longitude, latitude, 4326)::extensions.geography) stored,
  district text not null check (char_length(btrim(district)) between 2 and 80),
  landmark text not null check (char_length(btrim(landmark)) between 3 and 160),
  commission_rate numeric(5, 2) not null default 15 check (commission_rate between 0 and 100),
  prep_time_min integer not null default 20 check (prep_time_min between 5 and 120),
  is_active boolean not null default true,
  is_temporarily_closed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index restaurants_zone_idx on public.restaurants (zone_id);
create index restaurants_location_idx on public.restaurants using gist (location);
create trigger restaurants_updated_at before update on public.restaurants
  for each row execute function private.set_updated_at();

-- Gérants : invitation par email ou numéro, reliée au compte dès qu'il existe (et est vérifié).
create table public.restaurant_members (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  user_id uuid references public.profiles (id) on delete cascade,
  login_email text check (login_email = lower(login_email)),
  login_phone text check (login_phone ~ '^\+[1-9][0-9]{7,14}$'),
  created_at timestamptz not null default now(),
  check (num_nonnulls(login_email, login_phone) = 1)
);
create unique index restaurant_members_user_idx on public.restaurant_members (restaurant_id, user_id);
create index restaurant_members_lookup_idx on public.restaurant_members (user_id);

-- Plages d'ouverture en heure locale de la zone ; jour ISO (1 = lundi … 7 = dimanche).
create table public.opening_hours (
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  weekday smallint not null check (weekday between 1 and 7),
  opens_at time not null,
  closes_at time not null check (closes_at > opens_at),
  primary key (restaurant_id, weekday, opens_at)
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 40),
  position integer not null default 0,
  unique (restaurant_id, name)
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  category_id uuid references public.categories (id) on delete set null,
  name text not null check (char_length(btrim(name)) between 2 and 80),
  description text check (char_length(description) <= 300),
  price integer not null check (price > 0),
  photo_path text,
  is_available boolean not null default true,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index products_restaurant_idx on public.products (restaurant_id, category_id);
create trigger products_updated_at before update on public.products
  for each row execute function private.set_updated_at();

create function private.is_member_of(p_restaurant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.restaurant_members where restaurant_id = p_restaurant_id and user_id = auth.uid()
  );
$$;
grant execute on function private.is_member_of(uuid) to authenticated;

-- Ouvert maintenant (RES-03) : actif, non fermé temporairement, dans une plage du jour, à l'heure de la zone.
-- Exposé comme champ calculé : select=*,is_open
create function public.is_open(r public.restaurants)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select r.is_active and not r.is_temporarily_closed and exists (
    select 1
      from public.opening_hours h
      join public.zones z on z.id = r.zone_id
      cross join lateral (select now() at time zone z.timezone as local) t
     where h.restaurant_id = r.id
       and h.weekday = extract(isodow from t.local)
       and t.local::time >= h.opens_at and t.local::time < h.closes_at
  );
$$;
grant execute on function public.is_open(public.restaurants) to authenticated;

alter table public.restaurants enable row level security;
alter table public.restaurant_members enable row level security;
alter table public.opening_hours enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;

create policy "restaurants : actifs visibles, les siens et tous pour un admin" on public.restaurants
  for select to authenticated using (is_active or private.is_member_of(id) or private.is_admin());
create policy "restaurants : profil modifié par ses gérants" on public.restaurants
  for update to authenticated using (private.is_member_of(id)) with check (private.is_member_of(id));
-- Zone, position, commission et activation : réservées à l'admin (fonction admin_save_restaurant).
revoke insert, update, delete on public.restaurants from anon, authenticated;
grant update (description, category, cover_path, phone, prep_time_min, is_temporarily_closed)
  on public.restaurants to authenticated;

create policy "gérants : chacun voit ses accès, l'admin tous" on public.restaurant_members
  for select to authenticated using (user_id = auth.uid() or private.is_admin());
revoke insert, update, delete on public.restaurant_members from anon, authenticated;

create policy "horaires : visibles avec le restaurant" on public.opening_hours
  for select to authenticated using (
    exists (select 1 from public.restaurants r where r.id = restaurant_id)
  );
revoke insert, update, delete on public.opening_hours from anon, authenticated;

create policy "catégories : visibles avec le restaurant" on public.categories
  for select to authenticated using (exists (select 1 from public.restaurants r where r.id = restaurant_id));
create policy "catégories : gérées par les gérants ou un admin" on public.categories
  for all to authenticated
  using (private.is_member_of(restaurant_id) or private.is_admin())
  with check (private.is_member_of(restaurant_id) or private.is_admin());

create policy "produits : non archivés visibles avec le restaurant ; tous pour ses gérants" on public.products
  for select to authenticated using (
    (archived_at is null and exists (select 1 from public.restaurants r where r.id = restaurant_id))
    or private.is_member_of(restaurant_id) or private.is_admin()
  );
create policy "produits : gérés par les gérants ou un admin" on public.products
  for insert to authenticated with check (private.is_member_of(restaurant_id) or private.is_admin());
create policy "produits : modifiés par les gérants ou un admin" on public.products
  for update to authenticated
  using (private.is_member_of(restaurant_id) or private.is_admin())
  with check (private.is_member_of(restaurant_id) or private.is_admin());
-- Pas de suppression : un produit est archivé (l'historique des commandes y fait référence).
revoke delete on public.products from anon, authenticated;
revoke all on public.restaurants, public.restaurant_members, public.opening_hours, public.categories, public.products from anon;

-- Horaires remplacés en une fois par un gérant ou un admin (R-05).
create function public.save_opening_hours(p_restaurant_id uuid, p_hours jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not (private.is_member_of(p_restaurant_id) or private.is_admin()) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  delete from public.opening_hours where restaurant_id = p_restaurant_id;
  insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
  select p_restaurant_id, (h ->> 'weekday')::smallint, (h ->> 'opens_at')::time, (h ->> 'closes_at')::time
    from jsonb_array_elements(p_hours) h;
end;
$$;
revoke all on function public.save_opening_hours(uuid, jsonb) from public, anon;
grant execute on function public.save_opening_hours(uuid, jsonb) to authenticated;

-- RES-01 : création / modification d'un restaurant par l'admin (zone, position, commission, activation compris).
create function public.admin_save_restaurant(
  p_id uuid,
  p_zone_id uuid,
  p_name text,
  p_description text,
  p_category text,
  p_phone text,
  p_latitude double precision,
  p_longitude double precision,
  p_district text,
  p_landmark text,
  p_commission_rate numeric,
  p_is_active boolean
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  saved_id uuid;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  insert into public.restaurants as r (
    id, zone_id, name, description, category, phone, latitude, longitude, district, landmark, commission_rate, is_active
  )
  values (
    coalesce(p_id, gen_random_uuid()), p_zone_id, btrim(p_name), nullif(btrim(p_description), ''),
    nullif(btrim(p_category), ''), p_phone, p_latitude, p_longitude, btrim(p_district), btrim(p_landmark),
    p_commission_rate, p_is_active
  )
  on conflict (id) do update
    set zone_id = excluded.zone_id, name = excluded.name, description = excluded.description,
        category = excluded.category, phone = excluded.phone, latitude = excluded.latitude,
        longitude = excluded.longitude, district = excluded.district, landmark = excluded.landmark,
        commission_rate = excluded.commission_rate, is_active = excluded.is_active
  returning r.id into saved_id;
  perform private.audit('restaurant_saved', 'restaurant', saved_id,
                        jsonb_build_object('commission_rate', p_commission_rate, 'is_active', p_is_active));
  return saved_id;
end;
$$;
revoke all on function public.admin_save_restaurant(uuid, uuid, text, text, text, text, double precision, double precision, text, text, numeric, boolean) from public, anon;
grant execute on function public.admin_save_restaurant(uuid, uuid, text, text, text, text, double precision, double precision, text, text, numeric, boolean) to authenticated;

-- Invitation d'un gérant par email ou numéro ; reliée immédiatement si le compte existe déjà.
create function public.admin_invite_member(p_restaurant_id uuid, p_email text, p_phone text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_email text := lower(nullif(btrim(p_email), ''));
  v_phone text := nullif(btrim(p_phone), '');
  existing uuid;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  select u.id into existing from auth.users u
   where (v_email is not null and lower(u.email) = v_email)
      or (v_phone is not null and '+' || u.phone = v_phone)
   limit 1;
  insert into public.restaurant_members (restaurant_id, user_id, login_email, login_phone)
  values (p_restaurant_id, existing, v_email, v_phone)
  on conflict (restaurant_id, user_id) do nothing;
  perform private.audit('member_invited', 'restaurant', p_restaurant_id,
                        jsonb_build_object('channel', case when v_email is not null then 'email' else 'phone' end));
end;
$$;
revoke all on function public.admin_invite_member(uuid, text, text) from public, anon;
grant execute on function public.admin_invite_member(uuid, text, text) to authenticated;

create function public.admin_remove_member(p_member_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  delete from public.restaurant_members where id = p_member_id;
end;
$$;
revoke all on function public.admin_remove_member(uuid) from public, anon;
grant execute on function public.admin_remove_member(uuid) to authenticated;

-- Liaison des invitations quand le compte invité vérifie son email ou son numéro.
create function private.link_restaurant_invites()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.restaurant_members m
     set user_id = new.id
   where m.user_id is null
     and ((new.email_confirmed_at is not null and m.login_email = lower(new.email))
       or (new.phone_confirmed_at is not null and m.login_phone = '+' || new.phone))
     and not exists (
       select 1 from public.restaurant_members o where o.restaurant_id = m.restaurant_id and o.user_id = new.id
     );
  return new;
end;
$$;
create trigger on_auth_user_verified after insert or update of email_confirmed_at, phone_confirmed_at, email, phone
  on auth.users for each row execute function private.link_restaurant_invites();

-- Rôles du compte : ajout des restaurants gérés (espace Restaurant).
create or replace function public.my_roles()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'is_admin', private.is_admin(),
    'courier_status', (select status from public.couriers where user_id = auth.uid()),
    'restaurant_ids', coalesce(
      (select jsonb_agg(restaurant_id order by created_at) from public.restaurant_members where user_id = auth.uid()),
      '[]'::jsonb
    )
  );
$$;

-- Photos publiques (couvertures, produits) : lecture libre, écriture par les gérants du restaurant et l'admin.
-- Chemins : restaurants/<restaurant_id>/…
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media', 'media', true, 2097152, array['image/jpeg', 'image/png', 'image/webp']);

create policy "médias restaurants : dépôt par les gérants ou un admin" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'media' and (storage.foldername(name))[1] = 'restaurants'
    and (private.is_member_of(((storage.foldername(name))[2])::uuid) or private.is_admin())
  );
create policy "médias restaurants : remplacement par les gérants ou un admin" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'media' and (storage.foldername(name))[1] = 'restaurants'
    and (private.is_member_of(((storage.foldername(name))[2])::uuid) or private.is_admin())
  );
