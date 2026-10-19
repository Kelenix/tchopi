# Serveur (VPS Hostinger) piloté depuis ce PC. Guide : docs/deployer-sur-vps.md.
#   .\vps.ps1 cle <IP du VPS>                crée la clé SSH de ce PC et affiche la clé publique à ajouter chez Hostinger
#   .\vps.ps1 installer api.<domaine>        installe le serveur (une seule fois)
#   .\vps.ps1 deployer                      envoie la base et les fonctions serveur (version commitée)
#   .\vps.ps1 ci                            déploiement automatique par GitHub à chaque push sur main (une seule fois)
#   .\vps.ps1 testeur +225XXXXXXXXXX <code>  autorise l'inscription de ce numéro avec ce code à 6 chiffres
#   .\vps.ps1 admin +225XXXXXXXXXX           donne le rôle admin à ce compte (déjà inscrit dans l'app)
#   .\vps.ps1 demo                           ajoute les restaurants de démonstration (menus, photos)
#   .\vps.ps1 studio                        tableau de bord Supabase sur http://localhost:8000 (Ctrl+C pour fermer)
param(
  [Parameter(Mandatory)][ValidateSet('cle', 'installer', 'deployer', 'ci', 'testeur', 'admin', 'demo', 'studio')][string]$Action,
  [string]$Valeur,
  [string]$Code
)

function Fail([string]$message) { Write-Host "ÉCHEC : $message" -ForegroundColor Red; exit 1 }

# Commande sur le VPS : hôte « tchopi » de ~/.ssh/config (créé par « cle »).
function Remote([string]$command) {
  ssh tchopi $command
  if ($LASTEXITCODE -ne 0) { Fail "commande sur le VPS : $command" }
}

# Numéro tel que l'enregistre le serveur : chiffres seuls, indicatif compris (225...).
function Phone([string]$value) {
  $digits = $value -replace '[\s+.-]', ''
  if ($digits -notmatch '^\d{8,15}$') { Fail "numéro invalide : $value (ex. +2250701020304)" }
  # Côte d'Ivoire : 10 chiffres après +225, commençant par 01, 05 ou 07 (même règle que l'app).
  if ($digits -like '225*' -and $digits -notmatch '^225(01|05|07)\d{8}$') {
    Fail "numéro ivoirien invalide : $value (10 chiffres après +225, ex. +2250701020304)"
  }
  $digits
}

# Envoie la version commitée de infra/ et supabase/ (migrations, fonctions), jamais les secrets locaux.
function Send-Source {
  if (git -C $PSScriptRoot status --porcelain -- infra supabase) {
    Write-Host 'Attention : modifications non commitées dans infra/ ou supabase/ ; seule la version commitée est envoyée.' -ForegroundColor Yellow
  }
  $tar = Join-Path $env:TEMP 'tchopi-src.tar'
  git -C $PSScriptRoot archive -o $tar HEAD infra supabase/migrations supabase/functions supabase/demo.sql supabase/seed-media/media
  scp -q $tar tchopi:/tmp/tchopi-src.tar
  if ($LASTEXITCODE -ne 0) { Fail 'envoi vers le VPS : clé de ce PC enregistrée sur le VPS ? (docs/deployer-sur-vps.md § 1)' }
  Remove-Item $tar
  Remote 'rm -rf /opt/tchopi/src && mkdir -p /opt/tchopi/src && tar -xf /tmp/tchopi-src.tar -C /opt/tchopi/src && rm /tmp/tchopi-src.tar'
}

