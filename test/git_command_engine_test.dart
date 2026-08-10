import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';

void main() {
  group('GitCommandEngine', () {
    late VirtualRepository repository;
    late GitCommandEngine engine;

    setUp(() {
      repository = VirtualRepository();
      engine = GitCommandEngine(repository);
    });

    test('initialise, prépare et crée un commit', () {
      expect(engine.execute('git init').isSuccess, isTrue);
      expect(repository.initialized, isTrue);
      expect(engine.execute('git add README.md').isSuccess, isTrue);
      final result = engine.execute('git commit -m "Premier commit"');
      expect(result.isSuccess, isTrue);
      expect(repository.commits.single.message, 'Premier commit');
      expect(repository.stagedFiles, isEmpty);
    });

    test('explique les fautes de frappe courantes', () {
      final result = engine.execute('git comit');
      expect(result.isSuccess, isFalse);
      expect(result.text, contains('git commit'));
    });

    test('crée, active puis fusionne une branche', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Base"');
      engine.execute('git switch -c feature/profile');
      engine.execute('touch profile.md');
      engine.execute('git add .');
      engine.execute('git commit -m "Profil"');
      engine.execute('git switch main');
      final result = engine.execute('git merge feature/profile');
      expect(result.isSuccess, isTrue);
      expect(repository.mergedBranches, contains('feature/profile'));
      expect(repository.currentBranch, 'main');
    });

    test('refuse un commit sans staging', () {
      engine.execute('git init');
      final result = engine.execute('git commit -m "Vide"');
      expect(result.isSuccess, isFalse);
      expect(result.text, contains('git add'));
    });

    test('compte les réussites, erreurs et corrections', () {
      engine.execute('git init');
      expect(engine.execute('git add').isSuccess, isFalse);
      expect(engine.execute('git add README.md').isSuccess, isTrue);

      expect(repository.commandHistory, hasLength(3));
      expect(repository.successfulCommands, 2);
      expect(repository.commandErrors, 1);
      expect(repository.correctedErrors, 1);
      expect(repository.dailyCommands.values.single, 3);
    });

    test('remplace le dernier commit avec amend', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Message vague"');
      final previousId = repository.head!.id;

      final result = engine.execute('git commit --amend -m "Ajoute le README"');

      expect(result.isSuccess, isTrue);
      expect(repository.commits, hasLength(1));
      expect(repository.head!.message, 'Ajoute le README');
      expect(repository.head!.id, isNot(previousId));
    });

    test('reset soft déplace HEAD et conserve les fichiers préparés', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Base"');
      engine.execute('touch notes.txt');
      engine.execute('git add .');
      engine.execute('git commit -m "Notes"');

      final result = engine.execute('git reset --soft HEAD~1');

      expect(result.isSuccess, isTrue);
      expect(repository.head!.message, 'Base');
      expect(repository.stagedFiles, isNotEmpty);
    });

    test('revert ajoute un commit sans supprimer l’historique', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Base"');
      final before = repository.commits.length;

      final result = engine.execute('git revert HEAD');

      expect(result.isSuccess, isTrue);
      expect(repository.commits, hasLength(before + 1));
      expect(repository.head!.message, startsWith('Annule'));
    });

    test('crée et liste un tag', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Version stable"');
      expect(engine.execute('git tag v1.0.0').isSuccess, isTrue);
      expect(repository.tags['v1.0.0'], repository.head!.id);
      expect(engine.execute('git tag').text, contains('v1.0.0'));
    });

    test('détecte puis termine un conflit de fusion', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Base"');
      engine.execute('git switch -c feature/theme');
      engine.execute('echo "Version feature" > README.md');
      engine.execute('git add .');
      engine.execute('git commit -m "Thème feature"');
      engine.execute('git switch main');
      engine.execute('echo "Version main" > README.md');
      engine.execute('git add .');
      engine.execute('git commit -m "Thème main"');

      final merge = engine.execute('git merge feature/theme');
      expect(merge.type, TerminalOutputType.warning);
      expect(repository.conflicts, contains('README.md'));
      expect(repository.files['README.md']!.state, FileState.conflicted);
      expect(
        engine.execute('git status').text,
        contains('Chemins non fusionnés'),
      );

      engine.execute('git checkout --theirs README.md');
      engine.execute('git add README.md');
      final commit = engine.execute('git commit -m "Résout le conflit"');
      expect(commit.isSuccess, isTrue);
      expect(repository.conflicts, isEmpty);
      expect(repository.pendingMergeBranch, isNull);
      expect(repository.head!.parentIds, hasLength(2));
      expect(repository.files['README.md']!.content, 'Version feature');
    });

    test('cherry-pick rejoue un changement ciblé', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Base"');
      engine.execute('git switch -c feature/notes');
      engine.execute('touch notes.md');
      engine.execute('git add .');
      engine.execute('git commit -m "Ajoute les notes"');
      final pickedId = repository.head!.id;
      engine.execute('git switch main');

      final result = engine.execute('git cherry-pick $pickedId');

      expect(result.isSuccess, isTrue);
      expect(repository.files, contains('notes.md'));
      expect(repository.head!.message, 'Ajoute les notes');
      expect(repository.reflog.last, contains('cherry-pick'));
    });

    test('rebase rejoue une branche propre sur main', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "Base"');
      engine.execute('git switch -c feature/docs');
      engine.execute('touch docs.md');
      engine.execute('git add .');
      engine.execute('git commit -m "Ajoute la documentation"');
      engine.execute('git switch main');
      engine.execute('touch main.md');
      engine.execute('git add .');
      engine.execute('git commit -m "Évolue main"');
      final mainHead = repository.head!.id;
      engine.execute('git switch feature/docs');

      final result = engine.execute('git rebase main');

      expect(result.isSuccess, isTrue);
      expect(repository.files, contains('docs.md'));
      expect(repository.files, contains('main.md'));
      expect(repository.head!.parentIds, contains(mainHead));
      expect(repository.reflog.last, contains('rebase'));
    });
  });
}
