begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000d1', 'livreur@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000d2', 'autre@exemple.ci', 'authenticated', 'authenticated', now());
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('55555555-5555-5555-5555-555555555555', 'Daloa', 'Daloa', 6.8774, -6.4502, 6000);

create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.submit(p_vehicle text, p_plate text, p_id_type text, p_id text) returns void language sql as $$
  select public.submit_courier_profile('55555555-5555-5555-5555-555555555555', p_vehicle::public.vehicle_type, p_plate,
    '00000000-0000-0000-0000-0000000000d1/p.jpg', p_id_type, p_id, 'Lobia, près du marché');
$$;
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d1');

-- Vérification automatique : plaque pour un véhicule, pièce d'identité à pied ou à vélo.
select throws_ok($$ select pg_temp.submit('motorbike', 'ABC', null, null) $$, 'P0001', 'invalid_plate', 'plaque au mauvais format refusée');
select lives_ok($$ select pg_temp.submit('motorbike', '1234-ab-01', null, null) $$, 'plaque ivoirienne acceptée');
select is((select plate_number from public.couriers), '1234 AB 01', 'plaque enregistrée sous forme lisible');
select throws_ok($$ select pg_temp.submit('on_foot', null, null, null) $$, 'P0001', 'invalid_id_number', 'à pied : pièce obligatoire');
select throws_ok($$ select pg_temp.submit('on_foot', null, 'cni', '12345') $$, 'P0001', 'invalid_id_number', 'numéro de CNI invalide refusé');
select throws_ok($$ select pg_temp.submit('bicycle', null, 'passport', 'CI0012345678') $$, 'P0001', 'invalid_id_number',
  'numéro qui ne correspond pas au type de pièce refusé');
select lives_ok($$ select pg_temp.submit('on_foot', null, 'cni', 'CI 001 234 5678') $$, 'CNI biométrique acceptée');
select is((select id_number || ' / ' || coalesce(plate_number, '-') || ' / ' || residence from public.couriers),
  'CI0012345678 / - / Lobia, près du marché', 'pièce normalisée, sans plaque, adresse enregistrée');

-- Changement sensible d'un livreur approuvé : revalidation.
reset role;
update public.couriers set status = 'approved', approved_at = now();
set local role authenticated;
select pg_temp.submit('motorbike', '4321 CD 01', null, null);
select is((select status::text from public.couriers), 'pending', 'nouveau véhicule : dossier revalidé');

-- Livraisons : seulement les siennes, filtrées par le serveur.
select is(public.courier_deliveries(now() - interval '1 day', now() + interval '1 hour') #>> '{summary,total}', '0',
  'aucune livraison sur la période');
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d2');
select throws_ok($$ select public.courier_deliveries(now() - interval '1 day', now()) $$, 'P0001', 'forbidden',
  'un compte sans profil livreur ne lit rien');

-- Suppression du profil : refusée avec des espèces dues, sinon faite ; le compte reste.
reset role;
insert into public.cash_ledger (courier_id, type, amount) values ('00000000-0000-0000-0000-0000000000d1', 'collected', 3000);
set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d1');
select throws_ok($$ select public.delete_courier_profile() $$, 'P0001', 'cash_due', 'espèces à reverser : suppression refusée');
reset role;
insert into public.cash_ledger (courier_id, type, amount) values ('00000000-0000-0000-0000-0000000000d1', 'remitted', 3000);
set local role authenticated;
select lives_ok($$ select public.delete_courier_profile() $$, 'profil livreur supprimé');
reset role;
select ok(not exists (select 1 from public.couriers) and exists (select 1 from public.profiles
            where id = '00000000-0000-0000-0000-0000000000d1' and deleted_at is null)
          and (select count(*) from public.cash_ledger) = 2,
  'compte client et mouvements d''espèces conservés');

select * from finish();
rollback;
