-- Moyens de paiement, transactions, espèces (Inc-10, docs/data-model.md §4 « Paiements » ; ADR-026).

create type public.transaction_status as enum ('pending', 'succeeded', 'failed', 'cancelled', 'refunded');

-- PAY-01 / ADM-05 : moyens proposés par pays ; seuls ceux activés sont proposés. Mobile Money et carte restent
-- désactivés tant que leur fournisseur n'est pas intégré (Inc-11 / 12).
create table public.payment_options (
  id uuid primary key default gen_random_uuid(),
  country_code text not null check (country_code ~ '^[A-Z]{2}$'),
  method public.payment_method not null,
  operator text,
  provider text,
  label text not null,
  is_enabled boolean not null default false,
  position integer not null default 0,
  unique nulls not distinct (country_code, method, operator)
);
alter table public.payment_options enable row level security;
create policy "moyens de paiement : lus par tous les comptes" on public.payment_options
  for select to authenticated using (true);
revoke all on public.payment_options from anon;
revoke insert, update, delete on public.payment_options from authenticated;

insert into public.payment_options (country_code, method, operator, provider, label, is_enabled, position) values
  ('CI', 'cash', null, 'cash', 'Espèces', true, 0),
  ('CI', 'mobile_money', 'orange', null, 'Orange Money', false, 1),
  ('CI', 'mobile_money', 'mtn', null, 'MTN MoMo', false, 2),
  ('CI', 'mobile_money', 'wave', null, 'Wave', false, 3),
  ('CI', 'mobile_money', 'moov', null, 'Moov Money', false, 4),
  ('CI', 'card', null, 'stripe', 'Carte bancaire', false, 5);

-- ADM-05 : activation par l'admin ; un moyen dont le fournisseur n'est pas intégré ne peut pas être activé.
create function public.admin_set_payment_option(p_id uuid, p_enabled boolean)
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
  if p_enabled and result.method <> 'cash' then
    raise exception 'payment_unavailable' using errcode = 'P0001';
  end if;
  update public.payment_options set is_enabled = p_enabled where id = p_id returning * into result;
  perform private.audit('payment_option', 'payment_option', p_id, jsonb_build_object('enabled', p_enabled));
  return result;
end;
$$;
revoke all on function public.admin_set_payment_option(uuid, boolean) from public, anon;
grant execute on function public.admin_set_payment_option(uuid, boolean) to authenticated;

-- TRX-01 : une transaction par paiement, montant égal au total de la commande ; au plus une en cours, réussie ou
-- remboursée par commande (PAY-05).
create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  amount integer not null check (amount > 0),
  currency text not null,
  method public.payment_method not null,
  operator text,
  provider text not null,
  provider_reference text unique,
  status public.transaction_status not null default 'pending',
  failure_reason text,
  refund_reference text,
  created_at timestamptz not null default now(),
  succeeded_at timestamptz,
  updated_at timestamptz not null default now()
);
create unique index transactions_active_idx on public.transactions (order_id)
  where status in ('pending', 'succeeded', 'refunded');
create index transactions_created_idx on public.transactions (created_at desc);
create trigger transactions_updated_at before update on public.transactions
  for each row execute function private.set_updated_at();
alter table public.transactions enable row level security;
create policy "transactions : le client de la commande et les admins" on public.transactions
  for select to authenticated using (
    private.is_admin() or exists (select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid())
  );
revoke all on public.transactions from anon;
revoke insert, update, delete on public.transactions from authenticated;

-- Commande refusée sans moyen de paiement activé dans son pays (PAY-01) ; espèces : transaction en attente
-- dès la création (PAY-02).
create function private.check_payment_option()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.payment_options p join public.zones z on z.country_code = p.country_code
     where z.id = new.zone_id and p.method = new.payment_method and p.is_enabled
  ) then
    raise exception 'payment_unavailable' using errcode = 'P0001';
  end if;
  return new;
end;
$$;
create trigger orders_check_payment before insert on public.orders
  for each row execute function private.check_payment_option();

create function private.open_cash_transaction()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.payment_method = 'cash' then
    insert into public.transactions (order_id, amount, currency, method, provider)
    values (new.id, new.total, new.currency, 'cash', 'cash');
  end if;
  return null;
end;
$$;
create trigger orders_open_cash_transaction after insert on public.orders
  for each row execute function private.open_cash_transaction();

-- Commande close avant encaissement : la transaction en attente est annulée (PAY-02).
create function private.close_pending_transaction()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status in ('cancelled', 'rejected', 'failed') and old.status is distinct from new.status then
    update public.transactions set status = 'cancelled' where order_id = new.id and status = 'pending';
  end if;
  return null;
end;
$$;
create trigger orders_close_pending_transaction after update of status on public.orders
  for each row execute function private.close_pending_transaction();

-- Encaissement : la transaction réussit en même temps que l'écriture au registre des espèces.
create or replace function private.record_cash(o public.orders)
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
  update public.transactions set status = 'succeeded', succeeded_at = now()
   where order_id = o.id and status = 'pending';
end;
$$;

-- Commandes antérieures : transaction reconstituée selon leur état.
insert into public.transactions (order_id, amount, currency, method, provider, status, succeeded_at, created_at)
select o.id, o.total, o.currency, o.payment_method, 'cash',
       case when o.payment_status = 'paid' then 'succeeded'
            when o.status in ('cancelled', 'rejected', 'failed') then 'cancelled'
            else 'pending' end::public.transaction_status,
       o.paid_at, o.created_at
  from public.orders o
 where o.payment_method = 'cash';

-- ADM-04 (espèces) : solde dû par livreur, versements enregistrés par l'admin.
create function public.admin_cash_balances()
returns table (
  courier_id uuid, first_name text, last_name text, phone text, collected bigint, remitted bigint, due bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  return query
  select l.courier_id, p.first_name, p.last_name, p.phone,
         coalesce(sum(l.amount) filter (where l.type = 'collected'), 0),
         coalesce(sum(l.amount) filter (where l.type = 'remitted'), 0),
         coalesce(sum(case when l.type = 'collected' then l.amount else -l.amount end), 0)
    from public.cash_ledger l
    join public.profiles p on p.id = l.courier_id
   group by l.courier_id, p.first_name, p.last_name, p.phone
   order by 7 desc;
end;
$$;
revoke all on function public.admin_cash_balances() from public, anon;
grant execute on function public.admin_cash_balances() to authenticated;

create function public.admin_record_cash_remittance(p_courier_id uuid, p_amount integer, p_reference text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  due bigint;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  perform 1 from public.couriers where user_id = p_courier_id for update;
  select coalesce(sum(case when type = 'collected' then amount else -amount end), 0) into due
    from public.cash_ledger where courier_id = p_courier_id;
  if p_amount is null or p_amount <= 0 or p_amount > due then
    raise exception 'amount_exceeds_due' using errcode = 'P0001';
  end if;
  insert into public.cash_ledger (courier_id, type, amount, reference, recorded_by)
  values (p_courier_id, 'remitted', p_amount, nullif(btrim(p_reference), ''), auth.uid());
  perform private.audit('cash_remitted', 'courier', p_courier_id,
                        jsonb_build_object('amount', p_amount, 'reference', nullif(btrim(p_reference), '')));
end;
$$;
revoke all on function public.admin_record_cash_remittance(uuid, integer, text) from public, anon;
grant execute on function public.admin_record_cash_remittance(uuid, integer, text) to authenticated;
