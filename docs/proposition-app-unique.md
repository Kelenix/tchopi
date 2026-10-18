# Proposition — une seule app mobile, un espace par rôle

> Statut : **validée le 2026-10-18 et réalisée** (ADR-016, remplace ADR-002). Le back-end n'a pas changé.

## Ce que voit l'utilisateur

- **Une app « Tchopi »** sur Google Play (puis l'App Store).
- Tout compte arrive dans l'**espace Client** (commander, envoyer un colis, adresses, paiements).
- Selon ses droits, le menu propose aussi d'autres espaces, avec un bouton **« Changer d'espace »** (le dernier
  espace utilisé est mémorisé) :

| Espace | Qui y a accès | Comment l'obtenir |
|--------|---------------|-------------------|
| Client | Tout le monde | Automatique |
| Livreur | Livreurs (profil soumis) | Bouton « Devenir livreur » dans l'espace Client → validation par l'admin |
| Restaurant | Gérants de restaurant | Invitation par l'admin (Inc-4) |
| Admin | Équipe | Accordé par un admin |

## Organisation du code

```
apps/mobile/                 ← une seule app (Android, iOS ; compilable aussi en web pour l'admin sur ordinateur)
  lib/features/client/       adresses, puis commandes, colis, suivi, paiements
  lib/features/courier/      profil livreur, statut, puis missions
  lib/features/restaurant/   commandes reçues, menu (Inc-4, Inc-5)
  lib/features/admin/        zones et tarifs, livreurs, utilisateurs, puis supervision
  lib/spaces/                choix de l'espace selon les rôles (my_roles) + menu « Changer d'espace »
packages/core/               inchangé (design system, connexion, compte, Supabase)
supabase/                    inchangé
```

Les écrans déjà écrits sont **déplacés, pas réécrits** ; les tests aussi. `apps/client`, `apps/courier` et
`apps/backoffice` sont supprimés après le déplacement.

## Conséquences

| Sujet | Effet |
|-------|-------|
| Taille de l'app | Un peu plus lourde (écrans des 4 espaces), largement sous le budget de 25 Mo |
| Localisation en arrière-plan | Déclarée dans l'app mais **demandée uniquement quand un livreur passe en ligne** ; déclaration à justifier sur Google Play (risque de questions à la revue, parade : justification et vidéo) |
| Notifications | Une seule configuration Firebase au lieu de trois |
| Publication | Une seule fiche store, un seul identifiant (`com.tchopi.mobile`, provisoire) |
| Admin sur ordinateur | Même app compilée pour le navigateur (aucun écran en plus) ; la future app web gardera l'API |
| Délai | Réorganisation estimée à une session de travail, avant de poursuivre l'Inc-3 |
