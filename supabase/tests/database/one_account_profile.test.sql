begin;
create extension if not exists pgtap with schema extensions;
select plan(5);

-- Inscription Google : le fournisseur donne le prénom et le nom.
insert into auth.users (id, email, aud, role, raw_user_meta_data)
values
  ('00000000-0000-0000-0000-0000000000c1', 'g@exemple.ci', 'authenticated', 'authenticated',
   '{"full_name": "Awa Marie Koné", "given_name": "Awa", "family_name": "Koné"}'),
  ('00000000-0000-0000-0000-0000000000c2', 'n@exemple.ci', 'authenticated', 'authenticated',
   '{"name": "Brice Yao Kouassi"}');

select is(
  (select first_name || ' / ' || last_name from public.profiles where id = '00000000-0000-0000-0000-0000000000c1'),
  'Awa / Koné', 'le prénom et le nom Google sont repris à l''inscription'
);
select is(
  (select first_name || ' / ' || last_name from public.profiles where id = '00000000-0000-0000-0000-0000000000c2'),
  'Brice / Yao Kouassi', 'à défaut, le nom complet est découpé'
);

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select is((public.my_roles() ->> 'profile_complete')::boolean, false, 'sans téléphone ni ville, le profil est incomplet');

update public.profiles set phone = '+2250544183108', city = 'Abidjan' where id = '00000000-0000-0000-0000-0000000000c1';
select is((public.my_roles() ->> 'profile_complete')::boolean, true, 'profil complet : reconnu sur toutes les plateformes');
select is((public.my_roles() ->> 'onboarded')::boolean, false, 'le parcours reste à choisir tant qu''il ne l''a pas été');

select * from finish();
rollback;
