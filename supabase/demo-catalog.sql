-- Catalogue de démonstration élargi (ADR-064) : 20 établissements et 100 produits, avec horaires, catégories,
-- options (portions, accompagnements, suppléments) et photos. Rejouable : chaque ligne a un identifiant fixe.
-- En local à chaque supabase db reset ; sur le serveur en ligne par .\vps.ps1 demo (photos : seed-media/media).
-- Généré à partir d'une liste unique ; les quartiers, repères et prix reflètent l'offre réelle de chaque ville.

-- 01. Garba Chez Moussa (Abidjan, Adjamé Roxy)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000001', z.id, 'restaurant', 'Garba Chez Moussa', 'Garba', 'Le vrai garba d''Adjamé : attiéké chaud, thon frit croustillant, piment et oignons frais, depuis 2012.', '+2250707120101', 5.3641, -4.0262,
  'Adjamé Roxy', 'À côté de la gare UTB d''Adjamé', 15, false, 'demo/cover-garba-chez-moussa.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000001', 1, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000001', 2, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000001', 3, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000001', 4, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000001', 5, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000001', 6, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000001', 7, '10:00', '22:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000001000000', '22222222-0000-0000-0001-000000000001', 'Garba', 0),
  ('33333333-0000-0000-0001-000001000001', '22222222-0000-0000-0001-000000000001', 'Boissons', 1)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000001000001', '22222222-0000-0000-0001-000000000001', '33333333-0000-0000-0001-000001000000', 'Garba thon', 'Attiéké, thon frit, piment frais et oignons.', 1000, 'demo/garba-chez-moussa.jpg', true),
  ('44444444-0000-0000-0001-000001000002', '22222222-0000-0000-0001-000000000001', '33333333-0000-0000-0001-000001000000', 'Garba spécial', 'Double thon, œuf dur et alloco.', 2000, 'demo/garba.jpg', true),
  ('44444444-0000-0000-0001-000001000003', '22222222-0000-0000-0001-000000000001', '33333333-0000-0000-0001-000001000000', 'Attiéké poisson frit', 'Attiéké, carpe frite, tomate et oignon.', 2000, 'demo/attieke-poisson.jpg', true),
  ('44444444-0000-0000-0001-000001000004', '22222222-0000-0000-0001-000000000001', '33333333-0000-0000-0001-000001000001', 'Gnamakoudji', 'Jus de gingembre frais, citron et menthe.', 500, 'demo/gnamakoudji.jpg', true),
  ('44444444-0000-0000-0001-000001000005', '22222222-0000-0000-0001-000000000001', '33333333-0000-0000-0001-000001000001', 'Bissap', 'Jus d''hibiscus maison, bien frais.', 500, 'demo/bissap.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000100010000', '44444444-0000-0000-0001-000001000001', 'Portion', 1, 1, 0),
  ('55555555-0000-0000-0001-000100010001', '44444444-0000-0000-0001-000001000001', 'Suppléments', 0, 3, 1),
  ('55555555-0000-0000-0001-000100020000', '44444444-0000-0000-0001-000001000002', 'Piment', 0, 1, 0),
  ('55555555-0000-0000-0001-000100030000', '44444444-0000-0000-0001-000001000003', 'Poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-000100040000', '44444444-0000-0000-0001-000001000004', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-000100050000', '44444444-0000-0000-0001-000001000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-001001000000', '55555555-0000-0000-0001-000100010000', 'Simple', 0, 0),
  ('66666666-0000-0000-0001-001001000001', '55555555-0000-0000-0001-000100010000', 'Double', 800, 1),
  ('66666666-0000-0000-0001-001001001000', '55555555-0000-0000-0001-000100010001', 'Œuf dur', 200, 0),
  ('66666666-0000-0000-0001-001001001001', '55555555-0000-0000-0001-000100010001', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-001001001002', '55555555-0000-0000-0001-000100010001', 'Thon en plus', 500, 2),
  ('66666666-0000-0000-0001-001002000000', '55555555-0000-0000-0001-000100020000', 'Piment frais', 0, 0),
  ('66666666-0000-0000-0001-001002000001', '55555555-0000-0000-0001-000100020000', 'Piment fort', 0, 1),
  ('66666666-0000-0000-0001-001003000000', '55555555-0000-0000-0001-000100030000', 'Carpe', 0, 0),
  ('66666666-0000-0000-0001-001003000001', '55555555-0000-0000-0001-000100030000', 'Mâchoiron', 1000, 1),
  ('66666666-0000-0000-0001-001003000002', '55555555-0000-0000-0001-000100030000', 'Capitaine', 1500, 2),
  ('66666666-0000-0000-0001-001004000000', '55555555-0000-0000-0001-000100040000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-001004000001', '55555555-0000-0000-0001-000100040000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-001005000000', '55555555-0000-0000-0001-000100050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-001005000001', '55555555-0000-0000-0001-000100050000', '1 litre', 500, 1)
on conflict (id) do nothing;

-- 02. Maquis L'Alloco Chaud (Abidjan, Yopougon Siporex)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000002', z.id, 'restaurant', 'Maquis L''Alloco Chaud', 'Maquis ivoirien', 'Alloco doré à la minute, poisson frit et poulet braisé, servis avec sauce piment maison.', '+2250505120202', 5.3382, -4.0741,
  'Yopougon Siporex', 'Près de la pharmacie Siporex', 20, false, 'demo/cover-alloco-chaud.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000002', 1, '11:00', '23:30'),
  ('22222222-0000-0000-0001-000000000002', 2, '11:00', '23:30'),
  ('22222222-0000-0000-0001-000000000002', 3, '11:00', '23:30'),
  ('22222222-0000-0000-0001-000000000002', 4, '11:00', '23:30'),
  ('22222222-0000-0000-0001-000000000002', 5, '11:00', '23:30'),
  ('22222222-0000-0000-0001-000000000002', 6, '11:00', '23:30'),
  ('22222222-0000-0000-0001-000000000002', 7, '11:00', '23:30')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000002000000', '22222222-0000-0000-0001-000000000002', 'Plats', 0),
  ('33333333-0000-0000-0001-000002000001', '22222222-0000-0000-0001-000000000002', 'Grillades', 1),
  ('33333333-0000-0000-0001-000002000002', '22222222-0000-0000-0001-000000000002', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000002000001', '22222222-0000-0000-0001-000000000002', '33333333-0000-0000-0001-000002000000', 'Alloco poisson frit', 'Banane plantain frite, tilapia frit, sauce piment.', 2500, 'demo/alloco-chaud.jpg', true),
  ('44444444-0000-0000-0001-000002000002', '22222222-0000-0000-0001-000000000002', '33333333-0000-0000-0001-000002000000', 'Alloco poulet braisé', 'Alloco et cuisse de poulet braisée au charbon.', 3000, 'demo/alloco-poulet.jpg', true),
  ('44444444-0000-0000-0001-000002000003', '22222222-0000-0000-0001-000000000002', '33333333-0000-0000-0001-000002000000', 'Alloco œufs', 'Alloco, deux œufs durs et sauce tomate pimentée.', 1000, 'demo/alloco-chaud.jpg', true),
  ('44444444-0000-0000-0001-000002000004', '22222222-0000-0000-0001-000000000002', '33333333-0000-0000-0001-000002000001', 'Poisson braisé', 'Poisson entier braisé, attiéké et crudités.', 4000, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000002000005', '22222222-0000-0000-0001-000000000002', '33333333-0000-0000-0001-000002000002', 'Jus de mangue', 'Mangue fraîche mixée, sans sucre ajouté.', 700, 'demo/jus-mangue.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000200010000', '44444444-0000-0000-0001-000002000001', 'Poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-000200010001', '44444444-0000-0000-0001-000002000001', 'Suppléments', 0, 2, 1),
  ('55555555-0000-0000-0001-000200020000', '44444444-0000-0000-0001-000002000002', 'Morceau', 1, 1, 0),
  ('55555555-0000-0000-0001-000200040000', '44444444-0000-0000-0001-000002000004', 'Taille du poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-000200040001', '44444444-0000-0000-0001-000002000004', 'Accompagnement', 1, 1, 1),
  ('55555555-0000-0000-0001-000200050000', '44444444-0000-0000-0001-000002000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-002001000000', '55555555-0000-0000-0001-000200010000', 'Carpe', 0, 0),
  ('66666666-0000-0000-0001-002001000001', '55555555-0000-0000-0001-000200010000', 'Mâchoiron', 1000, 1),
  ('66666666-0000-0000-0001-002001000002', '55555555-0000-0000-0001-000200010000', 'Capitaine', 1500, 2),
  ('66666666-0000-0000-0001-002001001000', '55555555-0000-0000-0001-000200010001', 'Œuf dur', 200, 0),
  ('66666666-0000-0000-0001-002001001001', '55555555-0000-0000-0001-000200010001', 'Attiéké', 300, 1),
  ('66666666-0000-0000-0001-002002000000', '55555555-0000-0000-0001-000200020000', 'Quart', 0, 0),
  ('66666666-0000-0000-0001-002002000001', '55555555-0000-0000-0001-000200020000', 'Demi-poulet', 2500, 1),
  ('66666666-0000-0000-0001-002002000002', '55555555-0000-0000-0001-000200020000', 'Poulet entier', 6000, 2),
  ('66666666-0000-0000-0001-002004000000', '55555555-0000-0000-0001-000200040000', 'Moyen', 0, 0),
  ('66666666-0000-0000-0001-002004000001', '55555555-0000-0000-0001-000200040000', 'Grand', 1500, 1),
  ('66666666-0000-0000-0001-002004001000', '55555555-0000-0000-0001-000200040001', 'Attiéké', 0, 0),
  ('66666666-0000-0000-0001-002004001001', '55555555-0000-0000-0001-000200040001', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-002004001002', '55555555-0000-0000-0001-000200040001', 'Riz blanc', 0, 2),
  ('66666666-0000-0000-0001-002004001003', '55555555-0000-0000-0001-000200040001', 'Frites', 500, 3),
  ('66666666-0000-0000-0001-002005000000', '55555555-0000-0000-0001-000200050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-002005000001', '55555555-0000-0000-0001-000200050000', '1 litre', 500, 1)
on conflict (id) do nothing;

-- 03. Chez Tantie Adjoua (Abidjan, Cocody Angré 8e tranche)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000003', z.id, 'restaurant', 'Chez Tantie Adjoua', 'Cuisine ivoirienne', 'Sauces du terroir mijotées au feu de bois : graine, claire, gombo et arachide, comme au village.', '+2250102120303', 5.3985, -3.9871,
  'Cocody Angré 8e tranche', 'Derrière la station Total d''Angré', 30, false, 'demo/cover-foutou-sauce-graine.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000003', 1, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000003', 1, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000003', 2, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000003', 2, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000003', 3, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000003', 3, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000003', 4, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000003', 4, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000003', 5, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000003', 5, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000003', 6, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000003', 6, '18:00', '22:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000003000000', '22222222-0000-0000-0001-000000000003', 'Sauces', 0),
  ('33333333-0000-0000-0001-000003000001', '22222222-0000-0000-0001-000000000003', 'Boissons', 1)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000003000001', '22222222-0000-0000-0001-000000000003', '33333333-0000-0000-0001-000003000000', 'Foutou banane sauce graine', 'Foutou banane, sauce graine de palme et viande au choix.', 3000, 'demo/foutou-sauce-graine.jpg', true),
  ('44444444-0000-0000-0001-000003000002', '22222222-0000-0000-0001-000000000003', '33333333-0000-0000-0001-000003000000', 'Foutou igname sauce claire', 'Foutou igname, sauce claire aux gombos et piment.', 3000, 'demo/foutou-sauce-claire.jpg', true),
  ('44444444-0000-0000-0001-000003000003', '22222222-0000-0000-0001-000000000003', '33333333-0000-0000-0001-000003000000', 'Placali sauce gombo', 'Placali tendre et sauce gombo gluante.', 2500, 'demo/placali.jpg', true),
  ('44444444-0000-0000-0001-000003000004', '22222222-0000-0000-0001-000000000003', '33333333-0000-0000-0001-000003000000', 'Sauce arachide au poulet', 'Poulet mijoté dans une sauce arachide onctueuse.', 3000, 'demo/sauce-arachide.jpg', true),
  ('44444444-0000-0000-0001-000003000005', '22222222-0000-0000-0001-000000000003', '33333333-0000-0000-0001-000003000001', 'Bangui frais', 'Vin de palme frais du jour (boisson alcoolisée).', 1000, 'demo/bangui.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000300010000', '44444444-0000-0000-0001-000003000001', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-000300020000', '44444444-0000-0000-0001-000003000002', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-000300030000', '44444444-0000-0000-0001-000003000003', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-000300040000', '44444444-0000-0000-0001-000003000004', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-000300050000', '44444444-0000-0000-0001-000003000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-003001000000', '55555555-0000-0000-0001-000300010000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-003001000001', '55555555-0000-0000-0001-000300010000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-003001000002', '55555555-0000-0000-0001-000300010000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-003001000003', '55555555-0000-0000-0001-000300010000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-003002000000', '55555555-0000-0000-0001-000300020000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-003002000001', '55555555-0000-0000-0001-000300020000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-003002000002', '55555555-0000-0000-0001-000300020000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-003002000003', '55555555-0000-0000-0001-000300020000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-003003000000', '55555555-0000-0000-0001-000300030000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-003003000001', '55555555-0000-0000-0001-000300030000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-003003000002', '55555555-0000-0000-0001-000300030000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-003003000003', '55555555-0000-0000-0001-000300030000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-003004000000', '55555555-0000-0000-0001-000300040000', 'Riz blanc', 0, 0),
  ('66666666-0000-0000-0001-003004000001', '55555555-0000-0000-0001-000300040000', 'Foutou banane', 500, 1),
  ('66666666-0000-0000-0001-003004000002', '55555555-0000-0000-0001-000300040000', 'Attiéké', 0, 2),
  ('66666666-0000-0000-0001-003005000000', '55555555-0000-0000-0001-000300050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-003005000001', '55555555-0000-0000-0001-000300050000', '1 litre', 700, 1)
on conflict (id) do nothing;

-- 04. Le Kédjénou d'Or (Abidjan, Marcory Zone 4)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000004', z.id, 'restaurant', 'Le Kédjénou d''Or', 'Maquis ivoirien', 'Kédjénou cuit à l''étouffée dans le canari, poulet braisé et riz gras, en plein cœur de la Zone 4.', '+2250707120404', 5.2921, -3.9874,
  'Marcory Zone 4', 'Rue du Canal, en face du supermarché', 35, false, 'demo/cover-kedjenou-canari.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000004', 1, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000004', 2, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000004', 3, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000004', 4, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000004', 5, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000004', 6, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000004', 7, '12:00', '23:30')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000004000000', '22222222-0000-0000-0001-000000000004', 'Plats', 0),
  ('33333333-0000-0000-0001-000004000001', '22222222-0000-0000-0001-000000000004', 'Grillades', 1),
  ('33333333-0000-0000-0001-000004000002', '22222222-0000-0000-0001-000000000004', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000004000001', '22222222-0000-0000-0001-000000000004', '33333333-0000-0000-0001-000004000000', 'Kédjénou de poulet', 'Poulet fermier mijoté au canari, légumes et piment.', 4500, 'demo/kedjenou-canari.jpg', true),
  ('44444444-0000-0000-0001-000004000002', '22222222-0000-0000-0001-000000000004', '33333333-0000-0000-0001-000004000000', 'Kédjénou de pintade', 'Pintade mijotée à l''étouffée, attiéké.', 6000, 'demo/kedjenou-poulet.jpg', true),
  ('44444444-0000-0000-0001-000004000003', '22222222-0000-0000-0001-000000000004', '33333333-0000-0000-0001-000004000001', 'Poulet braisé', 'Poulet mariné aux épices, braisé au charbon.', 4000, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000004000004', '22222222-0000-0000-0001-000000000004', '33333333-0000-0000-0001-000004000000', 'Riz gras au poulet', 'Riz cuit dans la sauce tomate, poulet et légumes.', 2500, 'demo/riz-gras.jpg', true),
  ('44444444-0000-0000-0001-000004000005', '22222222-0000-0000-0001-000000000004', '33333333-0000-0000-0001-000004000002', 'Bissap 1 litre', 'Carafe de bissap maison, menthe et ananas.', 1200, 'demo/bissap-carafe.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000400010000', '44444444-0000-0000-0001-000004000001', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-000400010001', '44444444-0000-0000-0001-000004000001', 'Taille', 1, 1, 1),
  ('55555555-0000-0000-0001-000400020000', '44444444-0000-0000-0001-000004000002', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-000400030000', '44444444-0000-0000-0001-000004000003', 'Morceau', 1, 1, 0),
  ('55555555-0000-0000-0001-000400030001', '44444444-0000-0000-0001-000004000003', 'Sauces', 0, 2, 1)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-004001000000', '55555555-0000-0000-0001-000400010000', 'Attiéké', 0, 0),
  ('66666666-0000-0000-0001-004001000001', '55555555-0000-0000-0001-000400010000', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-004001000002', '55555555-0000-0000-0001-000400010000', 'Riz blanc', 0, 2),
  ('66666666-0000-0000-0001-004001000003', '55555555-0000-0000-0001-000400010000', 'Frites', 500, 3),
  ('66666666-0000-0000-0001-004001001000', '55555555-0000-0000-0001-000400010001', 'Pour 1 personne', 0, 0),
  ('66666666-0000-0000-0001-004001001001', '55555555-0000-0000-0001-000400010001', 'Pour 2 personnes', 4000, 1),
  ('66666666-0000-0000-0001-004002000000', '55555555-0000-0000-0001-000400020000', 'Attiéké', 0, 0),
  ('66666666-0000-0000-0001-004002000001', '55555555-0000-0000-0001-000400020000', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-004002000002', '55555555-0000-0000-0001-000400020000', 'Riz blanc', 0, 2),
  ('66666666-0000-0000-0001-004002000003', '55555555-0000-0000-0001-000400020000', 'Frites', 500, 3),
  ('66666666-0000-0000-0001-004003000000', '55555555-0000-0000-0001-000400030000', 'Quart', 0, 0),
  ('66666666-0000-0000-0001-004003000001', '55555555-0000-0000-0001-000400030000', 'Demi-poulet', 2500, 1),
  ('66666666-0000-0000-0001-004003000002', '55555555-0000-0000-0001-000400030000', 'Poulet entier', 6000, 2),
  ('66666666-0000-0000-0001-004003001000', '55555555-0000-0000-0001-000400030001', 'Piment', 0, 0),
  ('66666666-0000-0000-0001-004003001001', '55555555-0000-0000-0001-000400030001', 'Moutarde', 0, 1),
  ('66666666-0000-0000-0001-004003001002', '55555555-0000-0000-0001-000400030001', 'Mayonnaise', 100, 2)
on conflict (id) do nothing;

-- 05. Grill d'Abobo (Abidjan, Abobo Gare)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000005', z.id, 'restaurant', 'Grill d''Abobo', 'Grillades', 'Brochettes, choukouya et poulet braisé au feu de bois, du goûter jusqu''à tard le soir.', '+2250505120505', 5.4204, -4.0198,
  'Abobo Gare', 'Carrefour Samaké, côté gare', 25, false, 'demo/cover-brochettes-boeuf.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000005', 1, '16:00', '23:59'),
  ('22222222-0000-0000-0001-000000000005', 2, '16:00', '23:59'),
  ('22222222-0000-0000-0001-000000000005', 3, '16:00', '23:59'),
  ('22222222-0000-0000-0001-000000000005', 4, '16:00', '23:59'),
  ('22222222-0000-0000-0001-000000000005', 5, '16:00', '23:59'),
  ('22222222-0000-0000-0001-000000000005', 6, '16:00', '23:59'),
  ('22222222-0000-0000-0001-000000000005', 7, '16:00', '23:59')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000005000000', '22222222-0000-0000-0001-000000000005', 'Grillades', 0),
  ('33333333-0000-0000-0001-000005000001', '22222222-0000-0000-0001-000000000005', 'Boissons', 1)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000005000001', '22222222-0000-0000-0001-000000000005', '33333333-0000-0000-0001-000005000000', 'Brochettes de bœuf', 'Brochettes marinées, oignons et piment.', 1500, 'demo/brochettes-boeuf.jpg', true),
  ('44444444-0000-0000-0001-000005000002', '22222222-0000-0000-0001-000000000005', '33333333-0000-0000-0001-000005000000', 'Choukouya de mouton', 'Mouton grillé, oignons, tomate et épices kankankan.', 3000, 'demo/brochettes-boeuf.jpg', true),
  ('44444444-0000-0000-0001-000005000003', '22222222-0000-0000-0001-000000000005', '33333333-0000-0000-0001-000005000000', 'Poulet braisé entier', 'Poulet entier braisé, à partager.', 7000, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000005000004', '22222222-0000-0000-0001-000000000005', '33333333-0000-0000-0001-000005000000', 'Poisson braisé', 'Carpe braisée, attiéké et crudités.', 3500, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000005000005', '22222222-0000-0000-0001-000000000005', '33333333-0000-0000-0001-000005000001', 'Gnamakoudji', 'Jus de gingembre bien relevé.', 500, 'demo/gnamakoudji-bol.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000500010000', '44444444-0000-0000-0001-000005000001', 'Quantité', 1, 1, 0),
  ('55555555-0000-0000-0001-000500010001', '44444444-0000-0000-0001-000005000001', 'Sauces', 0, 2, 1),
  ('55555555-0000-0000-0001-000500020000', '44444444-0000-0000-0001-000005000002', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-000500030000', '44444444-0000-0000-0001-000005000003', 'Sauces', 0, 2, 0),
  ('55555555-0000-0000-0001-000500040000', '44444444-0000-0000-0001-000005000004', 'Taille du poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-000500050000', '44444444-0000-0000-0001-000005000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-005001000000', '55555555-0000-0000-0001-000500010000', '3 brochettes', 0, 0),
  ('66666666-0000-0000-0001-005001000001', '55555555-0000-0000-0001-000500010000', '5 brochettes', 1000, 1),
  ('66666666-0000-0000-0001-005001001000', '55555555-0000-0000-0001-000500010001', 'Piment', 0, 0),
  ('66666666-0000-0000-0001-005001001001', '55555555-0000-0000-0001-000500010001', 'Moutarde', 0, 1),
  ('66666666-0000-0000-0001-005001001002', '55555555-0000-0000-0001-000500010001', 'Mayonnaise', 100, 2),
  ('66666666-0000-0000-0001-005002000000', '55555555-0000-0000-0001-000500020000', 'Attiéké', 0, 0),
  ('66666666-0000-0000-0001-005002000001', '55555555-0000-0000-0001-000500020000', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-005002000002', '55555555-0000-0000-0001-000500020000', 'Riz blanc', 0, 2),
  ('66666666-0000-0000-0001-005002000003', '55555555-0000-0000-0001-000500020000', 'Frites', 500, 3),
  ('66666666-0000-0000-0001-005003000000', '55555555-0000-0000-0001-000500030000', 'Piment', 0, 0),
  ('66666666-0000-0000-0001-005003000001', '55555555-0000-0000-0001-000500030000', 'Moutarde', 0, 1),
  ('66666666-0000-0000-0001-005003000002', '55555555-0000-0000-0001-000500030000', 'Mayonnaise', 100, 2),
  ('66666666-0000-0000-0001-005004000000', '55555555-0000-0000-0001-000500040000', 'Moyen', 0, 0),
  ('66666666-0000-0000-0001-005004000001', '55555555-0000-0000-0001-000500040000', 'Grand', 1500, 1),
  ('66666666-0000-0000-0001-005005000000', '55555555-0000-0000-0001-000500050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-005005000001', '55555555-0000-0000-0001-000500050000', '1 litre', 500, 1)
on conflict (id) do nothing;

-- 06. La Table de Bassam (Grand-Bassam, Quartier France)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000006', z.id, 'restaurant', 'La Table de Bassam', 'Fruits de mer', 'Poissons et crevettes de la lagune, face à la mer, dans le quartier historique.', '+2250707120606', 5.2006, -3.7378,
  'Quartier France', 'Face à la plage, près du phare', 40, false, 'demo/cover-sauce-gombo-crevettes.jpg'
from public.zones z where z.city = 'Grand-Bassam' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000006', 1, '11:00', '22:00'),
  ('22222222-0000-0000-0001-000000000006', 2, '11:00', '22:00'),
  ('22222222-0000-0000-0001-000000000006', 3, '11:00', '22:00'),
  ('22222222-0000-0000-0001-000000000006', 4, '11:00', '22:00'),
  ('22222222-0000-0000-0001-000000000006', 5, '11:00', '22:00'),
  ('22222222-0000-0000-0001-000000000006', 6, '11:00', '22:00'),
  ('22222222-0000-0000-0001-000000000006', 7, '11:00', '22:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000006000000', '22222222-0000-0000-0001-000000000006', 'Plats', 0),
  ('33333333-0000-0000-0001-000006000001', '22222222-0000-0000-0001-000000000006', 'Grillades', 1),
  ('33333333-0000-0000-0001-000006000002', '22222222-0000-0000-0001-000000000006', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000006000001', '22222222-0000-0000-0001-000000000006', '33333333-0000-0000-0001-000006000000', 'Sauce gombo aux crevettes', 'Gombo frais, crevettes, poisson fumé et piment.', 5000, 'demo/sauce-gombo-crevettes.jpg', true),
  ('44444444-0000-0000-0001-000006000002', '22222222-0000-0000-0001-000000000006', '33333333-0000-0000-0001-000006000001', 'Capitaine braisé', 'Capitaine entier braisé, alloco et attiéké.', 7000, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000006000003', '22222222-0000-0000-0001-000000000006', '33333333-0000-0000-0001-000006000000', 'Alloco poisson', 'Alloco et poisson frit de la lagune.', 3000, 'demo/alloco-poisson.jpg', true),
  ('44444444-0000-0000-0001-000006000004', '22222222-0000-0000-0001-000000000006', '33333333-0000-0000-0001-000006000000', 'Attiéké poisson braisé', 'Attiéké, poisson braisé, tomate et oignon.', 3500, 'demo/attieke-poisson.jpg', true),
  ('44444444-0000-0000-0001-000006000005', '22222222-0000-0000-0001-000000000006', '33333333-0000-0000-0001-000006000002', 'Jus de mangue', 'Mangue de saison, servi glacé.', 1000, 'demo/jus-mangue.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000600010000', '44444444-0000-0000-0001-000006000001', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-000600020000', '44444444-0000-0000-0001-000006000002', 'Taille du poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-000600040000', '44444444-0000-0000-0001-000006000004', 'Poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-000600050000', '44444444-0000-0000-0001-000006000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-006001000000', '55555555-0000-0000-0001-000600010000', 'Riz blanc', 0, 0),
  ('66666666-0000-0000-0001-006001000001', '55555555-0000-0000-0001-000600010000', 'Foutou banane', 500, 1),
  ('66666666-0000-0000-0001-006001000002', '55555555-0000-0000-0001-000600010000', 'Attiéké', 0, 2),
  ('66666666-0000-0000-0001-006002000000', '55555555-0000-0000-0001-000600020000', 'Moyen', 0, 0),
  ('66666666-0000-0000-0001-006002000001', '55555555-0000-0000-0001-000600020000', 'Grand', 1500, 1),
  ('66666666-0000-0000-0001-006004000000', '55555555-0000-0000-0001-000600040000', 'Carpe', 0, 0),
  ('66666666-0000-0000-0001-006004000001', '55555555-0000-0000-0001-000600040000', 'Mâchoiron', 1000, 1),
  ('66666666-0000-0000-0001-006004000002', '55555555-0000-0000-0001-000600040000', 'Capitaine', 1500, 2),
  ('66666666-0000-0000-0001-006005000000', '55555555-0000-0000-0001-000600050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-006005000001', '55555555-0000-0000-0001-000600050000', '1 litre', 500, 1)
on conflict (id) do nothing;

-- 07. Maman Brou Cuisine (Bouaké, Commerce)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000007', z.id, 'restaurant', 'Maman Brou Cuisine', 'Cuisine ivoirienne', 'Cuisine familiale du centre : sauces maison, riz gras et dêguê, à deux pas du grand marché.', '+2250102120707', 7.6893, -5.0312,
  'Commerce', 'À côté du grand marché de Bouaké', 30, false, 'demo/cover-sauce-arachide.jpg'
from public.zones z where z.city = 'Bouaké' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000007', 1, '10:30', '21:30'),
  ('22222222-0000-0000-0001-000000000007', 2, '10:30', '21:30'),
  ('22222222-0000-0000-0001-000000000007', 3, '10:30', '21:30'),
  ('22222222-0000-0000-0001-000000000007', 4, '10:30', '21:30'),
  ('22222222-0000-0000-0001-000000000007', 5, '10:30', '21:30'),
  ('22222222-0000-0000-0001-000000000007', 6, '10:30', '21:30'),
  ('22222222-0000-0000-0001-000000000007', 7, '10:30', '21:30')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000007000000', '22222222-0000-0000-0001-000000000007', 'Sauces', 0),
  ('33333333-0000-0000-0001-000007000001', '22222222-0000-0000-0001-000000000007', 'Plats', 1),
  ('33333333-0000-0000-0001-000007000002', '22222222-0000-0000-0001-000000000007', 'Desserts', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000007000001', '22222222-0000-0000-0001-000000000007', '33333333-0000-0000-0001-000007000000', 'Sauce arachide', 'Sauce arachide, viande au choix, riz blanc.', 2000, 'demo/sauce-arachide.jpg', true),
  ('44444444-0000-0000-0001-000007000002', '22222222-0000-0000-0001-000000000007', '33333333-0000-0000-0001-000007000000', 'Sauce légumes au poisson', 'Aubergine, chou, carottes et poisson fumé.', 2000, 'demo/sauce-legumes.jpg', true),
  ('44444444-0000-0000-0001-000007000003', '22222222-0000-0000-0001-000000000007', '33333333-0000-0000-0001-000007000000', 'Foutou igname sauce claire', 'Foutou igname pilé à la main, sauce claire.', 2500, 'demo/foutou-sauce-claire.jpg', true),
  ('44444444-0000-0000-0001-000007000004', '22222222-0000-0000-0001-000000000007', '33333333-0000-0000-0001-000007000001', 'Riz gras', 'Riz gras à la viande et légumes.', 1500, 'demo/riz-gras.jpg', true),
  ('44444444-0000-0000-0001-000007000005', '22222222-0000-0000-0001-000000000007', '33333333-0000-0000-0001-000007000002', 'Dêguê', 'Mil et lait caillé sucré, bien frais.', 500, 'demo/degue.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000700010000', '44444444-0000-0000-0001-000007000001', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-000700020000', '44444444-0000-0000-0001-000007000002', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-000700030000', '44444444-0000-0000-0001-000007000003', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-000700040000', '44444444-0000-0000-0001-000007000004', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-000700050000', '44444444-0000-0000-0001-000007000005', 'Suppléments', 0, 2, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-007001000000', '55555555-0000-0000-0001-000700010000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-007001000001', '55555555-0000-0000-0001-000700010000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-007001000002', '55555555-0000-0000-0001-000700010000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-007001000003', '55555555-0000-0000-0001-000700010000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-007002000000', '55555555-0000-0000-0001-000700020000', 'Riz blanc', 0, 0),
  ('66666666-0000-0000-0001-007002000001', '55555555-0000-0000-0001-000700020000', 'Foutou banane', 500, 1),
  ('66666666-0000-0000-0001-007002000002', '55555555-0000-0000-0001-000700020000', 'Attiéké', 0, 2),
  ('66666666-0000-0000-0001-007003000000', '55555555-0000-0000-0001-000700030000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-007003000001', '55555555-0000-0000-0001-000700030000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-007003000002', '55555555-0000-0000-0001-000700030000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-007003000003', '55555555-0000-0000-0001-000700030000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-007004000000', '55555555-0000-0000-0001-000700040000', 'Poulet', 0, 0),
  ('66666666-0000-0000-0001-007004000001', '55555555-0000-0000-0001-000700040000', 'Mouton', 500, 1),
  ('66666666-0000-0000-0001-007005000000', '55555555-0000-0000-0001-000700050000', 'Arachides grillées', 100, 0),
  ('66666666-0000-0000-0001-007005000001', '55555555-0000-0000-0001-000700050000', 'Lait concentré', 200, 1)
on conflict (id) do nothing;

-- 08. Le Petit Bouaké Grill (Bouaké, Koko)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000008', z.id, 'restaurant', 'Le Petit Bouaké Grill', 'Grillades', 'Le rendez-vous du soir à Koko : poulet braisé, brochettes et bangui frais.', '+2250505120808', 7.6981, -5.0186,
  'Koko', 'Route de Béoumi, après le rond-point', 25, false, 'demo/cover-plateau-braise.jpg'
from public.zones z where z.city = 'Bouaké' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000008', 1, '17:00', '23:30'),
  ('22222222-0000-0000-0001-000000000008', 2, '17:00', '23:30'),
  ('22222222-0000-0000-0001-000000000008', 3, '17:00', '23:30'),
  ('22222222-0000-0000-0001-000000000008', 4, '17:00', '23:30'),
  ('22222222-0000-0000-0001-000000000008', 5, '17:00', '23:30'),
  ('22222222-0000-0000-0001-000000000008', 6, '17:00', '23:30'),
  ('22222222-0000-0000-0001-000000000008', 7, '17:00', '23:30')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000008000000', '22222222-0000-0000-0001-000000000008', 'Grillades', 0),
  ('33333333-0000-0000-0001-000008000001', '22222222-0000-0000-0001-000000000008', 'Plats', 1),
  ('33333333-0000-0000-0001-000008000002', '22222222-0000-0000-0001-000000000008', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000008000001', '22222222-0000-0000-0001-000000000008', '33333333-0000-0000-0001-000008000000', 'Poulet braisé', 'Poulet braisé, sauce oignon et attiéké.', 3500, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000008000002', '22222222-0000-0000-0001-000000000008', '33333333-0000-0000-0001-000008000000', 'Brochettes de bœuf', 'Brochettes de bœuf grillées, piment.', 1500, 'demo/brochettes-boeuf.jpg', true),
  ('44444444-0000-0000-0001-000008000003', '22222222-0000-0000-0001-000000000008', '33333333-0000-0000-0001-000008000001', 'Alloco poulet', 'Alloco et poulet braisé.', 2500, 'demo/alloco-poulet.jpg', true),
  ('44444444-0000-0000-0001-000008000004', '22222222-0000-0000-0001-000000000008', '33333333-0000-0000-0001-000008000000', 'Poisson braisé', 'Poisson braisé, attiéké et piment.', 3000, 'demo/plateau-braise.jpg', false),
  ('44444444-0000-0000-0001-000008000005', '22222222-0000-0000-0001-000000000008', '33333333-0000-0000-0001-000008000002', 'Bangui frais', 'Vin de palme frais (boisson alcoolisée).', 800, 'demo/bangui.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000800010000', '44444444-0000-0000-0001-000008000001', 'Morceau', 1, 1, 0),
  ('55555555-0000-0000-0001-000800020000', '44444444-0000-0000-0001-000008000002', 'Quantité', 1, 1, 0),
  ('55555555-0000-0000-0001-000800040000', '44444444-0000-0000-0001-000008000004', 'Taille du poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-000800050000', '44444444-0000-0000-0001-000008000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-008001000000', '55555555-0000-0000-0001-000800010000', 'Quart', 0, 0),
  ('66666666-0000-0000-0001-008001000001', '55555555-0000-0000-0001-000800010000', 'Demi-poulet', 2500, 1),
  ('66666666-0000-0000-0001-008001000002', '55555555-0000-0000-0001-000800010000', 'Poulet entier', 6000, 2),
  ('66666666-0000-0000-0001-008002000000', '55555555-0000-0000-0001-000800020000', '3 brochettes', 0, 0),
  ('66666666-0000-0000-0001-008002000001', '55555555-0000-0000-0001-000800020000', '5 brochettes', 1000, 1),
  ('66666666-0000-0000-0001-008004000000', '55555555-0000-0000-0001-000800040000', 'Moyen', 0, 0),
  ('66666666-0000-0000-0001-008004000001', '55555555-0000-0000-0001-000800040000', 'Grand', 1500, 1),
  ('66666666-0000-0000-0001-008005000000', '55555555-0000-0000-0001-000800050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-008005000001', '55555555-0000-0000-0001-000800050000', '1 litre', 700, 1)
on conflict (id) do nothing;

-- 09. Les Délices de Yakro (Yamoussoukro, Habitat)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000009', z.id, 'restaurant', 'Les Délices de Yakro', 'Maquis ivoirien', 'Maquis convivial près de la basilique : kédjénou, placali et garba à petits prix.', '+2250707120909', 6.8126, -5.2654,
  'Habitat', 'Route de l''hôtel Président, près de la basilique', 25, false, 'demo/cover-sauce-legumes.jpg'
from public.zones z where z.city = 'Yamoussoukro' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000009', 1, '11:00', '22:30'),
  ('22222222-0000-0000-0001-000000000009', 2, '11:00', '22:30'),
  ('22222222-0000-0000-0001-000000000009', 3, '11:00', '22:30'),
  ('22222222-0000-0000-0001-000000000009', 4, '11:00', '22:30'),
  ('22222222-0000-0000-0001-000000000009', 5, '11:00', '22:30'),
  ('22222222-0000-0000-0001-000000000009', 6, '11:00', '22:30'),
  ('22222222-0000-0000-0001-000000000009', 7, '11:00', '22:30')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000009000000', '22222222-0000-0000-0001-000000000009', 'Plats', 0),
  ('33333333-0000-0000-0001-000009000001', '22222222-0000-0000-0001-000000000009', 'Sauces', 1),
  ('33333333-0000-0000-0001-000009000002', '22222222-0000-0000-0001-000000000009', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000009000001', '22222222-0000-0000-0001-000000000009', '33333333-0000-0000-0001-000009000000', 'Kédjénou de poulet', 'Poulet mijoté au canari, attiéké.', 3500, 'demo/kedjenou-poulet.jpg', true),
  ('44444444-0000-0000-0001-000009000002', '22222222-0000-0000-0001-000000000009', '33333333-0000-0000-0001-000009000001', 'Placali sauce gombo', 'Placali et sauce gombo au poisson fumé.', 2500, 'demo/placali.jpg', true),
  ('44444444-0000-0000-0001-000009000003', '22222222-0000-0000-0001-000000000009', '33333333-0000-0000-0001-000009000000', 'Garba', 'Attiéké et thon frit, piment.', 1000, 'demo/garba.jpg', true),
  ('44444444-0000-0000-0001-000009000004', '22222222-0000-0000-0001-000000000009', '33333333-0000-0000-0001-000009000000', 'Alloco œufs', 'Alloco, œufs durs et sauce piment.', 1000, 'demo/alloco-chaud.jpg', true),
  ('44444444-0000-0000-0001-000009000005', '22222222-0000-0000-0001-000000000009', '33333333-0000-0000-0001-000009000002', 'Bissap', 'Bissap maison, 50 cl.', 500, 'demo/bissap.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-000900010000', '44444444-0000-0000-0001-000009000001', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-000900020000', '44444444-0000-0000-0001-000009000002', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-000900030000', '44444444-0000-0000-0001-000009000003', 'Portion', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-009001000000', '55555555-0000-0000-0001-000900010000', 'Attiéké', 0, 0),
  ('66666666-0000-0000-0001-009001000001', '55555555-0000-0000-0001-000900010000', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-009001000002', '55555555-0000-0000-0001-000900010000', 'Riz blanc', 0, 2),
  ('66666666-0000-0000-0001-009001000003', '55555555-0000-0000-0001-000900010000', 'Frites', 500, 3),
  ('66666666-0000-0000-0001-009002000000', '55555555-0000-0000-0001-000900020000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-009002000001', '55555555-0000-0000-0001-000900020000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-009002000002', '55555555-0000-0000-0001-000900020000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-009002000003', '55555555-0000-0000-0001-000900020000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-009003000000', '55555555-0000-0000-0001-000900030000', 'Simple', 0, 0),
  ('66666666-0000-0000-0001-009003000001', '55555555-0000-0000-0001-000900030000', 'Double', 800, 1)
on conflict (id) do nothing;

-- 10. Douceurs du Lac (Yamoussoukro, Dioulakro)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000010', z.id, 'shop', 'Douceurs du Lac', 'Jus et douceurs', 'Jus naturels pressés à la commande, dêguê et viennoiseries, au bord du lac aux caïmans.', '+2250102121010', 6.8213, -5.2766,
  'Dioulakro', 'Bord du lac aux caïmans', 10, false, 'demo/cover-jus-mangue.jpg'
from public.zones z where z.city = 'Yamoussoukro' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000010', 1, '08:00', '20:00'),
  ('22222222-0000-0000-0001-000000000010', 2, '08:00', '20:00'),
  ('22222222-0000-0000-0001-000000000010', 3, '08:00', '20:00'),
  ('22222222-0000-0000-0001-000000000010', 4, '08:00', '20:00'),
  ('22222222-0000-0000-0001-000000000010', 5, '08:00', '20:00'),
  ('22222222-0000-0000-0001-000000000010', 6, '08:00', '20:00'),
  ('22222222-0000-0000-0001-000000000010', 7, '08:00', '20:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000010000000', '22222222-0000-0000-0001-000000000010', 'Jus', 0),
  ('33333333-0000-0000-0001-000010000001', '22222222-0000-0000-0001-000000000010', 'Desserts', 1),
  ('33333333-0000-0000-0001-000010000002', '22222222-0000-0000-0001-000000000010', 'Viennoiseries', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000010000001', '22222222-0000-0000-0001-000000000010', '33333333-0000-0000-0001-000010000000', 'Jus de mangue', 'Mangue fraîche mixée à la commande.', 700, 'demo/jus-mangue.jpg', true),
  ('44444444-0000-0000-0001-000010000002', '22222222-0000-0000-0001-000000000010', '33333333-0000-0000-0001-000010000000', 'Bissap 1 litre', 'Bissap menthe et ananas en carafe.', 1200, 'demo/bissap-carafe.jpg', true),
  ('44444444-0000-0000-0001-000010000003', '22222222-0000-0000-0001-000000000010', '33333333-0000-0000-0001-000010000000', 'Gnamakoudji', 'Gingembre, citron vert et menthe.', 600, 'demo/gnamakoudji-bol.jpg', true),
  ('44444444-0000-0000-0001-000010000004', '22222222-0000-0000-0001-000000000010', '33333333-0000-0000-0001-000010000001', 'Dêguê', 'Dêguê crémeux au lait caillé.', 700, 'demo/degue.jpg', true),
  ('44444444-0000-0000-0001-000010000005', '22222222-0000-0000-0001-000000000010', '33333333-0000-0000-0001-000010000002', 'Pain au chocolat', 'Pain au chocolat pur beurre.', 500, 'demo/pain-au-chocolat.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001000010000', '44444444-0000-0000-0001-000010000001', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-001000030000', '44444444-0000-0000-0001-000010000003', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-001000040000', '44444444-0000-0000-0001-000010000004', 'Suppléments', 0, 2, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-010001000000', '55555555-0000-0000-0001-001000010000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-010001000001', '55555555-0000-0000-0001-001000010000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-010003000000', '55555555-0000-0000-0001-001000030000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-010003000001', '55555555-0000-0000-0001-001000030000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-010004000000', '55555555-0000-0000-0001-001000040000', 'Arachides grillées', 100, 0),
  ('66666666-0000-0000-0001-010004000001', '55555555-0000-0000-0001-001000040000', 'Lait concentré', 200, 1)
on conflict (id) do nothing;

-- 11. Saveurs de San-Pédro (San-Pédro, Bardot)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000011', z.id, 'restaurant', 'Saveurs de San-Pédro', 'Poissons', 'Le poisson du port, braisé ou en sauce, directement des pirogues du matin.', '+2250505121111', 4.7392, -6.6293,
  'Bardot', 'Près du port de pêche', 35, false, 'demo/cover-attieke-poisson.jpg'
from public.zones z where z.city = 'San-Pédro' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000011', 1, '11:00', '23:00'),
  ('22222222-0000-0000-0001-000000000011', 2, '11:00', '23:00'),
  ('22222222-0000-0000-0001-000000000011', 3, '11:00', '23:00'),
  ('22222222-0000-0000-0001-000000000011', 4, '11:00', '23:00'),
  ('22222222-0000-0000-0001-000000000011', 5, '11:00', '23:00'),
  ('22222222-0000-0000-0001-000000000011', 6, '11:00', '23:00'),
  ('22222222-0000-0000-0001-000000000011', 7, '11:00', '23:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000011000000', '22222222-0000-0000-0001-000000000011', 'Plats', 0),
  ('33333333-0000-0000-0001-000011000001', '22222222-0000-0000-0001-000000000011', 'Grillades', 1),
  ('33333333-0000-0000-0001-000011000002', '22222222-0000-0000-0001-000000000011', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000011000001', '22222222-0000-0000-0001-000000000011', '33333333-0000-0000-0001-000011000000', 'Attiéké poisson braisé', 'Attiéké, poisson braisé et sauce tomate.', 3000, 'demo/attieke-poisson.jpg', true),
  ('44444444-0000-0000-0001-000011000002', '22222222-0000-0000-0001-000000000011', '33333333-0000-0000-0001-000011000000', 'Sauce gombo aux crevettes', 'Gombo, crevettes et crabe, riz blanc.', 4500, 'demo/sauce-gombo-crevettes.jpg', true),
  ('44444444-0000-0000-0001-000011000003', '22222222-0000-0000-0001-000000000011', '33333333-0000-0000-0001-000011000001', 'Plateau braisé', 'Poulet et poisson braisés, attiéké, alloco.', 5000, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000011000004', '22222222-0000-0000-0001-000000000011', '33333333-0000-0000-0001-000011000000', 'Alloco poisson', 'Alloco et poisson frit.', 2500, 'demo/alloco-poisson.jpg', true),
  ('44444444-0000-0000-0001-000011000005', '22222222-0000-0000-0001-000000000011', '33333333-0000-0000-0001-000011000002', 'Jus de mangue', 'Mangue fraîche, 50 cl.', 600, 'demo/jus-mangue.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001100010000', '44444444-0000-0000-0001-000011000001', 'Poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-001100020000', '44444444-0000-0000-0001-000011000002', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-001100030000', '44444444-0000-0000-0001-000011000003', 'Sauces', 0, 2, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-011001000000', '55555555-0000-0000-0001-001100010000', 'Carpe', 0, 0),
  ('66666666-0000-0000-0001-011001000001', '55555555-0000-0000-0001-001100010000', 'Mâchoiron', 1000, 1),
  ('66666666-0000-0000-0001-011001000002', '55555555-0000-0000-0001-001100010000', 'Capitaine', 1500, 2),
  ('66666666-0000-0000-0001-011002000000', '55555555-0000-0000-0001-001100020000', 'Riz blanc', 0, 0),
  ('66666666-0000-0000-0001-011002000001', '55555555-0000-0000-0001-001100020000', 'Foutou banane', 500, 1),
  ('66666666-0000-0000-0001-011002000002', '55555555-0000-0000-0001-001100020000', 'Attiéké', 0, 2),
  ('66666666-0000-0000-0001-011003000000', '55555555-0000-0000-0001-001100030000', 'Piment', 0, 0),
  ('66666666-0000-0000-0001-011003000001', '55555555-0000-0000-0001-001100030000', 'Moutarde', 0, 1),
  ('66666666-0000-0000-0001-011003000002', '55555555-0000-0000-0001-001100030000', 'Mayonnaise', 100, 2)
on conflict (id) do nothing;

-- 12. Saveurs du Nord (Korhogo, Soba)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000012', z.id, 'restaurant', 'Saveurs du Nord', 'Cuisine du Nord', 'Riz gras, tô et sauces du Poro, servis généreusement près du marché central.', '+2250707121212', 9.4581, -5.629,
  'Soba', 'Près du marché central de Korhogo', 25, false, 'demo/cover-riz-gras.jpg'
from public.zones z where z.city = 'Korhogo' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000012', 1, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000012', 2, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000012', 3, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000012', 4, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000012', 5, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000012', 6, '10:00', '22:00'),
  ('22222222-0000-0000-0001-000000000012', 7, '10:00', '22:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000012000000', '22222222-0000-0000-0001-000000000012', 'Plats', 0),
  ('33333333-0000-0000-0001-000012000001', '22222222-0000-0000-0001-000000000012', 'Sauces', 1),
  ('33333333-0000-0000-0001-000012000002', '22222222-0000-0000-0001-000000000012', 'Desserts', 2),
  ('33333333-0000-0000-0001-000012000003', '22222222-0000-0000-0001-000000000012', 'Boissons', 3)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000012000001', '22222222-0000-0000-0001-000000000012', '33333333-0000-0000-0001-000012000000', 'Riz gras', 'Riz gras à la viande et légumes du marché.', 1500, 'demo/riz-gras.jpg', true),
  ('44444444-0000-0000-0001-000012000002', '22222222-0000-0000-0001-000000000012', '33333333-0000-0000-0001-000012000001', 'Tô sauce gombo', 'Tô de maïs et sauce gombo au soumbala.', 1500, 'demo/placali.jpg', true),
  ('44444444-0000-0000-0001-000012000003', '22222222-0000-0000-0001-000000000012', '33333333-0000-0000-0001-000012000001', 'Sauce arachide', 'Sauce arachide et riz blanc.', 2000, 'demo/sauce-arachide.jpg', true),
  ('44444444-0000-0000-0001-000012000004', '22222222-0000-0000-0001-000000000012', '33333333-0000-0000-0001-000012000002', 'Dêguê', 'Dêguê de mil au lait caillé.', 500, 'demo/degue.jpg', true),
  ('44444444-0000-0000-0001-000012000005', '22222222-0000-0000-0001-000000000012', '33333333-0000-0000-0001-000012000003', 'Gnamakoudji', 'Jus de gingembre maison.', 400, 'demo/gnamakoudji.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001200010000', '44444444-0000-0000-0001-000012000001', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-001200030000', '44444444-0000-0000-0001-000012000003', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-001200040000', '44444444-0000-0000-0001-000012000004', 'Suppléments', 0, 2, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-012001000000', '55555555-0000-0000-0001-001200010000', 'Poulet', 0, 0),
  ('66666666-0000-0000-0001-012001000001', '55555555-0000-0000-0001-001200010000', 'Mouton', 500, 1),
  ('66666666-0000-0000-0001-012003000000', '55555555-0000-0000-0001-001200030000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-012003000001', '55555555-0000-0000-0001-001200030000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-012003000002', '55555555-0000-0000-0001-001200030000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-012003000003', '55555555-0000-0000-0001-001200030000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-012004000000', '55555555-0000-0000-0001-001200040000', 'Arachides grillées', 100, 0),
  ('66666666-0000-0000-0001-012004000001', '55555555-0000-0000-0001-001200040000', 'Lait concentré', 200, 1)
on conflict (id) do nothing;

-- 13. Chez Ablo Braisé (Abidjan, Koumassi Remblais)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000013', z.id, 'restaurant', 'Chez Ablo Braisé', 'Grillades', 'Poulet DG, poulet braisé et brochettes, le spécialiste du braisé à Koumassi.', '+2250505121313', 5.2969, -3.9518,
  'Koumassi Remblais', 'Derrière le marché de Koumassi', 30, false, 'demo/cover-poulet-dg.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000013', 1, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000013', 2, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000013', 3, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000013', 4, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000013', 5, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000013', 6, '12:00', '23:30'),
  ('22222222-0000-0000-0001-000000000013', 7, '12:00', '23:30')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000013000000', '22222222-0000-0000-0001-000000000013', 'Plats', 0),
  ('33333333-0000-0000-0001-000013000001', '22222222-0000-0000-0001-000000000013', 'Grillades', 1),
  ('33333333-0000-0000-0001-000013000002', '22222222-0000-0000-0001-000000000013', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000013000001', '22222222-0000-0000-0001-000000000013', '33333333-0000-0000-0001-000013000000', 'Poulet DG', 'Poulet, plantain mûr et légumes sautés.', 5000, 'demo/poulet-dg.jpg', true),
  ('44444444-0000-0000-0001-000013000002', '22222222-0000-0000-0001-000000000013', '33333333-0000-0000-0001-000013000001', 'Poulet braisé', 'Poulet braisé au charbon, attiéké.', 4000, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000013000003', '22222222-0000-0000-0001-000000000013', '33333333-0000-0000-0001-000013000001', 'Brochettes de bœuf', 'Brochettes, oignons, piment.', 1500, 'demo/brochettes-boeuf.jpg', true),
  ('44444444-0000-0000-0001-000013000004', '22222222-0000-0000-0001-000000000013', '33333333-0000-0000-0001-000013000000', 'Alloco poulet', 'Alloco et cuisse de poulet braisée.', 2500, 'demo/alloco-poulet.jpg', true),
  ('44444444-0000-0000-0001-000013000005', '22222222-0000-0000-0001-000000000013', '33333333-0000-0000-0001-000013000002', 'Bissap', 'Bissap maison, 50 cl.', 500, 'demo/bissap.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001300010000', '44444444-0000-0000-0001-000013000001', 'Taille', 1, 1, 0),
  ('55555555-0000-0000-0001-001300020000', '44444444-0000-0000-0001-000013000002', 'Morceau', 1, 1, 0),
  ('55555555-0000-0000-0001-001300020001', '44444444-0000-0000-0001-000013000002', 'Sauces', 0, 2, 1),
  ('55555555-0000-0000-0001-001300030000', '44444444-0000-0000-0001-000013000003', 'Quantité', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-013001000000', '55555555-0000-0000-0001-001300010000', 'Pour 1 personne', 0, 0),
  ('66666666-0000-0000-0001-013001000001', '55555555-0000-0000-0001-001300010000', 'Pour 2 personnes', 4000, 1),
  ('66666666-0000-0000-0001-013002000000', '55555555-0000-0000-0001-001300020000', 'Quart', 0, 0),
  ('66666666-0000-0000-0001-013002000001', '55555555-0000-0000-0001-001300020000', 'Demi-poulet', 2500, 1),
  ('66666666-0000-0000-0001-013002000002', '55555555-0000-0000-0001-001300020000', 'Poulet entier', 6000, 2),
  ('66666666-0000-0000-0001-013002001000', '55555555-0000-0000-0001-001300020001', 'Piment', 0, 0),
  ('66666666-0000-0000-0001-013002001001', '55555555-0000-0000-0001-001300020001', 'Moutarde', 0, 1),
  ('66666666-0000-0000-0001-013002001002', '55555555-0000-0000-0001-001300020001', 'Mayonnaise', 100, 2),
  ('66666666-0000-0000-0001-013003000000', '55555555-0000-0000-0001-001300030000', '3 brochettes', 0, 0),
  ('66666666-0000-0000-0001-013003000001', '55555555-0000-0000-0001-001300030000', '5 brochettes', 1000, 1)
on conflict (id) do nothing;

-- 14. Restaurant Le Bon Gombo (Abidjan, Treichville avenue 16)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000014', z.id, 'restaurant', 'Restaurant Le Bon Gombo', 'Cuisine ivoirienne', 'Sauces gombo, graine et légumes du jour à Treichville, servies avec placali, foutou ou riz.', '+2250102121414', 5.2962, -4.0058,
  'Treichville avenue 16', 'Près de la grande mosquée de Treichville', 30, false, 'demo/cover-placali.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000014', 1, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000014', 1, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000014', 2, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000014', 2, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000014', 3, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000014', 3, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000014', 4, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000014', 4, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000014', 5, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000014', 5, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000014', 6, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000014', 6, '18:00', '22:00'),
  ('22222222-0000-0000-0001-000000000014', 7, '11:00', '15:00'),
  ('22222222-0000-0000-0001-000000000014', 7, '18:00', '22:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000014000000', '22222222-0000-0000-0001-000000000014', 'Sauces', 0),
  ('33333333-0000-0000-0001-000014000001', '22222222-0000-0000-0001-000000000014', 'Plats', 1),
  ('33333333-0000-0000-0001-000014000002', '22222222-0000-0000-0001-000000000014', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000014000001', '22222222-0000-0000-0001-000000000014', '33333333-0000-0000-0001-000014000000', 'Placali sauce gombo', 'Placali et sauce gombo au poisson fumé.', 2500, 'demo/placali.jpg', true),
  ('44444444-0000-0000-0001-000014000002', '22222222-0000-0000-0001-000000000014', '33333333-0000-0000-0001-000014000000', 'Foutou banane sauce graine', 'Foutou banane, sauce graine.', 3000, 'demo/foutou-sauce-graine.jpg', true),
  ('44444444-0000-0000-0001-000014000003', '22222222-0000-0000-0001-000000000014', '33333333-0000-0000-0001-000014000000', 'Sauce légumes au poisson', 'Sauce légumes et poisson, riz.', 2500, 'demo/sauce-legumes.jpg', true),
  ('44444444-0000-0000-0001-000014000004', '22222222-0000-0000-0001-000000000014', '33333333-0000-0000-0001-000014000001', 'Riz gras au poulet', 'Riz gras et poulet.', 2000, 'demo/riz-gras.jpg', true),
  ('44444444-0000-0000-0001-000014000005', '22222222-0000-0000-0001-000000000014', '33333333-0000-0000-0001-000014000002', 'Gnamakoudji', 'Gingembre frais.', 500, 'demo/gnamakoudji-bol.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001400010000', '44444444-0000-0000-0001-000014000001', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-001400020000', '44444444-0000-0000-0001-000014000002', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-001400030000', '44444444-0000-0000-0001-000014000003', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-001400050000', '44444444-0000-0000-0001-000014000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-014001000000', '55555555-0000-0000-0001-001400010000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-014001000001', '55555555-0000-0000-0001-001400010000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-014001000002', '55555555-0000-0000-0001-001400010000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-014001000003', '55555555-0000-0000-0001-001400010000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-014002000000', '55555555-0000-0000-0001-001400020000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-014002000001', '55555555-0000-0000-0001-001400020000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-014002000002', '55555555-0000-0000-0001-001400020000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-014002000003', '55555555-0000-0000-0001-001400020000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-014003000000', '55555555-0000-0000-0001-001400030000', 'Riz blanc', 0, 0),
  ('66666666-0000-0000-0001-014003000001', '55555555-0000-0000-0001-001400030000', 'Foutou banane', 500, 1),
  ('66666666-0000-0000-0001-014003000002', '55555555-0000-0000-0001-001400030000', 'Attiéké', 0, 2),
  ('66666666-0000-0000-0001-014005000000', '55555555-0000-0000-0001-001400050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-014005000001', '55555555-0000-0000-0001-001400050000', '1 litre', 500, 1)
on conflict (id) do nothing;

-- 15. Le Maquis des Deux Plateaux (Abidjan, Cocody Deux Plateaux Vallon)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000015', z.id, 'restaurant', 'Le Maquis des Deux Plateaux', 'Maquis ivoirien', 'Maquis chic des Deux Plateaux : foutou, kédjénou et poisson braisé en terrasse.', '+2250707121515', 5.3729, -3.9973,
  'Cocody Deux Plateaux Vallon', 'Rue des Jardins, près de la boulangerie', 30, false, 'demo/cover-foutou-sauce-claire.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000015', 1, '12:00', '23:59'),
  ('22222222-0000-0000-0001-000000000015', 2, '12:00', '23:59'),
  ('22222222-0000-0000-0001-000000000015', 3, '12:00', '23:59'),
  ('22222222-0000-0000-0001-000000000015', 4, '12:00', '23:59'),
  ('22222222-0000-0000-0001-000000000015', 5, '12:00', '23:59'),
  ('22222222-0000-0000-0001-000000000015', 6, '12:00', '23:59'),
  ('22222222-0000-0000-0001-000000000015', 7, '12:00', '23:59')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000015000000', '22222222-0000-0000-0001-000000000015', 'Sauces', 0),
  ('33333333-0000-0000-0001-000015000001', '22222222-0000-0000-0001-000000000015', 'Plats', 1),
  ('33333333-0000-0000-0001-000015000002', '22222222-0000-0000-0001-000000000015', 'Grillades', 2),
  ('33333333-0000-0000-0001-000015000003', '22222222-0000-0000-0001-000000000015', 'Boissons', 3)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000015000001', '22222222-0000-0000-0001-000000000015', '33333333-0000-0000-0001-000015000000', 'Foutou igname sauce claire', 'Foutou igname, sauce claire et viande.', 3500, 'demo/foutou-sauce-claire.jpg', true),
  ('44444444-0000-0000-0001-000015000002', '22222222-0000-0000-0001-000000000015', '33333333-0000-0000-0001-000015000001', 'Kédjénou de poulet', 'Kédjénou au canari, attiéké.', 4500, 'demo/kedjenou-canari.jpg', true),
  ('44444444-0000-0000-0001-000015000003', '22222222-0000-0000-0001-000000000015', '33333333-0000-0000-0001-000015000002', 'Poisson braisé', 'Poisson braisé, attiéké, crudités.', 5000, 'demo/plateau-braise.jpg', true),
  ('44444444-0000-0000-0001-000015000004', '22222222-0000-0000-0001-000000000015', '33333333-0000-0000-0001-000015000001', 'Alloco poisson', 'Alloco et poisson frit.', 3000, 'demo/alloco-poisson.jpg', true),
  ('44444444-0000-0000-0001-000015000005', '22222222-0000-0000-0001-000000000015', '33333333-0000-0000-0001-000015000003', 'Jus de mangue', 'Mangue fraîche mixée.', 1000, 'demo/jus-mangue.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001500010000', '44444444-0000-0000-0001-000015000001', 'Viande', 1, 1, 0),
  ('55555555-0000-0000-0001-001500020000', '44444444-0000-0000-0001-000015000002', 'Accompagnement', 1, 1, 0),
  ('55555555-0000-0000-0001-001500020001', '44444444-0000-0000-0001-000015000002', 'Taille', 1, 1, 1),
  ('55555555-0000-0000-0001-001500030000', '44444444-0000-0000-0001-000015000003', 'Taille du poisson', 1, 1, 0),
  ('55555555-0000-0000-0001-001500030001', '44444444-0000-0000-0001-000015000003', 'Accompagnement', 1, 1, 1),
  ('55555555-0000-0000-0001-001500050000', '44444444-0000-0000-0001-000015000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-015001000000', '55555555-0000-0000-0001-001500010000', 'Bœuf', 0, 0),
  ('66666666-0000-0000-0001-015001000001', '55555555-0000-0000-0001-001500010000', 'Poisson fumé', 0, 1),
  ('66666666-0000-0000-0001-015001000002', '55555555-0000-0000-0001-001500010000', 'Poulet', 500, 2),
  ('66666666-0000-0000-0001-015001000003', '55555555-0000-0000-0001-001500010000', 'Escargots', 1500, 3),
  ('66666666-0000-0000-0001-015002000000', '55555555-0000-0000-0001-001500020000', 'Attiéké', 0, 0),
  ('66666666-0000-0000-0001-015002000001', '55555555-0000-0000-0001-001500020000', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-015002000002', '55555555-0000-0000-0001-001500020000', 'Riz blanc', 0, 2),
  ('66666666-0000-0000-0001-015002000003', '55555555-0000-0000-0001-001500020000', 'Frites', 500, 3),
  ('66666666-0000-0000-0001-015002001000', '55555555-0000-0000-0001-001500020001', 'Pour 1 personne', 0, 0),
  ('66666666-0000-0000-0001-015002001001', '55555555-0000-0000-0001-001500020001', 'Pour 2 personnes', 4000, 1),
  ('66666666-0000-0000-0001-015003000000', '55555555-0000-0000-0001-001500030000', 'Moyen', 0, 0),
  ('66666666-0000-0000-0001-015003000001', '55555555-0000-0000-0001-001500030000', 'Grand', 1500, 1),
  ('66666666-0000-0000-0001-015003001000', '55555555-0000-0000-0001-001500030001', 'Attiéké', 0, 0),
  ('66666666-0000-0000-0001-015003001001', '55555555-0000-0000-0001-001500030001', 'Alloco', 300, 1),
  ('66666666-0000-0000-0001-015003001002', '55555555-0000-0000-0001-001500030001', 'Riz blanc', 0, 2),
  ('66666666-0000-0000-0001-015003001003', '55555555-0000-0000-0001-001500030001', 'Frites', 500, 3),
  ('66666666-0000-0000-0001-015005000000', '55555555-0000-0000-0001-001500050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-015005000001', '55555555-0000-0000-0001-001500050000', '1 litre', 500, 1)
on conflict (id) do nothing;

-- 16. La Calebasse de Vridi (Abidjan, Port-Bouët Vridi cité)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000016', z.id, 'shop', 'La Calebasse de Vridi', 'Boissons locales', 'Bangui, bissap et gnamakoudji servis frais en calebasse ou à emporter.', '+2250505121616', 5.256, -3.9768,
  'Port-Bouët Vridi cité', 'Près du rond-point de Vridi', 10, false, 'demo/cover-bangui.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000016', 1, '09:00', '22:00'),
  ('22222222-0000-0000-0001-000000000016', 2, '09:00', '22:00'),
  ('22222222-0000-0000-0001-000000000016', 3, '09:00', '22:00'),
  ('22222222-0000-0000-0001-000000000016', 4, '09:00', '22:00'),
  ('22222222-0000-0000-0001-000000000016', 5, '09:00', '22:00'),
  ('22222222-0000-0000-0001-000000000016', 6, '09:00', '22:00'),
  ('22222222-0000-0000-0001-000000000016', 7, '09:00', '22:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000016000000', '22222222-0000-0000-0001-000000000016', 'Boissons', 0),
  ('33333333-0000-0000-0001-000016000001', '22222222-0000-0000-0001-000000000016', 'Desserts', 1)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000016000001', '22222222-0000-0000-0001-000000000016', '33333333-0000-0000-0001-000016000000', 'Bangui frais', 'Vin de palme du jour (boisson alcoolisée).', 800, 'demo/bangui.jpg', true),
  ('44444444-0000-0000-0001-000016000002', '22222222-0000-0000-0001-000000000016', '33333333-0000-0000-0001-000016000000', 'Bissap 1 litre', 'Bissap en carafe, menthe et ananas.', 1200, 'demo/bissap-carafe.jpg', true),
  ('44444444-0000-0000-0001-000016000003', '22222222-0000-0000-0001-000000000016', '33333333-0000-0000-0001-000016000000', 'Gnamakoudji', 'Gingembre frais en calebasse.', 500, 'demo/gnamakoudji-bol.jpg', true),
  ('44444444-0000-0000-0001-000016000004', '22222222-0000-0000-0001-000000000016', '33333333-0000-0000-0001-000016000001', 'Dêguê', 'Dêguê bien frais.', 600, 'demo/degue.jpg', true),
  ('44444444-0000-0000-0001-000016000005', '22222222-0000-0000-0001-000000000016', '33333333-0000-0000-0001-000016000000', 'Jus de mangue', 'Mangue de saison.', 700, 'demo/jus-mangue.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001600010000', '44444444-0000-0000-0001-000016000001', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-001600030000', '44444444-0000-0000-0001-000016000003', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-001600040000', '44444444-0000-0000-0001-000016000004', 'Suppléments', 0, 2, 0),
  ('55555555-0000-0000-0001-001600050000', '44444444-0000-0000-0001-000016000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-016001000000', '55555555-0000-0000-0001-001600010000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-016001000001', '55555555-0000-0000-0001-001600010000', '1 litre', 700, 1),
  ('66666666-0000-0000-0001-016003000000', '55555555-0000-0000-0001-001600030000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-016003000001', '55555555-0000-0000-0001-001600030000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-016004000000', '55555555-0000-0000-0001-001600040000', 'Arachides grillées', 100, 0),
  ('66666666-0000-0000-0001-016004000001', '55555555-0000-0000-0001-001600040000', 'Lait concentré', 200, 1),
  ('66666666-0000-0000-0001-016005000000', '55555555-0000-0000-0001-001600050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-016005000001', '55555555-0000-0000-0001-001600050000', '1 litre', 500, 1)
on conflict (id) do nothing;

-- 17. Le Coin du Bissap (Abidjan, Plateau)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000017', z.id, 'shop', 'Le Coin du Bissap', 'Jus naturels', 'Jus naturels du Plateau : bissap, gingembre et mangue préparés chaque matin.', '+2250102121717', 5.3226, -4.0187,
  'Plateau', 'Avenue Chardy, face à la cité administrative', 10, false, 'demo/cover-bissap-carafe.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000017', 1, '07:00', '19:00'),
  ('22222222-0000-0000-0001-000000000017', 2, '07:00', '19:00'),
  ('22222222-0000-0000-0001-000000000017', 3, '07:00', '19:00'),
  ('22222222-0000-0000-0001-000000000017', 4, '07:00', '19:00'),
  ('22222222-0000-0000-0001-000000000017', 5, '07:00', '19:00'),
  ('22222222-0000-0000-0001-000000000017', 6, '07:00', '19:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000017000000', '22222222-0000-0000-0001-000000000017', 'Jus', 0),
  ('33333333-0000-0000-0001-000017000001', '22222222-0000-0000-0001-000000000017', 'Desserts', 1)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000017000001', '22222222-0000-0000-0001-000000000017', '33333333-0000-0000-0001-000017000000', 'Bissap 1 litre', 'Bissap maison, menthe et ananas.', 1200, 'demo/bissap-carafe.jpg', true),
  ('44444444-0000-0000-0001-000017000002', '22222222-0000-0000-0001-000000000017', '33333333-0000-0000-0001-000017000000', 'Bissap', 'Bissap maison, 50 cl.', 500, 'demo/bissap.jpg', true),
  ('44444444-0000-0000-0001-000017000003', '22222222-0000-0000-0001-000000000017', '33333333-0000-0000-0001-000017000000', 'Gnamakoudji', 'Gingembre, citron, menthe.', 500, 'demo/gnamakoudji.jpg', true),
  ('44444444-0000-0000-0001-000017000004', '22222222-0000-0000-0001-000000000017', '33333333-0000-0000-0001-000017000000', 'Jus de mangue', 'Mangue fraîche, sans sucre ajouté.', 800, 'demo/jus-mangue.jpg', true),
  ('44444444-0000-0000-0001-000017000005', '22222222-0000-0000-0001-000000000017', '33333333-0000-0000-0001-000017000001', 'Dêguê', 'Dêguê au lait caillé.', 700, 'demo/degue.jpg', false)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001700030000', '44444444-0000-0000-0001-000017000003', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-001700040000', '44444444-0000-0000-0001-000017000004', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-001700050000', '44444444-0000-0000-0001-000017000005', 'Suppléments', 0, 2, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-017003000000', '55555555-0000-0000-0001-001700030000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-017003000001', '55555555-0000-0000-0001-001700030000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-017004000000', '55555555-0000-0000-0001-001700040000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-017004000001', '55555555-0000-0000-0001-001700040000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-017005000000', '55555555-0000-0000-0001-001700050000', 'Arachides grillées', 100, 0),
  ('66666666-0000-0000-0001-017005000001', '55555555-0000-0000-0001-001700050000', 'Lait concentré', 200, 1)
on conflict (id) do nothing;

-- 18. Dêguê et Douceurs d'Angré (Abidjan, Cocody Angré Château)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000018', z.id, 'shop', 'Dêguê et Douceurs d''Angré', 'Desserts', 'Dêguê, viennoiseries et jus frais pour la pause sucrée à Angré.', '+2250505121818', 5.3958, -3.9925,
  'Cocody Angré Château', 'En face de l''école primaire du Château', 10, true, 'demo/cover-degue.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000018', 1, '07:30', '20:00'),
  ('22222222-0000-0000-0001-000000000018', 2, '07:30', '20:00'),
  ('22222222-0000-0000-0001-000000000018', 3, '07:30', '20:00'),
  ('22222222-0000-0000-0001-000000000018', 4, '07:30', '20:00'),
  ('22222222-0000-0000-0001-000000000018', 5, '07:30', '20:00'),
  ('22222222-0000-0000-0001-000000000018', 6, '07:30', '20:00'),
  ('22222222-0000-0000-0001-000000000018', 7, '07:30', '20:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000018000000', '22222222-0000-0000-0001-000000000018', 'Desserts', 0),
  ('33333333-0000-0000-0001-000018000001', '22222222-0000-0000-0001-000000000018', 'Viennoiseries', 1),
  ('33333333-0000-0000-0001-000018000002', '22222222-0000-0000-0001-000000000018', 'Jus', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000018000001', '22222222-0000-0000-0001-000000000018', '33333333-0000-0000-0001-000018000000', 'Dêguê', 'Dêguê crémeux, mil et lait caillé.', 600, 'demo/degue.jpg', true),
  ('44444444-0000-0000-0001-000018000002', '22222222-0000-0000-0001-000000000018', '33333333-0000-0000-0001-000018000001', 'Croissant', 'Croissant pur beurre du jour.', 400, 'demo/croissant.jpg', true),
  ('44444444-0000-0000-0001-000018000003', '22222222-0000-0000-0001-000000000018', '33333333-0000-0000-0001-000018000001', 'Pain au chocolat', 'Pain au chocolat pur beurre.', 500, 'demo/pain-au-chocolat.jpg', true),
  ('44444444-0000-0000-0001-000018000004', '22222222-0000-0000-0001-000000000018', '33333333-0000-0000-0001-000018000002', 'Gnamakoudji', 'Jus de gingembre frais.', 500, 'demo/gnamakoudji-bol.jpg', true),
  ('44444444-0000-0000-0001-000018000005', '22222222-0000-0000-0001-000000000018', '33333333-0000-0000-0001-000018000002', 'Bissap', 'Bissap maison.', 500, 'demo/bissap.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001800010000', '44444444-0000-0000-0001-000018000001', 'Suppléments', 0, 2, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-018001000000', '55555555-0000-0000-0001-001800010000', 'Arachides grillées', 100, 0),
  ('66666666-0000-0000-0001-018001000001', '55555555-0000-0000-0001-001800010000', 'Lait concentré', 200, 1)
on conflict (id) do nothing;

-- 19. Le Baobab de Bingerville (Abidjan, Bingerville centre)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000019', z.id, 'restaurant', 'Le Baobab de Bingerville', 'Cuisine africaine', 'Cuisine ivoirienne et africaine dans un jardin ombragé, à l''entrée de Bingerville.', '+2250707121919', 5.3552, -3.8857,
  'Bingerville centre', 'À l''entrée de la ville, après le jardin botanique', 35, false, 'demo/cover-alloco-poulet.jpg'
from public.zones z where z.city = 'Abidjan' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000019', 1, '11:30', '22:30'),
  ('22222222-0000-0000-0001-000000000019', 2, '11:30', '22:30'),
  ('22222222-0000-0000-0001-000000000019', 3, '11:30', '22:30'),
  ('22222222-0000-0000-0001-000000000019', 4, '11:30', '22:30'),
  ('22222222-0000-0000-0001-000000000019', 5, '11:30', '22:30'),
  ('22222222-0000-0000-0001-000000000019', 6, '11:30', '22:30'),
  ('22222222-0000-0000-0001-000000000019', 7, '11:30', '22:30')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000019000000', '22222222-0000-0000-0001-000000000019', 'Plats', 0),
  ('33333333-0000-0000-0001-000019000001', '22222222-0000-0000-0001-000000000019', 'Sauces', 1),
  ('33333333-0000-0000-0001-000019000002', '22222222-0000-0000-0001-000000000019', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000019000001', '22222222-0000-0000-0001-000000000019', '33333333-0000-0000-0001-000019000000', 'Alloco poulet braisé', 'Alloco et poulet braisé du jardin.', 3000, 'demo/alloco-poulet.jpg', true),
  ('44444444-0000-0000-0001-000019000002', '22222222-0000-0000-0001-000000000019', '33333333-0000-0000-0001-000019000000', 'Kédjénou de pintade', 'Pintade au canari, attiéké.', 6000, 'demo/kedjenou-poulet.jpg', true),
  ('44444444-0000-0000-0001-000019000003', '22222222-0000-0000-0001-000000000019', '33333333-0000-0000-0001-000019000001', 'Sauce gombo aux crevettes', 'Gombo, crevettes, riz blanc.', 4500, 'demo/sauce-gombo-crevettes.jpg', true),
  ('44444444-0000-0000-0001-000019000004', '22222222-0000-0000-0001-000000000019', '33333333-0000-0000-0001-000019000000', 'Poulet DG', 'Poulet, plantain et légumes.', 5000, 'demo/poulet-dg.jpg', true),
  ('44444444-0000-0000-0001-000019000005', '22222222-0000-0000-0001-000000000019', '33333333-0000-0000-0001-000019000002', 'Bissap 1 litre', 'Carafe de bissap maison.', 1200, 'demo/bissap-carafe.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-001900010000', '44444444-0000-0000-0001-000019000001', 'Morceau', 1, 1, 0),
  ('55555555-0000-0000-0001-001900020000', '44444444-0000-0000-0001-000019000002', 'Taille', 1, 1, 0),
  ('55555555-0000-0000-0001-001900030000', '44444444-0000-0000-0001-000019000003', 'Accompagnement', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-019001000000', '55555555-0000-0000-0001-001900010000', 'Quart', 0, 0),
  ('66666666-0000-0000-0001-019001000001', '55555555-0000-0000-0001-001900010000', 'Demi-poulet', 2500, 1),
  ('66666666-0000-0000-0001-019001000002', '55555555-0000-0000-0001-001900010000', 'Poulet entier', 6000, 2),
  ('66666666-0000-0000-0001-019002000000', '55555555-0000-0000-0001-001900020000', 'Pour 1 personne', 0, 0),
  ('66666666-0000-0000-0001-019002000001', '55555555-0000-0000-0001-001900020000', 'Pour 2 personnes', 4000, 1),
  ('66666666-0000-0000-0001-019003000000', '55555555-0000-0000-0001-001900030000', 'Riz blanc', 0, 0),
  ('66666666-0000-0000-0001-019003000001', '55555555-0000-0000-0001-001900030000', 'Foutou banane', 500, 1),
  ('66666666-0000-0000-0001-019003000002', '55555555-0000-0000-0001-001900030000', 'Attiéké', 0, 2)
on conflict (id) do nothing;

-- 20. Gingembre et Cie (Daloa, Lobia)
insert into public.restaurants (id, zone_id, kind, name, category, description, phone, latitude, longitude,
  district, landmark, prep_time_min, is_temporarily_closed, cover_path)
select '22222222-0000-0000-0001-000000000020', z.id, 'shop', 'Gingembre et Cie', 'Jus naturels', 'Jus de gingembre, bissap et dêguê faits maison, à emporter près de la gare de Daloa.', '+2250102122020', 6.877, -6.4502,
  'Lobia', 'Près de la gare routière de Daloa', 10, false, 'demo/cover-gnamakoudji-bol.jpg'
from public.zones z where z.city = 'Daloa' order by z.created_at limit 1
on conflict (id) do nothing;
insert into public.opening_hours (restaurant_id, weekday, opens_at, closes_at) values
  ('22222222-0000-0000-0001-000000000020', 1, '08:00', '21:00'),
  ('22222222-0000-0000-0001-000000000020', 2, '08:00', '21:00'),
  ('22222222-0000-0000-0001-000000000020', 3, '08:00', '21:00'),
  ('22222222-0000-0000-0001-000000000020', 4, '08:00', '21:00'),
  ('22222222-0000-0000-0001-000000000020', 5, '08:00', '21:00'),
  ('22222222-0000-0000-0001-000000000020', 6, '08:00', '21:00'),
  ('22222222-0000-0000-0001-000000000020', 7, '08:00', '21:00')
on conflict do nothing;
insert into public.categories (id, restaurant_id, name, position) values
  ('33333333-0000-0000-0001-000020000000', '22222222-0000-0000-0001-000000000020', 'Jus', 0),
  ('33333333-0000-0000-0001-000020000001', '22222222-0000-0000-0001-000000000020', 'Desserts', 1),
  ('33333333-0000-0000-0001-000020000002', '22222222-0000-0000-0001-000000000020', 'Boissons', 2)
on conflict (id) do nothing;
insert into public.products (id, restaurant_id, category_id, name, description, price, photo_path, is_available) values
  ('44444444-0000-0000-0001-000020000001', '22222222-0000-0000-0001-000000000020', '33333333-0000-0000-0001-000020000000', 'Gnamakoudji', 'Gingembre frais, citron vert, menthe.', 400, 'demo/gnamakoudji-bol.jpg', true),
  ('44444444-0000-0000-0001-000020000002', '22222222-0000-0000-0001-000000000020', '33333333-0000-0000-0001-000020000000', 'Bissap', 'Bissap maison, 50 cl.', 400, 'demo/bissap.jpg', true),
  ('44444444-0000-0000-0001-000020000003', '22222222-0000-0000-0001-000000000020', '33333333-0000-0000-0001-000020000000', 'Jus de mangue', 'Mangue de Daloa, 50 cl.', 500, 'demo/jus-mangue.jpg', true),
  ('44444444-0000-0000-0001-000020000004', '22222222-0000-0000-0001-000000000020', '33333333-0000-0000-0001-000020000001', 'Dêguê', 'Dêguê de mil, lait caillé.', 500, 'demo/degue.jpg', true),
  ('44444444-0000-0000-0001-000020000005', '22222222-0000-0000-0001-000000000020', '33333333-0000-0000-0001-000020000002', 'Bangui frais', 'Vin de palme frais (boisson alcoolisée).', 600, 'demo/bangui.jpg', true)
on conflict (id) do nothing;
insert into public.product_option_groups (id, product_id, name, min_choices, max_choices, position) values
  ('55555555-0000-0000-0001-002000010000', '44444444-0000-0000-0001-000020000001', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-002000020000', '44444444-0000-0000-0001-000020000002', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-002000030000', '44444444-0000-0000-0001-000020000003', 'Format', 1, 1, 0),
  ('55555555-0000-0000-0001-002000040000', '44444444-0000-0000-0001-000020000004', 'Suppléments', 0, 2, 0),
  ('55555555-0000-0000-0001-002000050000', '44444444-0000-0000-0001-000020000005', 'Format', 1, 1, 0)
on conflict (id) do nothing;
insert into public.product_options (id, group_id, name, price_delta, position) values
  ('66666666-0000-0000-0001-020001000000', '55555555-0000-0000-0001-002000010000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-020001000001', '55555555-0000-0000-0001-002000010000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-020002000000', '55555555-0000-0000-0001-002000020000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-020002000001', '55555555-0000-0000-0001-002000020000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-020003000000', '55555555-0000-0000-0001-002000030000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-020003000001', '55555555-0000-0000-0001-002000030000', '1 litre', 500, 1),
  ('66666666-0000-0000-0001-020004000000', '55555555-0000-0000-0001-002000040000', 'Arachides grillées', 100, 0),
  ('66666666-0000-0000-0001-020004000001', '55555555-0000-0000-0001-002000040000', 'Lait concentré', 200, 1),
  ('66666666-0000-0000-0001-020005000000', '55555555-0000-0000-0001-002000050000', '50 cl', 0, 0),
  ('66666666-0000-0000-0001-020005000001', '55555555-0000-0000-0001-002000050000', '1 litre', 700, 1)
on conflict (id) do nothing;
