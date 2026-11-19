import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/data/seed/missions.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';

/// Dépôt distant simulé, bisect et scénarios du laboratoire.
void main() {
  late VirtualRepository repository;
  late GitCommandEngine engine;

  setUp(() {
    repository = VirtualRepository();
    engine = GitCommandEngine(repository);
  });

  void run(List<String> commands) {
    for (final command in commands) {
      engine.execute(command);
    }
  }

  void commitFile(String path, String content, String message) => run([
    'echo "$content" > $path',
    'git add $path',
    'git commit -m "$message"',
  ]);

  /// Dépôt publié sur origin/main avec un premier commit.
  void published() {
    run([
      'git init',
      'git add .',
      'git commit -m "Base"',
      'git remote add origin https://example.com/site.git',
      'git push -u origin main',
    ]);
  }

  bool validates(String id) =>
      missions.singleWhere((mission) => mission.id == id).validator(repository);

  group('push', () {
    test('publie une nouvelle branche et met à jour origin/main', () {
      published();
      expect(repository.serverBranches['origin/main'], repository.head!.id);
      expect(repository.remoteBranches['origin/main'], repository.head!.id);
      expect(engine.execute('git status').text, contains('elle est à jour'));
    });

    test('sans suivi ni argument, indique la commande à utiliser', () {
      run([
        'git init',
        'git add .',
        'git commit -m "Base"',
        'git remote add origin https://example.com/site.git',
      ]);
      final result = engine.execute('git push');
      expect(result.isSuccess, isFalse);
      expect(result.text, contains('git push -u origin main'));
    });

    test('refuse une branche vide', () {
      run(['git init', 'git remote add origin https://example.com/site.git']);
      expect(engine.execute('git push -u origin main').isSuccess, isFalse);
      expect(repository.upstreams, isEmpty);
    });

    test('affiche l’avance puis publie avec git push', () {
      published();
      commitFile('a.txt', 'A', 'a');
      commitFile('b.txt', 'B', 'b');
      expect(
        engine.execute('git status').text,
        contains('en avance de 2 commits'),
      );
      expect(
        engine.execute('git branch -vv').text,
        contains('[origin/main: ahead 2]'),
      );
      expect(engine.execute('git push').isSuccess, isTrue);
      expect(engine.execute('git status').text, contains('elle est à jour'));
    });
  });

  group('travail d’une collègue', () {
    test('reste invisible jusqu’au fetch, puis apparaît en retard', () {
      published();
      final result = engine.execute('gitquest collegue');
      expect(result.isSuccess, isTrue);
      expect(engine.execute('git status').text, contains('elle est à jour'));

      expect(engine.execute('git fetch').text, contains('origin/main'));
      expect(
        engine.execute('git status').text,
        contains('en retard de 1 commit'),
      );
      expect(engine.execute('git branch -vv').text, contains('behind 1'));
      expect(repository.files.containsKey('NOTES-equipe.md'), isFalse);
    });

    test('exige une branche déjà publiée', () {
      run([
        'git init',
        'git add .',
        'git commit -m "Base"',
        'git remote add origin https://example.com/site.git',
      ]);
      expect(engine.execute('gitquest collegue').isSuccess, isFalse);
    });

    test('un push divergent est refusé puis réussit après pull --rebase', () {
      published();
      run(['gitquest collegue']);
      commitFile('todo.md', 'x', 'docs: ajoute la todo');

      final rejected = engine.execute('git push');
      expect(rejected.isSuccess, isFalse);
      expect(rejected.text, contains('non fast-forward'));
      expect(repository.rejectedPushes, 1);

      final pulled = engine.execute('git pull --rebase origin main');
      expect(pulled.isSuccess, isTrue, reason: pulled.text);
      expect(repository.files.containsKey('NOTES-equipe.md'), isTrue);
      expect(repository.head!.message, 'docs: ajoute la todo');
      expect(
        repository.head!.parentIds.single,
        repository.remoteBranches['origin/main'],
      );

      expect(engine.execute('git push').isSuccess, isTrue);
      expect(repository.serverBranches['origin/main'], repository.head!.id);
    });

    test('git pull sans --rebase crée un commit de fusion', () {
      published();
      run(['gitquest collegue']);
      commitFile('todo.md', 'x', 'docs: ajoute la todo');

      expect(engine.execute('git pull').isSuccess, isTrue);

      expect(repository.head!.parentIds, hasLength(2));
      expect(repository.files.containsKey('NOTES-equipe.md'), isTrue);
      expect(engine.execute('git status').text, contains('en avance de'));
    });

    test('git pull avance simplement une branche en retard', () {
      published();
      run(['gitquest collegue']);
      expect(engine.execute('git pull').isSuccess, isTrue);
      expect(repository.head!.author, startsWith('Camille'));
      expect(engine.execute('git status').text, contains('elle est à jour'));
    });

    test('--force-with-lease protège un distant non récupéré', () {
      published();
      run(['gitquest collegue']);
      commitFile('todo.md', 'x', 'mon travail');

      final lease = engine.execute('git push --force-with-lease');
      expect(lease.isSuccess, isFalse);
      expect(lease.text, contains('bail périmé'));

      run(['git fetch']);
      final forced = engine.execute('git push --force-with-lease');
      expect(forced.type, TerminalOutputType.warning);
      expect(repository.serverBranches['origin/main'], repository.head!.id);
    });

    test('git log --all affiche la branche distante', () {
      published();
      run(['gitquest collegue', 'git fetch']);
      expect(
        engine.execute('git log --oneline --all').text,
        contains('(origin/main) docs: complète les notes d’équipe'),
      );
    });

    test('les références distantes survivent à la sauvegarde', () {
      published();
      run(['gitquest collegue', 'git fetch', 'git push']);
      final restored = VirtualRepository.fromJson(repository.toJson());
      expect(restored.serverBranches, repository.serverBranches);
      expect(restored.remoteBranches, repository.remoteBranches);
      expect(restored.rejectedPushes, 1);
    });
  });

  group('git bisect', () {
    test('trouve le commit qui introduit le bug', () {
      run(['git init', 'git add .', 'git commit -m "Base"']);
      expect(engine.execute('gitquest regression').isSuccess, isTrue);
      expect(repository.tags['version-saine'], isNotNull);
      final actual = repository.commits.firstWhere(
        (commit) => commit.snapshot['app.js']?.contains('bug') ?? false,
      );

      run([
        'git bisect start',
        'git bisect bad',
        'git bisect good version-saine',
      ]);
      var steps = 0;
      while (repository.bisectCulprit == null && steps < 10) {
        expect(repository.isDetached, isTrue);
        final buggy = repository.files['app.js']!.content.contains('bug');
        engine.execute(buggy ? 'git bisect bad' : 'git bisect good');
        steps += 1;
      }

      expect(repository.bisectCulprit, actual.id);
      expect(steps, lessThanOrEqualTo(3));
      expect(validates('find-bug'), isFalse, reason: 'reset manquant');
      engine.execute('git bisect reset');
      expect(repository.isDetached, isFalse);
      expect(repository.currentBranch, 'main');
      expect(repository.files['app.js']!.content, contains('bug'));
      expect(validates('find-bug'), isTrue);
    });

    test('guide l’utilisateur avant d’avoir un bon et un mauvais commit', () {
      run(['git init', 'git add .', 'git commit -m "Base"']);
      expect(engine.execute('git bisect bad').isSuccess, isFalse);
      engine.execute('git bisect start');
      expect(engine.execute('git bisect bad').text, contains('commit bon'));
      expect(engine.execute('git bisect start').isSuccess, isFalse);
    });

    test('une session en cours survit à la sauvegarde', () {
      run([
        'git init',
        'git add .',
        'git commit -m "Base"',
        'gitquest regression',
      ]);
      run(['git bisect start', 'git bisect bad']);
      final restored = VirtualRepository.fromJson(repository.toJson());
      expect(restored.bisect?.bad, repository.bisect!.bad);
      expect(restored.bisect?.returnBranch, 'main');
    });
  });

  test('mission push refusé', () {
    published();
    run([
      'gitquest collegue',
      'echo "x" > todo.md',
      'git add .',
      'git commit -m "docs: ajoute la todo"',
    ]);
    expect(validates('rejected-push'), isFalse);
    run(['git push', 'git pull --rebase origin main']);
    expect(validates('rejected-push'), isFalse, reason: 'pas encore publié');
    run(['git push']);
    expect(validates('rejected-push'), isTrue);
  });

  test('mission dépôt distant exige une vraie publication', () {
    run([
      'git init',
      'git remote add origin https://example.com/t.git',
      'git remote -v',
    ]);
    run(['git push -u origin main']);
    expect(validates('remote-repo'), isFalse);
    run(['git add .', 'git commit -m "Base"', 'git push -u origin main']);
    expect(validates('remote-repo'), isTrue);
  });
}
