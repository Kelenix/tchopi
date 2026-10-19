# Vérifie le projet comme la CI : code généré, analyse, tests, base de données.
#   .\check.ps1                 analyse + tests Flutter + tests de la base (pgTAP)
#   .\check.ps1 -Integration    + tests d'intégration réels contre Supabase local
#   .\check.ps1 -SkipDb         sans la base (si Docker est fermé)
# Attention : les tests de la base vident la base locale (comptes de test, admin).
# Prérequis pour la base : Docker ouvert et Supabase local démarré (supabase start).
param([switch]$Integration, [switch]$SkipDb)

$root = $PSScriptRoot

function Run([string]$dir, [string]$command) {
  Write-Host "`n> [$dir] $command" -ForegroundColor Cyan
  Push-Location (Join-Path $root $dir)
  try {
    Invoke-Expression $command
    if ($LASTEXITCODE -ne 0) {
      Write-Host "ÉCHEC : $command ($dir)" -ForegroundColor Red
      exit 1
    }
  } finally {
    Pop-Location
  }
}

Run 'packages\core' 'flutter gen-l10n'
Run 'packages\core' 'dart run build_runner build'
Run '.' 'dart run build_runner build'
Run '.' 'flutter analyze'
Run 'packages\core' 'flutter test'
Run '.' 'flutter test'
if (-not $SkipDb) {
  Run '.' 'supabase db reset'
  Run '.' 'supabase test db'
}
if ($Integration) {
  Run 'packages\core' 'flutter test -t integration --run-skipped'
  Run '.' 'flutter test -t integration --run-skipped'
}
Write-Host "`nTout est vert." -ForegroundColor Green
