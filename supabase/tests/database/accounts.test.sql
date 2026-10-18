begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

-- Deux comptes : A inscrit par email, B inscrit par téléphone (Auth stocke le numéro sans « + »).
insert into auth.users (id, email, phone, aud, role)
values
  ('00000000-0000-0000-0000-0000000000aa', 'a@exemple.ci', null, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000bb', null, '2250799999901', 'authenticated', 'authenticated');

select is(
  (select count(*)::int from public.profiles where id in ('00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000bb')),
  2, 'un profil est créé à chaque inscription'
);
select is(
  (select phone from public.profiles where id = '00000000-0000-0000-0000-0000000000bb'),
  '+2250799999901', 'le numéro d''inscription devient le téléphone de contact, au format international'
);

-- Session de A.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000aa","role":"authenticated"}';

select is((select count(*)::int from public.profiles), 1, 'un utilisateur ne voit que son propre profil');

update public.profiles set first_name = 'Aïcha', last_name = 'Koné', phone = '+2250544183108', city = 'Abidjan'
 where id = '00000000-0000-0000-0000-0000000000aa';
select is(
  (select first_name from public.profiles where id = '00000000-0000-0000-0000-0000000000aa'),
  'Aïcha', 'un utilisateur complète son profil'
);

update public.profiles set first_name = 'Pirate' where id = '00000000-0000-0000-0000-0000000000bb';
select throws_ok(
  $$ update public.profiles set is_suspended = false where id = '00000000-0000-0000-0000-0000000000aa' $$,
  '42501', null, 'un utilisateur ne peut pas modifier son statut de suspension'
);
select throws_ok(
  $$ update public.profiles set phone = '0700000000' where id = '00000000-0000-0000-0000-0000000000aa' $$,
  '23514', null, 'un téléphone hors format international est refusé'
);
select is((select public.my_roles() ->> 'is_admin'), 'false', 'un compte ordinaire n''est pas admin');
select throws_ok(
  $$ select public.anonymize_account('00000000-0000-0000-0000-0000000000bb') $$,
  '42501', null, 'un utilisateur ne peut pas anonymiser un compte'
);
select throws_ok(
  $$ insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000aa') $$,
  '42501', null, 'un utilisateur ne peut pas se déclarer admin'
);

-- Vérifications avec les droits du serveur.
reset role;
select is(
  (select first_name from public.profiles where id = '00000000-0000-0000-0000-0000000000bb'),
  null, 'un utilisateur ne peut pas modifier le profil d''un autre'
);

insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000aa');
set local role authenticated;
select is((select public.my_roles() ->> 'is_admin'), 'true', 'un admin est reconnu comme tel');
select ok(
  exists (select 1 from public.profiles where id = '00000000-0000-0000-0000-0000000000bb'),
  'un admin voit le profil des autres comptes'
);

-- Un compte suspendu ne peut plus modifier son profil.
reset role;
update public.profiles set is_suspended = true where id = '00000000-0000-0000-0000-0000000000bb';
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000bb","role":"authenticated"}';
update public.profiles set first_name = 'Moussa' where id = '00000000-0000-0000-0000-0000000000bb';
reset role;
select is(
  (select first_name from public.profiles where id = '00000000-0000-0000-0000-0000000000bb'),
  null, 'un compte suspendu ne peut plus modifier son profil'
);

select public.anonymize_account('00000000-0000-0000-0000-0000000000aa');
select ok(
  (select first_name is null and phone is null and deleted_at is not null
     from public.profiles where id = '00000000-0000-0000-0000-0000000000aa')
  and not exists (select 1 from public.admins where user_id = '00000000-0000-0000-0000-0000000000aa'),
  'la suppression du compte anonymise le profil et retire les droits'
);

select * from finish();
rollback;
