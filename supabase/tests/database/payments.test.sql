begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000f1', 'gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c2', 'autre@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a1', 'k1@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', last_name = 'Koné', phone = '+2250700000011'
 where id = '00000000-0000-0000-0000-0000000000c1';
update public.profiles set first_name = 'Koffi' where id = '00000000-0000-0000-0000-0000000000a1';
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
create function pg_temp.tx(p_key text) returns public.transactions language sql security definer as $$
  select * from public.transactions where order_id = pg_temp.order_id(p_key)
$$;
create function pg_temp.code(p_key text) returns text language sql security definer as $$
  select code from public.delivery_codes where order_id = pg_temp.order_id(p_key)
$$;
create function pg_temp.place(p_key text) returns void language sql as $$
  select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]', 'cash',
    ((public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
      '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2}]'))->>'total')::integer,
    ('99999999-0000-0000-0000-00000000000' || p_key)::uuid);
$$;

-- TRX-01 / PAY-02 : transaction en attente dès la commande en espèces.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place('1');
select pg_temp.place('2');
select is(
  (select row(status, method, provider, amount = (select total from public.orders where id = pg_temp.order_id('1')))::text
     from pg_temp.tx('1')),
  row('pending'::public.transaction_status, 'cash'::public.payment_method, 'cash', true)::text,
  'transaction espèces en attente, montant égal au total'
);
select is((select count(*) from public.transactions)::integer, 2, 'le client voit ses transactions');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c2');
select is((select count(*) from public.transactions)::integer, 0, 'un autre client ne voit rien');

-- Annulée avant encaissement : transaction annulée.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select public.cancel_order(pg_temp.order_id('2'));
select is((pg_temp.tx('2')).status, 'cancelled'::public.transaction_status,
  'commande annulée avant encaissement : transaction annulée');

-- Livraison puis encaissement : transaction réussie, espèces dues par le livreur.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id('1'), 'accepted');
select public.transition_order(pg_temp.order_id('1'), 'preparing');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.respond_to_offer((select id from public.delivery_offers where status = 'pending'), true);
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select public.transition_order(pg_temp.order_id('1'), 'ready');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select public.confirm_pickup(pg_temp.order_id('1'));
select public.start_delivery(pg_temp.order_id('1'));
select public.confirm_delivery(pg_temp.order_id('1'), pg_temp.code('1'));
select is((pg_temp.tx('1')).status, 'pending'::public.transaction_status,
  'livrée, pas encore encaissée : « Livrée · non encaissée »');
select public.confirm_cash_collected(pg_temp.order_id('1'));
select ok((select status = 'succeeded' and succeeded_at is not null from pg_temp.tx('1')),
  'encaissement confirmé : transaction réussie');

-- PAY-05 : jamais deux transactions actives pour une commande.
reset role;
select throws_ok(
  $$ insert into public.transactions (order_id, amount, currency, method, provider)
     values (pg_temp.order_id('1'), 3000, 'XOF', 'cash', 'cash') $$,
  '23505', null, 'une seule transaction active par commande'
);

-- ADM-04 : solde dû par livreur, versements.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select throws_ok($$ select * from public.admin_cash_balances() $$, 'P0001', 'forbidden',
  'soldes réservés aux admins');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
create temporary table total on commit drop as
select (select total from public.orders where id = pg_temp.order_id('1')) as amount;
select is((select due from public.admin_cash_balances()), (select amount from total)::bigint,
  'espèces dues par le livreur');
select throws_ok(
  $$ select public.admin_record_cash_remittance('00000000-0000-0000-0000-0000000000a1',
       (select amount from total) + 1, 'Reçu 12') $$,
  'P0001', 'amount_exceeds_due', 'pas de versement supérieur au dû'
);
select lives_ok(
  $$ select public.admin_record_cash_remittance('00000000-0000-0000-0000-0000000000a1', 1000, 'Reçu 12') $$,
  'versement enregistré'
);
select is(
  (select row(collected, remitted, due)::text from public.admin_cash_balances()),
  row((select amount from total)::bigint, 1000::bigint, (select amount from total)::bigint - 1000)::text,
  'encaissé, versé, reste dû'
);
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select is((public.courier_summary()->>'cash_due')::integer, (select amount from total) - 1000,
  'le livreur voit son solde diminuer');

-- PAY-01 / ADM-05 : moyens activés par pays ; un fournisseur non intégré ne s'active pas.
reset role;
insert into public.payment_options (country_code, method, operator, provider, label, is_enabled, position)
values ('CI', 'mobile_money', 'wave', 'paystack', 'Wave', false, 9);
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select throws_ok(
  $$ select public.admin_set_payment_option((select id from public.payment_options where provider = 'paystack'), true) $$,
  'P0001', 'payment_unavailable', 'fournisseur non intégré : activation refusée'
);
select public.admin_set_payment_option((select id from public.payment_options where method = 'cash'), false);
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select throws_ok($$ select pg_temp.place('3') $$, 'P0001', 'payment_unavailable',
  'espèces désactivées : commande refusée');
select is((select count(*) from public.payment_options where is_enabled)::integer, 0,
  'le client voit qu''aucun moyen n''est actif');

select * from finish();
rollback;
