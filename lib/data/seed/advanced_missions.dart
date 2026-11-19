import '../../core/models/learning_models.dart';
import '../../features/terminal/domain/virtual_repository.dart';

/// Missions des notions ajoutées au parcours : clone, rm/mv, suivi distant,
/// HEAD détachée, regroupement de commits, push refusé et bisect.
final advancedMissions = <Mission>[
  Mission(
    id: 'clone-start',
    title: 'Rejoindre un projet',
    context:
        'L’équipe t’invite sur un projet existant. Réinitialise le laboratoire, clone le dépôt, puis vérifie d’où il vient.',
    objectives: const [
      'Cloner le dépôt',
      'Vérifier le dépôt distant',
      'Lire l’historique',
    ],
    hints: const [
      'clone crée le dépôt, sa copie de travail et le distant origin.',
      'Après le clonage, git remote -v montre l’adresse d’origine.',
      'Bouton ↺ du terminal → git clone https://github.com/equipe/site.git → git remote -v → git log --oneline',
    ],
    xp: 120,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.remotes.containsKey('origin') &&
          repo.upstreams['main'] == 'origin/main' &&
          repo.commits.isNotEmpty &&
          repo.commandHistory.any(
            (command) => command.startsWith('git clone '),
          ) &&
          repo.commandHistory.contains('git remote -v') &&
          repo.commandHistory.any((command) => command.startsWith('git log'));
    },
  ),
  Mission(
    id: 'tidy-files',
    title: 'Grand ménage',
    context:
        'brouillon.txt n’a plus sa place dans le projet et notes.txt doit devenir NOTES.md. Fais le ménage en gardant un historique propre.',
    objectives: const [
      'Committer brouillon.txt et notes.txt',
      'Supprimer brouillon.txt avec Git',
      'Renommer notes.txt en NOTES.md',
      'Enregistrer le ménage dans un commit',
    ],
    hints: const [
      'git rm supprime le fichier et prépare la suppression en une étape.',
      'git mv renomme le fichier et prépare les deux noms.',
      'echo "x" > brouillon.txt → echo "y" > notes.txt → git add . → git commit -m "Ajoute les notes" → git rm brouillon.txt → git mv notes.txt NOTES.md → git commit -m "chore: range les notes"',
    ],
    xp: 140,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final head = repo.head;
      if (head == null || repo.hasStagedChanges) return false;
      final hadBoth = repo.commits.any(
        (commit) =>
            commit.snapshot.containsKey('brouillon.txt') &&
            commit.snapshot.containsKey('notes.txt'),
      );
      return hadBoth &&
          head.snapshot.containsKey('NOTES.md') &&
          !head.snapshot.containsKey('notes.txt') &&
          !head.snapshot.containsKey('brouillon.txt') &&
          repo.commandHistory.contains('git rm brouillon.txt') &&
          repo.commandHistory.contains('git mv notes.txt NOTES.md');
    },
  ),
  Mission(
    id: 'publish-track',
    title: 'Publier et suivre',
    context:
        'La branche feature/contact est prête à être partagée. Publie-la en mémorisant sa branche distante, puis vérifie le suivi.',
    objectives: const [
      'Configurer le dépôt origin',
      'Créer la branche feature/contact',
      'Y enregistrer un commit',
      'Publier avec suivi',
      'Vérifier avec git branch -vv',
    ],
    hints: const [
      'L’option -u mémorise la branche distante.',
      'git branch -vv affiche la branche suivie entre crochets.',
      'git remote add origin https://example.com/site.git → git switch -c feature/contact → echo "contact" > contact.html → git add . → git commit -m "feat: ajoute le contact" → git push -u origin feature/contact → git branch -vv',
    ],
    xp: 130,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.upstreams['feature/contact'] == 'origin/feature/contact' &&
          repo.commandHistory.contains('git branch -vv');
    },
  ),
  Mission(
    id: 'detached-rescue',
    title: 'Essai à sauver',
    context:
        'Tu explores un ancien commit et tu y fais un essai prometteur. Mets-le à l’abri sur une branche avant de repartir.',
    objectives: const [
      'Disposer d’au moins deux commits',
      'Détacher HEAD sur un ancien commit',
      'Committer un essai',
      'Sauver l’essai sur une branche',
    ],
    hints: const [
      'git switch --detach suivi d’un identifiant place HEAD sur ce commit.',
      'Avant de repartir, crée une branche à l’endroit où tu te trouves.',
      'git log --oneline → git switch --detach <id> → echo "essai" > essai.txt → git add essai.txt → git commit -m "Essai" → git switch -c essai',
    ],
    xp: 160,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      if (repo.isDetached) return false;
      final history = repo.commandHistory;
      final detach = history.lastIndexWhere(
        (command) => command.startsWith('git switch --detach '),
      );
      if (detach < 0) return false;
      final commit = history.indexWhere(
        (command) => command.startsWith('git commit'),
        detach,
      );
      if (commit < 0) return false;
      final saved = history.indexWhere(
        (command) =>
            command.startsWith('git switch -c ') ||
            command.startsWith('git branch '),
        commit,
      );
      if (saved < 0) return false;
      final mainAncestors = _ancestors(repo, repo.branches['main']);
      return repo.branches.entries.any(
        (branch) =>
            branch.key != 'main' &&
            branch.value != null &&
            !mainAncestors.contains(branch.value),
      );
    },
  ),
  Mission(
    id: 'squash-wip',
    title: 'Historique présentable',
    context:
        'Trois commits « wip » encombrent ta branche. Regroupe-les en un seul commit conventionnel avant la revue.',
    objectives: const [
      'Créer trois commits wip',
      'Reculer de trois commits en gardant les changements',
      'Créer un commit unique feat:',
    ],
    hints: const [
      'reset --soft recule la branche en gardant les changements préparés.',
      'HEAD~3 désigne le commit situé trois crans avant HEAD.',
      'git reset --soft HEAD~3 → git commit -m "feat: ajoute le formulaire" → git log --oneline',
    ],
    xp: 170,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final head = repo.head;
      if (head == null || repo.hasStagedChanges) return false;
      final history = repo.commandHistory;
      final reset = history.lastIndexWhere(
        (command) =>
            RegExp(r'^git reset --soft HEAD~([2-9]|\d{2,})$').hasMatch(command),
      );
      if (reset < 0) return false;
      final committed = history.indexWhere(
        (command) => command.startsWith('git commit'),
        reset,
      );
      if (committed < 0) return false;
      final reachable = _ancestors(repo, head.id);
      final hasWip = repo.commits.any(
        (commit) =>
            reachable.contains(commit.id) &&
            commit.message.toLowerCase().startsWith('wip'),
      );
      return !hasWip &&
          RegExp(r'^feat(\(.+\))?:').hasMatch(head.message) &&
          repo.commits.any(
            (commit) => commit.message.toLowerCase().startsWith('wip'),
          );
    },
  ),
  Mission(
    id: 'rejected-push',
    title: 'Push refusé',
    context:
        'Camille a publié un commit sur main pendant que tu travaillais. Ton push est refusé : intègre son travail, puis publie le tien.',
    objectives: const [
      'Publier main avec suivi',
      'Laisser Camille pousser un commit',
      'Créer ton propre commit',
      'Constater le refus du push',
      'Intégrer puis publier',
    ],
    hints: const [
      'Un push est refusé quand le distant contient des commits absents de ta branche.',
      'git pull --rebase origin main rejoue ton commit au-dessus de celui de Camille.',
      'git push -u origin main → gitquest collegue → echo "x" > todo.md → git add . → git commit -m "docs: ajoute la todo" → git push → git pull --rebase origin main → git push',
    ],
    xp: 180,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final main = repo.branches['main'];
      if (main == null || repo.rejectedPushes == 0) return false;
      if (repo.serverBranches['origin/main'] != main) return false;
      final reachable = _ancestors(repo, main);
      final included = repo.commits.where(
        (commit) => reachable.contains(commit.id),
      );
      return included.any((commit) => commit.author.startsWith('Camille')) &&
          repo.head?.author.startsWith('Camille') == false;
    },
  ),
  Mission(
    id: 'find-bug',
    title: 'Chasse au bug',
    context:
        'Un bug s’est glissé dans app.js au fil de plusieurs commits. Retrouve le commit fautif avec git bisect sans tout relire.',
    objectives: const [
      'Préparer le scénario',
      'Lancer la recherche',
      'Marquer un commit bon et un mauvais',
      'Identifier le premier commit fautif',
      'Revenir sur ta branche',
    ],
    hints: const [
      'Le commit actuel est mauvais ; le tag version-saine est bon.',
      'À chaque étape, affiche app.js : s’il contient le mot bug, réponds git bisect bad, sinon git bisect good.',
      'gitquest regression → git bisect start → git bisect bad → git bisect good version-saine → cat app.js → git bisect good ou bad… → git bisect reset',
    ],
    xp: 200,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final culprit = repo.bisectCulprit == null
          ? null
          : repo.commitByReference(repo.bisectCulprit!);
      if (repo.bisect != null || culprit == null) return false;
      final parentId = culprit.parentIds.firstOrNull;
      final parent = parentId == null ? null : repo.commitByReference(parentId);
      bool hasBug(VirtualCommit? commit) =>
          commit?.snapshot['app.js']?.contains('bug') ?? false;
      return hasBug(culprit) && !hasBug(parent);
    },
  ),
];

Set<String> _ancestors(VirtualRepository repo, String? start) {
  final result = <String>{};
  final pending = <String>[?start];
  while (pending.isNotEmpty) {
    final id = pending.removeLast();
    if (!result.add(id)) continue;
    final commit = repo.commitByReference(id);
    if (commit != null) pending.addAll(commit.parentIds);
  }
  return result;
}
