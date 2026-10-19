# Déployer sur le VPS (back-end, app web, puis Play Store)

```
App mobile (Play Store) ─┐
                         ├─► https://api.tchopi.com : base + API (Supabase), sur le VPS
App web SaaS (tchopi.com)┘   l'app web est elle aussi hébergée sur le VPS
```

Ordre : 1) back-end sur le VPS (ce guide) ; 2) app web sur `tchopi.com` ; 3) app mobile sur Google Play (test
interne, puis production). L'app appelle directement `https://api.tchopi.com` (adresse inscrite dans
`packages/core/lib/src/config/env.dart`) : `flutter run` suffit (README). Choix techniques : ADR-009, ADR-031, ADR-032.

**Le VPS** (Hostinger `srv1681209`, IP `69.62.116.243`) est partagé avec d'autres sites (melodya, ponctio…) :
Tchopi y tourne à part (`/opt/tchopi`, conteneurs `tchopi-*`, port local 8010), derrière le nginx du serveur ;
pare-feu et SSH ne sont pas modifiés. DNS : enregistrement `A` `api` → `69.62.116.243` (fait).

## 1. Accès depuis un PC (une fois par PC)

PowerShell, dans le dossier du projet :

```powershell
.\vps.ps1 cle 69.62.116.243
```

La **clé SSH** est le badge d'accès de ce PC au VPS (aucun mot de passe à communiquer). Le VPS doit l'enregistrer :
dans hPanel → VPS → **Console web**, coller cette ligne puis Entrée, en remplaçant `<clé>` par la ligne
`ssh-ed25519 …` affichée par la commande :

```bash
printf '\n%s\n' "<clé>" >> ~/.ssh/authorized_keys
```

## 2. Installer le serveur (une fois, déjà fait le 2026-10-19)

```powershell
.\vps.ps1 installer api.tchopi.com
```

Installe Supabase (version figée, secrets générés sur le VPS), le site nginx `api.tchopi.com` avec HTTPS
(certbot), les sauvegardes quotidiennes, la base et les fonctions serveur. Relançable sans risque : les données sont
conservées. Après une réinstallation complète, reporter la clé « anon » affichée dans `env.dart`.

## 3. Premier administrateur et installation de l'app

Pas encore de SMS réel (tâche manuelle n° 6) : seuls les numéros autorisés peuvent s'inscrire, avec le code que
vous leur attribuez (6 chiffres, un code différent par numéro).

```powershell
.\vps.ps1 testeur +225XXXXXXXXXX 482913
flutter run
```

Sur le téléphone (branché en USB) : « Créer un compte » avec ce numéro, puis le code `482913`. Ensuite :

```powershell
.\vps.ps1 admin +225XXXXXXXXXX
```

Se déconnecter puis se reconnecter : l'Administration s'ouvre. Y créer la zone (Admin → Zones), les restaurants, et
valider les livreurs. Un compte admin n'ouvre que l'Administration : commander ou livrer se fait avec d'autres numéros.

## 4. Inviter des testeurs (livreurs, restaurants, clients)

```powershell
.\vps.ps1 testeur +225XXXXXXXXXX <code>
flutter build apk --release
```

Envoyer au testeur son code et le fichier `build\app\outputs\flutter-apk\app-release.apk` (WhatsApp, Google
Drive…). Sur son téléphone : ouvrir le fichier, autoriser « Installer des applis inconnues » ; si Play Protect
avertit, « Installer quand même » (l'app n'est pas encore sur le Play Store).

## 5. Mettre à jour

| Changement | Commande |
|------------|----------|
| Base de données ou fonctions serveur (après commit) | `.\vps.ps1 deployer` |
| App | `flutter run` (téléphone branché) ou `flutter build apk --release` et renvoyer l'APK ; s'installe par-dessus, comptes conservés |

## 6. Administrer le serveur

- **Tableau de bord Supabase** (tables, comptes, fichiers) : `.\vps.ps1 studio`, puis http://localhost:8000 ;
  démarré à la demande, arrêté par Ctrl+C (mémoire du VPS partagé).
- **Secrets** (Mobile Money, notifications) : `ssh tchopi nano /opt/tchopi/supabase/.env`, bloc « Tchopi » en fin
  de fichier, puis `.\vps.ps1 deployer`. Ne jamais les coller dans le chat ni dans le code.
- **Sauvegardes** : chaque nuit dans `/opt/tchopi/backups` sur le VPS (14 jours). Copie sur le PC, à faire
  régulièrement : `scp -r tchopi:/opt/tchopi/backups .`
- **Journaux** : `ssh tchopi "cd /opt/tchopi/supabase && docker compose logs --tail 100 auth"` (ou `functions`, `db`).
- **Retirer l'accès d'un PC** : supprimer sa ligne `… tchopi` dans `~/.ssh/authorized_keys` (Console web).

## 7. Limites actuelles

| Limite | Pour la lever (`docs/manual-tasks.md`) |
|--------|----------------------------------------|
| Inscription réservée aux numéros autorisés | n° 6 : fournisseur SMS |
| Pas de connexion par email | n° 5 : envoi d'emails (SMTP), puis `ENABLE_EMAIL_SIGNUP=true` dans le `.env` |
| Pas de notifications push (les écrans se mettent à jour en direct) | n° 8 : Firebase |
| Mobile Money | n° 1 : clés nyole |
| Carte : serveurs publics OpenStreetMap, à remplacer avant d'ouvrir au public | n° 7 |
| APK signé avec la clé de test : Google Play demandera la signature définitive | n° 11 (phase 6) |

## En cas de problème

| Symptôme | Solution |
|----------|----------|
| `Permission denied (publickey)` | Clé de ce PC enregistrée sur le VPS (§ 1) ? |
| L'app n'arrive pas à joindre le serveur | `nslookup api.tchopi.com` doit renvoyer `69.62.116.243` ; puis relancer `.\vps.ps1 installer api.tchopi.com` |
| « Impossible d'envoyer le code par SMS à ce numéro » | Numéro non autorisé : `.\vps.ps1 testeur …` |
| Code refusé | Vérifier le code attribué ; le dernier `testeur` pour un numéro remplace le précédent |
