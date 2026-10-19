begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000f1', 'gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c2', 'autre@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a1', 'k1@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', last_name = 'Koné', phone = '+2250700000011'
 where id = '00000000-0000-0000-0000-0000000000c1';
update public.profiles set first_name = 'Koffi' where id = '00000000-0000-0000-0000-0000000000a1';
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);
insert into public.pricing_rules (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, courier_base, courier_per_km)
values ('55555555-5555-5555-5555-555555555555', 'food', 500, 150, 500, 3000, 400, 100);
insert into public.restaurants (id, zone_id, name, phone, latitude, longitude, district, landmark, commission_rate)
values ('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555', 'Chez Tantie Rose',
        '+2250544183108', 6.8780, -6.4500, 'Commerce', 'Face à la gare', 10);
insert into public.restaurant_members (restaurant_id, user_id, login_email)
values ('66666666-6666-6666-6666-666666666666', '00000000-0000-0000-0000-0000000000f1', 'gerant@exemple.ci');
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
select '66666666-6666-6666-6666-666666666666', d, '00:00', '23:59:59' from generate_series(1, 7) d;
insert into public.products (id, restaurant_id, name, price, is_available)
values ('77777777-0000-0000-0000-000000000001', '66666666-6666-6666-6666-666666666666', 'Garba', 1500, true);
insert into public.addresses (id, user_id, district, landmark, latitude, longitude)
values ('88888888-8888-8888-8888-888888888888', '00000000-0000-0000-0000-0000000000c1', 'Lobia',
        'Près du marché', 6.8850, -6.4400);
insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path, status, approved_at, is_online)
values ('00000000-0000-0000-0000-0000000000a1', '55555555-5555-5555-5555-555555555555', 'motorbike', 'AB-123-CI',
        '00000000-0000-0000-0000-0000000000a1/p.jpg', 'approved', now(), true);
insert into public.courier_locations (courier_id, latitude, longitude)
values ('00000000-0000-0000-0000-0000000000a1', 6.8790, -6.4505);

create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.order_id() returns uuid language sql security definer as $$
  select id from public.orders limit 1
$$;
create function pg_temp.kinds(p_user text) returns text language sql security definer as $$
  select array_agg(kind order by id)::text from public.notifications where user_id = p_user::uuid
$$;

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
  '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]', 'cash',
  ((public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]'))->>'total')::integer,
  '99999999-0000-0000-0000-000000000001');
select is(pg_temp.kinds('00000000-0000-0000-0000-0000000000f1'), '{new_order}',
  'NOT-03 : le restaurant est prévenu de la nouvelle commande');
select is(pg_temp.kinds('00000000-0000-0000-0000-0000000000c1'), null,
  'le client n''est pas notifié de sa propre action');

select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id(), 'accepted');
select public.transition_order(pg_temp.order_id(), 'preparing');
select is(pg_temp.kinds('00000000-0000-0000-0000-0000000000c1'), '{order_accepted}', 'NOT-01 : commande acceptée');
select is(pg_temp.kinds('00000000-0000-0000-0000-0000000000a1'), '{offer}', 'NOT-02 : offre au livreur');
reset role;
select matches((select body from public.notifications where kind = 'offer'), '^\+[0-9 ]+ F · Commerce → Lobia$',
  'offre : gain et trajet');
select ok((select route = '/orders/' || pg_temp.order_id() from public.notifications where kind = 'order_accepted'),
  'la notification ouvre le suivi de la commande');

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select is((select count(*) from public.courier_locations)::integer, 0, 'pas de position avant l''attribution');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer((select id from public.delivery_offers where status = 'pending'), true);
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select is(pg_temp.kinds('00000000-0000-0000-0000-0000000000c1'), '{order_accepted,courier_assigned}',
  'livreur assigné');
select is((select count(*) from public.courier_locations)::integer, 1,
  'TRK-01 : le client voit la position de son livreur');
select is((select count(*) from public.notifications)::integer, 2, 'chacun ne lit que ses notifications');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c2');
select is((select count(*) from public.courier_locations)::integer, 0, 'un autre client ne la voit pas');

select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id(), 'ready');
select is(pg_temp.kinds('00000000-0000-0000-0000-0000000000a1'), '{offer,order_ready}',
  'le livreur est prévenu que la commande est prête');

-- Appareils : enregistrés par leur compte, repris par le dernier compte connecté.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select public.register_push_token('jeton-fcm-de-test-0123456789', 'android');
select is((select count(*) from public.push_tokens)::integer, 1, 'NOT-04 : appareil enregistré');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c2');
select public.register_push_token('jeton-fcm-de-test-0123456789', 'android');
select is((select count(*) from public.push_tokens)::integer, 1, 'l''appareil suit le compte connecté');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select is((select count(*) from public.push_tokens)::integer, 0, 'l''ancien compte ne reçoit plus rien');

select * from finish();
rollback;
