#!/bin/sh
# Serveur Tchopi (VPS Ubuntu 24.04 partagé, en root), appelé par vps.ps1 depuis le PC. Guide : docs/deployer-sur-vps.md.
#   sh server.sh install api.<domaine>   première installation : Supabase auto-hébergé, site nginx + HTTPS, sauvegardes
#   sh server.sh deploy                  applique les migrations et les fonctions serveur envoyées par vps.ps1
#   sh server.sh tester <numéro> <code>  autorise l'inscription de ce numéro avec ce code fixe (pas de SMS réel)
#   sh server.sh admin <numéro>          donne le rôle admin à un compte déjà inscrit
#   sh server.sh studio start|stop       démarre ou arrête le tableau de bord (Studio)
#   sh server.sh demo                    ajoute les restaurants de démonstration et leurs photos (une seule fois)
# Le pare-feu et SSH du serveur ne sont pas modifiés (déjà limités à 22, 80 et 443).
set -eu

SUPABASE_REF=self-hosted/v0.8.3
ROOT=${TCHOPI_ROOT:-/opt/tchopi}
SRC=$ROOT/src
APP=$ROOT/supabase

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
# Secrets des fonctions serveur : Mobile Money (nyole), notifications (compte de service Firebase)
NYOLE_API_URL=https://app.nyole.com/api
NYOLE_SECRET_KEY=
NYOLE_RETURN_URL=
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
  sh "$APP/run.sh" start
}

# Site nginx de l'hôte (à côté des autres sites du serveur), puis HTTPS par certbot.
install_nginx() {
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

case "${1:-}" in
  install) install_supabase "$2"; install_nginx "$2"; install_backups; deploy ;;
  deploy) deploy ;;
  tester) tester "$2" "$3" ;;
  admin) admin "$2" ;;
  studio) studio "$2" ;;
  demo) demo ;;
  *) sed -n '2,9p' "$0"; exit 1 ;;
esac
