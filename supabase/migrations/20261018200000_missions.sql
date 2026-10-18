-- Mission du livreur : récupération, livraison par code, espèces, problèmes, échec, abandon, historique
-- (Inc-8, docs/data-model.md §4, §5, §7 ; ADR-024).

alter table public.settings
  add column delivery_code_max_attempts integer not null default 5 check (delivery_code_max_attempts between 3 and 10);

alter table public.orders
  add column paid_at timestamptz,
  -- Alertes de supervision (ADM-03) : code bloqué, problème signalé par le livreur.
  add column code_locked_at timestamptz,
  add column problem_reported_at timestamptz;

-- MIS-02 : les numéros ne restent lisibles qu'une heure après la fin de la mission ; l'historique passe par
-- courier_missions(), sans coordonnées.
drop policy "commandes : le livreur assigné" on public.orders;
create policy "commandes : le livreur assigné, pendant la mission" on public.orders
  for select to authenticated using (
    courier_id = auth.uid() and (closed_at is null or closed_at > now() - interval '1 hour')
  );

-- PAY-02 (partie livreur) : espèces encaissées, à reverser ; les versements arrivent avec le back-office (Inc-10).
create type public.cash_entry_type as enum ('collected', 'remitted');
create table public.cash_ledger (
  id bigint generated always as identity primary key,
  courier_id uuid not null references public.couriers (user_id),
  order_id uuid references public.orders (id) on delete set null,
  type public.cash_entry_type not null,
  amount integer not null check (amount > 0),
  reference text,
  recorded_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);
create unique index cash_ledger_collected_idx on public.cash_ledger (order_id) where type = 'collected';
create index cash_ledger_courier_idx on public.cash_ledger (courier_id, created_at);
alter table public.cash_ledger enable row level security;
create policy "espèces : lues par le livreur concerné et les admins" on public.cash_ledger
  for select to authenticated using (courier_id = auth.uid() or private.is_admin());
revoke all on public.cash_ledger from anon;
revoke insert, update, delete on public.cash_ledger from authenticated;

-- Commande de la mission en cours du livreur connecté, verrouillée ; sinon « not_found ».
create function private.my_mission(p_order_id uuid)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
begin
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null or o.courier_id is distinct from auth.uid() then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.profiles where id = auth.uid() and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  return o;
end;
$$;

-- Encaissement enregistré une seule fois par commande ; la commande devient payée.
create function private.record_cash(o public.orders)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.cash_ledger (courier_id, order_id, type, amount, recorded_by)
  values (o.courier_id, o.id, 'collected', o.total, auth.uid())
  on conflict (order_id) where type = 'collected' do nothing;
  update public.orders set payment_status = 'paid', paid_at = now()
   where id = o.id and payment_status = 'unpaid';
end;
$$;

-- MIS-04 / ORD-10 : récupération par le livreur, ou remise déclarée par le restaurant. Repas : seulement
-- « Prête ». Colis en espèces : l'expéditeur paie d'abord le livreur.
create function public.confirm_pickup(p_order_id uuid, p_cash_received boolean default false)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders := private.my_mission(p_order_id);
begin
  if o.type = 'food' and o.status in ('accepted', 'preparing') then
    raise exception 'not_ready' using errcode = 'P0001';
  end if;
  if o.status not in ('ready', 'courier_assigned') then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  if o.type = 'parcel' and o.payment_method = 'cash' then
    if not coalesce(p_cash_received, false) then
      raise exception 'cash_confirmation_required' using errcode = 'P0001';
    end if;
    perform private.record_cash(o);
  end if;
  update public.orders set status = 'picked_up', picked_up_at = now() where id = o.id returning * into o;
  perform private.log_order_event(o.id, 'picked_up', 'courier');
  return o;
end;
$$;
revoke all on function public.confirm_pickup(uuid, boolean) from public, anon;
grant execute on function public.confirm_pickup(uuid, boolean) to authenticated;

-- ORD-10 : « Remise au livreur » par le restaurant, une fois la commande prête et un livreur attribué.
create or replace function public.transition_order(p_order_id uuid, p_to_status public.order_status, p_reason text default null)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  admin boolean := private.is_admin();
  reason text := nullif(btrim(p_reason), '');
