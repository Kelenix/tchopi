begin;
create extension if not exists pgtap with schema extensions;
select plan(20);

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
create function pg_temp.tx(p_key text) returns uuid language sql security definer as $$
  select id from public.transactions where order_id = pg_temp.order_id(p_key)
$$;
create function pg_temp.state(p_key text) returns text language sql security definer as $$
  select o.status || '/' || o.payment_status || '/' || t.status
    from public.orders o join public.transactions t on t.order_id = o.id where o.id = pg_temp.order_id(p_key)
$$;
create function pg_temp.place_food(p_key text) returns void language sql as $$
  select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]', 'mobile_money',
    ((public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
      '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]'))->>'total')::integer,
    ('99999999-0000-0000-0000-00000000000' || p_key)::uuid);
$$;

-- ADM-05 : Mobile Money activable par l'admin (nyole intégré).
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select lives_ok(
  $$ select public.admin_set_payment_option((select id from public.payment_options where method = 'mobile_money'), true) $$,
  'Mobile Money activé'
);

-- PAY-03 : la commande attend son paiement ; le restaurant ne la voit pas encore.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_food('1');
select is(pg_temp.state('1'), 'awaiting_payment/unpaid/pending', 'en attente du paiement, transaction ouverte');
select is((select provider from public.transactions where id = pg_temp.tx('1')), 'nyole', 'fournisseur nyole');
select is(
  (select (public.begin_online_payment(pg_temp.order_id('1')))->>'amount')::integer,
  (select total from public.orders where id = pg_temp.order_id('1')),
  'montant de la session = total de la commande'
);
select throws_ok($$ select public.apply_payment_status(pg_temp.tx('1'), 'SUCCESS', 1, 'XOF', null) $$,
  '42501', null, 'le client ne confirme jamais lui-même un paiement');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select is((select count(*)::integer from public.orders), 0, 'le restaurant ne voit pas une commande non payée');
select throws_ok($$ select public.begin_online_payment(pg_temp.order_id('1')) $$,
  'P0001', 'not_found', 'seul le client paie sa commande');

-- Refus chez l'opérateur, nouvel essai, montant falsifié, puis confirmation (une seule fois).
reset role;
select public.record_checkout_session(pg_temp.tx('1'), 'sess_1', 'https://app.nyole.com/checkout/sess_1', 'CS-1', 0);
select is(public.apply_payment_status(pg_temp.tx('1'), 'FAILED', null, null, null), 'failed', 'refus enregistré');
select is(pg_temp.state('1'), 'awaiting_payment/unpaid/failed', 'la commande attend toujours');
select public.record_checkout_session(pg_temp.tx('1'), 'sess_1', 'https://app.nyole.com/checkout/sess_1', 'CS-1', 0);
select is(pg_temp.state('1'), 'awaiting_payment/unpaid/pending', 'nouvel essai sur la même session');
select is(public.apply_payment_status(pg_temp.tx('1'), 'SUCCESS', 1, 'XOF', 'pd_1'), 'amount_mismatch',
  'montant différent : refusé');
select is(
  public.apply_payment_status(pg_temp.tx('1'), 'SUCCESS',
    (select total from public.orders where id = pg_temp.order_id('1')), 'xof', 'pd_1'),
  'succeeded', 'paiement confirmé'
);
select is(pg_temp.state('1'), 'pending/paid/succeeded', 'commande transmise au restaurant');
select is(
  public.apply_payment_status(pg_temp.tx('1'), 'SUCCESS',
    (select total from public.orders where id = pg_temp.order_id('1')), 'XOF', 'pd_1'),
  'succeeded', 'webhook reçu deux fois : sans effet (PAY-05)'
);
select is(
  (select array_agg(status order by created_at, id)::text from public.order_events
    where order_id = pg_temp.order_id('1')),
  '{awaiting_payment,pending}', 'chronologie : paiement attendu puis commande transmise'
);
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select is((select count(*)::integer from public.orders), 1, 'le restaurant la reçoit après paiement');

-- Sans confirmation sous 15 min : annulée ; un paiement arrivé ensuite est à rembourser.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_food('2');
reset role;
update public.orders set created_at = now() - interval '16 minutes' where id = pg_temp.order_id('2');
select private.expire_payments();
select is(
  (select status || '/' || close_reason from public.orders where id = pg_temp.order_id('2')),
  'cancelled/payment_timeout', 'paiement expiré : commande annulée'
);
select public.apply_payment_status(pg_temp.tx('2'), 'SUCCESS',
  (select total from public.orders where id = pg_temp.order_id('2')), 'XOF', 'pd_2');
select is(pg_temp.state('2'), 'cancelled/refund_pending/succeeded', 'payé trop tard : à rembourser');

-- Colis payé par Mobile Money : la recherche du livreur démarre à la confirmation.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select public.place_parcel_order(
  '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
  '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché"}',
  'Koffi', '+2250700000022', (select id from public.parcel_types where code = 'small'), null, true, 'mobile_money',
  ((public.quote_parcel(6.878, -6.45, 6.89, -6.44, (select id from public.parcel_types where code = 'small')))->>'total')::integer,
  '99999999-0000-0000-0000-000000000003');
reset role;
select is((select count(*)::integer from public.delivery_offers where order_id = pg_temp.order_id('3')), 0,
  'aucun livreur sollicité avant le paiement');
select public.apply_payment_status(pg_temp.tx('3'), 'SUCCESS',
  (select total from public.orders where id = pg_temp.order_id('3')), 'XOF', 'pd_3');
select is(
  (select status || '/' || (select count(*) from public.delivery_offers f where f.order_id = o.id)
     from public.orders o where o.id = pg_temp.order_id('3')),
  'searching_courier/1', 'payé : offre envoyée au livreur'
);

select * from finish();
rollback;
