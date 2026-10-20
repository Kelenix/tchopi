begin;
create extension if not exists pgtap with schema extensions;
select plan(24);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
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
values ('55555555-5555-5555-5555-555555555555', 'food', 500, 150, 500, 3000, 400, 100);
insert into public.restaurants (id, zone_id, name, phone, latitude, longitude, district, landmark, commission_rate)
values ('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555', 'Chez Tantie Rose',
        '+2250544183108', 6.8780, -6.4500, 'Commerce', 'Face à la gare', 10);
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
-- Adresse de la fonction de remboursement (déjà présente après le seed local).
select vault.create_secret('http://kong:8000/functions/v1/payments-refund', 'refund_function_url')
 where not exists (select 1 from vault.secrets where name = 'refund_function_url');
select vault.create_secret('cle-de-service', 'refund_function_key')
 where not exists (select 1 from vault.secrets where name = 'refund_function_key');

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
create function pg_temp.place_food(p_key text, p_method public.payment_method) returns void language sql as $$
  select public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]', p_method,
    ((public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
      '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]'))->>'total')::integer,
    ('99999999-0000-0000-0000-00000000000' || p_key)::uuid);
$$;

-- ADM-05 : la carte (Stripe) est activable par l'admin.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select lives_ok(
  $$ select public.admin_set_payment_option((select id from public.payment_options where method = 'card'), true) $$,
  'carte activée'
);

-- PAY-04 : la commande attend la confirmation de Stripe ; session ouverte pour la commande du client seulement.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_food('1', 'card');
select is(pg_temp.state('1'), 'awaiting_payment/unpaid/pending', 'en attente du paiement, transaction ouverte');
select is(
  (select (public.begin_online_payment(pg_temp.order_id('1')))->>'provider'),
  'stripe', 'session ouverte chez Stripe'
);
select pg_temp.place_food('2', 'cash');
select throws_ok($$ select public.begin_online_payment(pg_temp.order_id('2')) $$,
  'P0001', 'not_found', 'rien à payer en ligne pour une commande en espèces');

-- Confirmé par Stripe (devise en minuscules chez Stripe) : commande transmise, intention de paiement gardée.
reset role;
select public.record_checkout_session(pg_temp.tx('1'), 'cs_test_1', 'https://checkout.stripe.com/c/pay/cs_test_1',
  null, 0);
select is(
  public.apply_payment_status(pg_temp.tx('1'), 'SUCCESS',
    (select total from public.orders where id = pg_temp.order_id('1')), 'xof', 'pi_1'),
  'succeeded', 'paiement confirmé'
);
select is(pg_temp.state('1'), 'pending/paid/succeeded', 'commande transmise au restaurant');
select is((select provider_reference from public.transactions where id = pg_temp.tx('1')), 'pi_1',
  'référence Stripe enregistrée');

-- TRX-03 : annulée après paiement, la commande est remboursée automatiquement par Stripe.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select public.cancel_order(pg_temp.order_id('1'));
reset role;
select is(pg_temp.state('1'), 'cancelled/refund_pending/succeeded', 'annulée : à rembourser');
select private.request_refunds();
select isnt((select refund_requested_at from public.transactions where id = pg_temp.tx('1')), null,
  'remboursement demandé à Stripe');
update public.transactions set refund_requested_at = now() - interval '1 minute' where id = pg_temp.tx('1');
select private.request_refunds();
select ok((select refund_requested_at < now() - interval '30 seconds' from public.transactions
            where id = pg_temp.tx('1')), 'pas de nouvelle demande avant 10 min');

select is(public.record_provider_refund(pg_temp.tx('1'), 're_1'), 'refunded', 'remboursement accepté par Stripe');
select is(pg_temp.state('1'), 'cancelled/refunded/refunded', 'transaction et commande remboursées');
select is(
  (select actor_role || '/' || reason from public.order_events
    where order_id = pg_temp.order_id('1') and kind = 'refunded'),
  'system/re_1', 'chronologie : remboursement automatique avec sa référence'
);
select is(public.record_provider_refund(pg_temp.tx('1'), 're_1'), 'refunded', 'confirmation rejouée : sans effet');

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select throws_ok($$ select public.record_provider_refund(pg_temp.tx('1'), 're_2') $$,
  '42501', null, 'seul le serveur enregistre un remboursement');

-- ADR-039 : remboursement refusé après coup par la banque → de nouveau « à rembourser », alerte admin.
reset role;
select is(public.record_refund_failure(pg_temp.tx('1'), 're_autre'), 'refunded',
  'échec d''un autre remboursement : sans effet');
select is(public.record_refund_failure(pg_temp.tx('1'), 're_1'), 'refund_pending', 'échec du remboursement enregistré');
select is(pg_temp.state('1'), 'cancelled/refund_pending/succeeded', 'commande de nouveau à rembourser');
select is((select count(*)::int from public.audit_log where action = 'refund_failed' and target_id = pg_temp.tx('1')),
  1, 'admin alerté');
select is(public.record_refund_failure(pg_temp.tx('1'), 're_1'), 'refund_pending', 'échec rejoué : sans effet');

-- Remboursement signalé par le fournisseur (nyole : fait par son équipe) : appliqué, tracé s'il n'était pas demandé.
select is(public.apply_payment_status(pg_temp.tx('1'), 'REFUNDED', null, null, 're_manuel'), 'refunded',
  'remboursement du fournisseur appliqué');
select is(pg_temp.state('1'), 'cancelled/refunded/refunded', 'commande remboursée');
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select pg_temp.place_food('3', 'card');
reset role;
select public.record_checkout_session(pg_temp.tx('3'), 'cs_test_3', 'https://checkout.stripe.com/c/pay/cs_test_3',
  null, 0);
select public.apply_payment_status(pg_temp.tx('3'), 'SUCCESS',
  (select total from public.orders where id = pg_temp.order_id('3')), 'XOF', 'pi_3');
select public.apply_payment_status(pg_temp.tx('3'), 'REFUNDED', null, null, null);
select is(pg_temp.state('3'), 'pending/refunded/refunded', 'remboursement non demandé appliqué');
select is((select count(*)::int from public.audit_log
            where action = 'payment_refunded_by_provider' and target_id = pg_temp.tx('3')),
  1, 'remboursement non demandé signalé à l''admin');

select * from finish();
rollback;
