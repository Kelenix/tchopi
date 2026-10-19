-- Suivi en temps réel et notifications (Inc-9, docs/data-model.md §6, §8, §9 ; ADR-025).

-- TRK-01 : le client voit la position et la photo du livreur de sa commande en cours.
-- Identifiant en texte : il sert aussi pour les chemins du stockage (« <livreur>/photo.jpg »).
create function private.serves_my_active_order(p_courier_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.orders
     where courier_id::text = p_courier_id and customer_id = auth.uid()
       and status in ('accepted', 'preparing', 'ready', 'courier_assigned', 'picked_up', 'in_transit')
  );
$$;
grant execute on function private.serves_my_active_order(text) to authenticated;

create policy "positions : lues par le client d'une commande en cours avec ce livreur" on public.courier_locations
  for select to authenticated using (private.serves_my_active_order(courier_id::text));
create policy "photos livreurs : lecture par le client d'une commande en cours" on storage.objects
  for select to authenticated
  using (bucket_id = 'couriers' and private.serves_my_active_order((storage.foldername(name))[1]));
alter publication supabase_realtime add table public.courier_locations;

-- NOT-04 : appareils autorisés à recevoir des notifications ; un appareil suit le dernier compte connecté.
create table public.push_tokens (
  token text primary key check (char_length(token) between 20 and 4096),
  user_id uuid not null references public.profiles (id) on delete cascade,
  platform text not null check (platform in ('android', 'ios', 'web')),
  updated_at timestamptz not null default now()
);
create index push_tokens_user_idx on public.push_tokens (user_id);
alter table public.push_tokens enable row level security;
create policy "appareils : chacun gère les siens" on public.push_tokens
  for select to authenticated using (user_id = auth.uid());
revoke all on public.push_tokens from anon;
revoke insert, update, delete on public.push_tokens from authenticated;

create function public.register_push_token(p_token text, p_platform text)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.push_tokens (token, user_id, platform)
  values (p_token, auth.uid(), p_platform)
  on conflict (token) do update set user_id = excluded.user_id, platform = excluded.platform, updated_at = now();
$$;
revoke all on function public.register_push_token(text, text) from public, anon;
grant execute on function public.register_push_token(text, text) to authenticated;

-- NOT-01 à NOT-03 : file des notifications, remplie dans la même transaction que l'événement, envoyée par la
-- fonction « push » (FCM). Lisible par son destinataire.
create table public.notifications (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  order_id uuid references public.orders (id) on delete cascade,
  kind text not null,
  title text not null,
  body text not null,
  -- Écran ouvert au toucher de la notification.
  route text not null check (route like '/%'),
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  attempts integer not null default 0,
  error text
);
create index notifications_pending_idx on public.notifications (created_at) where sent_at is null;
create index notifications_user_idx on public.notifications (user_id, created_at desc);
alter table public.notifications enable row level security;
create policy "notifications : lues par leur destinataire" on public.notifications
  for select to authenticated using (user_id = auth.uid());
revoke all on public.notifications from anon;
revoke insert, update, delete on public.notifications from authenticated;

