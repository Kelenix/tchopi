begin;
create extension if not exists pgtap with schema extensions;
select plan(18);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c2', 'autre@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', phone = '+2250700000011' where id = '00000000-0000-0000-0000-0000000000c1';
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);
update public.zones set is_active = false where id <> '55555555-5555-5555-5555-555555555555';
-- Grille par défaut : 500 F + 100 F par km, arrondi à 5 F.
insert into public.pricing_rules (zone_id, service, courier_base, courier_per_km)
values ('55555555-5555-5555-5555-555555555555', 'food', 400, 100);
insert into public.restaurants (id, zone_id, name, category, phone, latitude, longitude, district, landmark, commission_rate)
values ('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555', 'Chez Tantie Rose',
        'Maquis ivoirien', '+2250544183108', 6.8780, -6.4500, 'Commerce', 'Face à la gare', 10),
       ('66666666-6666-6666-6666-666666666667', '55555555-5555-5555-5555-555555555555', 'Doublon',
        'Maquis ivoirien', '+2250544183109', 6.8781, -6.4501, 'Commerce', 'Marché', 10);
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
select '66666666-6666-6666-6666-666666666666', d, '00:00', '23:59:59' from generate_series(1, 7) d;
insert into public.products (id, restaurant_id, name, price, is_available)
values ('77777777-0000-0000-0000-000000000001', '66666666-6666-6666-6666-666666666666', 'Garba', 1500, true);
insert into public.addresses (id, user_id, district, landmark, latitude, longitude)
values ('88888888-8888-8888-8888-888888888888', '00000000-0000-0000-0000-0000000000c1', 'Lobia',
        'Près du marché', 6.8850, -6.4400);

create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.quote() returns jsonb language sql as $$
  select public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
                                 '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]');
$$;

-- Frais de livraison : serveur de trajets absent ou injoignable → distance estimée (vol d'oiseau × détour).
select is(private.road_distance_m(extensions.st_point(-6.45, 6.878, 4326)::extensions.geography,
                                  extensions.st_point(-6.44, 6.885, 4326)::extensions.geography), null,
  'sans serveur de trajets, pas de distance routière');
insert into private.config (key, value) values ('routing_url', 'http://127.0.0.1:9');
select is(private.road_distance_m(extensions.st_point(-6.45, 6.878, 4326)::extensions.geography,
                                  extensions.st_point(-6.44, 6.885, 4326)::extensions.geography), null,
  'serveur de trajets injoignable : repli sans erreur');

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select is(pg_temp.quote() ->> 'distance_source', 'estimate', 'distance signalée comme estimée');
select is((pg_temp.quote() ->> 'delivery_fee')::integer,
  (ceil((500 + 100 * (pg_temp.quote() ->> 'distance_m')::integer / 1000.0) / 5) * 5)::integer,
  'frais = 500 + 100 × km, arrondis à 5 F');
select is((pg_temp.quote() ->> 'total')::integer, 1500 + (pg_temp.quote() ->> 'delivery_fee')::integer,
  'total = produits + livraison');
select lives_ok($$ select public.place_food_order('66666666-6666-6666-6666-666666666666',
  '88888888-8888-8888-8888-888888888888', '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]',
  'cash', (pg_temp.quote() ->> 'total')::integer, '99999999-0000-0000-0000-00000000c0de') $$,
  'commande passée au prix du devis');
select is((select delivery_fee from public.orders), (pg_temp.quote() ->> 'delivery_fee')::integer,
  'frais enregistrés avec la commande');
select throws_ok($$ select public.admin_dashboard(now() - interval '7 days', now(), 'day') $$,
  'P0001', 'forbidden', 'tableau de bord réservé aux admins');

-- Tableau de bord et paiements.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select is(public.admin_dashboard(now() - interval '7 days', now() + interval '1 hour', 'day') #>> '{orders,in_progress}', '1',
  'commande en cours comptée');
select is(jsonb_array_length(public.admin_dashboard(date_trunc('day', now()) - interval '6 days',
                                                    date_trunc('day', now()) + interval '1 day', 'day') -> 'series'), 7,
  'série complète : un point par jour, même sans commande');
select is((public.admin_dashboard(now() - interval '1 day', now() + interval '1 hour', 'hour') -> 'by_zone' -> 0 ->> 'orders'),
  '1', 'répartition par ville');
select throws_ok($$ select public.admin_dashboard(now() - interval '60 days', now(), 'hour') $$,
  'P0001', 'period_too_long', 'série trop longue refusée');
select is(public.admin_payment_stats(now() - interval '1 day', now() + interval '1 hour', 'day') #>> '{by_outcome,pending,count}',
  '1', 'paiement en espèces en attente jusqu''à la livraison');
select is((select e ->> 'count' from jsonb_array_elements(
           public.admin_payment_stats(now() - interval '1 day', now() + interval '1 hour', 'day') -> 'by_method') e
          where e ->> 'method' = 'cash'), '1', 'répartition par moyen de paiement');

-- Actions d'administration.
select throws_ok($$ select public.admin_delete_restaurant('66666666-6666-6666-6666-666666666666') $$,
  'P0001', 'restaurant_has_orders', 'établissement avec commandes : à désactiver, pas à supprimer');
select public.admin_delete_restaurant('66666666-6666-6666-6666-666666666667');
select is((select count(*) from public.restaurants where id = '66666666-6666-6666-6666-666666666667')::integer, 0,
  'établissement sans commande supprimé');
select throws_ok($$ select public.admin_delete_account('00000000-0000-0000-0000-0000000000c1') $$,
  'P0001', 'account_busy', 'compte avec une commande en cours conservé');
select public.admin_update_profile('00000000-0000-0000-0000-0000000000c2', ' Koffi ', '');
select public.admin_delete_account('00000000-0000-0000-0000-0000000000c2');
select ok((select deleted_at is not null and first_name is null from public.profiles
            where id = '00000000-0000-0000-0000-0000000000c2'), 'compte anonymisé par l''admin');

select * from finish();
rollback;
