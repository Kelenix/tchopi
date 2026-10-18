begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c2', 'autre@exemple.ci', 'authenticated', 'authenticated', now());
update public.profiles set first_name = 'Awa', last_name = 'Koné', phone = '+2250700000011'
 where id = '00000000-0000-0000-0000-0000000000c1';
insert into public.zones (id, name, city, center_lat, center_lng, radius_m) values
  ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000),
  ('55555555-5555-5555-5555-555555555556', 'Man', 'Man', 7.4125, -7.5538, 6000);
insert into public.pricing_rules (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, courier_base, courier_per_km)
values ('55555555-5555-5555-5555-555555555555', 'parcel', 700, 175, 700, 4000, 500, 120);

create temporary table pt on commit drop as select id from public.parcel_types where code = 'small';
grant select on pt to authenticated;

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';

select is((select count(*) from public.parcel_types)::integer, 3, 'trois types de colis proposés');
select ok(
  ((public.quote_parcel(6.8780, -6.4500, 6.8900, -6.4400, (select id from pt)))->>'delivery_fee')::integer >= 700,
  'devis colis selon les règles de la zone'
);
select throws_ok(
  $$ select public.quote_parcel(6.8780, -6.4500, 7.4125, -7.5538, (select id from pt)) $$,
  'P0001', 'different_zones', 'pas de livraison entre villes'
);
select throws_ok(
  $$ select public.quote_parcel(6.8780, -6.4500, 0, 0, (select id from pt)) $$,
  'P0001', 'address_out_of_zone', 'arrivée hors zone refusée'
);
select throws_ok(
  $$ select public.quote_parcel(6.8780, -6.4500, 6.8785, -6.4500, (select id from pt)) $$,
  'P0001', 'same_location', 'départ et arrivée à moins de 100 m refusés'
);

create temporary table q on commit drop as
select ((public.quote_parcel(6.8780, -6.4500, 6.8900, -6.4400, (select id from pt)))->>'total')::integer as total;
grant select on q to authenticated;

select throws_ok(
  $$ select public.place_parcel_order(
       '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
       '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché"}',
       'Koffi', '+2250700000022', (select id from pt), 'Un sac', false, 'cash', (select total from q),
       '99999999-0000-0000-0000-000000000001') $$,
  'P0001', 'rules_not_accepted', 'la liste des objets autorisés doit être acceptée'
);
select throws_ok(
  $$ select public.place_parcel_order(
       '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
       '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché"}',
       'Koffi', '0700000022', (select id from pt), 'Un sac', true, 'cash', (select total from q),
       '99999999-0000-0000-0000-000000000001') $$,
  'P0001', 'invalid_recipient', 'téléphone du destinataire au format international'
);
select lives_ok(
  $$ select public.place_parcel_order(
       '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
       '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché","instructions":"Portail bleu"}',
       'Koffi', '+2250700000022', (select id from pt), 'Un sac de vêtements', true, 'cash', (select total from q),
       '99999999-0000-0000-0000-000000000002') $$,
  'le client envoie un colis en espèces'
);
select public.place_parcel_order(
  '{"lat":6.878,"lng":-6.45,"district":"Commerce","landmark":"Face à la gare"}',
  '{"lat":6.89,"lng":-6.44,"district":"Lobia","landmark":"Près du marché"}',
  'Koffi', '+2250700000022', (select id from pt), 'Un sac', true, 'cash', (select total from q),
  '99999999-0000-0000-0000-000000000002');
select is((select count(*) from public.orders)::integer, 1, 'un double envoi ne crée qu''une demande');
select is(
  (select row(type, status, subtotal, total = delivery_fee, pickup_name, recipient_name, dropoff_instructions)::text
     from public.orders),
  row('parcel'::public.order_type, 'searching_courier'::public.order_status, 0, true, 'Awa Koné', 'Koffi',
      'Portail bleu')::text,
  'statut « recherche de livreur », montants et adresses figés'
);
select matches((select number from public.orders), '^C-[2-9A-HJ-NP-Z]{5}$', 'identifiant court de colis');
select matches((select code from public.delivery_codes), '^[0-9]{4}$', 'code de livraison à 4 chiffres pour le client');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}';
select is((select count(*) from public.delivery_codes)::integer, 0, 'personne d''autre ne lit le code');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select is(
  (public.cancel_order((select id from public.orders limit 1))).status,
  'cancelled'::public.order_status, 'le client annule un colis non récupéré'
);

reset role;
update public.orders set status = 'picked_up';
set local role authenticated;
select throws_ok(
  $$ select public.cancel_order((select id from public.orders limit 1)) $$,
  'P0001', 'already_picked_up', 'impossible d''annuler un colis récupéré'
);

select * from finish();
rollback;
