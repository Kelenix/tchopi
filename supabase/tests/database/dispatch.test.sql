begin;
create extension if not exists pgtap with schema extensions;
select plan(38);
-- Colis en pause sur la plateforme (ADR-043) : réactivés pour ces tests.
update public.settings set parcels_enabled = true;
-- Réglage de préparation : hors de la modification tracée vérifiée plus bas.
delete from public.audit_log where action = 'settings_updated';

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000f1', 'gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a1', 'k1@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a2', 'k2@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a3', 'k3@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a4', 'k4@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', last_name = 'Koné', phone = '+2250700000011'
 where id = '00000000-0000-0000-0000-0000000000c1';
update public.profiles set first_name = 'Koffi', phone = '+2250700000031' where id = '00000000-0000-0000-0000-0000000000a1';
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
-- k1 moto à 120 m du restaurant, k2 vélo à 1 km, k3 voiture loin ; k4 pas encore validé. Tous hors ligne.
insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path, status, approved_at) values
  ('00000000-0000-0000-0000-0000000000a1', '55555555-5555-5555-5555-555555555555', 'motorbike', 'AB-123-CI',
   '00000000-0000-0000-0000-0000000000a1/p.jpg', 'approved', now()),
  ('00000000-0000-0000-0000-0000000000a2', '55555555-5555-5555-5555-555555555555', 'bicycle', null,
   '00000000-0000-0000-0000-0000000000a2/p.jpg', 'approved', now()),
  ('00000000-0000-0000-0000-0000000000a3', '55555555-5555-5555-5555-555555555555', 'car', 'CD-456-CI',
   '00000000-0000-0000-0000-0000000000a3/p.jpg', 'approved', now()),
  ('00000000-0000-0000-0000-0000000000a4', '55555555-5555-5555-5555-555555555555', 'motorbike', 'EF-789-CI',
   '00000000-0000-0000-0000-0000000000a4/p.jpg', 'pending', null);

create temporary table ids (name text primary key, id uuid) on commit drop;
grant select, insert on ids to authenticated;
create function pg_temp.order_id(p_key text) returns uuid language sql as $$
  select id from public.orders where idempotency_key = ('99999999-0000-0000-0000-00000000000' || p_key)::uuid
$$;

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
create temporary table q on commit drop as
select public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
  '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]') as quote;
select is((select quote->>'couriers_available' from q), 'false', 'le devis signale l''absence de livreur en ligne');
select lives_ok(
  $$ select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
       '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]', 'cash',
       (select (quote->>'total')::integer from q), '99999999-0000-0000-0000-000000000001') $$,
  'le client commande même sans livreur en ligne'
);

-- Mise en ligne (COU-05).
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a4","role":"authenticated"}';
select throws_ok($$ select public.set_courier_online(true) $$, 'P0001', 'courier_not_approved',
  'un livreur non validé ne peut pas passer en ligne');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}';
select throws_ok($$ select public.report_location(6.9, -6.45) $$, 'P0001', 'courier_offline',
  'pas de position partagée hors ligne');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}';
select lives_ok($$ select public.set_courier_online(true) $$, 'un livreur validé passe en ligne');
select lives_ok($$ select public.report_location(6.8790, -6.4505, 12) $$, 'il partage sa position');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}';
select public.set_courier_online(true);
select public.report_location(6.8850, -6.4550);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
  '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]', 'cash',
  (select (quote->>'total')::integer from q), ('99999999-0000-0000-0000-00000000000' || k)::uuid)
  from generate_series(2, 3) k;

-- Commande 1 : proposée aux livreurs seulement quand le restaurant la marque « Prête », à tous à la fois.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}';
select public.transition_order(pg_temp.order_id('1'), 'accepted');
select public.transition_order(pg_temp.order_id('1'), 'preparing');
reset role;
select is((select count(*) from public.delivery_offers)::integer, 0, 'pas d''offre avant « Prête »');
set local role authenticated;
select public.transition_order(pg_temp.order_id('1'), 'ready');
reset role;
select is(
  (select array_agg(courier_id order by courier_id)::text from public.delivery_offers where status = 'pending'),
  '{00000000-0000-0000-0000-0000000000a1,00000000-0000-0000-0000-0000000000a2}',
  'prête : proposée à tous les livreurs disponibles de la zone'
);
select ok(
  (select bool_and(summary ?& array['earning', 'to_pickup_m', 'trip_m', 'cash_amount', 'pickup_landmark',
                                    'dropoff_landmark'] and expires_at is null)
     from public.delivery_offers where status = 'pending'),
  'offre sans limite de temps, avec gain, distances, repères et espèces à encaisser'
);
insert into ids select 'a1', id from public.delivery_offers where courier_id = '00000000-0000-0000-0000-0000000000a1';
insert into ids select 'b1', id from public.delivery_offers where courier_id = '00000000-0000-0000-0000-0000000000a2';

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}';
select is((select count(*) from public.delivery_offers)::integer, 1, 'le livreur ne voit que ses offres');
select is((select count(*) from public.orders)::integer, 0, 'ni les commandes qui ne lui sont pas attribuées');
select throws_ok($$ select public.respond_to_offer((select id from ids where name = 'a1'), true) $$,
  'P0001', 'not_found', 'impossible de répondre à l''offre d''un autre');

