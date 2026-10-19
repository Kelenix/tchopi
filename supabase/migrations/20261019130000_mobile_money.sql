-- Mobile Money par nyole (Inc-11, docs/data-model.md §4 « Paiements » ; ADR-028). Le client paie sur la page
-- sécurisée de nyole (Orange Money, MTN MoMo, Wave, Moov) ; la commande n'est transmise qu'après confirmation du
-- paiement par un webhook signé, vérifiée auprès de nyole (Edge Functions payments-create et payments-webhook-nyole).

-- Moment où la commande est transmise (restaurant ou recherche d'un livreur) : à la création en espèces, à la
-- confirmation du paiement sinon. Le délai de réponse du restaurant part de là.
alter table public.orders add column submitted_at timestamptz;
update public.orders set submitted_at = created_at;
alter table public.orders alter column submitted_at set default now(), alter column submitted_at set not null;

create or replace function private.reject_unanswered_orders()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  rejected integer;
begin
  with expired as (
    update public.orders
       set status = 'rejected', closed_at = now(), close_reason = 'no_response'
     where status = 'pending'
       and submitted_at < now() - make_interval(secs => (select restaurant_timeout_s from public.settings))
    returning id
  ), events as (
    insert into public.order_events (order_id, status, actor_role, reason)
    select id, 'rejected', 'system', 'no_response' from expired
  )
  select count(*) into rejected from expired;
  return rejected;
end;
$$;

-- PAY-01 : un seul moyen « Mobile Money » ; l'opérateur se choisit sur la page de nyole.
delete from public.payment_options where method = 'mobile_money';
insert into public.payment_options (country_code, method, operator, provider, label, is_enabled, position)
values ('CI', 'mobile_money', null, 'nyole', 'Mobile Money', false, 1);

-- ADM-05 : Mobile Money activable maintenant que nyole est intégré ; la carte attend Stripe (Inc-12).
create or replace function public.admin_set_payment_option(p_id uuid, p_enabled boolean)
returns public.payment_options
language plpgsql
security definer
set search_path = ''
as $$
declare
  result public.payment_options;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  select * into result from public.payment_options where id = p_id for update;
  if result.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if p_enabled and result.provider is distinct from 'cash' and result.provider is distinct from 'nyole' then
    raise exception 'payment_unavailable' using errcode = 'P0001';
  end if;
  update public.payment_options set is_enabled = p_enabled where id = p_id returning * into result;
  perform private.audit('payment_option', 'payment_option', p_id, jsonb_build_object('enabled', p_enabled));
  return result;
end;
$$;

-- Session de paiement nyole de la transaction : page à rouvrir pour réessayer, tentative en cours (une nouvelle
-- session seulement si la précédente a été annulée par nyole).
alter table public.transactions
  add column checkout_session_id text unique,
  add column checkout_url text,
  add column checkout_attempt integer not null default 0;
alter publication supabase_realtime add table public.transactions;

-- TRX-01 : une transaction en attente dès la commande, quel que soit le moyen.
drop trigger orders_open_cash_transaction on public.orders;
drop function private.open_cash_transaction();
create function private.open_transaction()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.transactions (order_id, amount, currency, method, provider)
  select new.id, new.total, new.currency, new.payment_method, p.provider
    from public.payment_options p join public.zones z on z.country_code = p.country_code
   where z.id = new.zone_id and p.method = new.payment_method and p.is_enabled
   limit 1;
  return null;
end;
$$;
create trigger orders_open_transaction after insert on public.orders
  for each row execute function private.open_transaction();

-- PAY-03 : payée en ligne, une commande attend son paiement avant d'être transmise.
create function private.initial_status(p_status public.order_status, p_method public.payment_method)
returns public.order_status
language sql
immutable
set search_path = ''
as $$
  select case when p_method = 'cash' then p_status else 'awaiting_payment'::public.order_status end;
$$;

create or replace function public.place_food_order(
  p_restaurant_id uuid,
  p_address_id uuid,
  p_items jsonb,
  p_payment_method public.payment_method,
  p_expected_total integer,
  p_idempotency_key uuid
)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  existing public.orders;
  result public.orders;
  q jsonb;
  r public.restaurants;
  a public.addresses;
  me public.profiles;
  commission integer;
begin
  select * into existing from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
  if existing.id is not null then
    return existing;
  end if;

  q := private.food_quote(p_restaurant_id, p_address_id, p_items);
  if jsonb_array_length(q->'issues') > 0 then
    raise exception 'cart_changed' using errcode = 'P0001';
  end if;
  if (q->>'total')::integer <> p_expected_total then
    raise exception 'price_changed' using errcode = 'P0001';
  end if;

  select * into r from public.restaurants where id = p_restaurant_id;
  select * into a from public.addresses where id = p_address_id;
  select * into me from public.profiles where id = auth.uid();
  commission := round((q->>'subtotal')::integer * r.commission_rate / 100)::integer;

  insert into public.orders (
    number, type, status, customer_id, zone_id, currency, restaurant_id,
    pickup_lat, pickup_lng, pickup_name, pickup_phone, pickup_district, pickup_landmark,
    dropoff_lat, dropoff_lng, recipient_name, recipient_phone, dropoff_district, dropoff_landmark, dropoff_instructions,
    subtotal, delivery_fee, total, commission_amount, courier_earning, platform_amount, distance_m,
    payment_method, idempotency_key
  ) values (
    private.new_order_number('R'), 'food', private.initial_status('pending', p_payment_method), auth.uid(), r.zone_id, q->>'currency', r.id,
    r.latitude, r.longitude, r.name, r.phone, r.district, r.landmark,
    a.latitude, a.longitude, coalesce(nullif(btrim(concat_ws(' ', me.first_name, me.last_name)), ''), 'Client'),
    me.phone, a.district, a.landmark, a.instructions,
    (q->>'subtotal')::integer, (q->>'delivery_fee')::integer, (q->>'total')::integer, commission,
    (q->>'courier_earning')::integer,
    (q->>'delivery_fee')::integer - (q->>'courier_earning')::integer + commission,
    (q->>'distance_m')::integer, p_payment_method, p_idempotency_key
  )
  on conflict (customer_id, idempotency_key) do nothing
  returning * into result;
  if result.id is null then
    -- Requête concurrente avec la même clé : elle a déjà créé la commande.
    select * into result from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
    return result;
  end if;

  insert into public.order_items (order_id, product_id, name, unit_price, quantity, line_total)
  select result.id, (l->>'product_id')::uuid, l->>'name', (l->>'unit_price')::integer, (l->>'quantity')::integer,
         (l->>'line_total')::integer
    from jsonb_array_elements(q->'items') l;
  perform private.log_order_event(result.id, result.status, 'customer');
  return result;
end;
$$;

create or replace function public.place_parcel_order(
  p_pickup jsonb,
  p_dropoff jsonb,
  p_recipient_name text,
  p_recipient_phone text,
  p_parcel_type_id uuid,
  p_description text,
  p_rules_accepted boolean,
  p_payment_method public.payment_method,
  p_expected_total integer,
  p_idempotency_key uuid
)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  existing public.orders;
  result public.orders;
  q jsonb;
  me public.profiles;
  recipient text := nullif(btrim(p_recipient_name), '');
  description text := nullif(btrim(p_description), '');
begin
  select * into existing from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
  if existing.id is not null then
    return existing;
  end if;
  if not coalesce(p_rules_accepted, false) then
    raise exception 'rules_not_accepted' using errcode = 'P0001';
  end if;
  if recipient is null or char_length(recipient) > 80 or coalesce(p_recipient_phone, '') !~ '^\+[1-9][0-9]{7,14}$' then
    raise exception 'invalid_recipient' using errcode = 'P0001';
  end if;
  if char_length(btrim(coalesce(p_pickup->>'district', ''))) < 2 or char_length(btrim(coalesce(p_pickup->>'landmark', ''))) < 3
     or char_length(btrim(coalesce(p_dropoff->>'district', ''))) < 2 or char_length(btrim(coalesce(p_dropoff->>'landmark', ''))) < 3
  then
    raise exception 'invalid_address' using errcode = 'P0001';
  end if;

  q := private.parcel_quote((p_pickup->>'lat')::double precision, (p_pickup->>'lng')::double precision,
                            (p_dropoff->>'lat')::double precision, (p_dropoff->>'lng')::double precision,
                            p_parcel_type_id);
  if (q->>'total')::integer <> p_expected_total then
    raise exception 'price_changed' using errcode = 'P0001';
  end if;
  select * into me from public.profiles where id = auth.uid();

  insert into public.orders (
    number, type, status, customer_id, zone_id, currency, parcel_type_id, parcel_description,
    pickup_lat, pickup_lng, pickup_name, pickup_phone, pickup_district, pickup_landmark, pickup_instructions,
    dropoff_lat, dropoff_lng, recipient_name, recipient_phone, dropoff_district, dropoff_landmark, dropoff_instructions,
    subtotal, delivery_fee, total, commission_amount, courier_earning, platform_amount, distance_m,
    payment_method, idempotency_key
  ) values (
    private.new_order_number('C'), 'parcel', private.initial_status('searching_courier', p_payment_method),
    auth.uid(), (q->>'zone_id')::uuid, q->>'currency',
    p_parcel_type_id, description,
    (p_pickup->>'lat')::double precision, (p_pickup->>'lng')::double precision,
    coalesce(nullif(btrim(concat_ws(' ', me.first_name, me.last_name)), ''), 'Expéditeur'), me.phone,
    btrim(p_pickup->>'district'), btrim(p_pickup->>'landmark'), nullif(btrim(p_pickup->>'instructions'), ''),
    (p_dropoff->>'lat')::double precision, (p_dropoff->>'lng')::double precision, recipient, p_recipient_phone,
    btrim(p_dropoff->>'district'), btrim(p_dropoff->>'landmark'), nullif(btrim(p_dropoff->>'instructions'), ''),
    0, (q->>'delivery_fee')::integer, (q->>'total')::integer, 0, (q->>'courier_earning')::integer,
    (q->>'delivery_fee')::integer - (q->>'courier_earning')::integer, (q->>'distance_m')::integer,
    p_payment_method, p_idempotency_key
  )
  on conflict (customer_id, idempotency_key) do nothing
  returning * into result;
  if result.id is null then
    select * into result from public.orders where customer_id = auth.uid() and idempotency_key = p_idempotency_key;
    return result;
  end if;
  perform private.log_order_event(result.id, result.status, 'customer');
  return result;
end;
$$;

-- Données de la session à ouvrir pour la commande du client (Edge Function payments-create).
create function public.begin_mobile_money(p_order_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  t public.transactions;
  me public.profiles;
begin
  select * into o from public.orders where id = p_order_id and customer_id = auth.uid();
  if o.id is null or o.payment_method <> 'mobile_money' then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if o.payment_status <> 'unpaid' then
    raise exception 'already_paid' using errcode = 'P0001';
  end if;
  if o.status <> 'awaiting_payment' then
    raise exception 'payment_closed' using errcode = 'P0001';
  end if;
  select * into t from public.transactions where order_id = o.id order by created_at desc limit 1;
  select * into me from public.profiles where id = auth.uid();
  return jsonb_build_object(
    'transaction_id', t.id, 'amount', t.amount, 'currency', t.currency, 'order_number', o.number,
    'customer_name', nullif(btrim(concat_ws(' ', me.first_name, me.last_name)), ''), 'customer_phone', me.phone,
    'session_id', t.checkout_session_id, 'checkout_url', t.checkout_url, 'attempt', t.checkout_attempt
  );
end;
$$;
revoke all on function public.begin_mobile_money(uuid) from public, anon;
grant execute on function public.begin_mobile_money(uuid) to authenticated;

-- Session ouverte ou rouverte : la transaction repasse « en attente » (nouvel essai après un refus).
create function public.record_checkout_session(
  p_transaction_id uuid, p_session_id text, p_url text, p_reference text, p_attempt integer
)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.transactions
     set checkout_session_id = p_session_id, checkout_url = p_url, checkout_attempt = p_attempt,
         provider_reference = coalesce(p_reference, provider_reference), status = 'pending', failure_reason = null
   where id = p_transaction_id and status in ('pending', 'failed');
$$;
revoke all on function public.record_checkout_session(uuid, text, text, text, integer)
  from public, anon, authenticated;
grant execute on function public.record_checkout_session(uuid, text, text, text, integer) to service_role;

-- PAY-03 / PAY-05 : statut confirmé par nyole (jamais par l'app). Réussi : une seule fois, montant vérifié, commande
-- transmise ; payé après annulation ou expiration : à rembourser. Refusé ou annulé : le client peut réessayer.
create function public.apply_payment_status(
  p_transaction_id uuid, p_status text, p_amount integer, p_currency text, p_reference text
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  t public.transactions;
  o public.orders;
begin
  select * into t from public.transactions where id = p_transaction_id;
  if t.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  -- Verrous dans l'ordre commande puis transaction, comme partout ailleurs.
  select * into o from public.orders where id = t.order_id for update;
  select * into t from public.transactions where id = p_transaction_id for update;

  if p_status = 'SUCCESS' then
    if t.status in ('succeeded', 'refunded') then
      return t.status::text;
    end if;
    if p_amount is distinct from t.amount or upper(p_currency) is distinct from t.currency then
      update public.transactions set failure_reason = 'amount_mismatch' where id = t.id;
      perform private.audit('payment_mismatch', 'transaction', t.id,
        jsonb_build_object('amount', p_amount, 'currency', p_currency));
      return 'amount_mismatch';
    end if;
    update public.transactions
       set status = 'succeeded', succeeded_at = now(), failure_reason = null,
           provider_reference = coalesce(p_reference, provider_reference)
     where id = t.id;
    if o.status = 'awaiting_payment' then
      update public.orders
         set payment_status = 'paid', submitted_at = now(),
             status = case when o.type = 'food' then 'pending' else 'searching_courier' end::public.order_status
       where id = o.id
      returning * into o;
      perform private.log_order_event(o.id, o.status, 'system');
    else
      update public.orders set payment_status = 'refund_pending' where id = o.id;
      perform private.log_order_kind(o.id, 'refund_pending', null, 'system', 'late_payment');
    end if;
    return 'succeeded';
  end if;

  if p_status in ('FAILED', 'CANCELLED') and t.status = 'pending' then
    update public.transactions set status = 'failed', failure_reason = lower(p_status) where id = t.id;
    return 'failed';
  end if;
  return t.status::text;
end;
$$;
revoke all on function public.apply_payment_status(uuid, text, integer, text, text) from public, anon, authenticated;
grant execute on function public.apply_payment_status(uuid, text, integer, text, text) to service_role;

-- PAY-03 : sans confirmation dans le délai (15 min par défaut), la commande est annulée, rien n'est transmis.
create function private.expire_payments()
returns void
language sql
security definer
set search_path = ''
as $$
  with expired as (
    update public.orders
       set status = 'cancelled', closed_at = now(), close_reason = 'payment_timeout'
     where status = 'awaiting_payment'
       and created_at <= now() - make_interval(secs => (select payment_timeout_s from public.settings))
    returning id
  )
  insert into public.order_events (order_id, status, actor_role, reason)
  select id, 'cancelled', 'system', 'payment_timeout' from expired;
$$;

create or replace function private.tick()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  s public.settings;
  r record;
begin
  select * into s from public.settings;
  for r in select distinct order_id from public.delivery_offers where status = 'pending' and expires_at <= now() loop
    perform 1 from public.orders where id = r.order_id for update;
    update public.delivery_offers set status = 'expired'
     where order_id = r.order_id and status = 'pending' and expires_at <= now();
    perform private.dispatch(r.order_id);
  end loop;

  for r in select o.id from public.orders o
            where o.courier_id is null and o.dispatch_started_at is not null
              and o.status in ('preparing', 'ready', 'searching_courier')
              and not exists (select 1 from public.delivery_offers f where f.order_id = o.id and f.status = 'pending')
  loop
    perform private.dispatch(r.id);
  end loop;

  with alerted as (
    update public.orders
       set dispatch_alerted_at = now()
     where courier_id is null and dispatch_alerted_at is null
       and status in ('preparing', 'ready', 'searching_courier')
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_alert_s)
    returning id
  )
  insert into public.order_events (order_id, kind, actor_role)
  select id, 'dispatch_alert', 'system' from alerted;

  with abandoned as (
    update public.orders
       set status = 'cancelled', closed_at = now(), close_reason = 'no_courier'
     where courier_id is null
       and status in ('preparing', 'ready', 'searching_courier')
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_cancel_s)
    returning id
  )
  insert into public.order_events (order_id, status, actor_role, reason)
  select id, 'cancelled', 'system', 'no_courier' from abandoned;

  perform private.reject_unanswered_orders();
  perform private.expire_payments();
  perform private.flush_notifications();
end;
$$;
