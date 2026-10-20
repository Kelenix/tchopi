-- Plateforme web (tchopi-web, ADR-042) : magasins, options de produits, catalogue public en lecture seule et
-- candidatures d'établissements. Ajouts au backend commun : le mobile et le web restent sur les mêmes données.

-- 1. Magasins : même circuit de commande que les restaurants (préparation, « Prête », livreur).
alter table public.restaurants
  add column kind text not null default 'restaurant' check (kind in ('restaurant', 'shop'));

drop function public.admin_save_restaurant(uuid, uuid, text, text, text, text, double precision, double precision, text, text, numeric, boolean);
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
  p_is_active boolean,
  -- Absent (app mobile) : type inchangé, « restaurant » à la création.
  p_kind text default null
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
    id, zone_id, name, description, category, phone, latitude, longitude, district, landmark, commission_rate, is_active,
    kind
  )
  values (
    coalesce(p_id, gen_random_uuid()), p_zone_id, btrim(p_name), nullif(btrim(p_description), ''),
    nullif(btrim(p_category), ''), p_phone, p_latitude, p_longitude, btrim(p_district), btrim(p_landmark),
    p_commission_rate, p_is_active, coalesce(p_kind, 'restaurant')
  )
  on conflict (id) do update
    set zone_id = excluded.zone_id, name = excluded.name, description = excluded.description,
        category = excluded.category, phone = excluded.phone, latitude = excluded.latitude,
        longitude = excluded.longitude, district = excluded.district, landmark = excluded.landmark,
        commission_rate = excluded.commission_rate, is_active = excluded.is_active, kind = coalesce(p_kind, r.kind)
  returning r.id into saved_id;
  perform private.audit('restaurant_saved', 'restaurant', saved_id,
                        jsonb_build_object('commission_rate', p_commission_rate, 'is_active', p_is_active));
  return saved_id;
end;
$$;
revoke all on function public.admin_save_restaurant(uuid, uuid, text, text, text, text, double precision, double precision, text, text, numeric, boolean, text) from public, anon;
grant execute on function public.admin_save_restaurant(uuid, uuid, text, text, text, text, double precision, double precision, text, text, numeric, boolean, text) to authenticated;

-- 2. Options de produits (taille, suppléments) : groupes de choix, prix ajouté au produit.
create table public.product_option_groups (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 40),
  -- 0 : facultatif ; 1 ou plus : choix obligatoire.
  min_choices integer not null default 0 check (min_choices between 0 and 10),
  max_choices integer not null default 1 check (max_choices between 1 and 10 and max_choices >= min_choices),
  position integer not null default 0
);
create index product_option_groups_product_idx on public.product_option_groups (product_id, position);

create table public.product_options (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.product_option_groups (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 40),
  price_delta integer not null default 0 check (price_delta between 0 and 1000000),
  is_available boolean not null default true,
  position integer not null default 0
);
create index product_options_group_idx on public.product_options (group_id, position);

alter table public.product_option_groups enable row level security;
alter table public.product_options enable row level security;
create policy "groupes d'options : visibles avec le produit" on public.product_option_groups
  for select to authenticated using (exists (select 1 from public.products p where p.id = product_id));
create policy "groupes d'options : gérés par les gérants ou un admin" on public.product_option_groups
  for all to authenticated
  using (exists (select 1 from public.products p where p.id = product_id
                  and (private.is_member_of(p.restaurant_id) or private.is_admin())))
  with check (exists (select 1 from public.products p where p.id = product_id
                       and (private.is_member_of(p.restaurant_id) or private.is_admin())));
create policy "options : visibles avec leur groupe" on public.product_options
  for select to authenticated using (exists (select 1 from public.product_option_groups g where g.id = group_id));
create policy "options : gérées par les gérants ou un admin" on public.product_options
  for all to authenticated
  using (exists (select 1 from public.product_option_groups g join public.products p on p.id = g.product_id
                  where g.id = group_id and (private.is_member_of(p.restaurant_id) or private.is_admin())))
  with check (exists (select 1 from public.product_option_groups g join public.products p on p.id = g.product_id
                       where g.id = group_id and (private.is_member_of(p.restaurant_id) or private.is_admin())));
revoke all on public.product_option_groups, public.product_options from anon;

-- Choix recopiés dans la ligne de commande : [{"group": "Taille", "name": "Grande", "price_delta": 500}, …].
alter table public.order_items add column options jsonb not null default '[]'::jsonb;

-- Devis : chaque ligne peut porter "options": [id, …]. Prix unitaire = produit + options ; un choix obligatoire
-- manquant ou une option indisponible devient un écart (« options_required », « option_unavailable »).
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

  select * into fee from private.price_delivery(r.zone_id, 'food',
    extensions.st_distance(r.location, a.location));
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
    'courier_earning', fee.courier_earning,
    'issues', issues
  );
end;
$$;

