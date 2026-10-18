begin;
create extension if not exists pgtap with schema extensions;
select plan(3);

select ok(
  not has_schema_privilege('anon', 'private', 'usage'),
  'un visiteur ne peut pas utiliser le schéma private'
);
select ok(
  not has_function_privilege('authenticated', 'private.set_updated_at()', 'execute'),
  'un utilisateur connecté ne peut pas exécuter une fonction interne non autorisée'
);

create temporary table sample (id int primary key, updated_at timestamptz not null default '2000-01-01');
create trigger sample_updated_at before update on sample
  for each row execute function private.set_updated_at();
insert into sample (id) values (1);
update sample set id = 1;
select ok(
  (select updated_at > '2000-01-01' from sample),
  'set_updated_at horodate chaque modification'
);

select * from finish();
rollback;
