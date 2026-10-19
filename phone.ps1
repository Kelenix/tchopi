# Installe l'app sur un téléphone Android, reliée au Supabase local de ce PC (Wi-Fi) ou au VPS (-Vps, partout).
#   .\phone.ps1                        compile l'APK et l'installe sur le téléphone branché en USB
#   .\phone.ps1 -d <appareil>          idem si plusieurs appareils sont branchés (liste : flutter devices)
#   .\phone.ps1 -BuildOnly             compile seulement (APK à envoyer sur le téléphone)
#   .\phone.ps1 -Vps                   app reliée au VPS (env\prod.json, créé par .\vps.ps1 installer)
# Prérequis sans -Vps : supabase start, PC et téléphone sur le même Wi-Fi (docs/installer-sur-telephone.md).
param([switch]$BuildOnly, [string]$d, [switch]$Vps)

if ($Vps) {
  $envFile = 'prod.json'
  if (-not (Test-Path "$PSScriptRoot\env\prod.json")) { Write-Host 'ÉCHEC : env\prod.json manquant (docs/deployer-sur-vps.md).' -ForegroundColor Red; exit 1 }
  $server = (Get-Content "$PSScriptRoot\env\prod.json" -Raw | ConvertFrom-Json).SUPABASE_URL
} else {
  $ip = (Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
    Select-Object -First 1).IPv4Address.IPAddress
  if (-not $ip) { Write-Host 'ÉCHEC : ce PC n''est connecté à aucun réseau (Wi-Fi ?).' -ForegroundColor Red; exit 1 }

  # Même configuration que le PC, avec l'adresse du PC sur le Wi-Fi à la place de 127.0.0.1 (UTF-8 sans BOM).
  if (-not (Test-Path "$PSScriptRoot\env\local.json")) { Write-Host 'ÉCHEC : env\local.json manquant (docs/installer-sur-telephone.md, § Commandes).' -ForegroundColor Red; exit 1 }
  $config = Get-Content "$PSScriptRoot\env\local.json" -Raw | ConvertFrom-Json
  $config.SUPABASE_URL = $server = "http://${ip}:54321"
  $envFile = 'phone.json'
  [IO.File]::WriteAllText("$PSScriptRoot\env\phone.json", ($config | ConvertTo-Json))
}

Push-Location "$PSScriptRoot\apps\mobile"
try {
  flutter build apk --release --dart-define-from-file=..\..\env\$envFile
  if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC de la compilation.' -ForegroundColor Red; exit 1 }
  if (-not $BuildOnly) {
    if ($d) { flutter install --release -d $d } else { flutter install --release }
    if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC de l''installation : téléphone branché et autorisé ? (flutter devices)' -ForegroundColor Red; exit 1 }
  }
} finally {
  Pop-Location
}
Write-Host "APK : apps\mobile\build\app\outputs\flutter-apk\app-release.apk — serveur : $server" -ForegroundColor Green