-- Commande : lignes recopiées avec leurs options, aussi dans le libellé (« Garba (Grand, Œuf) ») pour que les écrans
-- existants les affichent ; le reste est inchangé (20261019130000_mobile_money).
create or replace function public.place_food_order(
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
    private.new_order_number('R'), 'food', private.initial_status('pending', p_payment_method), auth.uid(), r.zone_id, q->>'currency', r.id,
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

  insert into public.order_items (order_id, product_id, name, unit_price, quantity, line_total, options)
  select result.id, (l->>'product_id')::uuid,
         l->>'name' || coalesce(' (' || (select string_agg(o->>'name', ', ')
                                           from jsonb_array_elements(l->'options') o) || ')', ''),
         (l->>'unit_price')::integer, (l->>'quantity')::integer, (l->>'line_total')::integer, l->'options'
    from jsonb_array_elements(q->'items') l;
  perform private.log_order_event(result.id, result.status, 'customer');
  return result;
end;
$$;

-- 3. Catalogue public (accueil du site, visiteur sans compte) : lecture seule, colonnes sûres uniquement (ni
-- commission, ni gérants, ni téléphone), établissements actifs des zones actives. Les tables restent fermées à anon.
create function private.fold(p_text text)
returns text
language sql
immutable
set search_path = ''
as $$
  select translate(lower(coalesce(p_text, '')), 'àâäáãéèêëíìîïóòôöõúùûüçñ', 'aaaaaeeeeiiiiooooouuuucn');
$$;

create function public.public_zones()
returns table (id uuid, name text, city text, center_lat double precision, center_lng double precision,
               radius_m integer, currency text)
language sql
stable
security definer
set search_path = ''
as $$
  select z.id, z.name, z.city, z.center_lat, z.center_lng, z.radius_m, z.currency
    from public.zones z
   where z.is_active
   order by z.city, z.name;
$$;

create function public.public_establishments(p_zone_id uuid)
returns table (id uuid, kind text, name text, description text, category text, cover_path text, district text,
               landmark text, prep_time_min integer, is_open boolean)
language sql
stable
security definer
set search_path = ''
as $$
  select r.id, r.kind, r.name, r.description, r.category, r.cover_path, r.district, r.landmark, r.prep_time_min,
         public.is_open(r)
    from public.restaurants r
    join public.zones z on z.id = r.zone_id and z.is_active
   where r.is_active and r.zone_id = p_zone_id
   order by public.is_open(r) desc, r.name;
$$;

-- Produits en vedette : établissements ouverts d'abord, puis les plus livrés des 30 derniers jours, puis les plus
-- récents ; avec photo, disponibles.
create function public.public_featured_products(p_zone_id uuid, p_limit integer default 8)
returns table (id uuid, establishment_id uuid, establishment_name text, name text, description text, price integer,
               photo_path text, is_open boolean)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, r.id, r.name, p.name, p.description, p.price, p.photo_path, public.is_open(r)
    from public.products p
    join public.restaurants r on r.id = p.restaurant_id and r.is_active and r.zone_id = p_zone_id
    join public.zones z on z.id = r.zone_id and z.is_active
    left join lateral (
      select sum(oi.quantity) as sold
        from public.order_items oi
        join public.orders o on o.id = oi.order_id
       where oi.product_id = p.id and o.status = 'delivered' and o.created_at > now() - interval '30 days'
    ) s on true
   where p.archived_at is null and p.is_available and p.photo_path is not null
   order by public.is_open(r) desc, coalesce(s.sold, 0) desc, p.created_at desc
   limit least(greatest(coalesce(p_limit, 8), 1), 24);
$$;

-- Fiche publique d'un établissement : horaires, catégories, produits et leurs options.
create function public.public_establishment(p_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', r.id, 'kind', r.kind, 'name', r.name, 'description', r.description, 'category', r.category,
    'cover_path', r.cover_path, 'district', r.district, 'landmark', r.landmark, 'prep_time_min', r.prep_time_min,
    'is_open', public.is_open(r), 'zone_id', z.id, 'city', z.city, 'currency', z.currency,
    'hours', coalesce((select jsonb_agg(jsonb_build_object('weekday', h.weekday, 'opens_at', h.opens_at,
                                                            'closes_at', h.closes_at) order by h.weekday, h.opens_at)
                         from public.opening_hours h where h.restaurant_id = r.id), '[]'::jsonb),
    'categories', coalesce((select jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name) order by c.position, c.name)
                              from public.categories c where c.restaurant_id = r.id), '[]'::jsonb),
    'products', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', p.id, 'category_id', p.category_id, 'name', p.name, 'description', p.description,
               'price', p.price, 'photo_path', p.photo_path, 'is_available', p.is_available,
               'option_groups', coalesce((
                 select jsonb_agg(jsonb_build_object(
                          'id', g.id, 'name', g.name, 'min_choices', g.min_choices, 'max_choices', g.max_choices,
                          'options', coalesce((
                            select jsonb_agg(jsonb_build_object('id', o.id, 'name', o.name,
                                                                'price_delta', o.price_delta,
                                                                'is_available', o.is_available)
                                             order by o.position, o.name)
                              from public.product_options o where o.group_id = g.id), '[]'::jsonb))
                          order by g.position, g.name)
                   from public.product_option_groups g where g.product_id = p.id), '[]'::jsonb))
             order by p.name)
        from public.products p where p.restaurant_id = r.id and p.archived_at is null), '[]'::jsonb))
    from public.restaurants r
    join public.zones z on z.id = r.zone_id and z.is_active
   where r.id = p_id and r.is_active;
