# GitQuest

**Apprends Git. Maîtrise GitHub. Construis ton historique.**

GitQuest est une application Flutter pédagogique, locale et ludique pour apprendre Git en français. Elle combine cours progressifs, exercices corrigés, terminal simulé, visualisation du dépôt et missions validées sur l’état réel d’un dépôt virtuel.

## MVP 1.0

- onboarding et profil local ;
- thème clair, sombre ou système et texte ajustable ;
- tableau de bord responsive avec XP, rang et série ;
- 7 niveaux, 10 leçons structurées et 15 exercices ;
- moteur Git indépendant de l’interface ;
- système de fichiers, index, commits, branches, fusion conflictuelle, stash, remotes, tags, reset, revert, cherry-pick, rebase et reflog virtuels ;
- terminal sécurisé avec aide, suggestions, historique et corrections pédagogiques ;
- visualiseur de fichiers, branches, commits et HEAD ;
- 11 missions à validation d’état et trois niveaux d’indices ;
- 8 badges, aide-mémoire et profil ;
- export/import JSON versionné ;
- stockage local avec `SharedPreferences` ;
- tests du moteur, des sauvegardes et de l’interface principale.

Le terminal ne lance **aucune commande système**. Tout est interprété par `GitCommandEngine` dans un dépôt en mémoire.

## Installation

Prérequis : Flutter stable avec Dart 3.9 ou supérieur.

```bash
flutter pub get
flutter run
```

Choisir explicitement une cible si nécessaire :

```bash
flutter run -d linux
flutter run -d chrome
```

## Vérification

```bash
dart format .
flutter analyze
flutter test
```

## Compilation

```bash
flutter build apk --release
flutter build appbundle --release
flutter build linux --release
flutter build web --release
```

La compilation iOS requiert macOS et Xcode : `flutter build ios --release`.

## Architecture

```text
lib/
├── app/                    # application, portée, shell et thème
├── core/                   # modèles, stockage et widgets partagés
├── data/seed/              # contenus pédagogiques et missions
└── features/
    ├── dashboard/
    ├── learning/
    ├── missions/
    ├── onboarding/
    ├── profile/
    ├── settings/
    └── terminal/
        ├── domain/         # dépôt virtuel et interpréteur testable
        └── presentation/
```

L’état utilisateur est centralisé dans `LocalProgressStore`. Son JSON contient un `formatVersion` afin de préparer les migrations. Le moteur Git ne dépend pas de Flutter et peut être testé isolément.

## Ajouter une leçon

Ajouter un objet `Lesson` dans `lib/data/seed/learning_content.dart`. Une leçon est composée de `LessonBlock` (texte, analogie, commande, conseil ou avertissement) et d’exercices avec explication. Les identifiants doivent rester stables pour préserver la progression.

## Ajouter une mission

Ajouter un objet `Mission` dans `lib/data/seed/missions.dart`. Le validateur reçoit le `VirtualRepository` final : il vérifie l’état attendu, pas une suite exacte de commandes. Plusieurs solutions Git peuvent donc être acceptées.

## Sauvegardes

L’export copie un JSON versionné qui peut être enregistré avec l’extension `.gitquest`. L’import vérifie actuellement `formatVersion: 1` avant de remplacer les données en mémoire et locales.

## Confidentialité

GitQuest ne nécessite ni compte ni backend. Aucune télémétrie ou publicité n’est intégrée. Voir [PRIVACY.md](PRIVACY.md).

## Limites du MVP

- export/import via presse-papiers, sans sélecteur de fichiers natif ;
- rebase conflictuelle avec `--continue`, édition manuelle multi-fichiers et simulation GitHub complète sont prévus après stabilisation ;
- les niveaux 5 à 7 sont visibles mais leur contenu complet sera ajouté progressivement.

## Feuille de route

1. Persistance versionnée des dépôts virtuels et import de fichiers `.gitquest`.
2. Rebase conflictuelle complète et édition visuelle des conflits multi-fichiers.
3. 40 leçons, 25 missions, 3 projets fil rouge et simulation GitHub locale.
4. Statistiques hebdomadaires et rappels locaux facultatifs.

## Licence

MIT — voir [LICENSE](LICENSE).
