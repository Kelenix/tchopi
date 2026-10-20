begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a1', 'gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000a2', 'autre-gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000d1', 'livreur@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000d2', 'nouveau@exemple.ci', 'authenticated', 'authenticated', now());
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);
insert into public.restaurants (id, zone_id, name, category, phone, latitude, longitude, district, landmark)
values ('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555', 'Chez Tantie Rose',
        'Maquis ivoirien', '+2250544183108', 6.8780, -6.4500, 'Commerce', 'Face à la gare'),
       ('66666666-6666-6666-6666-666666666667', '55555555-5555-5555-5555-555555555555', 'Le Voisin',
        'Grillades', '+2250544183109', 6.8781, -6.4501, 'Commerce', 'Marché central');
insert into public.restaurant_members (restaurant_id, user_id, login_email) values
  ('66666666-6666-6666-6666-666666666666', '00000000-0000-0000-0000-0000000000a1', 'gerant@exemple.ci'),
  ('66666666-6666-6666-6666-666666666667', '00000000-0000-0000-0000-0000000000a2', 'autre-gerant@exemple.ci');
insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path, status, approved_at) values
  ('00000000-0000-0000-0000-0000000000d1', '55555555-5555-5555-5555-555555555555', 'motorbike', 'AB-123', '00000000-0000-0000-0000-0000000000d1/p.jpg', 'approved', now()),
  ('00000000-0000-0000-0000-0000000000d2', '55555555-5555-5555-5555-555555555555', 'motorbike', 'AB-124', '00000000-0000-0000-0000-0000000000d2/p.jpg', 'pending', null);

create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;
set local role authenticated;

-- Candidature d'un livreur validé ; pas de doublon ; livreur non validé refusé.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d1');
select lives_ok($$ select public.courier_request_affiliation('66666666-6666-6666-6666-666666666666', 'Je connais le quartier') $$,
  'un livreur validé postule auprès d''un restaurant');
select throws_ok($$ select public.courier_request_affiliation('66666666-6666-6666-6666-666666666666') $$,
  'P0001', 'already_submitted', 'pas de candidature en double');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d2');
select throws_ok($$ select public.courier_request_affiliation('66666666-6666-6666-6666-666666666666') $$,
  'P0001', 'courier_not_approved', 'un livreur non validé par l''admin ne postule pas');

-- Décision : seul le restaurant concerné ; notification du livreur ; transitions encadrées.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a2');
select throws_ok($$ select * from public.restaurant_couriers_list('66666666-6666-6666-6666-666666666666') $$,
  'P0001', 'forbidden', 'un autre restaurant ne voit pas les livreurs');
select throws_ok($$ select public.restaurant_set_affiliation('66666666-6666-6666-6666-666666666666',
  '00000000-0000-0000-0000-0000000000d1', 'approved') $$, 'P0001', 'forbidden', 'un autre restaurant ne décide pas');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select is((select status || ' / ' || message from public.restaurant_couriers_list('66666666-6666-6666-6666-666666666666')),
  'pending / Je connais le quartier', 'le restaurant voit la candidature');
select throws_ok($$ select public.restaurant_set_affiliation('66666666-6666-6666-6666-666666666666',
  '00000000-0000-0000-0000-0000000000d1', 'ended') $$, 'P0001', 'invalid_transition', 'transition non prévue refusée');
select public.restaurant_set_affiliation('66666666-6666-6666-6666-666666666666', '00000000-0000-0000-0000-0000000000d1', 'approved');
reset role;
select is((select title from public.notifications where user_id = '00000000-0000-0000-0000-0000000000d1'),
  'Affiliation acceptée', 'le livreur est prévenu');
select is((select count(*) from public.notifications where user_id = '00000000-0000-0000-0000-0000000000a1')::integer, 1,
  'le restaurant a été prévenu de la candidature');
set local role authenticated;
select public.restaurant_set_affiliation('66666666-6666-6666-6666-666666666666', '00000000-0000-0000-0000-0000000000d1', 'suspended');
select is((select status from public.restaurant_couriers), 'suspended', 'affiliation suspendue');

-- Profil : modification dans la zone ; hors zone refusée ; autre restaurant refusé.
select lives_ok($$ select public.restaurant_update_profile('66666666-6666-6666-6666-666666666666', 'Chez Tantie Rose & Fils',
  'Garba et alloco', 'Maquis ivoirien', '+2250544183108', 'Lobia', 'Près de la pharmacie', 6.8790, -6.4490, 25) $$,
  'le gérant modifie nom, adresse et position');
select is((select name || ' / ' || district from public.restaurants where id = '66666666-6666-6666-6666-666666666666'),
  'Chez Tantie Rose & Fils / Lobia', 'profil enregistré');
select throws_ok($$ select public.restaurant_update_profile('66666666-6666-6666-6666-666666666666', 'X Restaurant', null, null,
  '+2250544183108', 'Lobia', 'Loin d''ici', 5.30, -4.00, 25) $$, 'P0001', 'address_out_of_zone', 'position hors zone refusée');
select throws_ok($$ select public.restaurant_update_profile('66666666-6666-6666-6666-666666666667', 'Le Voisin', null, null,
  '+2250544183109', 'Commerce', 'Marché central', 6.8781, -6.4501, 20) $$, 'P0001', 'forbidden',
  'un gérant ne modifie pas un autre établissement');

-- Statistiques : réservées au restaurant, série complète.
select is(jsonb_array_length(public.restaurant_stats('66666666-6666-6666-6666-666666666666',
  date_trunc('day', now()) - interval '6 days', date_trunc('day', now()) + interval '1 day', 'day') -> 'series'), 7,
  'statistiques par jour sur 7 jours');

-- Désactivation demandée par le responsable.
select public.restaurant_request_deactivation('66666666-6666-6666-6666-666666666666', 'Fermeture définitive');
reset role;
select ok((select not is_active from public.restaurants where id = '66666666-6666-6666-6666-666666666666')
          and exists (select 1 from public.notifications where user_id = '00000000-0000-0000-0000-0000000000ad'),
  'établissement désactivé, admin prévenu');

select * from finish();
rollback;
