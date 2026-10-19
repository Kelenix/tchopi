# Serveur (VPS Hostinger) piloté depuis ce PC. Guide : docs/deployer-sur-vps.md.
#   .\vps.ps1 cle <IP du VPS>                crée la clé SSH de ce PC et affiche la clé publique à ajouter chez Hostinger
#   .\vps.ps1 installer api.<domaine>        installe le serveur (une seule fois)
#   .\vps.ps1 deployer                      envoie la base et les fonctions serveur (version commitée)
#   .\vps.ps1 testeur +225XXXXXXXXXX <code>  autorise l'inscription de ce numéro avec ce code à 6 chiffres
#   .\vps.ps1 admin +225XXXXXXXXXX           donne le rôle admin à ce compte (déjà inscrit dans l'app)
#   .\vps.ps1 studio                         tableau de bord Supabase sur http://localhost:8000 (Ctrl+C pour fermer)
param(
  [Parameter(Mandatory)][ValidateSet('cle', 'installer', 'deployer', 'testeur', 'admin', 'studio')][string]$Action,
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
  $digits
}

# Envoie la version commitée de infra/ et supabase/ (migrations, fonctions), jamais les secrets locaux.
function Send-Source {
  if (git -C $PSScriptRoot status --porcelain -- infra supabase) {
    Write-Host 'Attention : modifications non commitées dans infra/ ou supabase/ ; seule la version commitée est envoyée.' -ForegroundColor Yellow
  }
  $tar = Join-Path $env:TEMP 'tchopi-src.tar'
  git -C $PSScriptRoot archive -o $tar HEAD infra supabase/migrations supabase/functions
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
  'studio' {
    # Démarré à la demande (mémoire du VPS partagé), arrêté à la fermeture du tunnel.
    Remote 'sh /opt/tchopi/src/infra/server.sh studio start'
    Remote "grep -E '^DASHBOARD_(USERNAME|PASSWORD)=' /opt/tchopi/supabase/.env"
    Write-Host 'Studio : http://localhost:8000 avec les identifiants ci-dessus. Ctrl+C pour fermer.' -ForegroundColor Green
    try { ssh -N -L 8000:127.0.0.1:8010 tchopi }
    finally { ssh tchopi 'sh /opt/tchopi/src/infra/server.sh studio stop' }
  }
}
