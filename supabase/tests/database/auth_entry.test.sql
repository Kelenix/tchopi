begin;
create extension if not exists pgtap with schema extensions;
select plan(2);

update public.settings set auth_banner_title = 'Livraison offerte', auth_banner_body = 'Sur votre première commande.';
set local role anon;
select is(public.public_auth_config() ->> 'banner_title', 'Livraison offerte', 'bannière lisible avant la connexion');
select is(public.public_auth_config() ->> 'whatsapp', 'false', 'WhatsApp désactivé par défaut');

select * from finish();
rollback;
