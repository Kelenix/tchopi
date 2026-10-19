begin;
create extension if not exists pgtap with schema extensions;
select plan(18);

-- Jeu de données propre au test (indépendant des données de développement).
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c2', 'autre@exemple.ci', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated');
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');

insert into public.zones (id, name, city, center_lat, center_lng, radius_m, is_active) values
  ('22222222-2222-2222-2222-222222222222', 'Bouaké centre', 'Bouaké', 7.6900, -5.0300, 5000, true),
  ('33333333-3333-3333-3333-333333333333', 'Zone fermée', 'Korhogo', 9.4580, -5.6290, 5000, false);
-- Zones d'essai seules actives (les villes de départ couvrent aussi Bouaké et Korhogo).
update public.zones set is_active = false where id::text like '11111111-1111-1111-1111-%';
insert into public.pricing_rules
  (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, detour_factor, rounding_step, courier_base, courier_per_km)
values ('22222222-2222-2222-2222-222222222222', 'food', 500, 150, 500, 3000, 1.30, 25, 400, 100);

-- Calcul des frais (exemple de la story ADR-07).
select results_eq(
  $$ select distance_m, delivery_fee, courier_earning
       from private.price_delivery('22222222-2222-2222-2222-222222222222', 'food', 4000) $$,
  $$ values (5200, 1300, 925) $$,
  '4 km à vol d''oiseau : 5,2 km, frais 1 300 F (arrondis à 25 F), livreur 925 F'
);
select is(
  (select delivery_fee from private.price_delivery('22222222-2222-2222-2222-222222222222', 'food', 0)),
  500, 'les frais ne descendent jamais sous le plancher'
);
select is(
  (select delivery_fee from private.price_delivery('22222222-2222-2222-2222-222222222222', 'food', 30000)),
  3000, 'les frais ne dépassent jamais le plafond'
);

-- Session du client.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';

select ok(
  exists (select 1 from public.zones where id = '22222222-2222-2222-2222-222222222222')
  and not exists (select 1 from public.zones where id = '33333333-3333-3333-3333-333333333333'),
  'un client voit les zones actives et pas les zones désactivées'
);
select throws_ok(
  $$ insert into public.zones (name, city, center_lat, center_lng, radius_m) values ('X', 'X', 0, 0, 1000) $$,
  '42501', null, 'un client ne peut pas créer de zone'
);
select is((select count(*)::int from public.pricing_rules), 0, 'les règles tarifaires ne sont pas exposées aux clients');
select throws_ok(
  $$ select * from public.admin_simulate_fee('22222222-2222-2222-2222-222222222222', 'food', 4) $$,
  'P0001', 'forbidden', 'le simulateur de tarifs est réservé aux admins'
);

insert into public.addresses (label, district, landmark, instructions, latitude, longitude)
values ('Maison', 'Commerce', 'Derrière la grande mosquée', 'Portail bleu', 7.6905, -5.0310);
select ok(
  (select city = 'Bouaké' and zone_id = '22222222-2222-2222-2222-222222222222' and is_default
     from public.addresses where landmark = 'Derrière la grande mosquée'),
  'la ville et la zone sont déduites de la position ; la première adresse est l''adresse par défaut'
);
select throws_ok(
  $$ insert into public.addresses (district, landmark, latitude, longitude) values ('Loin', 'Hors de la ville', 7.8000, -5.0300) $$,
  'P0001', 'address_out_of_zone', 'une adresse hors de toute zone active est refusée'
);
select throws_ok(
  $$ insert into public.addresses (district, landmark, latitude, longitude) values ('Korhogo', 'Zone fermée', 9.4580, -5.6290) $$,
  'P0001', 'address_out_of_zone', 'une adresse dans une zone désactivée est refusée'
);
select throws_ok(
  $$ update public.addresses set zone_id = '33333333-3333-3333-3333-333333333333' $$,
  '42501', null, 'la zone d''une adresse ne peut pas être forcée depuis l''app'
);

insert into public.addresses (label, district, landmark, latitude, longitude)
values ('Bureau', 'Air France', 'Face à la pharmacie du marché', 7.6880, -5.0280);
select ok(
  (select not is_default from public.addresses where label = 'Bureau'),
  'une deuxième adresse n''est pas par défaut'
);
update public.addresses set is_default = true where label = 'Bureau';
select is(
  (select array_agg(label order by label) from public.addresses where is_default),
  array['Bureau'], 'choisir une nouvelle adresse par défaut remplace l''ancienne'
);

-- Un autre client ne voit ni ne modifie ces adresses.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}';
select is((select count(*)::int from public.addresses), 0, 'un client ne voit pas les adresses des autres');
update public.addresses set landmark = 'Piratée';
delete from public.addresses;

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select is(
  (select count(*)::int from public.addresses where landmark <> 'Piratée'),
  2, 'un client ne peut ni modifier ni supprimer les adresses des autres'
);

delete from public.addresses where label = 'Bureau';
select is(
  (select label from public.addresses where is_default),
  'Maison', 'supprimer l''adresse par défaut promeut la plus récente restante'
);

-- Admin.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}';
select results_eq(
  $$ select delivery_fee from public.admin_simulate_fee('22222222-2222-2222-2222-222222222222', 'food', 4) $$,
  $$ values (1300) $$, 'un admin simule les frais d''une règle'
);
select ok(
  exists (select 1 from public.zones where id = '33333333-3333-3333-3333-333333333333')
  and (select count(*) from public.pricing_rules) >= 1,
  'un admin voit toutes les zones et les règles tarifaires'
);

select * from finish();
rollback;
