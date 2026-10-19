-- Index des clés étrangères restantes (phase 5, conseiller de performance Supabase) : sans eux, supprimer ou
-- modifier la ligne référencée (produit, catégorie, zone, commande) parcourt toute la table qui la cite.
create index order_items_product_idx on public.order_items (product_id);
create index products_category_idx on public.products (category_id);
create index notifications_order_idx on public.notifications (order_id);
create index orders_zone_idx on public.orders (zone_id);
create index orders_parcel_type_idx on public.orders (parcel_type_id);
create index addresses_zone_idx on public.addresses (zone_id);
create index couriers_zone_idx on public.couriers (zone_id);
create index audit_log_actor_idx on public.audit_log (actor_id);
create index cash_ledger_recorded_by_idx on public.cash_ledger (recorded_by);
