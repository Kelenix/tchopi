begin;
create extension if not exists pgtap with schema extensions;
select plan(20);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', phone = '+2250700000011' where id = '00000000-0000-0000-0000-0000000000c1';
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);
update public.zones set is_active = false where id <> '55555555-5555-5555-5555-555555555555';
insert into public.pricing_rules (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, courier_base, courier_per_km)
values ('55555555-5555-5555-5555-555555555555', 'food', 500, 150, 500, 3000, 400, 100);
insert into public.restaurants (id, zone_id, name, category, phone, latitude, longitude, district, landmark,
                                commission_rate, kind)
values ('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555', 'Chez Tantie Rose',
        'Maquis ivoirien', '+2250544183108', 6.8780, -6.4500, 'Commerce', 'Face à la gare', 10, 'restaurant'),
       ('66666666-6666-6666-6666-666666666667', '55555555-5555-5555-5555-555555555555', 'Supérette du Marché',
        'Épicerie', '+2250544183109', 6.8781, -6.4501, 'Commerce', 'Marché central', 8, 'shop');
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
select r, d, '00:00', '23:59:59' from generate_series(1, 7) d,
  unnest(array['66666666-6666-6666-6666-666666666666', '66666666-6666-6666-6666-666666666667']::uuid[]) r;
insert into public.products (id, restaurant_id, name, price, is_available, photo_path) values
  ('77777777-0000-0000-0000-000000000001', '66666666-6666-6666-6666-666666666666', 'Garba', 1500, true, 'demo/garba.jpg'),
  ('77777777-0000-0000-0000-000000000002', '66666666-6666-6666-6666-666666666667', 'Pain de mie', 900, true, null);
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices) values
  ('99999999-0000-0000-0000-0000000000a1', '77777777-0000-0000-0000-000000000001', 'Taille', 1, 1),
  ('99999999-0000-0000-0000-0000000000a2', '77777777-0000-0000-0000-000000000001', 'Suppléments', 0, 2);
insert into public.product_options (id, group_id, name, price_delta, is_available) values
  ('99999999-0000-0000-0000-0000000000b1', '99999999-0000-0000-0000-0000000000a1', 'Normal', 0, true),
  ('99999999-0000-0000-0000-0000000000b2', '99999999-0000-0000-0000-0000000000a1', 'Grand', 500, true),
  ('99999999-0000-0000-0000-0000000000b3', '99999999-0000-0000-0000-0000000000a2', 'Œuf', 200, true),
  ('99999999-0000-0000-0000-0000000000b4', '99999999-0000-0000-0000-0000000000a2', 'Poisson', 1000, false);
insert into public.addresses (id, user_id, district, landmark, latitude, longitude)
values ('88888888-8888-8888-8888-888888888888', '00000000-0000-0000-0000-0000000000c1', 'Lobia',
        'Près du marché', 6.8850, -6.4400);

create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.quote(p_items text) returns jsonb language sql as $$
  select public.quote_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
                                 p_items::jsonb);
$$;

-- Catalogue public : visiteur sans compte.
set local role anon;
select is((select count(*) from public.public_zones())::integer, 1, 'zones actives visibles sans compte');
select is((select array_agg(kind order by name) from public.public_establishments('55555555-5555-5555-5555-555555555555'))::text,
  '{restaurant,shop}', 'restaurants et magasins de la zone visibles sans compte');
select ok(not (public.public_establishment('66666666-6666-6666-6666-666666666666') ? 'commission_rate')
          and not (public.public_establishment('66666666-6666-6666-6666-666666666666') ? 'phone'),
  'fiche publique sans commission ni téléphone');
select is(jsonb_array_length(public.public_establishment('66666666-6666-6666-6666-666666666666')
                              -> 'products' -> 0 -> 'option_groups'), 2, 'fiche publique avec les options');
select is((select array_agg(name) from public.public_featured_products('55555555-5555-5555-5555-555555555555'))::text,
  '{Garba}', 'produits en vedette : seulement ceux avec photo');
