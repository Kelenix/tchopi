-- Données de développement local (supabase db reset). Valeurs tarifaires indicatives, modifiables dans le back-office.
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('11111111-1111-1111-1111-111111111111', 'Abidjan — agglomération', 'Abidjan', 5.3364, -4.0267, 25000);

insert into public.pricing_rules
  (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, detour_factor, rounding_step, courier_base, courier_per_km)
values
  ('11111111-1111-1111-1111-111111111111', 'food', 500, 150, 500, 3000, 1.30, 25, 400, 100),
  ('11111111-1111-1111-1111-111111111111', 'parcel', 700, 175, 700, 4000, 1.30, 25, 500, 120);

-- Restaurants de démonstration (local uniquement) : accueil client et menus visibles sans saisie préalable.
insert into public.restaurants
  (id, zone_id, name, category, description, phone, latitude, longitude, district, landmark, prep_time_min)
values
  ('22222222-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Maquis Chez Tante',
   'Maquis ivoirien', 'Garba, alloco et poisson braisé comme à la maison, depuis 2009.',
   '+2250701000001', 5.3600, -3.9700, 'Cocody Riviera 2', 'Près du carrefour de la vie', 20),
  ('22222222-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'Le Grill du Plateau',
   'Grillades', 'Brochettes, poulet DG et grillades au feu de bois.',
   '+2250701000002', 5.3240, -4.0200, 'Plateau', 'Face à la tour BICICI', 25),
  ('22222222-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'Pâtisserie Akwaba',
   'Pâtisserie', 'Viennoiseries, gâteaux et jus frais.',
   '+2250701000003', 5.3480, -3.9900, 'Cocody Angré', 'Derrière la pharmacie des 7 Tranches', 10);

insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
select r.id, d, '07:00', '23:30'
from (values ('22222222-0000-0000-0000-000000000001'::uuid), ('22222222-0000-0000-0000-000000000002'::uuid)) r (id),
     generate_series(1, 7) d;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at)
select '22222222-0000-0000-0000-000000000003', d, '06:30', '09:00' from generate_series(1, 7) d;

insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001', 'Plats', 0),
  ('33333333-0000-0000-0000-000000000002', '22222222-0000-0000-0000-000000000001', 'Boissons', 1),
  ('33333333-0000-0000-0000-000000000003', '22222222-0000-0000-0000-000000000002', 'Grillades', 0),
  ('33333333-0000-0000-0000-000000000004', '22222222-0000-0000-0000-000000000003', 'Viennoiseries', 0);

insert into public.products (restaurant_id, category_id, name, description, price, is_available) values
  ('22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000001', 'Garba', 'Attiéké et thon frit, piment frais.', 1500, true),
  ('22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000001', 'Alloco poisson', 'Banane plantain frite et poisson braisé.', 2500, true),
  ('22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000001', 'Kédjénou de poulet', 'Poulet mijoté à l''étouffée, servi avec attiéké.', 3500, false),
  ('22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000002', 'Bissap', 'Jus d''hibiscus maison, 50 cl.', 500, true),
  ('22222222-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000002', 'Gnamakoudji', 'Jus de gingembre maison, 50 cl.', 500, true),
  ('22222222-0000-0000-0000-000000000002', '33333333-0000-0000-0000-000000000003', 'Brochettes de bœuf', 'Quatre brochettes, oignons et piment.', 2000, true),
  ('22222222-0000-0000-0000-000000000002', '33333333-0000-0000-0000-000000000003', 'Poulet DG', 'Poulet, plantain et légumes sautés.', 4500, true),
  ('22222222-0000-0000-0000-000000000003', '33333333-0000-0000-0000-000000000004', 'Croissant', null, 500, true),
  ('22222222-0000-0000-0000-000000000003', '33333333-0000-0000-0000-000000000004', 'Pain au chocolat', null, 600, true);

-- Photos de démonstration (bucket « media », envoyées depuis supabase/seed-media/media).
update public.restaurants r set cover_path = 'demo/' || p.file
from (values ('22222222-0000-0000-0000-000000000001'::uuid, 'cover-maquis-chez-tante.jpg'),
             ('22222222-0000-0000-0000-000000000002'::uuid, 'cover-grill-du-plateau.jpg'),
             ('22222222-0000-0000-0000-000000000003'::uuid, 'cover-patisserie-akwaba.jpg')) p (id, file)
where r.id = p.id;
update public.products pr set photo_path = 'demo/' || p.file
from (values ('Garba', 'garba.jpg'), ('Alloco poisson', 'alloco-poisson.jpg'),
             ('Kédjénou de poulet', 'kedjenou-poulet.jpg'), ('Bissap', 'bissap.jpg'),
             ('Gnamakoudji', 'gnamakoudji.jpg'), ('Brochettes de bœuf', 'brochettes-boeuf.jpg'),
             ('Poulet DG', 'poulet-dg.jpg'), ('Croissant', 'croissant.jpg'),
             ('Pain au chocolat', 'pain-au-chocolat.jpg')) p (name, file)
where pr.name = p.name and pr.restaurant_id::text like '22222222-%';

-- Notifications en local (ADR-025) : la base appelle la fonction « push » via la passerelle interne de Docker.
-- Clé de service de démonstration publique de Supabase local (jamais utilisée en production, voir manual-tasks §8).
select vault.create_secret('http://kong:8000/functions/v1/push', 'push_function_url');
select vault.create_secret(
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
  'push_function_key');
