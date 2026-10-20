-- Espace client (ADR-052) : photo de profil, et décision de l'admin sur une candidature livreur notifiée au compte.

alter table public.profiles add column avatar_path text check (avatar_path like 'avatars/' || id::text || '/%');
grant update (avatar_path) on public.profiles to authenticated;

-- Photos de profil dans le bucket public « media », dossier du titulaire uniquement.
create policy "photos de profil : dépôt dans son dossier" on storage.objects for insert to authenticated
  with check (bucket_id = 'media' and (storage.foldername(name))[1] = 'avatars'
              and (storage.foldername(name))[2] = auth.uid()::text);
create policy "photos de profil : remplacement dans son dossier" on storage.objects for update to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = 'avatars'
         and (storage.foldername(name))[2] = auth.uid()::text);

-- Candidature livreur : le compte est prévenu (push et centre de notifications) de chaque décision de l'admin.
create function private.notify_courier_status()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status is distinct from old.status and new.status in ('approved', 'rejected', 'suspended') then
    perform private.notify(new.user_id, null, 'courier_' || new.status,
      case new.status when 'approved' then 'Candidature livreur acceptée'
                      when 'rejected' then 'Candidature livreur refusée'
                      else 'Compte livreur suspendu' end,
      case new.status when 'approved' then 'Bienvenue ! Passez en ligne depuis l''espace Livreur pour recevoir des commandes.'
                      else coalesce(new.status_reason, 'Contactez l''équipe Tchopi pour en savoir plus.') end,
      '/courier/status');
  end if;
  return new;
end;
$$;
create trigger couriers_notify_status after update of status on public.couriers
  for each row execute function private.notify_courier_status();

-- Suppression du compte (client, AUTH-08) : refusée tant qu'une commande du compte est en cours, côté client ou
-- livreur ; sinon anonymisation inchangée (historique des commandes conservé sans donnée identifiante).
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
  update public.profiles
     set first_name = null, last_name = null, phone = null, city = null, avatar_path = null, deleted_at = now()
   where id = target;
  delete from public.admins where user_id = target;
end;
$$;
