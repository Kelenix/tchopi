-- Le restaurant est prévenu quand le livreur a remis la commande au client (ou que l'admin confirme la livraison).

-- Qui est prévenu de quoi : le restaurant suit la prise en charge (livreur en route, désistement, attente) et la
-- livraison au client.
create or replace function private.notify_order_event()
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
  title text;
  body text;
  kind text;
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
      when new.status = 'ready' and o.courier_id is null then
        perform private.notify(o.customer_id, o, 'order_ready', 'Commande prête',
          'Votre commande ' || o.number || ' est prête : un livreur va la récupérer.', customer_route);
      when new.kind = 'courier_assigned' then
        perform private.notify(o.customer_id, o, 'courier_assigned', 'Livreur en route',
          courier_name || ' va récupérer votre commande ' || o.number || '.', customer_route);
      when new.kind = 'courier_released' then
        perform private.notify(o.customer_id, o, 'courier_released', 'Changement de livreur',
          'Votre livreur a dû annuler, nous en cherchons un autre.', customer_route);
      when new.kind = 'dispatch_alert' then
        perform private.notify(o.customer_id, o, 'dispatch_alert', 'Nous cherchons encore un livreur',
          'Votre commande ' || o.number || ' sera prise en charge dès qu''un livreur est disponible.', customer_route);
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

  -- Restaurant : nouvelle commande, annulation, prise en charge par un livreur, désistement, attente prolongée,
  -- livraison au client.
  if o.restaurant_id is not null and new.actor_role <> 'restaurant' then
    title := null;
    kind := new.kind;
    if new.status = 'pending' then
      title := 'Nouvelle commande';
      kind := 'new_order';
      body := o.number || ' · à accepter dans les 10 minutes.';
    elsif new.status = 'cancelled' then
      title := 'Commande annulée';
      kind := 'order_cancelled';
      body := o.number || ' a été annulée.';
    elsif new.kind = 'courier_assigned' then
      title := 'Livreur en route';
      body := courier_name || ' vient chercher la commande ' || o.number || '.';
    elsif new.kind = 'courier_released' then
      title := 'Livreur désisté';
      body := 'La commande ' || o.number || ' est reproposée aux livreurs.';
    elsif new.kind = 'dispatch_alert' then
      title := 'Toujours sans livreur';
      body := 'La commande ' || o.number || ' attend un livreur ; l''équipe est prévenue.';
    elsif new.status = 'delivered' then
      title := 'Commande livrée';
      kind := 'order_delivered';
      body := 'La commande ' || o.number || ' a été livrée au client.';
    end if;
    if title is not null then
      for member in select user_id from public.restaurant_members
                     where restaurant_id = o.restaurant_id and user_id is not null loop
        perform private.notify(member, o, kind, title, body, '/restaurant/orders');
      end loop;
    end if;
  end if;
  return null;
end;
$$;
