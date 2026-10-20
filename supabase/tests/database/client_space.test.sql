begin;
create extension if not exists pgtap with schema extensions;
select plan(5);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now());
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);
-- Le client postule (même compte) ; un seul dossier par compte (clé primaire).
insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path)
values ('00000000-0000-0000-0000-0000000000c1', '55555555-5555-5555-5555-555555555555', 'motorbike', '1234 AB 01',
        '00000000-0000-0000-0000-0000000000c1/p.jpg');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}', true);
select public.admin_set_courier_status('00000000-0000-0000-0000-0000000000c1', 'rejected', 'Photo illisible');
select public.admin_set_courier_status('00000000-0000-0000-0000-0000000000c1', 'approved');
reset role;
select is((select array_agg(title || ' : ' || body order by id) from public.notifications
            where user_id = '00000000-0000-0000-0000-0000000000c1')::text,
  '{"Candidature livreur refusée : Photo illisible","Candidature livreur acceptée : Bienvenue ! Passez en ligne depuis l''espace Livreur pour recevoir des commandes."}',
  'le client est prévenu de chaque décision, motif compris');
select is((select status::text from public.couriers), 'approved', 'le même compte devient livreur');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
select lives_ok($$ update public.profiles set avatar_path = 'avatars/00000000-0000-0000-0000-0000000000c1/a.jpg'
                    where id = '00000000-0000-0000-0000-0000000000c1' $$, 'photo de profil enregistrée');
select throws_ok($$ update public.profiles set avatar_path = 'avatars/autre/a.jpg'
                     where id = '00000000-0000-0000-0000-0000000000c1' $$, '23514', null,
  'photo hors de son dossier refusée');

reset role;
select lives_ok($$ select public.anonymize_account('00000000-0000-0000-0000-0000000000c1') $$,
  'sans commande en cours : compte anonymisé');

select * from finish();
rollback;