select is((select array_agg(name order by name) from public.public_search('55555555-5555-5555-5555-555555555555', 'SUPERETTE'))::text,
  '{"Supérette du Marché"}', 'recherche sans accents ni majuscules');
select throws_ok($$ select count(*) from public.restaurants $$, '42501', null, 'les tables restent fermées aux visiteurs');

-- Candidature d'un établissement, sans compte.
select lives_ok($$ select public.submit_partner_application('shop', 'Boutique Awa', 'Awa Koné', '+2250700000099',
  'awa@exemple.ci', 'Daloa', 'Épicerie de quartier') $$, 'candidature envoyée sans compte');
select throws_ok($$ select public.submit_partner_application('shop', 'Boutique Awa', 'Awa Koné', '+2250700000099',
  null, 'Daloa', null) $$, 'P0001', 'already_submitted', 'une seule candidature en attente par numéro');

-- Options dans le devis et la commande.
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c1');
select is((select count(*) from public.partner_applications)::integer, 0, 'un client ne lit pas les candidatures');
select is(pg_temp.quote('[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":2,
  "options":["99999999-0000-0000-0000-0000000000b2","99999999-0000-0000-0000-0000000000b3"]}]') ->> 'subtotal',
  '4400', 'prix unitaire = produit + options (1 500 + 500 + 200) × 2');
select is(pg_temp.quote('[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1}]') -> 'issues' -> 0 ->> 'issue',
  'options_required', 'choix obligatoire manquant signalé');
select is(pg_temp.quote('[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1,
  "options":["99999999-0000-0000-0000-0000000000b1","99999999-0000-0000-0000-0000000000b4"]}]') -> 'issues' -> 0 ->> 'issue',
  'option_unavailable', 'option indisponible signalée');
select is(pg_temp.quote('[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1,
  "options":["99999999-0000-0000-0000-0000000000b1","99999999-0000-0000-0000-0000000000b2"]}]') -> 'issues' -> 0 ->> 'issue',
  'options_required', 'deux choix dans un groupe à choix unique refusés');
select is((public.place_food_order('66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888',
    '[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1,"options":["99999999-0000-0000-0000-0000000000b2"]}]',
    'cash', (pg_temp.quote('[{"product_id":"77777777-0000-0000-0000-000000000001","quantity":1,
      "options":["99999999-0000-0000-0000-0000000000b2"]}]') ->> 'total')::integer,
    '99999999-0000-0000-0000-00000000c0de')).subtotal, 2000, 'commande passée avec ses options');
select is((select name || ' / ' || (options -> 0 ->> 'name') from public.order_items), 'Garba (Grand) / Grand',
  'les options sont recopiées dans la commande et son libellé');

-- Administration.
select throws_ok($$ select public.admin_review_partner_application((select id from public.partner_applications limit 1), 'approved') $$,
  'P0001', 'forbidden', 'seul un admin examine les candidatures');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select public.admin_review_partner_application((select id from public.partner_applications limit 1), 'approved');
select is((select status from public.partner_applications), 'approved', 'candidature acceptée par l''admin');
select public.admin_save_restaurant('66666666-6666-6666-6666-666666666667', '55555555-5555-5555-5555-555555555555',
  'Supérette du Marché', null, 'Épicerie', '+2250544183109', 6.8781, -6.4501, 'Commerce', 'Marché central', 8, true);
select is((select kind from public.restaurants where id = '66666666-6666-6666-6666-666666666667'), 'shop',
  'enregistrement depuis le mobile (sans type) : le magasin reste un magasin');
select public.admin_save_restaurant(null, '55555555-5555-5555-5555-555555555555', 'Pharmacie du Centre', null, null,
  '+2250544183110', 6.8782, -6.4502, 'Commerce', 'Rond-point', 5, true, 'shop');
select is((select kind from public.restaurants where name = 'Pharmacie du Centre'), 'shop', 'magasin créé par l''admin');

select * from finish();
rollback;
