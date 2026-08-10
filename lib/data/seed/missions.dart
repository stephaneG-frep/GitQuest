import '../../core/models/learning_models.dart';
import '../../features/terminal/domain/virtual_repository.dart';
import 'professional_missions.dart';

final missions = <Mission>[
  Mission(
    id: 'first-repo',
    title: 'Premier dépôt',
    context:
        'Le portfolio de Lina existe déjà, mais son histoire n’a pas encore commencé. Transforme le dossier en dépôt et crée sa première étape.',
    objectives: const [
      'Initialiser le dépôt',
      'Préparer les fichiers',
      'Créer un premier commit',
      'Afficher l’historique',
    ],
    hints: const [
      'Commence par transformer le dossier courant en dépôt Git.',
      'Utilise git init, puis observe avec git status.',
      'git init → git add . → git commit -m "Premier commit" → git log',
    ],
    xp: 120,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.initialized &&
          repo.commits.isNotEmpty &&
          repo.commandHistory.any((command) => command.startsWith('git log'));
    },
  ),
  Mission(
    id: 'forgotten-file',
    title: 'Fichier oublié',
    context:
        'README.md attend encore dans la copie de travail. Ajoute-le proprement à l’historique.',
    objectives: const [
      'Examiner le statut',
      'Ajouter README.md',
      'Créer un commit',
    ],
    hints: const [
      'La zone de préparation reçoit les fichiers choisis.',
      'Utilise git add avec le nom du fichier.',
      'git status → git add README.md → git commit -m "Ajoute le README"',
    ],
    xp: 100,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.commits.any(
            (commit) => commit.snapshot.containsKey('README.md'),
          ) &&
          repo.commandHistory.any((command) => command == 'git status');
    },
  ),
  Mission(
    id: 'bad-message',
    title: 'Mauvais message de commit',
    context:
        'Le dernier commit porte un message trop vague. Remplace-le sans ajouter un commit inutile.',
    objectives: const [
      'Examiner le dernier commit',
      'Modifier son message avec amend',
      'Vérifier le nouvel historique',
    ],
    hints: const [
      'Le dernier commit peut être remplacé tant qu’il n’a pas été partagé.',
      'Utilise l’option --amend de git commit.',
      'git commit --amend -m "Décrit clairement le changement" → git log --oneline',
    ],
    xp: 120,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.reflog.any((entry) => entry.contains('commit (amend)')) &&
          repo.commandHistory.any((command) => command.startsWith('git log'));
    },
  ),
  Mission(
    id: 'feature-branch',
    title: 'Nouvelle fonctionnalité',
    context:
        'Une page profil doit être développée à l’écart de main puis intégrée quand elle est prête.',
    objectives: const [
      'Créer feature/profile',
      'Changer de branche',
      'Créer un commit',
      'Revenir sur main',
      'Fusionner la branche',
    ],
    hints: const [
      'Une branche isole ton nouveau travail.',
      'Crée-la avec git switch -c.',
      'git switch -c feature/profile → touch profile.md → git add . → git commit -m "Ajoute le profil" → git switch main → git merge feature/profile',
    ],
    xp: 180,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.branches.containsKey('feature/profile') &&
          repo.currentBranch == 'main' &&
          repo.mergedBranches.contains('feature/profile');
    },
  ),
  Mission(
    id: 'merge-conflict',
    title: 'Conflit de fusion',
    context:
        'Deux branches ont modifié différemment README.md. Provoque la fusion, choisis le contenu final et termine proprement le merge.',
    objectives: const [
      'Créer deux modifications divergentes de README.md',
      'Lancer la fusion et examiner le conflit',
      'Choisir --ours ou --theirs',
      'Ajouter le fichier résolu et terminer le commit',
    ],
    hints: const [
      'Un conflit apparaît lorsque les deux branches changent la même zone depuis leur ancêtre commun.',
      'Après git merge, utilise git checkout --ours ou --theirs sur le fichier.',
      'git checkout --theirs README.md → git add README.md → git commit -m "Résout le conflit"',
    ],
    xp: 220,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.conflicts.isEmpty &&
          repo.reflog.any(
            (entry) => entry.contains('merge') && entry.contains('conflit'),
          ) &&
          repo.commits.any((commit) => commit.parentIds.length == 2);
    },
  ),
  Mission(
    id: 'clean-staging',
    title: 'Le bon contenu',
    context:
        'Le staging doit contenir uniquement ce que tu veux photographier. Prépare au moins un fichier et vérifie le résultat.',
    objectives: const [
      'Initialiser si nécessaire',
      'Préparer un fichier',
      'Vérifier avec git status',
    ],
    hints: const [
      'L’index est la zone intermédiaire avant le commit.',
      'Utilise git add README.md.',
      'git init → git add README.md → git status',
    ],
    xp: 80,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.stagedFiles.isNotEmpty &&
          repo.commandHistory.lastOrNull == 'git status';
    },
  ),
  Mission(
    id: 'remote-repo',
    title: 'Dépôt distant',
    context:
        'L’équipe t’a transmis une URL. Configure origin, vérifie-la et simule l’envoi de main.',
    objectives: const [
      'Ajouter origin',
      'Lister les remotes',
      'Pousser la branche main',
    ],
    hints: const [
      'Un remote relie un nom local à une URL.',
      'Utilise git remote add origin URL.',
      'git remote add origin https://example.com/team.git → git remote -v → git push -u origin main',
    ],
    xp: 150,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.remotes.containsKey('origin') &&
          repo.commandHistory.any((command) => command.startsWith('git push'));
    },
  ),
  Mission(
    id: 'unwanted-commit',
    title: 'Commit indésirable',
    context:
        'Un commit déjà partagé introduit un problème. Annule-le sans réécrire l’historique de l’équipe.',
    objectives: const [
      'Identifier le commit courant',
      'Créer un commit d’annulation avec revert',
      'Conserver l’historique existant',
    ],
    hints: const [
      'Sur un historique partagé, ajoute une annulation plutôt que de déplacer HEAD.',
      'La commande recherchée est git revert.',
      'git log --oneline → git revert HEAD',
    ],
    xp: 160,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.commandHistory.any(
            (command) => command == 'git revert HEAD',
          ) &&
          repo.commits.any((commit) => commit.message.startsWith('Annule'));
    },
  ),
  Mission(
    id: 'prepare-release',
    title: 'Préparer une version',
    context:
        'La première version stable est prête. Marque précisément le commit livré avec un numéro sémantique.',
    objectives: const [
      'Créer le tag v1.0.0',
      'Afficher la liste des tags',
      'Vérifier le commit associé',
    ],
    hints: const [
      'Un tag donne un nom durable à un commit important.',
      'Utilise git tag suivi du numéro de version.',
      'git tag v1.0.0 → git tag',
    ],
    xp: 130,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.tags.containsKey('v1.0.0') &&
          repo.commandHistory
              .where((command) => command == 'git tag')
              .isNotEmpty;
    },
  ),
  Mission(
    id: 'targeted-change',
    title: 'Récupération ciblée',
    context:
        'Un correctif utile existe sur une autre branche, mais tu ne veux pas tout fusionner. Rejoue uniquement son commit.',
    objectives: const [
      'Identifier l’identifiant du correctif',
      'Revenir sur la branche destinataire',
      'Appliquer le commit avec cherry-pick',
    ],
    hints: const [
      'Chaque commit peut être désigné par son identifiant court.',
      'Utilise git cherry-pick suivi de l’identifiant.',
      'git log --oneline → git cherry-pick identifiant',
    ],
    xp: 180,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.reflog.any((entry) => entry.contains('cherry-pick'));
    },
  ),
  Mission(
    id: 'linear-history',
    title: 'Historique linéaire',
    context:
        'Ta branche locale doit repartir du dernier commit de main. Rejoue tes commits au-dessus sans créer de commit de fusion.',
    objectives: const [
      'Conserver une copie de travail propre',
      'Lancer git rebase main depuis ta branche',
      'Vérifier les nouveaux identifiants dans le reflog',
    ],
    hints: const [
      'Le rebase déplace la base et recrée les commits : leurs identifiants changent.',
      'Place-toi sur ta branche, puis utilise git rebase.',
      'git switch ta-branche → git rebase main → git reflog',
    ],
    xp: 240,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.reflog.any((entry) => entry.contains('rebase: onto main'));
    },
  ),
  Mission(
    id: 'temporary-shelter',
    title: 'Interruption urgente',
    context:
        'Tu dois changer de tâche alors que README.md contient un travail inachevé. Mets-le temporairement à l’abri, puis restaure-le sans créer de commit parasite.',
    objectives: const [
      'Modifier un fichier déjà suivi',
      'Mettre les changements de côté avec stash',
      'Retrouver une copie de travail propre',
      'Restaurer les changements avec stash pop',
    ],
    hints: const [
      'Le stash range provisoirement les modifications suivies.',
      'Après la mise de côté, la liste des stash contient ton travail.',
      'echo "Travail en cours" > README.md → git stash → git status → git stash pop',
    ],
    xp: 160,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.commandHistory.any((command) => command == 'git stash') &&
          repo.commandHistory.any((command) => command == 'git stash pop') &&
          repo.stashes.isEmpty &&
          repo.files.values.any((file) => file.state == FileState.modified);
    },
  ),
  Mission(
    id: 'safe-sync',
    title: 'Synchronisation prudente',
    context:
        'Avant d’envoyer ton travail, inspecte les changements distants, intègre-les puis publie ta branche dans le laboratoire hors connexion.',
    objectives: const [
      'Configurer le dépôt origin',
      'Récupérer les références avec fetch',
      'Intégrer les changements avec pull',
      'Publier la branche avec push',
    ],
    hints: const [
      'fetch observe le distant sans intégrer ses changements.',
      'pull récupère puis intègre ; push publie les commits locaux.',
      'git remote add origin URL → git fetch origin → git pull origin main → git push origin main',
    ],
    xp: 190,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.remotes.containsKey('origin') &&
          repo.commandHistory.any(
            (command) => command.startsWith('git fetch'),
          ) &&
          repo.commandHistory.any(
            (command) => command.startsWith('git pull'),
          ) &&
          repo.commandHistory.any((command) => command.startsWith('git push'));
    },
  ),
  Mission(
    id: 'conventional-history',
    title: 'Historique automatisable',
    context:
        'L’équipe prépare ses notes de version automatiquement. Crée un commit dont le message indique clairement la nature du changement.',
    objectives: const [
      'Préparer au moins un changement',
      'Créer un commit avec un préfixe conventionnel',
      'Vérifier le message dans l’historique compact',
    ],
    hints: const [
      'Les préfixes usuels sont feat, fix, docs, test et refactor.',
      'Le préfixe est suivi de deux-points puis d’une description précise.',
      'git add . → git commit -m "feat: ajoute une fonctionnalité" → git log --oneline',
    ],
    xp: 170,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final conventional = RegExp(r'^(feat|fix|docs|test|refactor): .+');
      return repo.commits.any(
            (commit) => conventional.hasMatch(commit.message),
          ) &&
          repo.commandHistory.any((command) => command == 'git log --oneline');
    },
  ),
  Mission(
    id: 'professional-release',
    title: 'Livraison professionnelle',
    context:
        'Une évolution validée doit devenir la version 2.0.0. Marque exactement le commit conventionnel livré et simule sa publication sur origin.',
    objectives: const [
      'Terminer par un commit conventionnel',
      'Créer le tag v2.0.0 sur HEAD',
      'Configurer origin si nécessaire',
      'Simuler la publication avec push',
    ],
    hints: const [
      'Le tag est attaché au commit qui est HEAD au moment de sa création.',
      'Vérifie que le dernier message commence par feat: ou fix: avant de poser le tag.',
      'git commit -m "feat: prépare la version majeure" → git tag v2.0.0 → git push origin main',
    ],
    xp: 260,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final head = repo.head;
      return head != null &&
          RegExp(r'^(feat|fix): .+').hasMatch(head.message) &&
          repo.tags['v2.0.0'] == head.id &&
          repo.remotes.containsKey('origin') &&
          repo.commandHistory.any((command) => command.startsWith('git push'));
    },
  ),
  ...professionalMissions,
];

extension LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
