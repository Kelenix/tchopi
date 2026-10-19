begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000f1', 'gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a1', 'k1@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', last_name = 'Koné', phone = '+2250700000011'
 where id = '00000000-0000-0000-0000-0000000000c1';
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);
insert into public.pricing_rules (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, courier_base, courier_per_km)
values ('55555555-5555-5555-5555-555555555555', 'food', 500, 150, 500, 3000, 400, 100),
       ('55555555-5555-5555-5555-555555555555', 'parcel', 700, 175, 700, 4000, 500, 120);
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
create function pg_temp.order_id(p_key text) returns uuid language sql security definer as $$
  select id from public.orders where idempotency_key = ('99999999-0000-0000-0000-00000000000' || p_key)::uuid
$$;
create function pg_temp.paid(p_key text) returns text language sql security definer as $$
  select o.payment_status || '/' || t.status from public.orders o join public.transactions t on t.order_id = o.id
   where o.id = pg_temp.order_id(p_key) and t.status <> 'cancelled'
$$;

-- Colis payé en espèces à la récupération, puis échec de livraison (MIS-08) : l'admin décide du remboursement.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select public.place_parcel_order(
  '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
  '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché"}',
  'Koffi', '+2250700000022', (select id from public.parcel_types where code = 'small'), null, true, 'cash',
  ((public.quote_parcel(6.878, -6.45, 6.89, -6.44, (select id from public.parcel_types where code = 'small')))->>'total')::integer,
  '99999999-0000-0000-0000-000000000001');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer((select id from public.delivery_offers where status = 'pending'), true);
select public.confirm_pickup(pg_temp.order_id('1'), true);
select public.declare_failure(pg_temp.order_id('1'), 'Destinataire absent');
select is(pg_temp.paid('1'), 'paid/succeeded', 'échec après encaissement : rien n''est remboursé d''office');

select throws_ok($$ select public.admin_request_refund(pg_temp.order_id('1'), 'Client absent') $$,
  'P0001', 'forbidden', 'seul l''admin décide d''un remboursement');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select throws_ok($$ select public.admin_request_refund(pg_temp.order_id('1'), ' ') $$,
  'P0001', 'reason_required', 'la décision de remboursement est motivée');
select public.admin_request_refund(pg_temp.order_id('1'), 'Destinataire absent, client prévenu');
select is(pg_temp.paid('1'), 'refund_pending/succeeded', 'remboursement à effectuer');
select throws_ok($$ select public.admin_mark_refunded(pg_temp.order_id('1'), '') $$,
  'P0001', 'reason_required', 'référence du remboursement obligatoire');
select public.admin_mark_refunded(pg_temp.order_id('1'), 'Espèces rendues, reçu 7');
select is(pg_temp.paid('1'), 'refunded/refunded', 'remboursé : commande et transaction');
select throws_ok($$ select public.admin_mark_refunded(pg_temp.order_id('1'), 'Encore') $$,
  'P0001', 'invalid_transition', 'pas de second remboursement');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select is(
  (select array_agg(kind order by id)::text from public.order_events
    where order_id = pg_temp.order_id('1') and kind in ('refund_pending', 'refunded')),
  '{refund_pending,refunded}', 'le client suit chaque étape du remboursement'
);
select is(
  (select array_agg(title order by id)::text from public.notifications
    where order_id = pg_temp.order_id('1') and kind in ('refund_pending', 'refunded')),
  '{"Remboursement en cours","Remboursement effectué"}', 'et en est prévenu'
);

-- TRX-03 : commande payée puis annulée → à rembourser automatiquement (paiements en ligne, Inc-11 / 12).
select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
  '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]', 'cash',
  ((public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]'))->>'total')::integer,
  '99999999-0000-0000-0000-000000000002');
reset role;
update public.orders set payment_status = 'paid' where id = pg_temp.order_id('2');
update public.transactions set status = 'succeeded' where order_id = pg_temp.order_id('2');
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id('2'), 'rejected', 'Rupture');
select is(pg_temp.paid('2'), 'refund_pending/succeeded', 'payée puis refusée : à rembourser');

-- ADM-06 : indicateurs de la période.
select throws_ok($$ select public.admin_stats(now() - interval '1 day', now() + interval '1 day') $$,
  'P0001', 'forbidden', 'statistiques réservées aux admins');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
create temporary table s on commit drop as
select public.admin_stats(now() - interval '1 day', now() + interval '1 day') as v;
select is(
  (select row(v->>'orders', v->'by_type'->>'parcel', v->'by_status'->>'failed', v->>'refunds_pending',
              v->>'couriers_online')::text from s),
  row('2', '1', '1', '1', '1')::text,
  'commandes par type et statut, remboursements en attente, livreurs en ligne'
);
select is((select (v->>'revenue')::integer from s), 0, 'chiffre d''affaires sur les commandes livrées seulement');

select * from finish();
rollback;
