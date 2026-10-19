begin;
create extension if not exists pgtap with schema extensions;
select plan(35);

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
-- Zone d'essai seule active (les villes de départ couvrent aussi Daloa).
update public.zones set is_active = false where id <> '55555555-5555-5555-5555-555555555555';
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

-- Raccourcis : commande par clé d'idempotence, offre en attente du livreur.
create function pg_temp.order_id(p_key text) returns uuid language sql as $$
  select id from public.orders where idempotency_key = ('99999999-0000-0000-0000-00000000000' || p_key)::uuid
$$;
create function pg_temp.pending_offer() returns uuid language sql as $$
  select id from public.delivery_offers where status = 'pending'
$$;
create function pg_temp.place_food(p_key text) returns void language sql as $$
  select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]', 'cash',
    ((public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
      '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]'))->>'total')::integer,
    ('99999999-0000-0000-0000-00000000000' || p_key)::uuid);
$$;
create function pg_temp.place_parcel(p_key text) returns void language sql as $$
  select public.place_parcel_order(
    '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
    '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché"}',
    'Koffi', '+2250700000022', (select id from public.parcel_types where code = 'small'), null, true, 'cash',
    ((public.quote_parcel(6.878, -6.45, 6.89, -6.44,
      (select id from public.parcel_types where code = 'small')))->>'total')::integer,
    ('99999999-0000-0000-0000-00000000000' || p_key)::uuid);
$$;
-- Le code n'est lisible que par le client : la fonction de test le lit avec les droits du propriétaire.
create function pg_temp.code(p_key text) returns text language sql security definer as $$
  select c.code from public.delivery_codes c join public.orders o on o.id = c.order_id
   where o.idempotency_key = ('99999999-0000-0000-0000-00000000000' || p_key)::uuid
$$;
create function pg_temp.wrong_code(p_key text) returns text language sql as $$
  select lpad(((pg_temp.code(p_key)::integer + 1) % 10000)::text, 4, '0')
$$;
create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;

-- Repas A : préparation, offre acceptée.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_food('1');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id('1'), 'accepted');
select public.transition_order(pg_temp.order_id('1'), 'preparing');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer(pg_temp.pending_offer(), true);

-- MIS-04 : récupération seulement une fois prête.
select throws_ok($$ select public.confirm_pickup(pg_temp.order_id('1')) $$, 'P0001', 'not_ready',
  'un repas en préparation ne peut pas être récupéré');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select throws_ok($$ select public.confirm_pickup(pg_temp.order_id('1')) $$, 'P0001', 'not_found',
  'seul le livreur de la mission la fait avancer');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id('1'), 'ready');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select is((public.confirm_pickup(pg_temp.order_id('1'))).status, 'picked_up'::public.order_status,
  'repas prêt : récupéré par le livreur');
select throws_ok($$ select public.confirm_delivery(pg_temp.order_id('1'), '0000') $$, 'P0001', 'invalid_transition',
  'le code se saisit une fois en route');
select is((public.start_delivery(pg_temp.order_id('1'))).status, 'in_transit'::public.order_status,
  'MIS-05 : en cours de livraison');
select throws_ok($$ select public.release_mission(pg_temp.order_id('1'), 'Panne') $$, 'P0001', 'already_picked_up',
  'pas d''abandon après la récupération');

-- MIS-06 : code faux compté, code juste → livrée.
select is(public.confirm_delivery(pg_temp.order_id('1'), pg_temp.wrong_code('1')),
  '{"delivered": false, "attempts_left": 4, "locked": false}'::jsonb, 'code faux : essais restants');
select is(public.confirm_delivery(pg_temp.order_id('1'), pg_temp.code('1')) ->> 'delivered', 'true',
  'code juste : livraison confirmée');
select ok((select status = 'delivered' and delivered_at is not null and closed_at is not null
             from public.orders where id = pg_temp.order_id('1')), 'statut, date et heure de livraison enregistrés');
select is(
  (select array_agg(kind order by id)::text from public.order_events
    where order_id = pg_temp.order_id('1') and kind <> 'status_changed'),
  '{courier_assigned,code_failed}', 'chronologie : livreur assigné, code faux'
);

-- PAY-02 : encaissement après livraison, une seule fois ; gains et espèces du jour (MIS-01).
select is(public.courier_summary(), jsonb_build_object('earnings_today',
  (select courier_earning from public.orders where id = pg_temp.order_id('1')), 'deliveries_today', 1, 'cash_due', 0),
  'gains et livraisons du jour, rien encaissé');
select is((public.confirm_cash_collected(pg_temp.order_id('1'))).payment_status, 'paid'::public.order_payment_status,
  'espèces reçues : commande payée');
select public.confirm_cash_collected(pg_temp.order_id('1'));
select is((public.courier_summary()->>'cash_due')::integer,
  (select total from public.orders where id = pg_temp.order_id('1')), 'espèces à reverser comptées une fois');