begin
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null or o.status = 'awaiting_payment' or not (admin or private.is_member_of(o.restaurant_id)) then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.profiles where id = auth.uid() and is_suspended) then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  if (o.status, p_to_status) not in (
    ('pending'::public.order_status, 'accepted'::public.order_status), ('pending', 'rejected'),
    ('accepted', 'preparing'), ('preparing', 'ready'), ('ready', 'picked_up')
  ) then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  if p_to_status = 'picked_up' and o.courier_id is null then
    raise exception 'no_courier' using errcode = 'P0001';
  end if;
  if p_to_status = 'rejected' and reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  update public.orders
     set status = p_to_status,
         accepted_at = case when p_to_status = 'accepted' then now() else accepted_at end,
         ready_at = case when p_to_status = 'ready' then now() else ready_at end,
         picked_up_at = case when p_to_status = 'picked_up' then now() else picked_up_at end,
         closed_at = case when p_to_status = 'rejected' then now() else closed_at end,
         close_reason = case when p_to_status = 'rejected' then reason else close_reason end
   where id = o.id
  returning * into o;
  perform private.log_order_event(o.id, p_to_status, case when admin and not private.is_member_of(o.restaurant_id)
                                                          then 'admin' else 'restaurant' end::public.actor_role, reason);
  return o;
end;
$$;

-- MIS-05 : départ vers le destinataire.
create function public.start_delivery(p_order_id uuid)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders := private.my_mission(p_order_id);
begin
  if o.status <> 'picked_up' then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  update public.orders set status = 'in_transit' where id = o.id returning * into o;
  perform private.log_order_event(o.id, 'in_transit', 'courier');
  return o;
end;
$$;
revoke all on function public.start_delivery(uuid) from public, anon;
grant execute on function public.start_delivery(uuid) to authenticated;

