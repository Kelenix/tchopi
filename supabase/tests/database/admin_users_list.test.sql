begin;
create extension if not exists pgtap with schema extensions;
select plan(4);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000c1', 'client@exemple.ci', 'authenticated', 'authenticated', now());
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
select throws_ok($$ select public.admin_users_list() $$, 'P0001', 'forbidden', 'réservé aux admins');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}', true);
select is(public.admin_users_list(p_query => 'client@') #>> '{rows,0,role}', 'client', 'rôle client et recherche par e-mail');
select is(public.admin_users_list(p_role => 'admin') #>> '{rows,0,email}', 'admin@exemple.ci', 'filtre par rôle');
select ok((public.admin_users_list() #>> '{counts,admin}')::int >= 1, 'compteurs par rôle');

select * from finish();
rollback;
