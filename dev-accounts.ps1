# Local uniquement : crée (ou remet en état) un compte de test par profil, sans vider la base.
#   .\dev-accounts.ps1
# Identifiants : docs/donnees-de-test.md. À relancer après .\check.ps1 ou supabase db reset.
$sql = @'
create function pg_temp.dev_account(p_phone text, p_first text, p_last text) returns uuid
language plpgsql as $$
declare v_id uuid;
begin
  select id into v_id from auth.users where phone = p_phone;
  if v_id is null then
    v_id := gen_random_uuid();
    insert into auth.users (instance_id, id, aud, role, phone, encrypted_password, phone_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token,
      email_change_token_new, email_change, phone_change, phone_change_token, email_change_token_current,
      reauthentication_token)
    values ('00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated', p_phone,
      extensions.crypt('Tchopi2026', extensions.gen_salt('bf')), now(),
      '{"provider":"phone","providers":["phone"]}', '{}', now(), now(), '', '', '', '', '', '', '', '');
    insert into auth.identities (user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
    values (v_id, v_id::text, 'phone', jsonb_build_object('sub', v_id::text, 'phone', p_phone), now(), now(), now());
  else
    update auth.users
       set encrypted_password = extensions.crypt('Tchopi2026', extensions.gen_salt('bf')),
           phone_confirmed_at = coalesce(phone_confirmed_at, now()), banned_until = null
     where id = v_id;
  end if;
  update public.profiles
     set first_name = p_first, last_name = p_last, city = 'Abidjan', phone = '+' || p_phone,
         is_suspended = false, suspension_reason = null, deleted_at = null
   where id = v_id;
  return v_id;
end $$;

-- Admin
insert into public.admins (user_id) select pg_temp.dev_account('2250700000003', 'Awa', 'Koné') on conflict do nothing;
-- Client
select pg_temp.dev_account('2250700000004', 'Aya', 'Traoré');
-- Livreur approuvé (moto, agglomération d'Abidjan)
insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path, status, approved_at)
select id, '11111111-1111-1111-1111-111111111111', 'motorbike', 'AB-1234-CI', id || '/photo.jpg', 'approved', now()
  from (select pg_temp.dev_account('2250700000005', 'Yao', 'Kouassi') as id) a
on conflict (user_id) do update set status = 'approved', status_reason = null;
-- Gérante du Grill du Plateau
insert into public.restaurant_members (restaurant_id, user_id, login_phone)
select '22222222-0000-0000-0000-000000000002', pg_temp.dev_account('2250700000006', 'Ama', 'Bamba'), '+2250700000006'
on conflict do nothing;
'@
$sql | docker exec -i supabase_db_food-delive psql -U postgres -q -v ON_ERROR_STOP=1 -o /dev/null
if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC : Supabase local est-il démarré ? (supabase start)' -ForegroundColor Red; exit 1 }
Write-Host 'Comptes de test prêts : voir docs/donnees-de-test.md.' -ForegroundColor Green
