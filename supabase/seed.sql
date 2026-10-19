-- Données de développement local (supabase db reset), après demo.sql.
-- Notifications en local (ADR-025) : la base appelle la fonction « push » via la passerelle interne de Docker.
-- Clé de service de démonstration publique de Supabase local (jamais utilisée en production, voir manual-tasks §8).
select vault.create_secret('http://kong:8000/functions/v1/push', 'push_function_url');
select vault.create_secret(
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
  'push_function_key');
