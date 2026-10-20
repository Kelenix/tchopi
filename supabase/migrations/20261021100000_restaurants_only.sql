-- Plateforme spécialisée dans la restauration (ADR-043) : le service colis est mis en pause sans rien supprimer.
-- Réactivation : `update public.settings set parcels_enabled = true` (et l'option PARCELS des applications).
alter table public.settings add column parcels_enabled boolean not null default false;

create function private.check_parcels_enabled()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not (select parcels_enabled from public.settings) then
    raise exception 'service_unavailable' using errcode = 'P0001';
  end if;
  return new;
end;
$$;
create trigger orders_parcels_enabled before insert on public.orders
  for each row when (new.type = 'parcel') execute function private.check_parcels_enabled();