-- DIS-02 : le premier qui accepte l'obtient ; « Livreur en route vers le retrait ».
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}';
select lives_ok($$ select public.respond_to_offer((select id from ids where name = 'a1'), true) $$,
  'le livreur accepte la commande');
select is(
  (select row(courier_id, status, courier_info->>'first_name', courier_info->>'plate_number')::text
     from public.orders where id = pg_temp.order_id('1')),
  row('00000000-0000-0000-0000-0000000000a1'::uuid, 'courier_assigned'::public.order_status, 'Koffi', 'AB-123-CI')::text,
  'livreur attribué, en route vers le restaurant'
);
select is(
  (select count(*) from public.order_events where order_id = pg_temp.order_id('1') and kind = 'courier_assigned')::integer,
  1, 'chronologie : livreur attribué'
);
select is((select count(*) from public.orders)::integer, 1, 'le livreur voit la commande qui lui est attribuée');
select throws_ok($$ select public.set_courier_online(false) $$, 'P0001', 'mission_in_progress',
  'hors ligne impossible pendant une mission');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}';
select throws_ok($$ select public.respond_to_offer((select id from ids where name = 'b1'), true) $$,
  'P0001', 'offer_unavailable', 'déjà prise : plus personne d''autre ne peut l''accepter');
reset role;
select ok(
  exists (select 1 from public.notifications n join auth.users u on u.id = n.user_id
           where n.order_id = pg_temp.order_id('1') and n.kind = 'courier_assigned'
             and u.id in ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000f1')
           group by n.kind having count(distinct u.id) = 2),
  'client et restaurant prévenus de l''attribution'
);

-- Commande 2 : le seul livreur libre refuse ; elle attend et va au prochain livreur disponible.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}';
select public.transition_order(pg_temp.order_id('2'), 'accepted');
select public.transition_order(pg_temp.order_id('2'), 'preparing');
select public.transition_order(pg_temp.order_id('2'), 'ready');
reset role;
select is(
  (select array_agg(courier_id)::text from public.delivery_offers
    where order_id = pg_temp.order_id('2') and status = 'pending'),
  '{00000000-0000-0000-0000-0000000000a2}', 'un livreur en mission n''est pas sollicité'
);
insert into ids select 'b2', id from public.delivery_offers where order_id = pg_temp.order_id('2');
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}';
select lives_ok($$ select public.respond_to_offer((select id from ids where name = 'b2'), false) $$, 'le livreur refuse');
select is((select reopenable from public.courier_declined_offers()), true, 'le refus reste visible et réversible');
select public.courier_reconsider_offer((select id from ids where name = 'b2'));
select is((select status::text from public.delivery_offers where id = (select id from ids where name = 'b2')), 'pending',
  'retour sur le refus : l''offre est de nouveau proposée');
select is((public.courier_deliveries(now() - interval '1 day', now() + interval '1 hour') #>> '{summary,declined}'), '0',
  'refus annulé : plus compté');
select public.respond_to_offer((select id from ids where name = 'b2'), false);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}';
select public.set_courier_online(true);
select public.report_location(6.9000, -6.4300);
reset role;
select private.tick();
select is(
  (select array_agg(courier_id)::text from public.delivery_offers
    where order_id = pg_temp.order_id('2') and status = 'pending'),
  '{00000000-0000-0000-0000-0000000000a3}', 'en attente, elle va au livreur qui devient disponible'
);

-- Désistement avant le retrait : le repas redevient « Prête » et est reproposé (pas à celui qui se désiste).
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}';
select public.release_mission(pg_temp.order_id('1'), 'Pneu crevé');
reset role;
select is(
  (select row(status, courier_id)::text from public.orders where id = pg_temp.order_id('1')),
  row('ready'::public.order_status, null::uuid)::text, 'désistement : la commande redevient « Prête »'
);
select is(
  (select array_agg(courier_id order by courier_id)::text from public.delivery_offers
    where order_id = pg_temp.order_id('1') and status = 'pending'),
  '{00000000-0000-0000-0000-0000000000a2,00000000-0000-0000-0000-0000000000a3}',
  'reproposée aux autres livreurs disponibles'
);