create function private.notify(
  p_user_id uuid, p_order public.orders, p_kind text, p_title text, p_body text, p_route text
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.notifications (user_id, order_id, kind, title, body, route)
  select p_user_id, p_order.id, p_kind, p_title, p_body, p_route
   where p_user_id is not null;
$$;

-- Qui est prévenu de quoi : le client à chaque étape utile, le livreur de sa mission, le restaurant de ses
-- commandes. L'auteur d'une action n'est pas notifié de sa propre action.
create function private.notify_order_event()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
  customer_route text;
  courier_name text;
  member uuid;
begin
  select * into o from public.orders where id = new.order_id;
  customer_route := '/orders/' || o.id;
  courier_name := coalesce(o.courier_info->>'first_name', 'Votre livreur');

  -- Client
  if new.actor_role <> 'customer' then
    case
      when new.status = 'accepted' then
        perform private.notify(o.customer_id, o, 'order_accepted', 'Commande acceptée',
          o.pickup_name || ' prépare votre commande ' || o.number || '.', customer_route);
      when new.status = 'rejected' then
        perform private.notify(o.customer_id, o, 'order_rejected', 'Commande refusée',
          'Le restaurant ne peut pas préparer votre commande ' || o.number || '.', customer_route);
      when new.kind = 'courier_assigned' then
        perform private.notify(o.customer_id, o, 'courier_assigned', 'Livreur assigné',
          courier_name || ' s''occupe de votre commande ' || o.number || '.', customer_route);
      when new.kind = 'courier_released' then
        perform private.notify(o.customer_id, o, 'courier_released', 'Changement de livreur',
          'Votre livreur a dû annuler, nous en cherchons un autre.', customer_route);
      when new.kind = 'dispatch_alert' then
        perform private.notify(o.customer_id, o, 'dispatch_alert', 'Nous cherchons encore un livreur',
          'Vous pouvez continuer d''attendre ou annuler sans frais.', customer_route);
      when new.status = 'picked_up' then
        perform private.notify(o.customer_id, o, 'picked_up', 'Commande récupérée',
          courier_name || ' a récupéré votre commande ' || o.number || '.', customer_route);
      when new.status = 'in_transit' then
        perform private.notify(o.customer_id, o, 'in_transit', 'Votre livreur est en route',
          courier_name || ' arrive avec votre commande ' || o.number || '.', customer_route);
      when new.status = 'delivered' then
        perform private.notify(o.customer_id, o, 'delivered',
          case when o.type = 'parcel' then 'Colis livré' else 'Commande livrée' end,
          'Merci d''avoir commandé avec Tchopi.', customer_route);
      when new.status = 'cancelled' then
        perform private.notify(o.customer_id, o, 'cancelled', 'Commande annulée',
          'Votre commande ' || o.number || ' a été annulée.', customer_route);
      when new.status = 'failed' then
        perform private.notify(o.customer_id, o, 'failed', 'Échec de livraison',
          'L''équipe vous contacte pour la suite de la commande ' || o.number || '.', customer_route);
      else
        null;
    end case;
  end if;

  -- Livreur : mission attribuée par l'admin, commande prête, mission annulée.
  if o.courier_id is not null and new.actor_role <> 'courier' then
    if new.kind = 'courier_assigned' and new.actor_role = 'admin' then
      perform private.notify(o.courier_id, o, 'mission_assigned', 'Mission attribuée',
        o.number || ' : retrait à ' || o.pickup_district || '.', '/courier/missions/' || o.id);
    elsif new.status = 'ready' then
      perform private.notify(o.courier_id, o, 'order_ready', 'Commande prête',
        o.number || ' vous attend chez ' || o.pickup_name || '.', '/courier/missions/' || o.id);
    elsif new.status = 'cancelled' then
      perform private.notify(o.courier_id, o, 'mission_cancelled', 'Mission annulée',
        'La commande ' || o.number || ' a été annulée.', '/courier');
    end if;
  end if;

  -- Restaurant : nouvelle commande, commande annulée.
  if o.restaurant_id is not null and new.actor_role <> 'restaurant' and new.status in ('pending', 'cancelled') then
    for member in select user_id from public.restaurant_members
                   where restaurant_id = o.restaurant_id and user_id is not null loop
      perform private.notify(member, o,
        case when new.status = 'pending' then 'new_order' else 'order_cancelled' end,
        case when new.status = 'pending' then 'Nouvelle commande' else 'Commande annulée' end,
        o.number || case when new.status = 'pending' then ' · à accepter dans les 10 minutes.'
                         else ' a été annulée.' end,
        '/restaurant/orders');
    end loop;
  end if;
  return null;
end;
$$;
create trigger order_events_notify after insert on public.order_events
  for each row execute function private.notify_order_event();

-- NOT-02 : nouvelle offre au livreur (notification prioritaire et sonore).
create function private.notify_offer()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.orders;
begin
  select * into o from public.orders where id = new.order_id;
  perform private.notify(new.courier_id, o, 'offer', 'Nouvelle mission',
    '+' || replace(to_char((new.summary->>'earning')::integer, 'FM999,999'), ',', ' ') || ' F · '
      || (new.summary->>'pickup_district') || ' → '
      || (new.summary->>'dropoff_district'), '/courier');
  return null;
end;
$$;
create trigger delivery_offers_notify after insert on public.delivery_offers
  for each row execute function private.notify_offer();

-- Envoi : appel de la fonction « push » par pg_net, après validation de la transaction. Adresse et clé dans le
-- coffre (« push_function_url », « push_function_key ») ; sans elles (déploiement non configuré), rien ne part.
create extension if not exists pg_net with schema extensions;

create function private.flush_notifications()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  url text := (select decrypted_secret from vault.decrypted_secrets where name = 'push_function_url');
  key text := (select decrypted_secret from vault.decrypted_secrets where name = 'push_function_key');
begin
  if url is null or key is null
     or not exists (select 1 from public.notifications where sent_at is null and attempts < 5) then
    return;
  end if;
  perform net.http_post(
    url := url,
    headers := jsonb_build_object('Authorization', 'Bearer ' || key, 'Content-Type', 'application/json'),
    body := '{}'::jsonb
  );
end;
$$;

create function private.flush_after_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.flush_notifications();
  return null;
end;
$$;
create trigger notifications_flush after insert on public.notifications
  for each statement execute function private.flush_after_insert();

-- Nouvel essai des envois en échec (réseau, FCM indisponible) à chaque passage de la tâche planifiée.
create or replace function private.tick()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  s public.settings;
  r record;
begin
  select * into s from public.settings;
  for r in select distinct order_id from public.delivery_offers where status = 'pending' and expires_at <= now() loop
    perform 1 from public.orders where id = r.order_id for update;
    update public.delivery_offers set status = 'expired'
     where order_id = r.order_id and status = 'pending' and expires_at <= now();
    perform private.dispatch(r.order_id);
  end loop;

  for r in select o.id from public.orders o
            where o.courier_id is null and o.dispatch_started_at is not null
              and o.status in ('preparing', 'ready', 'searching_courier')
              and not exists (select 1 from public.delivery_offers f where f.order_id = o.id and f.status = 'pending')
  loop
    perform private.dispatch(r.id);
  end loop;

  with alerted as (
    update public.orders
       set dispatch_alerted_at = now()
     where courier_id is null and dispatch_alerted_at is null
       and status in ('preparing', 'ready', 'searching_courier')
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_alert_s)
    returning id
  )
  insert into public.order_events (order_id, kind, actor_role)
  select id, 'dispatch_alert', 'system' from alerted;

  with abandoned as (
    update public.orders
       set status = 'cancelled', closed_at = now(), close_reason = 'no_courier'
     where courier_id is null
       and status in ('preparing', 'ready', 'searching_courier')
       and dispatch_started_at <= now() - make_interval(secs => s.dispatch_cancel_s)
    returning id
  )
  insert into public.order_events (order_id, status, actor_role, reason)
  select id, 'cancelled', 'system', 'no_courier' from abandoned;

  perform private.reject_unanswered_orders();
  perform private.flush_notifications();
end;
$$;
