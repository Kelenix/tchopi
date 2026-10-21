begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into public.zones (id, name, city, country_code, currency, timezone, center_lat, center_lng, radius_m)
values ('00000000-0000-0000-0000-00000000d001', 'Zone test', 'Ville Été', 'CI', 'XOF', 'Africa/Abidjan', 7.69, -5.03, 8000);
select is((select slug from public.zones where id = '00000000-0000-0000-0000-00000000d001'), 'ville-ete', 'ville : slug sans accent');

insert into public.restaurants (id, zone_id, name, phone, latitude, longitude, district, landmark)
values
  ('00000000-0000-0000-0000-00000000e001', '00000000-0000-0000-0000-00000000d001', 'Le Délice d''Awa !', '+2250701020304', 7.69, -5.03, 'Commerce', 'Gare'),
  ('00000000-0000-0000-0000-00000000e002', '00000000-0000-0000-0000-00000000d001', 'Le Délice d''Awa', '+2250701020305', 7.69, -5.03, 'Commerce', 'Gare'),
  ('00000000-0000-0000-0000-00000000e003', '00000000-0000-0000-0000-00000000d001', 'LE DÉLICE D''AWA', '+2250701020306', 7.69, -5.03, 'Commerce', 'Gare');

select is((select slug from public.restaurants where id = '00000000-0000-0000-0000-00000000e001'), 'le-delice-d-awa', 'slug lisible à partir du nom');
select is((select slug from public.restaurants where id = '00000000-0000-0000-0000-00000000e002'), 'le-delice-d-awa-ville-ete', 'homonyme : la ville départage');
select is((select slug from public.restaurants where id = '00000000-0000-0000-0000-00000000e003'), 'le-delice-d-awa-ville-ete-2', 'puis un numéro');

update public.restaurants set name = 'Chez Awa' where id = '00000000-0000-0000-0000-00000000e001';
select is((select slug from public.restaurants where id = '00000000-0000-0000-0000-00000000e001'), 'chez-awa', 'renommé : nouveau slug');
select is(public.public_establishment_slug('le-delice-d-awa'), 'chez-awa', 'l''ancien slug mène à la nouvelle adresse');
select is(public.public_establishment_slug('00000000-0000-0000-0000-00000000e001'), 'chez-awa', 'l''ancienne adresse UUID aussi');

insert into public.restaurants (zone_id, name, phone, latitude, longitude, district, landmark)
values ('00000000-0000-0000-0000-00000000d001', 'Le Délice d''Awa', '+2250701020307', 7.69, -5.03, 'Commerce', 'Gare');
select isnt(
  (select slug from public.restaurants where name = 'Le Délice d''Awa' and id not in ('00000000-0000-0000-0000-00000000e002')),
  'le-delice-d-awa', 'un ancien slug reste réservé à son établissement'
);

set local role anon;
select is(
  (public.public_establishment_by_slug('chez-awa') ->> 'id'), '00000000-0000-0000-0000-00000000e001',
  'fiche publique par slug'
);

select * from finish();
rollback;
