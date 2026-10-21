-- Évaluation du livreur (ADR-061) : après une livraison, le client note son livreur (1 à 5 étoiles, mots rapides,
-- commentaire facultatif), une fois, dans les 7 jours. Invitation envoyée à la livraison ; moyenne visible du livreur.
create table public.courier_ratings (
  order_id uuid primary key references public.orders (id) on delete cascade,
  courier_id uuid not null references public.profiles (id),
  customer_id uuid not null references public.profiles (id),
  stars smallint not null check (stars between 1 and 5),
  tags text[] not null default '{}',
  comment text check (char_length(comment) <= 300),
  created_at timestamptz not null default now()
);
create index courier_ratings_courier_idx on public.courier_ratings (courier_id);
alter table public.courier_ratings enable row level security;
create policy "notes : le client auteur et les admins" on public.courier_ratings
  for select to authenticated using (customer_id = auth.uid() or private.is_admin());
revoke insert, update, delete on public.courier_ratings from anon, authenticated;

create function public.rate_courier(p_order_id uuid, p_stars integer, p_tags text[] default '{}', p_comment text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
begin
  select * into o from public.orders where id = p_order_id and customer_id = auth.uid();
  if o.id is null or o.courier_id is null then
    raise exception 'not_found' using errcode = 'P0001';
  end if;
  if o.status <> 'delivered' or o.delivered_at < now() - interval '7 days' then
    raise exception 'rating_closed' using errcode = 'P0001';
  end if;
  if p_stars not between 1 and 5 then
    raise exception 'invalid_rating' using errcode = 'P0001';
  end if;
  insert into public.courier_ratings (order_id, courier_id, customer_id, stars, tags, comment)
  values (o.id, o.courier_id, auth.uid(), p_stars,
          coalesce((select array_agg(t) from unnest(p_tags) t
                     where t in ('fast', 'friendly', 'careful', 'on_time', 'late', 'damaged', 'rude')), '{}'),
          nullif(btrim(p_comment), ''))
  on conflict (order_id) do nothing;
  if not found then
    raise exception 'already_rated' using errcode = 'P0001';
  end if;
end;
$$;
revoke all on function public.rate_courier(uuid, integer, text[], text) from public, anon;
grant execute on function public.rate_courier(uuid, integer, text[], text) to authenticated;

-- Note moyenne d'un livreur (publique pour le livreur lui-même, ses restaurants et l'admin via les fonctions).
create function private.courier_rating(p_courier_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object('average', round(avg(stars)::numeric, 1), 'count', count(*))
    from public.courier_ratings where courier_id = p_courier_id;
$$;

-- Ma note (livreur connecté).
create function public.my_courier_rating()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select private.courier_rating(auth.uid());
$$;
revoke all on function public.my_courier_rating() from public, anon;
grant execute on function public.my_courier_rating() to authenticated;

-- Invitation à noter, juste après la notification « Commande livrée » (commandes avec livreur).
create function private.invite_courier_rating()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  courier_name text := (select first_name from public.profiles where id = new.courier_id);
begin
  if new.status = 'delivered' and old.status is distinct from 'delivered' and new.courier_id is not null then
    perform private.notify(new.customer_id, new, 'rate_courier',
      'Comment s''est passée la livraison ?',
      'Notez ' || coalesce(courier_name, 'votre livreur') || ' en un instant : cela aide toute la communauté Tchopi.',
      '/orders/' || new.id);
  end if;
  return new;
end;
$$;
create trigger orders_invite_courier_rating after update of status on public.orders
  for each row execute function private.invite_courier_rating();
