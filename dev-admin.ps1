# Local uniquement : donne le rôle admin à un compte déjà inscrit dans l'app.
#   .\dev-admin.ps1 +2250700000001
#   .\dev-admin.ps1 moi@exemple.com
# En production, voir docs/manual-tasks.md (§ 12).
param([Parameter(Mandatory)][string]$Login)

$login = $Login.Trim().TrimStart('+').Replace("'", "''")
$sql = "insert into public.admins (user_id) select id from auth.users where phone = '$login' or lower(email) = lower('$login') on conflict do nothing returning user_id;"
docker exec supabase_db_food-delive psql -U postgres -t -c $sql
if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC : Supabase local est-il démarré ?' -ForegroundColor Red; exit 1 }
Write-Host 'Fait si un identifiant est affiché ci-dessus (sinon : compte introuvable ou déjà admin). Reconnecte-toi dans l''app.' -ForegroundColor Green
