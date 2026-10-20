#!/bin/sh
# Serveur Tchopi (VPS Ubuntu 24.04 partagé, en root), appelé par vps.ps1 depuis le PC. Guide : docs/deployer-sur-vps.md.
#   sh server.sh install api.<domaine>   première installation : Supabase auto-hébergé, site nginx + HTTPS, sauvegardes
#   sh server.sh deploy                  applique les migrations et les fonctions serveur envoyées par vps.ps1
#   sh server.sh tester <numéro> <code>  autorise l'inscription de ce numéro avec ce code fixe (pas de SMS réel)
#   sh server.sh admin <numéro>          donne le rôle admin à un compte déjà inscrit
#   sh server.sh studio start|stop       démarre ou arrête le tableau de bord (Studio)
#   sh server.sh demo                    ajoute les restaurants de démonstration et leurs photos (une seule fois)
#   sh server.sh routing                 met à jour la carte des trajets routiers (aussi chaque dimanche, cron)
#   sh server.sh secret <NOM>            enregistre une clé de paiement lue sur l'entrée standard, puis relance les fonctions
#   sh server.sh fcm                     active les notifications : compte de service Firebase lu sur l'entrée standard
#   sh server.sh email <domaine>         active les emails (Resend) : clé API lue sur l'entrée standard
#   sh server.sh google                  active la connexion Google : identifiant puis secret lus sur l'entrée standard
# Le pare-feu et SSH du serveur ne sont pas modifiés (déjà limités à 22, 80 et 443).
set -eu

SUPABASE_REF=self-hosted/v0.8.3
ROOT=${TCHOPI_ROOT:-/opt/tchopi}
SRC=$ROOT/src
APP=$ROOT/supabase
ROUTING=$ROOT/routing
# Carte OpenStreetMap de Côte d'Ivoire, mise à jour chaque jour par Geofabrik.
ROUTING_MAP=https://download.geofabrik.de/africa/ivory-coast-latest.osm.pbf

# Remplace (ou ajoute) une variable du .env de Supabase.
set_env() {
  if grep -q "^$1=" "$APP/.env"; then sed -i "s|^$1=.*|$1=$2|" "$APP/.env"; else echo "$1=$2" >> "$APP/.env"; fi
}

sql() { docker exec -i tchopi-db psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q "$@"; }

install_supabase() {
  if [ ! -d "$APP" ]; then
    # Script officiel, version figée : fichiers de Supabase et secrets générés (Docker est déjà installé).
    mkdir -p "$ROOT"
    (cd "$ROOT" && curl -fsSL "https://raw.githubusercontent.com/supabase/supabase/$SUPABASE_REF/docker/setup.sh" |
      sh -s -- -y --ref "$SUPABASE_REF" --project-dir supabase)
    # Pas encore de SMTP (tâche manuelle 5) : inscription par téléphone seulement. Modifiable ensuite dans le .env.
    set_env ENABLE_EMAIL_SIGNUP false
    cat >> "$APP/.env" <<'EOF'

############
# Tchopi
############
# Numéros autorisés à s'inscrire sans SMS réel, avec leur code : 225XXXXXXXXXX:123456,... (vps.ps1 testeur)
SMS_TEST_OTP=
# Secrets des fonctions serveur : Mobile Money (nyole), carte (Stripe), notifications (compte de service Firebase)
NYOLE_API_URL=https://app.nyole.com/api
NYOLE_SECRET_KEY=
NYOLE_RETURN_URL=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
FCM_SERVICE_ACCOUNT=
EOF
  fi
  set_env COMPOSE_PROJECT_NAME tchopi
  set_env COMPOSE_FILE "docker-compose.yml:$SRC/infra/compose.yml"
  set_env SUPABASE_PUBLIC_URL "https://$1"
  set_env API_EXTERNAL_URL "https://$1/auth/v1"
  set_env SITE_URL "https://$1"
  set_env ENABLE_PHONE_AUTOCONFIRM false
  set_env PGRST_DB_EXTRA_SEARCH_PATH public,extensions
  routing_ready
  sh "$APP/run.sh" start
}

