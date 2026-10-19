# Installe l'app sur un téléphone Android, reliée par le Wi-Fi au Supabase local de ce PC.
#   .\phone.ps1                        compile l'APK et l'installe sur le téléphone branché en USB
#   .\phone.ps1 -d <appareil>          idem si plusieurs appareils sont branchés (liste : flutter devices)
#   .\phone.ps1 -BuildOnly             compile seulement (APK à envoyer sur le téléphone)
# Prérequis : supabase start, PC et téléphone sur le même Wi-Fi, port 54321 ouvert (docs/installer-sur-telephone.md).
param([switch]$BuildOnly, [string]$d)

$ip = (Get-NetIPConfiguration |
  Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
  Select-Object -First 1).IPv4Address.IPAddress
if (-not $ip) { Write-Host 'ÉCHEC : ce PC n''est connecté à aucun réseau (Wi-Fi ?).' -ForegroundColor Red; exit 1 }

# Même configuration que le PC, avec l'adresse du PC sur le Wi-Fi à la place de 127.0.0.1 (UTF-8 sans BOM).
$config = Get-Content "$PSScriptRoot\env\local.json" -Raw | ConvertFrom-Json
$config.SUPABASE_URL = "http://${ip}:54321"
[IO.File]::WriteAllText("$PSScriptRoot\env\phone.json", ($config | ConvertTo-Json))

Push-Location "$PSScriptRoot\apps\mobile"
try {
  flutter build apk --release --dart-define-from-file=..\..\env\phone.json
  if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC de la compilation.' -ForegroundColor Red; exit 1 }
  if (-not $BuildOnly) {
    if ($d) { flutter install --release -d $d } else { flutter install --release }
    if ($LASTEXITCODE -ne 0) { Write-Host 'ÉCHEC de l''installation : téléphone branché et autorisé ? (flutter devices)' -ForegroundColor Red; exit 1 }
  }
} finally {
  Pop-Location
}
Write-Host "APK : apps\mobile\build\app\outputs\flutter-apk\app-release.apk — serveur : http://${ip}:54321" -ForegroundColor Green
