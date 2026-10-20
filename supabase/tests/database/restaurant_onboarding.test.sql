begin;
create extension if not exists pgtap with schema extensions;
select plan(10);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000f1', 'Gerante@Exemple.ci', 'authenticated', 'authenticated', now());
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);
update public.zones set is_active = false where id <> '55555555-5555-5555-5555-555555555555';

create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.register() returns uuid language sql as $$
  select public.register_restaurant('55555555-5555-5555-5555-555555555555', 'Chez Tantie Rose', 'Maquis ivoirien',
    'Garba et alloco', '+2250544183108', 6.8780, -6.4500, 'Commerce', 'Face à la gare',
    '[{"weekday":1,"opens_at":"08:00","closes_at":"22:00"},{"weekday":2,"opens_at":"08:00","closes_at":"22:00"}]');
$$;

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000f1');
select lives_ok($$ select pg_temp.register() $$, 'un restaurateur inscrit son restaurant');
select is((select review_status || '/' || is_active from public.restaurants), 'pending/false', 'en attente, invisible des clients');
select is((public.my_roles() -> 'restaurant_ids' ->> 0)::uuid, (select id from public.restaurants), 'il accède tout de suite à son espace');
select is((select login_email from public.restaurant_members), 'gerante@exemple.ci', 'gérant relié à son compte');
select is((select count(*) from public.opening_hours)::integer, 2, 'horaires enregistrés');
select throws_ok($$ select pg_temp.register() $$, 'P0001', 'already_submitted', 'une seule demande en attente par compte');
select is((select count(*) from public.public_establishments('55555555-5555-5555-5555-555555555555'))::integer, 0,
  'absent du catalogue public avant validation');
select throws_ok($$ select public.admin_review_restaurant((select id from public.restaurants), true) $$,
  'P0001', 'forbidden', 'seul un admin valide');

select pg_temp.as_user('00000000-0000-0000-0000-0000000000ad');
select public.admin_review_restaurant((select id from public.restaurants), true, 12);
select is((select review_status || '/' || is_active || '/' || commission_rate from public.restaurants), 'approved/true/12.00',
  'validé avec sa commission');
reset role;
select is((select kind from public.notifications where user_id = '00000000-0000-0000-0000-0000000000f1'), 'restaurant_approved',
  'le gérant est prévenu');

select * from finish();
rollback;
