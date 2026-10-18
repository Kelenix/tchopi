begin;
create extension if not exists pgtap with schema extensions;
select plan(18);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000f1', 'gerant@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now());
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m, timezone)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000, 'Africa/Abidjan');

-- Admin : création, invitation du gérant (compte existant : relié tout de suite) et d'un futur gérant.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}';
select lives_ok(
  $$ select public.admin_save_restaurant('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555',
       'Chez Tantie Rose', 'Maquis', 'Maquis ivoirien', '+2250544183108', 6.8780, -6.4500, 'Commerce', 'Face à la gare',
       15, true) $$,
  'un admin crée un restaurant'
);
select lives_ok(
  $$ select public.admin_invite_member('66666666-6666-6666-6666-666666666666', 'GERANT@exemple.ci', null) $$,
  'un admin invite un gérant par email'
);
select public.admin_invite_member('66666666-6666-6666-6666-666666666666', null, '+2250799999902');
select is(
  (select user_id from public.restaurant_members where login_email = 'gerant@exemple.ci'),
  '00000000-0000-0000-0000-0000000000f1'::uuid, 'un compte existant est relié dès l''invitation'
);

reset role;
insert into auth.users (id, phone, aud, role, phone_confirmed_at)
values ('00000000-0000-0000-0000-0000000000f2', '2250799999902', 'authenticated', 'authenticated', now());
select is(
  (select user_id from public.restaurant_members where login_phone = '+2250799999902'),
  '00000000-0000-0000-0000-0000000000f2'::uuid, 'un invité est relié à son inscription vérifiée'
);
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
select '66666666-6666-6666-6666-666666666666', d, '00:00', '23:59:59' from generate_series(1, 7) d;

-- Gérant.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}';
select is(
  (select public.my_roles() -> 'restaurant_ids' ->> 0), '66666666-6666-6666-6666-666666666666',
  'les restaurants gérés figurent dans les rôles du compte'
);
update public.restaurants set description = 'Le meilleur attiéké', prep_time_min = 25 where id = '66666666-6666-6666-6666-666666666666';
select is(
  (select description from public.restaurants where id = '66666666-6666-6666-6666-666666666666'),
  'Le meilleur attiéké', 'un gérant modifie la présentation de son restaurant'
);
select throws_ok(
  $$ update public.restaurants set commission_rate = 0 where id = '66666666-6666-6666-6666-666666666666' $$,
  '42501', null, 'un gérant ne peut pas changer sa commission'
);
insert into public.categories (id, restaurant_id, name) values ('77777777-7777-7777-7777-777777777777', '66666666-6666-6666-6666-666666666666', 'Plats');
insert into public.products (restaurant_id, category_id, name, price)
values ('66666666-6666-6666-6666-666666666666', '77777777-7777-7777-7777-777777777777', 'Attiéké poisson braisé', 3500),
       ('66666666-6666-6666-6666-666666666666', '77777777-7777-7777-7777-777777777777', 'Garba', 1000);
update public.products set archived_at = now() where name = 'Garba';
select throws_ok(
  $$ insert into public.products (restaurant_id, name, price) values ('66666666-6666-6666-6666-666666666666', 'Gratuit', 0) $$,
  '23514', null, 'un prix doit être strictement positif'
);
select throws_ok(
  $$ delete from public.products $$, '42501', null, 'un produit ne se supprime pas : il s''archive'
);
select lives_ok(
  $$ select public.save_opening_hours('66666666-6666-6666-6666-666666666666',
       '[{"weekday":1,"opens_at":"00:00","closes_at":"23:59:59"},{"weekday":2,"opens_at":"00:00","closes_at":"23:59:59"},
         {"weekday":3,"opens_at":"00:00","closes_at":"23:59:59"},{"weekday":4,"opens_at":"00:00","closes_at":"23:59:59"},
         {"weekday":5,"opens_at":"00:00","closes_at":"23:59:59"},{"weekday":6,"opens_at":"00:00","closes_at":"23:59:59"},
         {"weekday":7,"opens_at":"00:00","closes_at":"23:59:59"}]'::jsonb) $$,
  'un gérant remplace ses horaires'
);

-- Client.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select ok(
  (select public.is_open(r) from public.restaurants r where id = '66666666-6666-6666-6666-666666666666'),
  'un restaurant actif dans ses horaires est ouvert'
);
select is(
  (select array_agg(name) from public.products where restaurant_id = '66666666-6666-6666-6666-666666666666'),
  array['Attiéké poisson braisé'], 'un client ne voit pas les produits archivés'
);
select throws_ok(
  $$ insert into public.products (restaurant_id, name, price) values ('66666666-6666-6666-6666-666666666666', 'Pirate', 100) $$,
  '42501', null, 'un client ne peut pas ajouter de produit'
);
update public.restaurants set description = 'Piraté' where id = '66666666-6666-6666-6666-666666666666';
select throws_ok(
  $$ select public.save_opening_hours('66666666-6666-6666-6666-666666666666', '[]'::jsonb) $$,
  'P0001', 'forbidden', 'un client ne peut pas changer les horaires'
);
select is((select count(*)::int from public.restaurant_members), 0, 'un client ne voit pas les gérants');

-- Fermeture temporaire puis désactivation.
reset role;
update public.restaurants set is_temporarily_closed = true where id = '66666666-6666-6666-6666-666666666666';
select ok(
  not (select public.is_open(r) from public.restaurants r where id = '66666666-6666-6666-6666-666666666666')
  and (select description from public.restaurants where id = '66666666-6666-6666-6666-666666666666') = 'Le meilleur attiéké',
  'fermé temporairement : le restaurant est fermé ; un client n''a rien pu modifier'
);
update public.restaurants set is_active = false, is_temporarily_closed = false where id = '66666666-6666-6666-6666-666666666666';
set local role authenticated;
select is(
  (select count(*)::int from public.restaurants where id = '66666666-6666-6666-6666-666666666666'),
  0, 'un restaurant désactivé disparaît des listes clients'
);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}';
select is(
  (select count(*)::int from public.restaurants where id = '66666666-6666-6666-6666-666666666666'),
  1, 'son gérant le voit toujours'
);

select * from finish();
rollback;