-- Attente prolongée : alerte (restaurant prévenu), mais un repas prêt n'est jamais annulé automatiquement.
update public.orders set dispatch_started_at = now() - interval '31 minutes' where id = pg_temp.order_id('2');
select private.tick();
select ok(
  (select dispatch_alerted_at is not null and status = 'ready' from public.orders where id = pg_temp.order_id('2'))
  and exists (select 1 from public.notifications where order_id = pg_temp.order_id('2') and kind = 'dispatch_alert'
                and user_id = '00000000-0000-0000-0000-0000000000f1'),
  'alerte au restaurant ; le repas prêt reste en attente d''un livreur'
);
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select is((public.cancel_order(pg_temp.order_id('2'))).status, 'cancelled'::public.order_status,
  'après l''alerte, le client peut annuler un repas resté sans livreur');
reset role;
select is((select count(*) from public.delivery_offers where order_id = pg_temp.order_id('2') and status = 'pending')::integer,
  0, 'les offres d''une commande annulée sont retirées');

-- Livreurs affiliés : un restaurant qui en a ne sollicite qu'eux.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select throws_ok($$ select public.admin_set_restaurant_couriers('66666666-6666-6666-6666-666666666666',
  array['00000000-0000-0000-0000-0000000000a3'::uuid]) $$, 'P0001', 'forbidden', 'seul l''admin choisit les affiliés');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}';
select public.admin_set_restaurant_couriers('66666666-6666-6666-6666-666666666666',
  array['00000000-0000-0000-0000-0000000000a3'::uuid]);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}';
select public.transition_order(pg_temp.order_id('3'), 'accepted');
select public.transition_order(pg_temp.order_id('3'), 'preparing');
select public.transition_order(pg_temp.order_id('3'), 'ready');
reset role;
select is(
  (select array_agg(courier_id)::text from public.delivery_offers
    where order_id = pg_temp.order_id('3') and status = 'pending'),
  '{00000000-0000-0000-0000-0000000000a3}', 'restaurant avec affiliés : seuls eux sont sollicités'
);

-- Colis : tous les types proposés sans livreur en ligne ; offre dès la confirmation.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select is(
  (select array_agg(code order by position)::text from public.available_parcel_types(6.8780, -6.4500)),
  '{documents,small,medium}', 'tous les types de colis, livreur en ligne ou non'
);
create temporary table pq on commit drop as
select ((public.quote_parcel(6.8780, -6.4500, 6.8900, -6.4400,
  (select id from public.parcel_types where code = 'small')))->>'total')::integer as total;
select public.place_parcel_order(
  '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
  '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché"}',
  'Koffi', '+2250700000022', (select id from public.parcel_types where code = 'small'), null, true, 'cash',
  (select total from pq), '99999999-0000-0000-0000-000000000004');
reset role;
select ok(
  exists (select 1 from public.delivery_offers where order_id = pg_temp.order_id('4') and status = 'pending'
            and courier_id = '00000000-0000-0000-0000-0000000000a2'),
  'colis confirmé : proposé aux livreurs de la zone'
);

-- DIS-04 : attribution manuelle par l'admin.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}';
select throws_ok(
  $$ select public.admin_assign_courier(pg_temp.order_id('4'), '00000000-0000-0000-0000-0000000000a2', ' ') $$,
  'P0001', 'reason_required', 'l''attribution manuelle exige un motif'
);
select is(
  (select row(status, courier_id)::text
     from public.admin_assign_courier(pg_temp.order_id('4'), '00000000-0000-0000-0000-0000000000a2', 'Client pressé')),
  row('courier_assigned'::public.order_status, '00000000-0000-0000-0000-0000000000a2'::uuid)::text,
  'l''admin attribue le colis, qui passe « Livreur en route »'
);

-- ADM-05 : paramètres lus par tous, modifiés par l'admin seulement (tracé).
update public.settings set offer_timeout_s = 60;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
update public.settings set offer_timeout_s = 20;
select is((select offer_timeout_s from public.settings), 60, 'le client lit les paramètres sans pouvoir les changer');
reset role;
select is((select count(*) from public.audit_log where action = 'settings_updated')::integer, 1,
  'modification des paramètres tracée');

select * from finish();
rollback;