# Site nginx de l'hôte (à côté des autres sites du serveur), puis HTTPS par certbot.
install_nginx() {
  cp "$SRC/infra/nginx-routing.conf" /etc/nginx/snippets/tchopi-routing.conf
  site=/etc/nginx/sites-available/tchopi-api.conf
  if [ ! -f "$site" ]; then
    sed "s/__DOMAIN__/$1/" "$SRC/infra/nginx.conf" > "$site"
    ln -sf "$site" /etc/nginx/sites-enabled/tchopi-api.conf
    nginx -t && systemctl reload nginx
  fi
  certbot --nginx -d "$1" --non-interactive --redirect --keep-until-expiring
}

# Sauvegarde quotidienne de la base et des fichiers, 14 jours conservés sur le VPS.
install_backups() {
  cat > /etc/cron.d/tchopi-backup <<EOF
30 3 * * * root mkdir -p $ROOT/backups && docker exec tchopi-db pg_dump -U supabase_admin -Fc postgres > $ROOT/backups/db-\$(date +\%F).dump && tar -czf $ROOT/backups/storage-\$(date +\%F).tgz -C $APP/volumes storage && find $ROOT/backups -type f -mtime +14 -delete
EOF
}

# Trajets routiers des cartes (OSRM, ADR-038) : carte préparée pour le profil voiture (valable pour les motos) dans
# un dossier neuf, qui ne remplace l'ancien qu'une fois complet.
routing_data() {
  rm -rf "$ROUTING.new" "$ROUTING.old"
  mkdir -p "$ROUTING.new"
  curl -fsSL -o "$ROUTING.new/ci.osm.pbf" "$ROUTING_MAP"
  cd "$APP"
  for step in "osrm-extract -p /opt/car.lua /new/ci.osm.pbf" "osrm-partition /new/ci.osrm" "osrm-customize /new/ci.osrm"; do
    docker compose run --rm --no-deps -T -v "$ROUTING.new:/new" routing $step
  done
  rm "$ROUTING.new/ci.osm.pbf"
  if [ -d "$ROUTING" ]; then mv "$ROUTING" "$ROUTING.old"; fi
  mv "$ROUTING.new" "$ROUTING"
  rm -rf "$ROUTING.old"
}

# Le service ne démarre qu'avec une carte prête.
routing_ready() { [ -f "$ROUTING/ci.osrm.cell_metrics" ] || routing_data; }

# Accès public par le site nginx de l'API (ajouté aux sites installés avant ce service) et mise à jour hebdomadaire.
install_routing() {
  routing_ready
  site=/etc/nginx/sites-available/tchopi-api.conf
  cp "$SRC/infra/nginx-routing.conf" /etc/nginx/snippets/tchopi-routing.conf
  grep -q tchopi-routing "$site" || sed -i 's|^  location / {|  include snippets/tchopi-routing.conf;\n\n&|' "$site"
  nginx -t && systemctl reload nginx
  echo "0 4 * * 0 root TCHOPI_ROOT=$ROOT sh $SRC/infra/server.sh routing > $ROOT/routing.log 2>&1" \
    > /etc/cron.d/tchopi-routing
}

