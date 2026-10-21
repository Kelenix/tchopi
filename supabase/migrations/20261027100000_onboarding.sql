-- Onboarding (ADR-054) : après l'inscription, le compte choisit son parcours (client, établissement, livreur).
-- Les comptes existants sont considérés comme déjà orientés.
alter table public.profiles add column onboarded_at timestamptz;
update public.profiles set onboarded_at = created_at;

create function public.complete_onboarding()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.profiles set onboarded_at = coalesce(onboarded_at, now()) where id = auth.uid();
$$;
revoke all on function public.complete_onboarding() from public, anon;
grant execute on function public.complete_onboarding() to authenticated;

-- Rôles du compte, plus l'état de l'onboarding (champ ignoré par l'app mobile).
create or replace function public.my_roles()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'is_admin', private.is_admin(),
    'courier_status', (select status from public.couriers where user_id = auth.uid()),
    'restaurant_ids', coalesce(
      (select jsonb_agg(restaurant_id order by created_at) from public.restaurant_members where user_id = auth.uid()),
      '[]'::jsonb
    ),
    'onboarded', (select onboarded_at is not null from public.profiles where id = auth.uid())
  );
$$;
