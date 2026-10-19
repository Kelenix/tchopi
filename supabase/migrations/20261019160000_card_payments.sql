-- Carte bancaire par Stripe (Inc-12, PAY-04 ; ADR-031). Même circuit que Mobile Money (ADR-028) : page de paiement
-- hébergée par Stripe (3-D Secure compris), commande transmise après confirmation vérifiée auprès de Stripe ;
-- remboursements automatiques des paiements par carte (ADR-027).

-- ADM-05 : la carte devient activable par l'admin.
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
  if p_enabled and result.provider not in ('cash', 'nyole', 'stripe') then
    raise exception 'payment_unavailable' using errcode = 'P0001';
  end if;
  update public.payment_options set is_enabled = p_enabled where id = p_id returning * into result;
  perform private.audit('payment_option', 'payment_option', p_id, jsonb_build_object('enabled', p_enabled));
  return result;
end;
$$;

-- Données de la session à ouvrir pour la commande du client, quel que soit le fournisseur (payments-create).
drop function public.begin_mobile_money(uuid);
create function public.begin_online_payment(p_order_id uuid)
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
  if o.id is null or o.payment_method = 'cash' then
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
    'transaction_id', t.id, 'provider', t.provider, 'amount', t.amount, 'currency', t.currency,
    'order_number', o.number,
    'customer_name', nullif(btrim(concat_ws(' ', me.first_name, me.last_name)), ''), 'customer_phone', me.phone,
    'session_id', t.checkout_session_id, 'checkout_url', t.checkout_url, 'attempt', t.checkout_attempt
  );
end;
$$;
revoke all on function public.begin_online_payment(uuid) from public, anon;
grant execute on function public.begin_online_payment(uuid) to authenticated;

-- TRX-03 : un paiement par carte à rembourser l'est automatiquement par Stripe (Edge Function payments-refund,
-- appelée par la tâche planifiée ; nouvel essai après 10 min si Stripe n'a pas répondu).
alter table public.transactions add column refund_requested_at timestamptz;

create function private.request_refunds()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  url text := (select decrypted_secret from vault.decrypted_secrets where name = 'refund_function_url');
  key text := (select decrypted_secret from vault.decrypted_secrets where name = 'refund_function_key');
begin
  if url is null or key is null then
    return;
  end if;
  update public.transactions t
     set refund_requested_at = now()
    from public.orders o
   where o.id = t.order_id and o.payment_status = 'refund_pending'
     and t.provider = 'stripe' and t.status = 'succeeded'
     and (t.refund_requested_at is null or t.refund_requested_at < now() - interval '10 minutes');
  if found then
    perform net.http_post(
      url := url,
      headers := jsonb_build_object('Authorization', 'Bearer ' || key, 'Content-Type', 'application/json'),
      body := '{}'::jsonb
    );
  end if;
end;
$$;

-- Remboursement accepté par le fournisseur : transaction « Remboursée » avec sa référence, client notifié.
create function public.record_provider_refund(p_transaction_id uuid, p_reference text)
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
  select * into o from public.orders where id = t.order_id for update;
  if o.payment_status <> 'refund_pending' then
    return o.payment_status::text;
  end if;
  update public.transactions set status = 'refunded', refund_reference = p_reference
   where id = t.id and status = 'succeeded';
  update public.orders set payment_status = 'refunded' where id = o.id;
  perform private.log_order_kind(o.id, 'refunded', null, 'system', p_reference);
  return 'refunded';
end;
$$;
revoke all on function public.record_provider_refund(uuid, text) from public, anon, authenticated;
grant execute on function public.record_provider_refund(uuid, text) to service_role;

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
  perform private.request_refunds();
  perform private.flush_notifications();
end;
$$;