deploy() {
  cd "$APP"
  # Base : migrations pas encore appliquées, chacune dans une transaction, notées comme le fait la CLI Supabase.
  sql -c 'create schema if not exists supabase_migrations;
    create table if not exists supabase_migrations.schema_migrations (version text primary key, statements text[], name text)'
  for f in "$SRC"/supabase/migrations/*.sql; do
    file=$(basename "$f" .sql)
    version=${file%%_*}
    [ -n "$(sql -tA -c "select 1 from supabase_migrations.schema_migrations where version = '$version'")" ] && continue
    echo "Migration $file"
    { cat "$f"; printf "\ninsert into supabase_migrations.schema_migrations (version, name) values ('%s', '%s');\n" \
      "$version" "${file#*_}"; } | sql -1 -f -
  done
  # Frais de livraison sur la distance routière (ADR-046) : la base interroge le serveur de trajets du réseau interne.
  sql -c "insert into private.config (key, value) values ('routing_url', 'http://routing:5000')
    on conflict (key) do update set value = excluded.value"
  # Fonctions : à côté du routeur officiel (main), qui partage une import map entre toutes les fonctions.
  rm -rf volumes/functions/hello
  for dir in "$SRC"/supabase/functions/*/; do
    name=$(basename "$dir")
    rm -rf "volumes/functions/$name"
    cp -r "$dir" "volumes/functions/$name"
  done
  jq -s '{imports: (map(.imports // {}) | add)}' volumes/functions/deno.jsonc "$SRC"/supabase/functions/*/deno.json \
    > volumes/functions/deno.tmp
  mv volumes/functions/deno.tmp volumes/functions/deno.jsonc
  docker compose restart functions
  # Remboursements par carte (ADR-034) : la tâche planifiée de la base appelle payments-refund avec la clé de service.
  key=$(grep "^SERVICE_ROLE_KEY=" .env | cut -d= -f2-)
  sql -c "select vault.create_secret('http://kong:8000/functions/v1/payments-refund', 'refund_function_url')
    where not exists (select 1 from vault.secrets where name = 'refund_function_url')"
  sql -c "select vault.create_secret('$key', 'refund_function_key')
    where not exists (select 1 from vault.secrets where name = 'refund_function_key')"
  install_routing
  # Site web (tchopi-web, ADR-045) : adresse de retour des connexions Google et des liens des emails.
  web=${WEB_URL:-https://tchopi.com}
  set_env SITE_URL "$web"
  set_env ADDITIONAL_REDIRECT_URLS "$web/**,http://localhost:3000/**,com.tchopi.mobile://**"
  # Applique aussi les changements du .env et attend que tous les services soient en bonne santé.
  sh run.sh start
}

tester() {
  list=$(grep '^SMS_TEST_OTP=' "$APP/.env" | cut -d= -f2- | tr ',' '\n' | grep -v "^$1:" | grep . | tr '\n' ',')
  set_env SMS_TEST_OTP "$list$1:$2"
  cd "$APP" && docker compose up -d --wait auth
}

admin() {
  sql -tA -c "insert into public.admins (user_id) select id from auth.users where phone = '$1'
    on conflict do nothing returning user_id"
}

studio() {
  cd "$APP"
  if [ "$1" = start ]; then docker compose --profile studio up -d --wait studio meta; else docker compose stop studio meta; fi
}

# Restaurants de démonstration (s'ils sont absents) et leurs photos dans le bucket « media ».
demo() {
  if [ -z "$(sql -tA -c "select 1 from public.restaurants where id = '22222222-0000-0000-0000-000000000001'")" ]; then
    sql -1 -f - < "$SRC/supabase/demo.sql"
  fi
  key=$(grep '^SERVICE_ROLE_KEY=' "$APP/.env" | cut -d= -f2-)
  for f in "$SRC"/supabase/seed-media/media/demo/*.jpg; do
    curl -fsS -o /dev/null -X POST "http://127.0.0.1:8010/storage/v1/object/media/demo/$(basename "$f")" \
      -H "Authorization: Bearer $key" -H "apikey: $key" -H 'Content-Type: image/jpeg' -H 'x-upsert: true' \
      --data-binary @"$f"
  done
}

# Clé de paiement (ADR-039) lue sur l'entrée standard (jamais en argument : invisible dans la liste des processus).
secret() {
  case "$1" in
    STRIPE_SECRET_KEY | STRIPE_WEBHOOK_SECRET | NYOLE_SECRET_KEY | NYOLE_RETURN_URL) ;;
    *) echo "clé inconnue : $1" >&2; exit 1 ;;
  esac
  IFS= read -r value
  value=$(printf %s "$value" | tr -d '\r')
  # Caractères des clés et adresses seulement : rien qui puisse casser le .env.
  case "$value" in '' | *[!A-Za-z0-9_:/.?=-]*) echo 'valeur invalide' >&2; exit 1 ;; esac
  set_env "$1" "$value"
  cd "$APP" && docker compose up -d --force-recreate --wait functions
}

# Notifications (ADR-025) : compte de service Firebase lu sur l'entrée standard (jamais en argument), puis adresse et
# clé de la fonction « push » dans le coffre de la base. Les notifications restées en attente, anciennes, ne partent pas.
fcm() {
  value=$(jq -ce 'select(.type == "service_account" and .project_id and .client_email and .private_key)') ||
    { echo 'compte de service invalide' >&2; exit 1; }
  case "$value" in *"'"*) echo 'compte de service invalide' >&2; exit 1 ;; esac
  # Entre apostrophes : valeur littérale pour Docker Compose. Réécrit en place : droits du .env conservés.
  grep -v '^FCM_SERVICE_ACCOUNT=' "$APP/.env" > "$APP/.env.tmp" || true
  printf "FCM_SERVICE_ACCOUNT='%s'\n" "$value" >> "$APP/.env.tmp"
  cat "$APP/.env.tmp" > "$APP/.env" && rm "$APP/.env.tmp"
  key=$(grep '^SERVICE_ROLE_KEY=' "$APP/.env" | cut -d= -f2-)
  sql -c "update public.notifications set sent_at = now(), error = 'expired' where sent_at is null"
  sql -c "select vault.create_secret('http://kong:8000/functions/v1/push', 'push_function_url')
    where not exists (select 1 from vault.secrets where name = 'push_function_url')"
  sql -c "select vault.create_secret('$key', 'push_function_key')
    where not exists (select 1 from vault.secrets where name = 'push_function_key')"
  cd "$APP" && docker compose up -d --force-recreate --wait functions
}

# Emails (ADR-045) : envoi par Resend en SMTP ; clé API lue sur l'entrée standard (jamais en argument). L'adresse
# d'envoi no-reply@<domaine> doit appartenir à un domaine vérifié chez Resend.
email() {
  IFS= read -r key
  key=$(printf %s "$key" | tr -d '\r')
  case "$key" in re_*) ;; *) echo 'clé Resend attendue (re_…)' >&2; exit 1 ;; esac
  case "$key" in *[!A-Za-z0-9_]*) echo 'clé invalide' >&2; exit 1 ;; esac
  case "$1" in *[!a-z0-9.-]* | '') echo 'domaine invalide' >&2; exit 1 ;; esac
  set_env SMTP_HOST smtp.resend.com
  set_env SMTP_PORT 465
  set_env SMTP_USER resend
  set_env SMTP_PASS "$key"
  set_env SMTP_ADMIN_EMAIL "no-reply@$1"
  set_env SMTP_SENDER_NAME Tchopi
  set_env ENABLE_EMAIL_SIGNUP true
  set_env ENABLE_EMAIL_AUTOCONFIRM false
  cd "$APP" && docker compose up -d --force-recreate --wait auth
}

# Connexion Google (ADR-045) : identifiant client puis secret, lus sur l'entrée standard (Google Cloud → Identifiants).
google() {
  IFS= read -r id
  IFS= read -r secret
  id=$(printf %s "$id" | tr -d '\r')
  secret=$(printf %s "$secret" | tr -d '\r')
  case "$id" in *.apps.googleusercontent.com) ;; *) echo 'identifiant client Google attendu' >&2; exit 1 ;; esac
  case "$id$secret" in *[!A-Za-z0-9_.-]*) echo 'valeur invalide' >&2; exit 1 ;; esac
  set_env GOOGLE_ENABLED true
  set_env GOOGLE_CLIENT_ID "$id"
  set_env GOOGLE_SECRET "$secret"
  cd "$APP" && docker compose up -d --force-recreate --wait auth
}

case "${1:-}" in
  install) install_supabase "$2"; install_nginx "$2"; install_backups; deploy ;;
  deploy) deploy ;;
  tester) tester "$2" "$3" ;;
  admin) admin "$2" ;;
  studio) studio "$2" ;;
  demo) demo ;;
  routing) routing_data; cd "$APP" && docker compose up -d --force-recreate --wait routing ;;
  secret) secret "$2" ;;
  fcm) fcm ;;
  email) email "$2" ;;
  google) google ;;
  *) sed -n '2,14p' "$0"; exit 1 ;;
esac
