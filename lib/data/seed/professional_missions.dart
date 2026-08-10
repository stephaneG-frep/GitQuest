import '../../core/models/learning_models.dart';
import '../../features/terminal/domain/virtual_repository.dart';

final professionalMissions = <Mission>[
  Mission(
    id: 'inspect-change',
    title: 'Relecture avant commit',
    context:
        'Une modification vient d’être faite. Inspecte son état et son contenu exact avant de la préparer.',
    objectives: const [
      'Modifier un fichier',
      'Observer son état',
      'Afficher les différences',
    ],
    hints: const [
      'Commence par la commande d’observation générale.',
      'La commande diff montre le contenu modifié.',
      'echo "Nouvelle version" > README.md → git status → git diff',
    ],
    xp: 100,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.files.values.any(
            (file) => file.state == FileState.modified,
          ) &&
          repo.commandHistory.contains('git status') &&
          repo.commandHistory.contains('git diff');
    },
  ),
  Mission(
    id: 'restore-mistake',
    title: 'Fausse manipulation',
    context:
        'README.md a été modifié par erreur. Restaure uniquement ce fichier depuis le dernier commit sans déplacer HEAD.',
    objectives: const [
      'Disposer d’une version committée',
      'Modifier README.md',
      'Restaurer sa dernière version',
    ],
    hints: const [
      'La commande recherchée agit sur un chemin précis.',
      'Utilise git restore avec le nom du fichier.',
      'echo "Erreur" > README.md → git diff → git restore README.md',
    ],
    xp: 130,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final file = repo.files['README.md'];
      return repo.head != null &&
          file != null &&
          file.state == FileState.committed &&
          file.content == repo.head!.snapshot['README.md'] &&
          repo.commandHistory.contains('git restore README.md');
    },
  ),
  Mission(
    id: 'selective-staging',
    title: 'Commit vraiment atomique',
    context:
        'notes.md est prêt, mais draft.md ne l’est pas. Enregistre uniquement les notes et laisse le brouillon hors du commit.',
    objectives: const [
      'Créer notes.md et draft.md',
      'Préparer uniquement notes.md',
      'Créer le commit ciblé',
      'Garder draft.md hors du snapshot',
    ],
    hints: const [
      'N’utilise pas git add . dans cette mission.',
      'Donne explicitement notes.md à git add.',
      'touch notes.md → touch draft.md → git add notes.md → git commit -m "Ajoute les notes"',
    ],
    xp: 170,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.head?.snapshot.containsKey('notes.md') == true &&
          repo.files.containsKey('draft.md') &&
          repo.head?.snapshot.containsKey('draft.md') == false;
    },
  ),
  Mission(
    id: 'fast-forward-delivery',
    title: 'Fusion en avance rapide',
    context:
        'main n’a pas bougé. Intègre feature/fast sans créer de commit de fusion inutile.',
    objectives: const [
      'Créer feature/fast',
      'Y enregistrer un changement',
      'Revenir sur main',
      'Fusionner en fast-forward',
    ],
    hints: const [
      'Ne crée aucun nouveau commit sur main entre-temps.',
      'La cible doit être un ancêtre direct de la source.',
      'git switch -c feature/fast → touch fast.md → git add . → git commit -m "Ajoute fast" → git switch main → git merge feature/fast',
    ],
    xp: 190,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.currentBranch == 'main' &&
          repo.mergedBranches.contains('feature/fast') &&
          repo.reflog.any(
            (entry) => entry.contains('merge feature/fast: fast-forward'),
          );
    },
  ),
  Mission(
    id: 'abort-conflict',
    title: 'Repli après conflit',
    context:
        'Une fusion révèle un conflit complexe. Annule proprement l’opération pour retrouver main intacte.',
    objectives: const [
      'Provoquer un conflit',
      'Examiner son état',
      'Annuler la fusion',
      'Retrouver une copie sans conflit',
    ],
    hints: const [
      'Les branches doivent modifier différemment le même fichier.',
      'Une fusion en cours peut être annulée sans choisir de version.',
      'Après le conflit : git status → git merge --abort',
    ],
    xp: 210,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.reflog.any(
            (entry) => entry.contains('merge') && entry.contains('conflit'),
          ) &&
          repo.commandHistory.contains('git merge --abort') &&
          repo.pendingMergeBranch == null &&
          repo.conflicts.isEmpty;
    },
  ),
  Mission(
    id: 'abort-rebase',
    title: 'Rebase sans issue',
    context:
        'Le rebase provoque un conflit inattendu. Reviens exactement à l’état qui précédait l’opération.',
    objectives: const [
      'Créer des changements divergents',
      'Lancer le rebase',
      'Constater le conflit',
      'Annuler le rebase',
    ],
    hints: const [
      'Modifie le même fichier sur main et sur ta branche.',
      'La commande d’annulation restaure branche et fichiers.',
      'Après git rebase main : git status → git rebase --abort',
    ],
    xp: 230,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.reflog.any((entry) => entry.contains('rebase: conflit')) &&
          repo.reflog.any((entry) => entry.contains('rebase: abort')) &&
          repo.pendingRebase == null &&
          repo.conflicts.isEmpty;
    },
  ),
  Mission(
    id: 'reflog-rescue',
    title: 'Le filet de sécurité',
    context:
        'Déplace HEAD avec un reset doux, vérifie que le changement reste préparé et retrouve le mouvement dans le reflog.',
    objectives: const [
      'Créer au moins deux commits',
      'Effectuer reset --soft HEAD~1',
      'Conserver l’index',
      'Consulter le reflog',
    ],
    hints: const [
      'Le mode soft ne vide pas l’index.',
      'Le journal local des références conserve le mouvement.',
      'git reset --soft HEAD~1 → git status → git reflog',
    ],
    xp: 200,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.stagedFiles.isNotEmpty &&
          repo.reflog.any((entry) => entry.contains('reset: moving')) &&
          repo.commandHistory.contains('git reflog');
    },
  ),
  Mission(
    id: 'patch-release',
    title: 'Correctif de production',
    context:
        'Un bug est corrigé. Termine par un commit fix: puis marque la version corrective v2.0.1.',
    objectives: const [
      'Créer un changement correctif',
      'Utiliser un message fix:',
      'Créer le tag v2.0.1 sur HEAD',
    ],
    hints: const [
      'Une correction compatible augmente le dernier nombre SemVer.',
      'Pose le tag seulement après le commit final.',
      'git commit -m "fix: corrige le problème" → git tag v2.0.1 → git tag',
    ],
    xp: 190,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      final head = repo.head;
      return head != null &&
          head.message.startsWith('fix: ') &&
          repo.tags['v2.0.1'] == head.id;
    },
  ),
  Mission(
    id: 'park-unfinished-work',
    title: 'Travail garé',
    context:
        'Une urgence arrive. Range le changement dans un stash et laisse une copie propre pour la personne suivante.',
    objectives: const [
      'Modifier un fichier suivi',
      'Créer un stash',
      'Vérifier la copie propre',
      'Conserver le stash',
    ],
    hints: const [
      'Cette fois, ne restaure pas immédiatement le stash.',
      'Après git stash, confirme l’état avec git status.',
      'echo "À finir" > README.md → git stash → git status',
    ],
    xp: 150,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.stashes.isNotEmpty &&
          repo.files.values.every((file) => file.state != FileState.modified) &&
          repo.commandHistory.lastOrNull == 'git status';
    },
  ),
  Mission(
    id: 'clean-handoff',
    title: 'Passage de relais propre',
    context:
        'Termine ta session avec un commit de documentation précis, aucun changement en attente et un statut vérifié.',
    objectives: const [
      'Modifier la documentation',
      'Créer un commit docs:',
      'Laisser une copie propre',
      'Terminer par git status',
    ],
    hints: const [
      'Le préfixe indique la nature documentaire.',
      'Après le commit, aucun fichier ne doit rester en attente.',
      'git add . → git commit -m "docs: améliore le guide" → git status',
    ],
    xp: 180,
    validator: (dynamic value) {
      final repo = value as VirtualRepository;
      return repo.head?.message.startsWith('docs: ') == true &&
          repo.stagedFiles.isEmpty &&
          repo.files.values.every(
            (file) => file.state == FileState.committed,
          ) &&
          repo.commandHistory.lastOrNull == 'git status';
    },
  ),
];

extension _LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
