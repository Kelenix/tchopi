begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

insert into auth.users (id, email, aud, role, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000e1', 'client@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000e2', 'livreur@exemple.ci', 'authenticated', 'authenticated', now()),
  ('00000000-0000-0000-0000-0000000000e3', 'autre@exemple.ci', 'authenticated', 'authenticated', now());

create function pg_temp.order_(p_number text, p_status text) returns uuid language sql as $$
  insert into public.orders (number, type, status, customer_id, courier_id, zone_id, currency, restaurant_id,
    pickup_lat, pickup_lng, pickup_name, pickup_district, pickup_landmark, dropoff_lat, dropoff_lng, recipient_name,
    dropoff_district, dropoff_landmark, subtotal, delivery_fee, total, commission_amount, courier_earning,
    platform_amount, distance_m, payment_method, idempotency_key)
  values (p_number, 'food', p_status::public.order_status, '00000000-0000-0000-0000-0000000000e1',
    '00000000-0000-0000-0000-0000000000e2', '11111111-1111-1111-1111-111111111111', 'XOF',
    '22222222-0000-0000-0000-000000000001', 5.36, -3.97, 'Maquis Chez Tante', 'Riviera', 'Carrefour', 5.37, -3.96,
    'Awa', 'Angré', 'Pharmacie', 1500, 500, 2000, 150, 400, 250, 1200, 'cash', gen_random_uuid())
  returning id;
$$;
create function pg_temp.as_user(p_id text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, true);
$$;

select pg_temp.order_('R-HID01', 'delivered');
select pg_temp.order_('R-HID02', 'cancelled');
select pg_temp.order_('R-HID03', 'preparing');

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000e3');
select is(public.hide_orders(null), 0, 'un autre compte ne masque rien');

select pg_temp.as_user('00000000-0000-0000-0000-0000000000e1');
select is(public.hide_orders(array[(select id from public.orders where number = 'R-HID03')]), 0,
  'une commande en cours ne se masque pas');
select is(public.hide_orders(array[(select id from public.orders where number = 'R-HID01')]), 1,
  'le client masque une commande terminée');
select is(public.hide_orders(null), 1, 'puis tout le reste de son historique terminé');

reset role;
select is((select count(*)::int from public.orders where number like 'R-HID%' and customer_hidden_at is not null), 2,
  'masquées pour le client seulement ; la commande en cours reste visible');
select is((select count(*)::int from public.orders where number like 'R-HID%' and courier_hidden_at is null), 3,
  'le livreur voit toujours les siennes');

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000e2');
select is(public.hide_orders(null), 2, 'le livreur masque ses missions terminées, de son côté');

select * from finish();
rollback;
