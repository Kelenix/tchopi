-- Inscription des restaurants en libre-service (ADR-044) : le restaurateur crée son compte puis son établissement,
-- qui reste invisible des clients jusqu'à la validation par l'admin. Il peut déjà préparer sa carte.
alter table public.restaurants
  add column review_status text not null default 'approved' check (review_status in ('pending', 'approved', 'rejected')),
  add column owner_id uuid references public.profiles (id) on delete set null;
create index restaurants_owner_idx on public.restaurants (owner_id);
create index restaurants_review_idx on public.restaurants (review_status) where review_status = 'pending';

-- p_hours : [{"weekday": 1, "opens_at": "08:00", "closes_at": "22:00"}, …] (jour ISO, heure locale de la zone).
create function public.register_restaurant(
  p_zone_id uuid,
  p_name text,
  p_category text,
  p_description text,
  p_phone text,
  p_latitude double precision,
  p_longitude double precision,
  p_district text,
  p_landmark text,
  p_hours jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  me auth.users;
  new_id uuid;
begin
  select * into me from auth.users where id = auth.uid();
  if me.id is null or exists (select 1 from public.profiles where id = me.id and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  -- Une seule demande à la fois par compte (l'admin valide avant la suivante).
  if exists (select 1 from public.restaurants where owner_id = me.id and review_status = 'pending') then
    raise exception 'already_submitted' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.zones where id = p_zone_id and is_active) then
    raise exception 'zone_unavailable' using errcode = 'P0001';
  end if;

  insert into public.restaurants (zone_id, name, category, description, phone, latitude, longitude, district, landmark,
                                  is_active, review_status, owner_id)
  values (p_zone_id, btrim(p_name), nullif(btrim(p_category), ''), nullif(btrim(p_description), ''), p_phone,
          p_latitude, p_longitude, btrim(p_district), btrim(p_landmark), false, 'pending', me.id)
  returning id into new_id;

  insert into public.restaurant_members (restaurant_id, user_id, login_email, login_phone)
  values (new_id, me.id, case when me.email is not null then lower(me.email) end,
          case when me.email is null then '+' || me.phone end);

  insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
  select new_id, (h ->> 'weekday')::smallint, (h ->> 'opens_at')::time, (h ->> 'closes_at')::time
    from jsonb_array_elements(coalesce(p_hours, '[]'::jsonb)) h;

  perform private.audit('restaurant_registered', 'restaurant', new_id, jsonb_build_object('zone_id', p_zone_id));
  return new_id;
end;
$$;
revoke all on function public.register_restaurant(uuid, text, text, text, text, double precision, double precision, text, text, jsonb) from public, anon;
grant execute on function public.register_restaurant(uuid, text, text, text, text, double precision, double precision, text, text, jsonb) to authenticated;

-- Validation par l'admin : accepté, l'établissement devient visible (commission fixée) ; le gérant est prévenu.
create function public.admin_review_restaurant(p_id uuid, p_approved boolean, p_commission_rate numeric default null, p_reason text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r public.restaurants;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  update public.restaurants
     set review_status = case when p_approved then 'approved' else 'rejected' end,
         is_active = p_approved,
         commission_rate = coalesce(p_commission_rate, commission_rate)
   where id = p_id and review_status = 'pending'
  returning * into r;
  if r.id is null then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  perform private.audit(case when p_approved then 'restaurant_approved' else 'restaurant_rejected' end, 'restaurant', r.id,
                        jsonb_build_object('commission_rate', r.commission_rate, 'reason', p_reason));
  perform private.notify(r.owner_id, null::public.orders,
    case when p_approved then 'restaurant_approved' else 'restaurant_rejected' end,
    case when p_approved then 'Restaurant validé' else 'Inscription refusée' end,
    case when p_approved then r.name || ' est en ligne : les clients peuvent commander.'
         else coalesce(p_reason, 'L''équipe Tchopi vous contacte pour en savoir plus.') end,
    '/restaurant/orders');
end;
$$;
revoke all on function public.admin_review_restaurant(uuid, boolean, numeric, text) from public, anon;
grant execute on function public.admin_review_restaurant(uuid, boolean, numeric, text) to authenticated;
