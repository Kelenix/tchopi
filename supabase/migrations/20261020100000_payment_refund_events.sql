-- Remboursements signalés par le fournisseur (ADR-039) :
--  * nyole rembourse à la main (support) puis envoie « payment.updated » au statut REFUNDED : la transaction et la
--    commande passent « remboursées » ; un remboursement que Tchopi n'avait pas demandé est tracé pour l'admin ;
--  * un remboursement Stripe peut échouer après coup (carte clôturée) : la commande repasse « à rembourser » et
--    l'admin est alerté.

create or replace function public.apply_payment_status(
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

  if p_status = 'REFUNDED' and t.status = 'succeeded' then
    update public.transactions set status = 'refunded', refund_reference = coalesce(p_reference, t.provider_reference)
     where id = t.id;
    update public.orders set payment_status = 'refunded' where id = o.id;
    perform private.log_order_kind(o.id, 'refunded', null, 'system', t.provider);
    if o.payment_status <> 'refund_pending' then
      perform private.audit('payment_refunded_by_provider', 'transaction', t.id,
        jsonb_build_object('order_status', o.status, 'payment_status', o.payment_status));
    end if;
    return 'refunded';
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

-- Remboursement [p_reference] refusé par la banque après coup : retour à « à rembourser », alerte admin. Sans effet
-- si ce remboursement n'est pas celui enregistré (événement ancien ou rejoué).
create function public.record_refund_failure(p_transaction_id uuid, p_reference text)
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
  select * into o from public.orders where id = t.order_id for update;
  select * into t from public.transactions where id = p_transaction_id for update;
  if t.status <> 'refunded' or t.refund_reference is distinct from p_reference then
    return o.payment_status::text;
  end if;
  update public.transactions set status = 'succeeded', refund_reference = null, failure_reason = 'refund_failed'
   where id = t.id;
  update public.orders set payment_status = 'refund_pending' where id = o.id;
  perform private.log_order_kind(o.id, 'refund_pending', null, 'system', 'refund_failed');
  perform private.audit('refund_failed', 'transaction', t.id, jsonb_build_object('refund', p_reference));
  return 'refund_pending';
end;
$$;
revoke all on function public.record_refund_failure(uuid, text) from public, anon, authenticated;
grant execute on function public.record_refund_failure(uuid, text) to service_role;
