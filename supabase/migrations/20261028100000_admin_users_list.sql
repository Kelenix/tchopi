-- Liste des comptes pour l'admin (ADR-056) : identité, identifiant de connexion, date d'inscription et rôles
-- (admin, établissements gérés, dossier livreur, client), filtrée par rôle et recherche, paginée par le serveur.
create function public.admin_users_list(
  p_query text default null, p_role text default null, p_limit integer default 50, p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if not private.is_admin() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;
  with accounts as (
    select p.id, p.first_name, p.last_name, p.phone, p.city, p.is_suspended, p.created_at, u.email,
           exists (select 1 from public.admins a where a.user_id = p.id) as is_admin,
           c.status::text as courier_status,
           coalesce((select jsonb_agg(r.name order by r.name) from public.restaurant_members m
                       join public.restaurants r on r.id = m.restaurant_id where m.user_id = p.id), '[]'::jsonb)
             as restaurants
      from public.profiles p
      join auth.users u on u.id = p.id
      left join public.couriers c on c.user_id = p.id
     where p.deleted_at is null
  ), typed as (
    select a.*,
           case when is_admin then 'admin'
                when jsonb_array_length(restaurants) > 0 then 'restaurant'
                when courier_status is not null then 'courier'
                else 'client' end as role
      from accounts a
  ), filtered as (
    select * from typed
     where (p_role is null or role = p_role)
       and (nullif(btrim(p_query), '') is null
            or concat_ws(' ', first_name, last_name, phone, email) ilike '%' || btrim(p_query) || '%')
  )
  select jsonb_build_object(
    'counts', (select jsonb_build_object('all', count(*),
                 'admin', count(*) filter (where role = 'admin'),
                 'restaurant', count(*) filter (where role = 'restaurant'),
                 'courier', count(*) filter (where role = 'courier'),
                 'client', count(*) filter (where role = 'client')) from typed),
    'total', (select count(*) from filtered),
    'rows', coalesce((select jsonb_agg(to_jsonb(f) order by f.created_at desc)
                        from (select * from filtered order by created_at desc
                               limit least(greatest(p_limit, 1), 200) offset greatest(p_offset, 0)) f), '[]'::jsonb)
  ) into result;
  return result;
end;
$$;
revoke all on function public.admin_users_list(text, text, integer, integer) from public, anon;
grant execute on function public.admin_users_list(text, text, integer, integer) to authenticated;
