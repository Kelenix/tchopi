-- Socle commun (docs/data-model.md §1).

-- Fonctions internes : aides RLS, attribution, tâches planifiées. Jamais exposées par l'API.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- Horodatage des modifications, branché sur chaque table qui a une colonne updated_at.
create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
