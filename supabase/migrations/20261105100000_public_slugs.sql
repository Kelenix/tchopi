-- Adresses publiques lisibles (ADR-063) : /etablissements/maquis-chez-tante, /?ville=abidjan. Les UUID restent les
-- clés internes ; le slug n'est qu'un nom public, unique, généré par le serveur. Un établissement renommé change de
-- slug et garde l'ancien en redirection permanente : aucun lien partagé ne casse.

create function private.slugify(p_text text)
returns text
language sql
immutable
set search_path = ''
as $$
  select coalesce(nullif(left(trim(both '-' from regexp_replace(private.fold(p_text), '[^a-z0-9]+', '-', 'g')), 60), ''), 'tchopi');
$$;

alter table public.restaurants add column slug text;
alter table public.zones add column slug text;

-- Anciens slugs d'un établissement renommé.
create table public.restaurant_slug_redirects (
  slug text primary key,
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.restaurant_slug_redirects enable row level security;
revoke all on public.restaurant_slug_redirects from anon, authenticated;

-- Slug libre (ni porté ni réservé par un autre établissement) : nom, puis nom-ville, puis nom-ville-2, -3…
create function private.restaurant_slug(p_id uuid, p_name text, p_zone_id uuid)
returns text
language plpgsql
stable
set search_path = ''
as $$
declare
  base text := private.slugify(p_name);
  city text := private.slugify((select z.city from public.zones z where z.id = p_zone_id));
  candidate text := base;
  n integer := 1;
begin
  loop
    exit when not exists (select 1 from public.restaurants r where r.slug = candidate and r.id <> p_id)
          and not exists (select 1 from public.restaurant_slug_redirects s
                           where s.slug = candidate and s.restaurant_id <> p_id);
    n := n + 1;
    candidate := base || '-' || city || case when n > 2 then '-' || (n - 1) else '' end;
  end loop;
  return candidate;
end;
$$;

create function private.restaurant_set_slug()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' and new.name is not distinct from old.name and new.slug is not null then
    return new;
  end if;
  new.slug := private.restaurant_slug(new.id, new.name, new.zone_id);
  if tg_op = 'UPDATE' and old.slug is not null and old.slug <> new.slug then
    insert into public.restaurant_slug_redirects (slug, restaurant_id) values (old.slug, new.id)
    on conflict (slug) do update set restaurant_id = excluded.restaurant_id;
  end if;
  -- Revenu à un ancien nom : son slug redevient l'adresse principale.
  delete from public.restaurant_slug_redirects where slug = new.slug and restaurant_id = new.id;
  return new;
end;
$$;

create trigger restaurants_slug before insert or update of name on public.restaurants
  for each row execute function private.restaurant_set_slug();

create function private.zone_set_slug()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  base text := private.slugify(new.city);
  candidate text := base;
  n integer := 1;
begin
  if tg_op = 'UPDATE' and new.city is not distinct from old.city and new.slug is not null then
    return new;
  end if;
  while exists (select 1 from public.zones z where z.slug = candidate and z.id <> new.id) loop
    n := n + 1;
    candidate := base || '-' || n;
  end loop;
  new.slug := candidate;
  return new;
end;
$$;

create trigger zones_slug before insert or update of city on public.zones
  for each row execute function private.zone_set_slug();

-- Établissements et zones existants, dans l'ordre de création (le plus ancien garde le nom seul).
do $$
declare
  r record;
begin
  for r in select id from public.zones order by created_at, id loop
    update public.zones set slug = null, city = city where id = r.id;
  end loop;
  for r in select id from public.restaurants order by created_at, id loop
    update public.restaurants set slug = private.restaurant_slug(id, name, zone_id) where id = r.id;
  end loop;
end;
$$;

alter table public.restaurants alter column slug set not null, add constraint restaurants_slug_key unique (slug);
alter table public.zones alter column slug set not null, add constraint zones_slug_key unique (slug);

-- Catalogue public : même contenu, plus les slugs.
drop function public.public_zones();
create function public.public_zones()
returns table (id uuid, name text, city text, center_lat double precision, center_lng double precision,
               radius_m integer, currency text, slug text)
language sql
stable
security definer
set search_path = ''
as $$
  select z.id, z.name, z.city, z.center_lat, z.center_lng, z.radius_m, z.currency, z.slug
    from public.zones z
   where z.is_active
   order by z.city, z.name;
$$;

drop function public.public_establishments(uuid);
create function public.public_establishments(p_zone_id uuid)
returns table (id uuid, kind text, name text, description text, category text, cover_path text, district text,
               landmark text, prep_time_min integer, is_open boolean, slug text)
language sql
stable
security definer
set search_path = ''
as $$
  select r.id, r.kind, r.name, r.description, r.category, r.cover_path, r.district, r.landmark, r.prep_time_min,
         public.is_open(r), r.slug
    from public.restaurants r
    join public.zones z on z.id = r.zone_id and z.is_active
   where r.is_active and r.zone_id = p_zone_id
   order by public.is_open(r) desc, r.name;
$$;

drop function public.public_featured_products(uuid, integer);
create function public.public_featured_products(p_zone_id uuid, p_limit integer default 8)
returns table (id uuid, establishment_id uuid, establishment_name text, name text, description text, price integer,
               photo_path text, is_open boolean, establishment_slug text)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, r.id, r.name, p.name, p.description, p.price, p.photo_path, public.is_open(r), r.slug
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

drop function public.public_search(uuid, text);
create function public.public_search(p_zone_id uuid, p_query text)
returns table (result_type text, id uuid, establishment_id uuid, name text, establishment_name text, price integer,
               photo_path text, is_open boolean, establishment_slug text)
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
  (select 'establishment', r.id, r.id, r.name, r.name, null::integer, r.cover_path, r.open_now, r.slug
     from zone_r r, q
    where char_length(q.term) >= 2
      and (private.fold(r.name) like '%' || q.term || '%' or private.fold(r.category) like '%' || q.term || '%')
    order by r.open_now desc, r.name
    limit 10)
  union all
  (select 'product', p.id, r.id, p.name, r.name, p.price, p.photo_path, r.open_now, r.slug
     from public.products p
     join zone_r r on r.id = p.restaurant_id
    cross join q
    where char_length(q.term) >= 2 and p.archived_at is null and p.is_available
      and (private.fold(p.name) like '%' || q.term || '%' or private.fold(p.description) like '%' || q.term || '%')
    order by r.open_now desc, p.name
    limit 30);
$$;

-- Fiche par slug (contenu identique à public_establishment, plus le slug).
create function public.public_establishment_by_slug(p_slug text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.public_establishment(r.id) || jsonb_build_object('slug', r.slug, 'zone_slug', z.slug)
    from public.restaurants r
    join public.zones z on z.id = r.zone_id
   where r.slug = p_slug and r.is_active and z.is_active;
$$;

-- Adresse actuelle d'un établissement à partir d'un ancien lien (UUID ou ancien slug) ; null si inconnu ou inactif.
create function public.public_establishment_slug(p_key text)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select r.slug
    from public.restaurants r
    join public.zones z on z.id = r.zone_id and z.is_active
   where r.is_active
     and (r.slug = p_key
          or r.id::text = lower(p_key)
          or r.id = (select s.restaurant_id from public.restaurant_slug_redirects s where s.slug = p_key))
   limit 1;
$$;

revoke all on function public.public_zones(), public.public_establishments(uuid),
  public.public_featured_products(uuid, integer), public.public_search(uuid, text),
  public.public_establishment_by_slug(text), public.public_establishment_slug(text) from public;
grant execute on function public.public_zones(), public.public_establishments(uuid),
  public.public_featured_products(uuid, integer), public.public_search(uuid, text),
  public.public_establishment_by_slug(text), public.public_establishment_slug(text) to anon, authenticated;
