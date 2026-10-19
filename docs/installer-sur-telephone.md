# Installer et tester l'app sur un téléphone Android

Deux façons de faire, selon ce que vous voulez tester.

| | A — Tout de suite, à la maison | B — En conditions réelles, avant la mise en ligne |
|---|---|---|
| Serveur | Supabase local de votre PC | VPS (`docs/deployer-sur-vps.md`) |
| Le téléphone doit être | sur le même Wi-Fi que le PC (PC allumé, Supabase démarré) | connecté à Internet (Wi-Fi ou 4G) |
| Testeurs | vous, sur 1 ou 2 téléphones + le PC | vous, des livreurs et des restaurants partenaires |
| Installation | `.\phone.ps1` (câble USB) ou fichier APK | `.\phone.ps1 -Vps` (APK), puis Google Play « Test interne » |

iPhone : plus tard (Android d'abord, D-6) ; il faudra un Mac et TestFlight.

## Commandes (mode A)

PowerShell, dans le dossier du projet, Docker Desktop ouvert.

**Une seule fois sur le PC** :

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
irm get.scoop.sh | iex
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
flutter doctor --android-licenses
flutter pub get
Copy-Item supabase\functions\.env.example supabase\functions\.env
supabase start
Copy-Item env\example.json env\local.json
supabase status
notepad env\local.json
```

Dans `env\local.json`, remplacer la valeur de `SUPABASE_ANON_KEY` par la clé `anon` (ou `Publishable`) affichée
par `supabase status`. Puis créer les comptes de test : `.\dev-accounts.ps1`.

**À chaque installation** (téléphone branché en USB, débogage USB autorisé — voir Préparation) :

```powershell
supabase start
flutter devices
.\phone.ps1
```

---

## A. Tester tout de suite (Wi-Fi de la maison)

### Préparation (une seule fois)

1. **Téléphone** : Paramètres → À propos du téléphone → appuyer 7 fois sur « Numéro de build » ; puis
   Paramètres → Options pour les développeurs → activer **Débogage USB**.
2. **Brancher le téléphone** au PC par câble USB, déverrouillé. À l'écran du téléphone, accepter
   « Autoriser le débogage USB ? » (cocher « Toujours autoriser depuis cet ordinateur »).
   `flutter devices` doit afficher le téléphone (et non « offline »).
3. **Seulement si l'app n'arrive pas à joindre le serveur** (souvent inutile : Docker Desktop ouvre déjà le port ;
   c'est le cas avec le partage de connexion du téléphone) — ouvrir le port du serveur local, PowerShell
   **en administrateur** (clic droit → Exécuter en tant qu'administrateur), une seule fois :
   ```powershell
   New-NetFirewallRule -DisplayName "Supabase local (Tchopi)" -Direction Inbound -Protocol TCP -LocalPort 54321 -Action Allow -Profile Private
   ```
   Le Wi-Fi du PC doit être en réseau **privé** (Paramètres Windows → Réseau et Internet → Wi-Fi → votre
   réseau → Type de profil réseau : Privé). Ne jamais le faire sur un Wi-Fi public.

### Installer

Commandes : voir [Commandes](#commandes-mode-a). Le script `.\phone.ps1` lit l'adresse du PC sur le Wi-Fi, compile l'app (2 à 5 minutes) et l'installe sur le téléphone
branché. Ensuite, débranchez : l'app fonctionne tant que le téléphone est sur le même Wi-Fi et que le PC reste
allumé avec Supabase démarré.

- **Sans câble** : `.\phone.ps1 -BuildOnly`, puis envoyez-vous le fichier
  `apps\mobile\build\app\outputs\flutter-apk\app-release.apk` (WhatsApp, Google Drive, email…). Sur le
  téléphone, ouvrez-le et autorisez « Installer des applis inconnues » ; si Play Protect avertit, choisissez
  « Installer quand même » (l'app n'est pas encore publiée).
- **Plusieurs appareils branchés** : `flutter devices`, puis `.\phone.ps1 -d <identifiant>`.
- **Adresse du PC changée** (nouveau Wi-Fi, box redémarrée) : l'app n'arrive plus à joindre le serveur ;
  relancez `.\phone.ps1`.

### Comptes pour tester chaque profil

Chaque profil a ses propres identifiants. Un même compte peut être **Client**, **Livreur** et **Gérant de
restaurant** (« Changer d'espace » dans Profil). Un compte **admin** n'ouvre que l'Administration : il n'apparaît
jamais dans « Changer d'espace » ; on y accède en se connectant avec ce compte.

Comptes prêts (admin, client, livreur, restaurant) : `.\dev-accounts.ps1`, identifiants dans
`docs/donnees-de-test.md`. Autres comptes :

| Profil | Comment l'obtenir |
|--------|-------------------|
| Client | « Créer un compte » avec un numéro `07 00 00 00 01` à `09` (code SMS local : `123456`) |
| Admin | un compte à part : `.\dev-admin.ps1 +225XXXXXXXXXX`, puis se reconnecter |
| Livreur | depuis un compte client : Profil → « Devenir livreur », puis validation par l'admin (Livreurs) |
| Restaurant | l'admin invite le numéro du gérant (Restaurants → un restaurant → « Inviter un gérant ») |

Pour une commande complète, il faut **trois comptes connectés en même temps** : le client (téléphone 1), le
livreur « En ligne » (téléphone 2, localisation autorisée) et le restaurant ou l'admin (PC, `.\run.ps1 -d chrome`).
Détails des comptes de test : `docs/donnees-de-test.md`.

### Ce qui ne marche pas encore en mode A

- Notifications push : projet Firebase à créer (tâche manuelle n° 8). Les écrans se mettent à jour en direct.
- Paiement Mobile Money réel : clés de test nyole à fournir (tâche n° 1) ; carte bancaire : Inc-12.
- Hors de la maison (4G) : impossible, le serveur est sur le PC → mode B.

---

## B. Tester en conditions réelles (avant la mise en ligne)

Pour des livreurs qui roulent en 4G, des restaurants partenaires et plusieurs testeurs, le serveur doit être
en ligne :

1. **VPS + nom de domaine** : suivre `docs/deployer-sur-vps.md` (`.\vps.ps1`, puis `.\phone.ps1 -Vps`).
2. Plus tard, **Google Play Console** (tâche n° 11, 25 $ une fois) : app signée envoyée en **Test interne**
   (jusqu'à 100 testeurs invités par email, mises à jour automatiques).

---

## En cas de problème

| Symptôme | Solution |
|----------|----------|
| `flutter devices` : « offline » ou rien | Déverrouiller le téléphone, accepter « Autoriser le débogage USB » ; câble de données (pas seulement charge) ; mode USB « Transfert de fichiers » |
| L'app affiche « Pas de connexion internet » alors que le téléphone a Internet | Même Wi-Fi que le PC ? `supabase status` répond ? Règle du pare-feu créée et Wi-Fi en « Privé » ? Sinon relancer `.\phone.ps1` (adresse changée) |
| « Appli non installée » | Désinstaller l'ancienne version de Tchopi, puis réinstaller |
| La position du livreur ne part pas | Autoriser la localisation « Pendant l'utilisation » et laisser l'app ouverte |
