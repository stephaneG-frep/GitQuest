import '../../core/models/learning_models.dart';
import '../../features/terminal/domain/virtual_repository.dart';

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
];

extension LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