-- MIS-02 : numéros visibles pendant la mission seulement ; l'historique reste, sans coordonnées.
select is((select count(*) from public.orders)::integer, 1, 'mission juste terminée encore lisible');
reset role;
update public.orders set closed_at = now() - interval '2 hours' where id = pg_temp.order_id('1');
set local role authenticated;
select is((select count(*) from public.orders)::integer, 0, 'une heure après, plus de numéros');
select is((select count(*) from public.courier_missions())::integer, 1, 'l''historique garde la mission');

-- Colis B en espèces : l'expéditeur paie à la récupération ; problème puis échec (MIS-08).
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_parcel('2');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer(pg_temp.pending_offer(), true);
select throws_ok($$ select public.confirm_pickup(pg_temp.order_id('2')) $$, 'P0001', 'cash_confirmation_required',
  'colis en espèces : encaissement à confirmer avant la récupération');
select is((select row(status, payment_status)::text from public.confirm_pickup(pg_temp.order_id('2'), true)),
  row('picked_up'::public.order_status, 'paid'::public.order_payment_status)::text,
  'colis récupéré et payé par l''expéditeur');
select throws_ok($$ select public.report_problem(pg_temp.order_id('2'), 'other', ' ') $$, 'P0001', 'reason_required',
  '« Autre » exige un commentaire');
select lives_ok($$ select public.report_problem(pg_temp.order_id('2'), 'recipient_absent') $$,
  'problème signalé');
select throws_ok($$ select public.declare_failure(pg_temp.order_id('2'), '') $$, 'P0001', 'reason_required',
  'l''échec exige un motif');
select is((public.declare_failure(pg_temp.order_id('2'), 'Destinataire absent')).status, 'failed'::public.order_status,
  'échec de livraison déclaré');
select ok((select problem_reported_at is not null from public.orders where id = pg_temp.order_id('2')),
  'alerte admin : problème signalé');

-- Colis C : code bloqué après 5 erreurs, puis livraison confirmée par l'admin (MIS-07).
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_parcel('3');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer(pg_temp.pending_offer(), true);
select public.confirm_pickup(pg_temp.order_id('3'), true);
select public.start_delivery(pg_temp.order_id('3'));
select public.confirm_delivery(pg_temp.order_id('3'), pg_temp.wrong_code('3')) from generate_series(1, 4);
select is(public.confirm_delivery(pg_temp.order_id('3'), pg_temp.wrong_code('3')),
  '{"delivered": false, "attempts_left": 0, "locked": true}'::jsonb, 'cinquième erreur : saisie bloquée');
select is(public.confirm_delivery(pg_temp.order_id('3'), pg_temp.code('3')) ->> 'delivered', 'false',
  'bloqué, même le bon code est refusé');
select ok((select code_locked_at is not null from public.orders where id = pg_temp.order_id('3')),
  'alerte admin : code bloqué');
select throws_ok($$ select public.admin_confirm_delivery(pg_temp.order_id('3'), 'Appel au client') $$,
  'P0001', 'forbidden', 'seul l''admin confirme sans code');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select throws_ok($$ select public.admin_confirm_delivery(pg_temp.order_id('3'), '') $$, 'P0001', 'reason_required',
  'confirmation sans code : motif obligatoire');
select is((public.admin_confirm_delivery(pg_temp.order_id('3'), 'Client joint par téléphone')).status,
  'delivered'::public.order_status, 'livraison confirmée par l''admin');

-- Colis D : abandon avant récupération, la recherche repart sans reproposer ce livreur (MIS-09).
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_parcel('4');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer(pg_temp.pending_offer(), true);
select throws_ok($$ select public.release_mission(pg_temp.order_id('4'), ' ') $$, 'P0001', 'reason_required',
  'l''abandon exige un motif');
select lives_ok($$ select public.release_mission(pg_temp.order_id('4'), 'Crevaison') $$, 'mission abandonnée');
reset role;
select is(
  (select row(status, courier_id is null, dispatch_started_at > now() - interval '1 minute')::text
     from public.orders where id = pg_temp.order_id('4')),
  row('searching_courier'::public.order_status, true, true)::text, 'colis de nouveau en recherche'
);
select is((select count(*) from public.delivery_offers where order_id = pg_temp.order_id('4') and status = 'pending')::integer,
  0, 'pas d''offre au livreur qui a abandonné');

-- ORD-10 : « Remise au livreur » par le restaurant ; impossible sans livreur.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_food('5');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id('5'), 'accepted');
select public.transition_order(pg_temp.order_id('5'), 'preparing');
select public.transition_order(pg_temp.order_id('5'), 'ready');
select throws_ok($$ select public.transition_order(pg_temp.order_id('5'), 'picked_up') $$, 'P0001', 'no_courier',
  'pas de remise sans livreur');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer(pg_temp.pending_offer(), true);
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select is((public.transition_order(pg_temp.order_id('5'), 'picked_up')).status, 'picked_up'::public.order_status,
  'le restaurant déclare la remise au livreur');

select * from finish();
rollback;
