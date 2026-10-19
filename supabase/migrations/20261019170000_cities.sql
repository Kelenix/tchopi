-- Villes desservies en Côte d'Ivoire (données de départ, comme ADR-033) : chaque ville est une zone (centre + rayon)
-- avec ses tarifs repas et colis. Valeurs indicatives, modifiables ou désactivables dans l'Administration (Zones).
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values
  ('11111111-1111-1111-1111-000000000002', 'Bouaké', 'Bouaké', 7.6906, -5.0303, 12000),
  ('11111111-1111-1111-1111-000000000003', 'Yamoussoukro', 'Yamoussoukro', 6.8276, -5.2893, 10000),
  ('11111111-1111-1111-1111-000000000004', 'San-Pédro', 'San-Pédro', 4.7485, -6.6363, 10000),
  ('11111111-1111-1111-1111-000000000005', 'Daloa', 'Daloa', 6.8774, -6.4502, 8000),
  ('11111111-1111-1111-1111-000000000006', 'Korhogo', 'Korhogo', 9.4580, -5.6296, 8000),
  ('11111111-1111-1111-1111-000000000007', 'Man', 'Man', 7.4125, -7.5538, 7000),
  ('11111111-1111-1111-1111-000000000008', 'Gagnoa', 'Gagnoa', 6.1319, -5.9506, 7000),
  ('11111111-1111-1111-1111-000000000009', 'Divo', 'Divo', 5.8372, -5.3572, 6000),
  ('11111111-1111-1111-1111-000000000010', 'Abengourou', 'Abengourou', 6.7297, -3.4964, 6000),
  ('11111111-1111-1111-1111-000000000011', 'Grand-Bassam', 'Grand-Bassam', 5.2118, -3.7388, 6000)
on conflict (id) do nothing;

-- Mêmes règles qu'Abidjan, avec un plafond plus bas (distances plus courtes hors de la capitale).
insert into public.pricing_rules
  (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, detour_factor, rounding_step, courier_base, courier_per_km)
select z.id, s.service::public.order_type, s.base_fee, s.per_km_fee, s.min_fee, s.max_fee, 1.30, 25, s.courier_base, s.courier_per_km
  from public.zones z
 cross join (values ('food', 500, 150, 500, 2000, 400, 100), ('parcel', 700, 175, 700, 2500, 500, 120))
       s (service, base_fee, per_km_fee, min_fee, max_fee, courier_base, courier_per_km)
 where z.id::text like '11111111-1111-1111-1111-0000000000%'
on conflict (zone_id, service) do nothing;