switch ($Action) {
  'cle' {
    if ($Valeur -notmatch '^\d{1,3}(\.\d{1,3}){3}$') { Fail 'adresse IP du VPS attendue (hPanel : VPS > Aperçu)' }
    $dir = Join-Path $HOME '.ssh'
    $key = Join-Path $dir 'tchopi'
    New-Item -ItemType Directory -Force $dir | Out-Null
    if (-not (Test-Path $key)) {
      Start-Process ssh-keygen -ArgumentList "-q -t ed25519 -N `"`" -C tchopi -f `"$key`"" -NoNewWindow -Wait
    }
    $config = Join-Path $dir 'config'
    $current = if (Test-Path $config) { [IO.File]::ReadAllText($config) } else { '' }
    $current = $current -replace '(?m)^Host tchopi\r?\n(?:[ \t]+[^\r\n]*\r?\n?)*', ''
    # Clé seulement (jamais de mot de passe demandé) ; échange de clés NIST P-256 : la réponse curve25519 du VPS se
    # perd sur le chemin réseau (connexion bloquée).
    $entry = "Host tchopi`n  HostName $Valeur`n  User root`n  IdentityFile ~/.ssh/tchopi`n  BatchMode yes`n" +
      "  StrictHostKeyChecking accept-new`n  KexAlgorithms ecdh-sha2-nistp256`n"
    [IO.File]::WriteAllText($config, ($current.Trim() + "`n`n" + $entry).TrimStart())
    Write-Host 'Clé de ce PC, à enregistrer sur le VPS par la Console web (docs/deployer-sur-vps.md § 1) :' -ForegroundColor Green
    Get-Content "$key.pub"
  }
  'installer' {
    if ($Valeur -notmatch '^[a-z0-9-]+(\.[a-z0-9-]+)+$') { Fail 'nom de domaine attendu, ex. api.mondomaine.com' }
    Send-Source
    Remote "sh /opt/tchopi/src/infra/server.sh install $Valeur"
    # L'app embarque l'adresse et la clé publique « anon » du serveur : à reporter si elles ont changé.
    Remote "sed -n 's/^ANON_KEY=//p' /opt/tchopi/supabase/.env"
    Write-Host "Serveur prêt : https://$Valeur. Clé « anon » ci-dessus : packages\core\lib\src\config\env.dart." -ForegroundColor Green
  }
  'deployer' {
    Send-Source
    Remote 'sh /opt/tchopi/src/infra/server.sh deploy'
    Write-Host 'Base et fonctions serveur à jour.' -ForegroundColor Green
  }
  'ci' {
    # Clé réservée à GitHub Actions (jamais celle de ce PC), autorisée sur le VPS ; adresse et empreinte du VPS et clé
    # privée enregistrées comme secrets du dépôt (gh connecté), puis premier déploiement.
    if (-not (ssh -G tchopi | Select-String '^hostname \d')) {
      Fail "ce PC n'a pas encore accès au VPS : d'abord .\vps.ps1 cle <IP du VPS> (docs/deployer-sur-vps.md § 1)"
    }
    $key = Join-Path $env:TEMP 'tchopi-github'
    Remove-Item "$key", "$key.pub" -ErrorAction SilentlyContinue
    Start-Process ssh-keygen -ArgumentList "-q -t ed25519 -N `"`" -C tchopi-github -f `"$key`"" -NoNewWindow -Wait
    $public = (Get-Content "$key.pub" -Raw).Trim()
    Remote "grep -qxF '$public' ~/.ssh/authorized_keys || echo '$public' >> ~/.ssh/authorized_keys"
    $address = ((ssh -G tchopi | Select-String '^hostname ').Line -split ' ')[1]
    $known = ssh-keygen -F $address | Where-Object { $_ -notmatch '^#' }
    if (-not $known) { Fail 'empreinte du VPS absente de known_hosts : se connecter une fois (ssh tchopi)' }
    Get-Content $key -Raw | gh secret set VPS_SSH_KEY
    if ($LASTEXITCODE -ne 0) { Fail 'gh non connecté à GitHub : gh auth login' }
    $address | gh secret set VPS_HOST
    ($known -join "`n") | gh secret set VPS_KNOWN_HOSTS
    Remove-Item "$key", "$key.pub"
    gh workflow run ci.yml --ref main
    Write-Host 'Déploiement automatique en place ; premier déploiement lancé (GitHub → Actions → CI).' -ForegroundColor Green
  }
  'testeur' {
    $phone = Phone $Valeur
    if ($Code -notmatch '^\d{6}$') { Fail 'code à 6 chiffres attendu, ex. .\vps.ps1 testeur +2250701020304 482913' }
    Remote "sh /opt/tchopi/src/infra/server.sh tester $phone $Code"
    Write-Host "+$phone peut s'inscrire dans l'app ; code de vérification : $Code" -ForegroundColor Green
  }
  'admin' {
    $phone = Phone $Valeur
    $id = ssh tchopi "sh /opt/tchopi/src/infra/server.sh admin $phone"
    if ($LASTEXITCODE -ne 0) { Fail 'le VPS ne répond pas' }
    if ($id) { Write-Host "+$phone est admin : se reconnecter dans l'app." -ForegroundColor Green }
    else { Write-Host "Aucun changement : +$phone n'est pas inscrit, ou il est déjà admin." -ForegroundColor Yellow }
  }
  'demo' {
    Send-Source
    Remote 'sh /opt/tchopi/src/infra/server.sh demo'
    Write-Host 'Restaurants de démonstration en place.' -ForegroundColor Green
  }
  'studio' {
    # Démarré à la demande (mémoire du VPS partagé), arrêté à la fermeture du tunnel.
    Remote 'sh /opt/tchopi/src/infra/server.sh studio start'
    Remote "grep -E '^DASHBOARD_(USERNAME|PASSWORD)=' /opt/tchopi/supabase/.env"
    Write-Host 'Studio : http://localhost:8000 avec les identifiants ci-dessus. Ctrl+C pour fermer.' -ForegroundColor Green
    try { ssh -N -L 8000:127.0.0.1:8010 tchopi }
    finally { ssh tchopi 'sh /opt/tchopi/src/infra/server.sh studio stop' }
  }
}
