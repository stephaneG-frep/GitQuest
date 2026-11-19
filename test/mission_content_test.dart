import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/models/learning_models.dart';
import 'package:gitquest/data/seed/missions.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';

void main() {
  test('le catalogue propose trente-deux missions cohérentes', () {
    expect(missions, hasLength(32));
    expect(missions.map((mission) => mission.id).toSet(), hasLength(32));
    expect(
      missions.every(
        (mission) => mission.objectives.isNotEmpty && mission.hints.length == 3,
      ),
      isTrue,
    );
  });

  test('valide la mission de mise à l’abri temporaire', () {
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "Base"');
    engine.execute('echo "Travail en cours" > README.md');
    engine.execute('git stash');
    engine.execute('git status');
    engine.execute('git stash pop');

    expect(_mission('temporary-shelter').validator(repository), isTrue);
  });

  test('valide la mission de synchronisation prudente', () {
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "Base"');
    engine.execute('git remote add origin https://example.com/team.git');
    engine.execute('git fetch origin');
    engine.execute('git pull origin main');
    engine.execute('git push origin main');

    expect(_mission('safe-sync').validator(repository), isTrue);
  });

  test('valide un historique conventionnel', () {
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "feat: ajoute le profil"');
    engine.execute('git log --oneline');

    expect(_mission('conventional-history').validator(repository), isTrue);
  });

  test('valide une livraison professionnelle', () {
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "feat: prépare la version majeure"');
    engine.execute('git tag v2.0.0');
    engine.execute('git remote add origin https://example.com/team.git');
    engine.execute('git push origin main');

    expect(_mission('professional-release').validator(repository), isTrue);
  });

  test('valide inspection, restauration et staging sélectif', () {
    final inspected = _baseRepository();
    inspected.$2.execute('echo "Changement" > README.md');
    inspected.$2.execute('git status');
    inspected.$2.execute('git diff');
    expect(_mission('inspect-change').validator(inspected.$1), isTrue);

    inspected.$2.execute('git restore README.md');
    expect(_mission('restore-mistake').validator(inspected.$1), isTrue);

    final selective = _baseRepository();
    selective.$2.execute('touch notes.md');
    selective.$2.execute('touch draft.md');
    selective.$2.execute('git add notes.md');
    selective.$2.execute('git commit -m "Ajoute les notes"');
    expect(_mission('selective-staging').validator(selective.$1), isTrue);
  });

  test('valide fast-forward et annulation de fusion', () {
    final fast = _baseRepository();
    fast.$2.execute('git switch -c feature/fast');
    fast.$2.execute('touch fast.md');
    fast.$2.execute('git add fast.md');
    fast.$2.execute('git commit -m "Ajoute fast"');
    fast.$2.execute('git switch main');
    fast.$2.execute('git merge feature/fast');
    expect(_mission('fast-forward-delivery').validator(fast.$1), isTrue);

    final aborted = _conflictedRepository('feature/abort');
    aborted.$2.execute('git status');
    aborted.$2.execute('git merge --abort');
    expect(_mission('abort-conflict').validator(aborted.$1), isTrue);
  });

  test('valide annulation de rebase et secours par reflog', () {
    final rebase = _baseRepository();
    rebase.$2.execute('git switch -c feature/rebase-abort');
    rebase.$2.execute('echo "Feature" > README.md');
    rebase.$2.execute('git add README.md');
    rebase.$2.execute('git commit -m "Feature"');
    rebase.$2.execute('git switch main');
    rebase.$2.execute('echo "Main" > README.md');
    rebase.$2.execute('git add README.md');
    rebase.$2.execute('git commit -m "Main"');
    rebase.$2.execute('git switch feature/rebase-abort');
    rebase.$2.execute('git rebase main');
    rebase.$2.execute('git rebase --abort');
    expect(_mission('abort-rebase').validator(rebase.$1), isTrue);

    final rescue = _baseRepository();
    rescue.$2.execute('touch second.md');
    rescue.$2.execute('git add second.md');
    rescue.$2.execute('git commit -m "Second"');
    rescue.$2.execute('git reset --soft HEAD~1');
    rescue.$2.execute('git status');
    rescue.$2.execute('git reflog');
    expect(_mission('reflog-rescue').validator(rescue.$1), isTrue);
  });

  test('valide correctif, travail garé et passage de relais', () {
    final patch = _baseRepository();
    patch.$2.execute('echo "Correction" > README.md');
    patch.$2.execute('git add README.md');
    patch.$2.execute('git commit -m "fix: corrige la production"');
    patch.$2.execute('git tag v2.0.1');
    expect(_mission('patch-release').validator(patch.$1), isTrue);

    final parked = _baseRepository();
    parked.$2.execute('echo "À finir" > README.md');
    parked.$2.execute('git stash');
    parked.$2.execute('git status');
    expect(_mission('park-unfinished-work').validator(parked.$1), isTrue);

    final clean = _baseRepository();
    clean.$2.execute('echo "Guide" > README.md');
    clean.$2.execute('git add README.md');
    clean.$2.execute('git commit -m "docs: améliore le guide"');
    clean.$2.execute('git status');
    expect(_mission('clean-handoff').validator(clean.$1), isTrue);
  });
}

Mission _mission(String id) =>
    missions.firstWhere((mission) => mission.id == id);

(VirtualRepository, GitCommandEngine) _baseRepository() {
  final repository = VirtualRepository();
  final engine = GitCommandEngine(repository);
  engine.execute('git init');
  engine.execute('git add .');
  engine.execute('git commit -m "Base"');
  return (repository, engine);
}

(VirtualRepository, GitCommandEngine) _conflictedRepository(String branch) {
  final result = _baseRepository();
  result.$2.execute('git switch -c $branch');
  result.$2.execute('echo "Feature" > README.md');
  result.$2.execute('git add README.md');
  result.$2.execute('git commit -m "Feature"');
  result.$2.execute('git switch main');
  result.$2.execute('echo "Main" > README.md');
  result.$2.execute('git add README.md');
  result.$2.execute('git commit -m "Main"');
  result.$2.execute('git merge $branch');
  return result;
}
