begin;
create extension if not exists pgtap with schema extensions;
select plan(24);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000f1', 'gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c2', 'autre@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', last_name = 'Koné', phone = '+2250700000011'
 where id = '00000000-0000-0000-0000-0000000000c1';
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
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
insert into public.products (id, restaurant_id, name, price, is_available) values
  ('77777777-0000-0000-0000-000000000001', '66666666-6666-6666-6666-666666666666', 'Garba', 1500, true),
  ('77777777-0000-0000-0000-000000000002', '66666666-6666-6666-6666-666666666666', 'Bissap', 500, true),
  ('77777777-0000-0000-0000-000000000003', '66666666-6666-6666-6666-666666666666', 'Kédjénou', 3500, false);

insert into public.addresses (id, user_id, district, landmark, latitude, longitude)
values ('88888888-8888-8888-8888-888888888888', '00000000-0000-0000-0000-0000000000c1', 'Lobia',
        'Près du marché', 6.8850, -6.4400);
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';

-- Devis : montants serveur et écarts signalés sans erreur.
select is(
  (public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2},
      {"product_id":"77777777-0000-0000-0000-000000000002","quantity":1}]'))->>'subtotal',
  '3500', 'le devis calcule le sous-total à partir des prix serveur'
);
select ok(
  not (public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]')) ? 'courier_earning',
  'le devis ne révèle pas la rémunération du livreur'
);
select is(
  (public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000003","quantity":1}]'))->'issues'->0->>'issue',
  'product_unavailable', 'un produit indisponible est signalé dans le devis'
);
select throws_ok(
  $$ select public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
       '[]') $$,
  'P0001', 'cart_empty', 'un panier vide est refusé'
);

-- Création : écarts, prix, paiement, puis commande unique malgré un double envoi.
select throws_ok(
  $$ select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
       '[{"product_id":"77777777-0000-0000-0000-000000000003","quantity":1}]', 'cash', 4000,
       '99999999-0000-0000-0000-000000000001') $$,
  'P0001', 'cart_changed', 'une commande avec un produit indisponible est refusée'
);
select throws_ok(
  $$ select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
       '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]', 'cash', 1,
       '99999999-0000-0000-0000-000000000001') $$,
  'P0001', 'price_changed', 'un total différent de celui affiché est refusé'
);
select throws_ok(
  $$ select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
       '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]', 'card', 1,
       '99999999-0000-0000-0000-000000000001') $$,
  'P0001', 'payment_unavailable', 'la carte n''est pas encore proposée'
);

create temporary table expected on commit drop as
select ((public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
  '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]'))->>'total')::integer as total;
grant select on expected to authenticated;
select lives_ok(
  $$ select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
       '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]', 'cash', (select total from expected),
       '99999999-0000-0000-0000-000000000002') $$,
  'le client passe commande en espèces'
);
select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
  '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]', 'cash', (select total from expected),
  '99999999-0000-0000-0000-000000000002');
select is((select count(*) from public.orders)::integer, 1, 'un double envoi ne crée qu''une commande');
select matches((select number from public.orders), '^R-[2-9A-HJ-NP-Z]{5}$', 'numéro court lisible');
select is(
  (select row(status, subtotal, commission_amount, recipient_name, pickup_name)::text from public.orders),
  row('pending'::public.order_status, 3000, 300, 'Awa Koné', 'Chez Tantie Rose')::text,
  'statut, montants, commission et adresses figés'
);
select is((select count(*) from public.order_items)::integer, 1, 'lignes de commande copiées');
select throws_ok(
  $$ update public.orders set total = 1 $$, '42501', null, 'aucune modification directe d''une commande'
);

-- Confidentialité : un autre client ne voit rien.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}';
select is((select count(*) from public.orders)::integer, 0, 'un autre client ne voit pas la commande');
select throws_ok(
  $$ select public.cancel_order((select id from public.orders limit 1)) $$, 'P0001', null,
  'un autre client ne peut rien annuler'
);

-- Restaurant : voit la commande, refus motivé exigé, transitions dans l'ordre.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}';
create temporary table o on commit drop as select id from public.orders;
grant select on o to authenticated;
select is((select count(*) from public.orders)::integer, 1, 'le restaurant voit sa commande');
select throws_ok(
  $$ select public.transition_order((select id from o), 'rejected', '  ') $$,
  'P0001', 'reason_required', 'un refus exige un motif'
);
select throws_ok(
  $$ select public.transition_order((select id from o), 'ready') $$,
  'P0001', 'invalid_transition', 'impossible de sauter des étapes'
);
select lives_ok($$ select public.transition_order((select id from o), 'accepted') $$, 'le restaurant accepte');

-- Client : annulation refusée une fois acceptée.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select throws_ok(
  $$ select public.cancel_order((select id from o)) $$,
  'P0001', 'already_accepted', 'le client ne peut plus annuler une commande acceptée'
);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}';
select public.transition_order((select id from o), 'preparing');
select public.transition_order((select id from o), 'ready');
select is(
  (select array_agg(status order by id)::text from public.order_events),
  '{pending,accepted,preparing,ready}', 'chronologie complète, dans l''ordre'
);

-- Refus automatique après 10 minutes sans réponse.
reset role;
insert into public.orders (number, type, status, customer_id, zone_id, currency, restaurant_id,
  pickup_lat, pickup_lng, pickup_name, pickup_district, pickup_landmark, dropoff_lat, dropoff_lng, recipient_name,
  dropoff_district, dropoff_landmark, subtotal, delivery_fee, total, commission_amount, courier_earning,
  platform_amount, distance_m, payment_method, idempotency_key, created_at)
values ('R-OLD22', 'food', 'pending', '00000000-0000-0000-0000-0000000000c1', '55555555-5555-5555-5555-555555555555',
  'XOF', '66666666-6666-6666-6666-666666666666', 6.878, -6.45, 'Chez Tantie Rose', 'Commerce', 'Gare', 6.885, -6.44,
  'Awa', 'Lobia', 'Marché', 1500, 500, 2000, 150, 400, 250, 1200, 'cash', gen_random_uuid(),
  now() - interval '11 minutes');
select is(private.reject_unanswered_orders(), 1, 'une commande sans réponse depuis 10 min est refusée');
select is(
  (select row(status, close_reason)::text from public.orders where number = 'R-OLD22'),
  row('rejected'::public.order_status, 'no_response')::text, 'motif « sans réponse du restaurant »'
);

-- Client : annulation possible tant que le restaurant n'a pas accepté.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
  '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]', 'cash', (select total from expected),
  '99999999-0000-0000-0000-000000000003');
select is(
  (public.cancel_order((select id from public.orders where status = 'pending'))).status,
  'cancelled'::public.order_status, 'le client annule une commande en attente'
);

select * from finish();
rollback;
