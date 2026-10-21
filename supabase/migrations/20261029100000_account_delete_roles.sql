-- Suppression d'un compte (ADR-057) : la fiche livreur et les accès aux établissements partent avec le profil.
-- Missions, gains et mouvements d'espèces restent sur les commandes et dans le journal (rattachés au compte anonymisé).
create or replace function public.anonymize_account(target uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (select 1 from public.orders
              where (customer_id = target or courier_id = target)
                and status not in ('delivered', 'rejected', 'cancelled', 'failed')) then
    raise exception 'account_busy' using errcode = 'P0001';
  end if;
  -- Offres, position et affiliations disparaissent avec la fiche livreur (cascade).
  delete from public.couriers where user_id = target;
  delete from public.restaurant_members where user_id = target;
  update public.profiles
     set first_name = null, last_name = null, phone = null, city = null, avatar_path = null, deleted_at = now()
   where id = target;
  delete from public.admins where user_id = target;
end;
$$;

-- Comptes déjà supprimés : fiches livreur et accès restés en place.
delete from public.couriers c using public.profiles p where p.id = c.user_id and p.deleted_at is not null;
delete from public.restaurant_members m using public.profiles p where p.id = m.user_id and p.deleted_at is not null;
