begin;
create extension if not exists pgtap with schema extensions;
select plan(2);

insert into auth.users (id, email, aud, role, email_confirmed_at)
values ('00000000-0000-0000-0000-0000000000c9', 'nouveau@exemple.ci', 'authenticated', 'authenticated', now());
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c9","role":"authenticated"}', true);
select is(public.my_roles() ->> 'onboarded', 'false', 'nouveau compte : choix du parcours à faire');
select public.complete_onboarding();
select is(public.my_roles() ->> 'onboarded', 'true', 'parcours choisi');

select * from finish();
rollback;
