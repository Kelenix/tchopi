-- Données de référence (ADR-033) : zone d'Abidjan et tarifs de départ, présentes sur tous les serveurs.
-- Valeurs indicatives, modifiables dans l'Administration (Zones).
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('11111111-1111-1111-1111-111111111111', 'Abidjan — agglomération', 'Abidjan', 5.3364, -4.0267, 25000)
on conflict (id) do nothing;

insert into public.pricing_rules
  (zone_id, service, base_fee, per_km_fee, min_fee, max_fee, detour_factor, rounding_step, courier_base, courier_per_km)
values
  ('11111111-1111-1111-1111-111111111111', 'food', 500, 150, 500, 3000, 1.30, 25, 400, 100),
  ('11111111-1111-1111-1111-111111111111', 'parcel', 700, 175, 700, 4000, 1.30, 25, 500, 120)
on conflict (zone_id, service) do nothing;
