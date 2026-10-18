# Journal de décisions (DECISION_LOG)

> ADR léger. Chaque décision structurante prise par Claude **en autonomie** y est consignée :
> contexte → décision → alternatives écartées → conséquences. Permet de tracer et de contester.
> Format inspiré des Architecture Decision Records. Le plus récent en haut.

---

## ADR-001 — Gestion d'état : Riverpod

- **Date** : <date>
- **Statut** : Accepté
- **Décideur** : Claude (rôle : mobile-architect / state-management-engineer)
- **Contexte** : Besoin d'une gestion d'état Flutter testable, sûre et scalable pour le projet.
- **Décision** : Utiliser **Riverpod** par défaut.
- **Alternatives écartées** : Bloc (plus verbeux pour un MVP), Provider seul (moins sûr à la
  compilation), setState (ne passe pas à l'échelle), GetX (couplage et magie implicite).
- **Conséquences** : État découplé de `BuildContext`, providers testables, bon support du code
  généré. Courbe d'apprentissage modérée acceptée.
- **Impact** : technique (réversible avec effort).

---

## ADR-000 — Modèle d'enregistrement

- **Date** : <date>
- **Statut** : Accepté
- **Contexte** : Établit le format des décisions. À copier pour chaque nouvelle entrée.
- **Décision** : Utiliser ce gabarit pour toute décision ayant un impact sur l'architecture,
  les dépendances, la sécurité, le coût ou le comportement produit.
- **Conséquences** : Traçabilité complète ; l'utilisateur peut revenir sur tout choix.

---

<!-- Copier ce bloc pour chaque nouvelle décision :

## ADR-NNN — <titre court>

- **Date** :
- **Statut** : Proposé / Accepté / Remplacé par ADR-XXX
- **Décideur** : Claude (rôle : <ex. mobile-architect>)
- **Contexte** :
- **Décision** :
- **Alternatives écartées** :
- **Conséquences** :
- **Impact** : technique / financier / métier / sécurité (et niveau)

-->