-- MIS-06 : code donné par le destinataire. Un code faux est compté (le résultat est rendu, pas levé, pour que
-- l'essai soit enregistré) ; au-delà du maximum, la saisie est bloquée et l'admin alerté.
-- Résultat : {"delivered": bool, "attempts_left": int, "locked": bool}.
create function public.confirm_delivery(p_order_id uuid, p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders := private.my_mission(p_order_id);
  c public.delivery_codes;
  max_attempts integer := (select delivery_code_max_attempts from public.settings);
begin
  if o.status <> 'in_transit' then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  select * into c from public.delivery_codes where order_id = o.id for update;
  if c.locked_at is not null then
    return jsonb_build_object('delivered', false, 'attempts_left', 0, 'locked', true);
  end if;
  if c.code is distinct from btrim(coalesce(p_code, '')) then
    update public.delivery_codes set failed_attempts = failed_attempts + 1,
           locked_at = case when failed_attempts + 1 >= max_attempts then now() end
     where order_id = o.id
    returning * into c;
    perform private.log_order_kind(o.id, case when c.locked_at is null then 'code_failed' else 'code_locked' end,
                                   null, 'courier');
    if c.locked_at is not null then
      update public.orders set code_locked_at = now() where id = o.id;
    end if;
    return jsonb_build_object('delivered', false, 'attempts_left', max_attempts - c.failed_attempts,
                              'locked', c.locked_at is not null);
  end if;
  update public.orders set status = 'delivered', delivered_at = now(), closed_at = now() where id = o.id;
  perform private.log_order_event(o.id, 'delivered', 'courier');
  return jsonb_build_object('delivered', true, 'attempts_left', max_attempts - c.failed_attempts, 'locked', false);
end;
$$;
revoke all on function public.confirm_delivery(uuid, text) from public, anon;
grant execute on function public.confirm_delivery(uuid, text) to authenticated;

-- PAY-02 : repas en espèces, encaissement confirmé par le livreur après la livraison.
create function public.confirm_cash_collected(p_order_id uuid)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
begin
  select * into o from public.orders where id = p_order_id for update;
  if o.id is null or o.courier_id is distinct from auth.uid() then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if o.payment_method <> 'cash' or o.status <> 'delivered' then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  perform private.record_cash(o);
  select * into o from public.orders where id = o.id;
  return o;
end;
$$;
revoke all on function public.confirm_cash_collected(uuid) from public, anon;
grant execute on function public.confirm_cash_collected(uuid) to authenticated;

-- MIS-08 : problème signalé (alerte admin) ; échec déclaré après récupération, motif obligatoire.
create function public.report_problem(p_order_id uuid, p_kind text, p_comment text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders := private.my_mission(p_order_id);
  comment text := nullif(btrim(p_comment), '');
begin
  if p_kind not in ('customer_unreachable', 'address_not_found', 'recipient_absent', 'other')
     or (p_kind = 'other' and comment is null) then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  if o.status in ('delivered', 'rejected', 'cancelled', 'failed') then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  update public.orders set problem_reported_at = now() where id = o.id;
  perform private.log_order_kind(o.id, 'problem_reported', null, 'courier', concat_ws(' · ', p_kind, comment));
end;
$$;
revoke all on function public.report_problem(uuid, text, text) from public, anon;
grant execute on function public.report_problem(uuid, text, text) to authenticated;

create function public.declare_failure(p_order_id uuid, p_reason text)
returns public.orders
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders := private.my_mission(p_order_id);
  reason text := nullif(btrim(p_reason), '');
begin
  if reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  if o.status not in ('picked_up', 'in_transit') then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  update public.orders
     set status = 'failed', closed_at = now(), close_reason = reason, problem_reported_at = now()
   where id = o.id
  returning * into o;
  perform private.log_order_event(o.id, 'failed', 'courier', reason);
  return o;
end;
$$;
revoke all on function public.declare_failure(uuid, text) from public, anon;
grant execute on function public.declare_failure(uuid, text) to authenticated;

-- MIS-09 : abandon avant récupération (motif) ; la recherche repart de zéro, sans reproposer ce livreur.
create function public.release_mission(p_order_id uuid, p_reason text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders := private.my_mission(p_order_id);
  reason text := nullif(btrim(p_reason), '');
begin
  if reason is null then
    raise exception 'reason_required' using errcode = 'P0001';
  end if;
  if o.status not in ('accepted', 'preparing', 'ready', 'courier_assigned') then
    raise exception 'already_picked_up' using errcode = 'P0001';
  end if;
  perform private.log_order_kind(o.id, 'courier_released', null, 'courier', reason);
  update public.orders
     set courier_id = null, courier_info = null, assigned_at = null,
         status = case when status = 'courier_assigned' then 'searching_courier' else status end,
         dispatch_started_at = case when dispatch_started_at is null then null else now() end,
         dispatch_alerted_at = null
   where id = o.id;
end;
$$;
revoke all on function public.release_mission(uuid, text) from public, anon;
grant execute on function public.release_mission(uuid, text) to authenticated;

-- MIS-07 : livraison confirmée sans code par l'admin, après vérification ; motif obligatoire, tracé.
create function public.admin_confirm_delivery(p_order_id uuid, p_reason text)
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
  if o.status not in ('picked_up', 'in_transit') then
    raise exception 'invalid_transition' using errcode = 'P0001';
  end if;
  update public.orders set status = 'delivered', delivered_at = now(), closed_at = now()
   where id = o.id
  returning * into o;
  perform private.log_order_event(o.id, 'delivered', 'admin', reason);
  return o;
end;
$$;
revoke all on function public.admin_confirm_delivery(uuid, text) from public, anon;
grant execute on function public.admin_confirm_delivery(uuid, text) to authenticated;

-- MIS-01 : gains et livraisons du jour (heure d'Abidjan), espèces à reverser.
create function public.courier_summary()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'earnings_today', coalesce(sum(o.courier_earning) filter (where o.status = 'delivered'), 0),
    'deliveries_today', count(*) filter (where o.status = 'delivered'),
    'cash_due', coalesce((
      select sum(case when l.type = 'collected' then l.amount else -l.amount end)
        from public.cash_ledger l where l.courier_id = auth.uid()), 0)
  )
    from public.orders o
   where o.courier_id = auth.uid()
     and (o.delivered_at at time zone 'Africa/Abidjan')::date = (now() at time zone 'Africa/Abidjan')::date;
$$;
revoke all on function public.courier_summary() from public, anon;
grant execute on function public.courier_summary() to authenticated;

-- MIS-10 : historique des missions, sans numéros de téléphone ni repères précis.
create function public.courier_missions()
returns table (
  id uuid, number text, type public.order_type, status public.order_status, pickup_district text,
  dropoff_district text, courier_earning integer, assigned_at timestamptz, closed_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select o.id, o.number, o.type, o.status, o.pickup_district, o.dropoff_district, o.courier_earning,
         o.assigned_at, o.closed_at
    from public.orders o
   where o.courier_id = auth.uid()
   order by o.assigned_at desc
   limit 200;
$$;
revoke all on function public.courier_missions() from public, anon;
grant execute on function public.courier_missions() to authenticated;

alter publication supabase_realtime add table public.cash_ledger;
