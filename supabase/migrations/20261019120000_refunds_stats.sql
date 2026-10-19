-- Remboursements, statistiques (Inc-13, docs/data-model.md §5 et §7 ; ADR-027). Les remboursements automatiques
-- par Stripe et Mobile Money arrivent avec leurs fournisseurs (Inc-11 / 12) ; ici, le circuit commun.

-- TRX-03 : une commande payée puis annulée ou refusée est à rembourser ; le client suit l'état sur sa commande.
create function private.flag_refund()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status in ('cancelled', 'rejected') and old.status is distinct from new.status
     and new.payment_status = 'paid' then
    update public.orders set payment_status = 'refund_pending' where id = new.id;
    perform private.log_order_kind(new.id, 'refund_pending', null, 'system');
  end if;
  return null;
end;
$$;
create trigger orders_flag_refund after update of status on public.orders
  for each row execute function private.flag_refund();

-- Le client est prévenu de chaque étape de son remboursement.
create function private.notify_refund()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
begin
  select * into o from public.orders where id = new.order_id;
  perform private.notify(o.customer_id, o, new.kind,
    case when new.kind = 'refund_pending' then 'Remboursement en cours' else 'Remboursement effectué' end,
    case when new.kind = 'refund_pending'
      then 'Le remboursement de la commande ' || o.number || ' est en cours.'
      else 'La commande ' || o.number || ' vous a été remboursée.' end,
    '/orders/' || o.id);
  return null;
end;
$$;
create trigger order_events_notify_refund after insert on public.order_events
  for each row when (new.kind in ('refund_pending', 'refunded'))
  execute function private.notify_refund();

-- MIS-08 : après un échec de livraison, l'admin décide du remboursement d'une commande payée.
create function public.admin_request_refund(p_order_id uuid, p_reason text)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  reason text := nullif(btrim(p_reason), '');
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if o.payment_status <> 'paid' or o.status not in ('failed', 'cancelled', 'rejected') then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  update public.orders set payment_status = 'refund_pending' where id = o.id returning * into o;
  perform private.log_order_kind(o.id, 'refund_pending', null, 'admin', reason);
  return o;
end;
$$;
revoke all on function public.admin_request_refund(uuid, text) from public, anon;
grant execute on function public.admin_request_refund(uuid, text) to authenticated;

-- ADM-04 : remboursement effectué hors application (espèces rendues, virement), référence obligatoire.
create function public.admin_mark_refunded(p_order_id uuid, p_reference text)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  reference text := nullif(btrim(p_reference), '');
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if reference is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if o.payment_status <> 'refund_pending' then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  update public.transactions set status = 'refunded', refund_reference = reference
   where order_id = o.id and status = 'succeeded';
  update public.orders set payment_status = 'refunded' where id = o.id returning * into o;
  perform private.log_order_kind(o.id, 'refunded', null, 'admin', reference);
  return o;
end;
$$;
revoke all on function public.admin_mark_refunded(uuid, text) from public, anon;
grant execute on function public.admin_mark_refunded(uuid, text) to authenticated;

-- ADM-06 : indicateurs d'une période (bornes en UTC calculées par l'app) ; montants sur les commandes livrées.
create function public.admin_stats(p_from timestamptz, p_to timestamptz)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  with period as (
    select * from public.orders where created_at >= p_from and created_at < p_to
  ), delivered as (
    select * from period where status = 'delivered'
  )
  select jsonb_build_object(
    'orders', (select count(*) from period),
    'by_status', coalesce((select jsonb_object_agg(status, n)
                             from (select status, count(*) n from period group by status) s), '{}'::jsonb),
    'by_type', coalesce((select jsonb_object_agg(type, n)
                           from (select type, count(*) n from period group by type) t), '{}'::jsonb),
    'revenue', coalesce((select sum(total) from delivered), 0),
    'delivery_fees', coalesce((select sum(delivery_fee) from delivered), 0),
    'commissions', coalesce((select sum(commission_amount) from delivered), 0),
    'courier_earnings', coalesce((select sum(courier_earning) from delivered), 0),
    'platform', coalesce((select sum(platform_amount) from delivered), 0),
    'cash_to_reconcile', coalesce((select sum(case when type = 'collected' then amount else -amount end)
                                     from public.cash_ledger), 0),
    'refunds_pending', (select count(*) from public.orders where payment_status = 'refund_pending'),
    'couriers_online', (select count(*) from public.couriers c
                          join public.courier_locations l on l.courier_id = c.user_id
                         where c.is_online and c.status = 'approved'
                           and l.recorded_at > now() - make_interval(secs => (select location_fresh_s
                                                                               from public.settings)))
  ) into result;
  return result;
end;
$$;
revoke all on function public.admin_stats(timestamptz, timestamptz) from public, anon;
grant execute on function public.admin_stats(timestamptz, timestamptz) to authenticated;
