# Crée (ou remet en état) un compte de test par profil (admin, client, livreur, restaurant), sans vider la base.
#   .\dev-accounts.ps1             Supabase local ; identifiants : docs/donnees-de-test.md
#   .\dev-accounts.ps1 -Serveur    serveur en ligne (accès VPS requis), mêmes numéros et mot de passe
param([switch]$Serveur)

# Mot de passe facile à retenir (serveur pilote fermé, comptes de test seulement).
$password = 'Tchopi2026'
$sql = @'
create function pg_temp.dev_account(p_phone text, p_first text, p_last text, p_password text) returns uuid
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
      extensions.crypt(p_password, extensions.gen_salt('bf')), now(),
      '{"provider":"phone","providers":["phone"]}', '{}', now(), now(), '', '', '', '', '', '', '', '');
    insert into auth.identities (user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
    values (v_id, v_id::text, 'phone', jsonb_build_object('sub', v_id::text, 'phone', p_phone), now(), now(), now());
  else
    update auth.users
       set encrypted_password = extensions.crypt(p_password, extensions.gen_salt('bf')),
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
insert into public.admins (user_id) select pg_temp.dev_account('2250700000003', 'Awa', 'Koné', :'password') on conflict do nothing;
-- Client
select pg_temp.dev_account('2250700000004', 'Aya', 'Traoré', :'password');
-- Livreur approuvé (moto, agglomération d'Abidjan)
insert into public.couriers (user_id, zone_id, vehicle_type, plate_number, photo_path, status, approved_at)
select id, '11111111-1111-1111-1111-111111111111', 'motorbike', 'AB-1234-CI', id || '/photo.jpg', 'approved', now()
  from (select pg_temp.dev_account('2250700000005', 'Yao', 'Kouassi', :'password') as id) a
on conflict (user_id) do update set status = 'approved', status_reason = null;
-- Gérante du Grill du Plateau
insert into public.restaurant_members (restaurant_id, user_id, login_phone)
select '22222222-0000-0000-0000-000000000002', pg_temp.dev_account('2250700000006', 'Ama', 'Bamba', :'password'), '+2250700000006'
on conflict do nothing;
'@
if ($Serveur) {
  $sql | ssh tchopi "docker exec -i tchopi-db psql -U postgres -d postgres -q -v ON_ERROR_STOP=1 -v password=$password -o /dev/null"
  if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC : accès au VPS ? (docs/deployer-sur-vps.md § 1)' -ForegroundColor Red; exit 1 }
  $file = Join-Path $PSScriptRoot 'env/comptes-serveur.txt'
  @("Comptes de test sur le serveur en ligne (mot de passe commun) : $password",
    'Admin 07 00 00 00 03 · Client 07 00 00 00 04 · Livreur 07 00 00 00 05 · Restaurant 07 00 00 00 06') |
    Set-Content $file -Encoding utf8
  Write-Host "Comptes créés sur le serveur ; numéros et mot de passe : $file" -ForegroundColor Green
} else {
  $sql | docker exec -i supabase_db_food-delive psql -U postgres -q -v ON_ERROR_STOP=1 -v password=$password -o /dev/null
  if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC : Supabase local est-il démarré ? (supabase start)' -ForegroundColor Red; exit 1 }
  Write-Host 'Comptes de test prêts : voir docs/donnees-de-test.md.' -ForegroundColor Green
}