$$;

-- Recherche (accents et majuscules ignorés) parmi les établissements et produits d'une zone.
create function public.public_search(p_zone_id uuid, p_query text)
returns table (result_type text, id uuid, establishment_id uuid, name text, establishment_name text, price integer,
               photo_path text, is_open boolean)
language sql
stable
security definer
set search_path = ''
as $$
  with q as (select private.fold(btrim(p_query)) as term),
  zone_r as (
    select r.*, public.is_open(r) as open_now
      from public.restaurants r
      join public.zones z on z.id = r.zone_id and z.is_active
     where r.is_active and r.zone_id = p_zone_id
  )
  (select 'establishment', r.id, r.id, r.name, r.name, null::integer, r.cover_path, r.open_now
     from zone_r r, q
    where char_length(q.term) >= 2
      and (private.fold(r.name) like '%' || q.term || '%' or private.fold(r.category) like '%' || q.term || '%')
    order by r.open_now desc, r.name
    limit 10)
  union all
  (select 'product', p.id, r.id, p.name, r.name, p.price, p.photo_path, r.open_now
     from public.products p
     join zone_r r on r.id = p.restaurant_id
    cross join q
    where char_length(q.term) >= 2 and p.archived_at is null and p.is_available
      and (private.fold(p.name) like '%' || q.term || '%' or private.fold(p.description) like '%' || q.term || '%')
    order by r.open_now desc, p.name
    limit 30);
$$;

revoke all on function public.public_zones(), public.public_establishments(uuid),
  public.public_featured_products(uuid, integer), public.public_establishment(uuid),
  public.public_search(uuid, text) from public;
grant execute on function public.public_zones(), public.public_establishments(uuid),
  public.public_featured_products(uuid, integer), public.public_establishment(uuid),
  public.public_search(uuid, text) to anon, authenticated;

-- 4. Candidatures « Rejoindre la plateforme » (restaurant ou magasin), examinées par l'admin, qui crée ensuite
-- l'établissement et invite son gérant comme aujourd'hui.
create table public.partner_applications (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('restaurant', 'shop')),
  business_name text not null check (char_length(btrim(business_name)) between 2 and 80),
  contact_name text not null check (char_length(btrim(contact_name)) between 2 and 80),
  phone text not null check (phone ~ '^\+[1-9][0-9]{7,14}$'),
  email text check (email is null or email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  city text not null check (char_length(btrim(city)) between 2 and 60),
  message text check (char_length(message) <= 1000),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles (id) on delete set null
);
create index partner_applications_status_idx on public.partner_applications (status, created_at desc);
create index partner_applications_reviewer_idx on public.partner_applications (reviewed_by);
alter table public.partner_applications enable row level security;
create policy "candidatures : lues par un admin" on public.partner_applications
  for select to authenticated using (private.is_admin());
revoke all on public.partner_applications from anon;
revoke insert, update, delete on public.partner_applications from authenticated;

create function public.submit_partner_application(
  p_kind text, p_business_name text, p_contact_name text, p_phone text, p_email text, p_city text, p_message text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Garde-fous contre les envois en masse : une candidature en attente par numéro, 30 par heure au total.
  if exists (select 1 from public.partner_applications where phone = p_phone and status = 'pending') then
    raise exception 'already_submitted' using errcode = 'P0001';
  end if;
  if (select count(*) from public.partner_applications where created_at > now() - interval '1 hour') >= 30 then
    raise exception 'too_many_requests' using errcode = 'P0001';
  end if;
  insert into public.partner_applications (kind, business_name, contact_name, phone, email, city, message)
  values (p_kind, btrim(p_business_name), btrim(p_contact_name), p_phone, nullif(lower(btrim(p_email)), ''),
          btrim(p_city), nullif(btrim(p_message), ''));
end;
$$;
revoke all on function public.submit_partner_application(text, text, text, text, text, text, text) from public;
grant execute on function public.submit_partner_application(text, text, text, text, text, text, text)
  to anon, authenticated;

create function public.admin_review_partner_application(p_id uuid, p_status text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if p_status not in ('approved', 'rejected') then
    raise exception 'invalid_status' using errcode = 'P0001';
  end if;
  update public.partner_applications set status = p_status, reviewed_at = now(), reviewed_by = auth.uid()
   where id = p_id;
  perform private.audit('partner_application_reviewed', 'partner_application', p_id,
                        jsonb_build_object('status', p_status));
end;
$$;
revoke all on function public.admin_review_partner_application(uuid, text) from public, anon;
grant execute on function public.admin_review_partner_application(uuid, text) to authenticated;
