# GitQuest

**Apprends Git. Maîtrise GitHub. Construis ton historique.**

GitQuest est une application Flutter pédagogique, locale et ludique pour apprendre Git en français. Elle combine cours progressifs, exercices corrigés, terminal simulé, visualisation du dépôt et missions validées sur l’état réel d’un dépôt virtuel.

## MVP 1.0

- onboarding et profil local ;
- thème clair, sombre ou système et texte ajustable ;
- tableau de bord responsive avec XP, rang et série ;
- 8 niveaux, 58 leçons structurées et 116 exercices ;
- moteur Git indépendant de l’interface ;
- système de fichiers, index, commits, branches, fusions et rebases conflictuels, stash, remotes, tags, reset, revert, cherry-pick et reflog virtuels ;
- clone simulé, `git rm` / `git mv`, HEAD détachée, suivi des branches distantes (`push -u`, `branch -vv`) et `log --graph --all` ;
- dépôt distant simulé : avance et retard, push refusé, `pull --rebase`, `--force-with-lease`, `git bisect`, et scénarios d’entraînement `gitquest collegue` et `gitquest regression` ;
- terminal sécurisé avec aide, suggestions, historique et corrections pédagogiques ;
- visualiseur de fichiers, branches, commits et HEAD ;
- 32 missions à validation d’état et trois niveaux d’indices ;
- GitHub Lab local avec dépôt distant, issues, pull requests, revues, commentaires et releases ;
- protection de `main` et pipeline CI simulé avec analyse, tests et compilation ;
- fusion des pull requests connectée au véritable moteur Git virtuel ;
- 4 projets fil rouge connectant le terminal, le dépôt virtuel et GitHub Lab, dont la publication d’un site GitHub Pages ;
- assistant de commandes, aide-mémoire filtrable et glossaire de 40 notions (41 situations de commandes) ;
- statistiques locales avec activité sur sept jours, progression par thème et commandes favorites ;
- recherche globale dans les leçons, missions, projets, commandes, définitions et erreurs fréquentes ;
- 13 badges, aide-mémoire et profil ;
- export/import complet dans un fichier `.gitquest` versionné avec aperçu et fusion ;
- stockage local avec `SharedPreferences` ;
- rappel quotidien facultatif, planifié localement à l’heure choisie ;
- mode d’emploi intégré avec démarrage rapide et guide de chaque espace ;
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
    ├── projects/               # projets fil rouge et validation réelle
    ├── search/                 # recherche globale et historique local
    ├── settings/
    ├── statistics/             # progression et activité locale
    ├── tools/                  # assistant, commandes et glossaire
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

L’export crée un fichier `.gitquest` versionné contenant le profil, le dépôt virtuel, GitHub Lab et les projets. L’import affiche un aperçu, propose la fusion ou le remplacement et conserve automatiquement un point de retour. Les anciens exports `formatVersion: 1` restent acceptés.

## Confidentialité

GitQuest ne nécessite ni compte ni backend. Aucune télémétrie ou publicité n’est intégrée. Voir [PRIVACY.md](PRIVACY.md).

## Feuille de route

Les objectifs initiaux — 40 leçons, 25 missions et rappels locaux facultatifs — sont réalisés. Les prochaines versions pourront enrichir le contenu sans modifier les fondations hors connexion.

## Licence

MIT — voir [LICENSE](LICENSE).
