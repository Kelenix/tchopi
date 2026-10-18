# Lance l'app mobile depuis la racine du projet : .\run.ps1   (navigateur : .\run.ps1 -d chrome)
# Prérequis : Supabase local démarré (supabase start) et env/local.json présent (voir README).
Push-Location "$PSScriptRoot\apps\mobile"
try {
  flutter run --dart-define-from-file=..\..\env\local.json @args
} finally {
  Pop-Location
}
