begin;
create extension if not exists pgtap with schema extensions;
select plan(17);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000e1', 'livreur@exemple.ci', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000e2', 'curieux@exemple.ci', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000ad', 'admin@exemple.ci', 'authenticated', 'authenticated');
insert into public.admins (user_id) values ('00000000-0000-0000-0000-0000000000ad');
insert into public.zones (id, name, city, center_lat, center_lng, radius_m)
values ('44444444-4444-4444-4444-444444444444', 'San-Pédro', 'San-Pédro', 4.7485, -6.6363, 6000);

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}';

select throws_ok(
  $$ select public.submit_courier_profile('44444444-4444-4444-4444-444444444444', 'motorbike', null, '00000000-0000-0000-0000-0000000000e1/photo.jpg') $$,
  'P0001', 'invalid_plate', 'une immatriculation est exigée pour une moto'
);
select throws_ok(
  $$ select public.submit_courier_profile('44444444-4444-4444-4444-444444444444', 'bicycle', null, 'autre-dossier/photo.jpg', 'cni', 'CI0012345678') $$,
  '23514', null, 'la photo doit être dans le dossier du livreur'
);
select is(
  (select status::text from public.submit_courier_profile('44444444-4444-4444-4444-444444444444', 'motorbike', '4821 HJ 01', '00000000-0000-0000-0000-0000000000e1/photo.jpg')),
  'pending', 'un profil soumis est en attente de validation'
);
select is((select public.my_roles() ->> 'courier_status'), 'pending', 'le statut livreur figure dans les rôles du compte');
select throws_ok(
  $$ update public.couriers set status = 'approved' $$,
  '42501', null, 'un livreur ne peut pas s''approuver lui-même'
);
select throws_ok(
  $$ select public.admin_set_courier_status('00000000-0000-0000-0000-0000000000e1', 'approved') $$,
  'P0001', 'forbidden', 'seul un admin valide un livreur'
);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}';
select is((select count(*)::int from public.couriers), 0, 'un compte ne voit pas le profil des livreurs');

-- Admin.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}';
select throws_ok(
  $$ select public.admin_set_courier_status('00000000-0000-0000-0000-0000000000e1', 'rejected') $$,
  'P0001', 'reason_required', 'un refus exige un motif'
);
select is(
  (select status_reason from public.admin_set_courier_status('00000000-0000-0000-0000-0000000000e1', 'rejected', 'Photo illisible')),
  'Photo illisible', 'le motif du refus est enregistré pour le livreur'
);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}';
select is(
  (select status::text from public.submit_courier_profile('44444444-4444-4444-4444-444444444444', 'motorbike', '4821 HJ 01', '00000000-0000-0000-0000-0000000000e1/photo2.jpg')),
  'pending', 'un profil refusé, corrigé, repasse en attente'
);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}';
select ok(
  (select status = 'approved' and approved_at is not null
     from public.admin_set_courier_status('00000000-0000-0000-0000-0000000000e1', 'approved')),
  'un admin approuve un livreur'
);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}';
select is(
  (select status::text from public.submit_courier_profile('44444444-4444-4444-4444-444444444444', 'motorbike', '4821 HJ 01', '00000000-0000-0000-0000-0000000000e1/photo3.jpg')),
  'approved', 'un livreur approuvé peut changer sa photo sans nouvelle validation'
);
select is(
  (select status::text from public.submit_courier_profile('44444444-4444-4444-4444-444444444444', 'car', '1234 AB 01', '00000000-0000-0000-0000-0000000000e1/photo3.jpg')),
  'pending', 'changer de moyen de transport impose une nouvelle validation'
);

-- Suspension d'un compte.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}';
select throws_ok(
  $$ select public.admin_set_user_suspended('00000000-0000-0000-0000-0000000000ad', true, 'test') $$,
  'P0001', 'cannot_target_self', 'un admin ne peut pas se suspendre lui-même'
);
select public.admin_set_user_suspended('00000000-0000-0000-0000-0000000000e1', true, 'Fraude');
select ok(
  (select is_suspended and suspension_reason = 'Fraude' from public.profiles where id = '00000000-0000-0000-0000-0000000000e1'),
  'un admin suspend un compte avec un motif'
);
select is(
  (select count(*)::int from public.audit_log where target_id = '00000000-0000-0000-0000-0000000000e1'),
  3, 'chaque décision admin (refus, validation, suspension) est tracée dans le journal d''audit'
);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}';
select throws_ok(
  $$ select public.submit_courier_profile('44444444-4444-4444-4444-444444444444', 'bicycle', null, '00000000-0000-0000-0000-0000000000e1/photo.jpg') $$,
  'P0001', 'forbidden', 'un compte suspendu ne peut plus modifier son profil livreur'
);

select * from finish();
rollback;
