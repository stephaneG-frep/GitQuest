import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/models/learning_models.dart';
import 'package:gitquest/data/seed/missions.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';

/// Commandes ajoutées pour les nouvelles leçons et leurs missions.
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

  Mission mission(String id) => missions.singleWhere((item) => item.id == id);

  group('git clone', () {
    test('crée le dépôt, le distant origin et le suivi de main', () {
      final result = engine.execute(
        'git clone https://github.com/equipe/site.git',
      );
      expect(result.isSuccess, isTrue, reason: result.text);
      expect(repository.initialized, isTrue);
      expect(
        repository.remotes['origin'],
        'https://github.com/equipe/site.git',
      );
      expect(repository.upstreams['main'], 'origin/main');
      expect(repository.commits.single.message, 'Initial commit');
      expect(repository.files['README.md']!.content, contains('site'));
      expect(engine.execute('git status').text, contains('suit origin/main'));
    });

    test('conserve l’historique des commandes et les statistiques', () {
      run(['git status', 'git log']);
      final errors = repository.commandErrors;
      engine.execute('git clone https://github.com/equipe/site.git');
      expect(repository.commandHistory, contains('git status'));
      expect(repository.commandHistory.last, startsWith('git clone'));
      expect(repository.commandErrors, errors);
    });

    test('refuse d’écraser un dépôt qui a déjà un historique', () {
      run(['git init', 'git add .', 'git commit -m "Base"']);
      final result = engine.execute('git clone https://github.com/a/b.git');
      expect(result.isSuccess, isFalse);
      expect(repository.commits.single.message, 'Base');
    });

    test('refuse une adresse invalide', () {
      expect(engine.execute('git clone projet').isSuccess, isFalse);
    });
  });

  group('git rm et git mv', () {
    test('git rm supprime et prépare la suppression', () {
      run(['git init']);
      commitFile('brouillon.txt', 'x', 'ajoute');
      engine.execute('git rm brouillon.txt');
      expect(repository.files.containsKey('brouillon.txt'), isFalse);
      expect(engine.execute('git status').text, contains('D  brouillon.txt'));
      engine.execute('git commit -m "supprime"');
      expect(repository.head!.snapshot.containsKey('brouillon.txt'), isFalse);
    });

    test('git rm protège un fichier modifié', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      engine.execute('echo "B" > a.txt');
      expect(engine.execute('git rm a.txt').isSuccess, isFalse);
      expect(repository.files['a.txt']!.content, 'B');
    });

    test('git rm --cached garde le fichier sur le disque', () {
      run(['git init']);
      commitFile('.env', 'secret', 'oups');
      engine.execute('git rm --cached .env');
      expect(repository.files['.env']!.state, FileState.untracked);
      engine.execute('git commit -m "arrête de suivre .env"');
      expect(repository.head!.snapshot.containsKey('.env'), isFalse);
      expect(repository.files.containsKey('.env'), isTrue);
    });

    test('git restore --staged annule un rm --cached', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      engine.execute('git rm --cached a.txt');
      engine.execute('git restore --staged a.txt');
      expect(repository.hasStagedChanges, isFalse);
      expect(repository.files['a.txt']!.state, FileState.committed);
    });

    test('git mv renomme et prépare le renommage', () {
      run(['git init']);
      commitFile('notes.txt', 'n', 'notes');
      expect(engine.execute('git mv notes.txt NOTES.md').isSuccess, isTrue);
      engine.execute('git commit -m "renomme"');
      expect(repository.head!.snapshot.keys, contains('NOTES.md'));
      expect(repository.head!.snapshot.keys, isNot(contains('notes.txt')));
      expect(repository.head!.snapshot['NOTES.md'], 'n');
    });

    test('git mv refuse un fichier non suivi ou une destination existante', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      engine.execute('touch libre.txt');
      expect(engine.execute('git mv libre.txt b.txt').isSuccess, isFalse);
      expect(engine.execute('git mv a.txt libre.txt').isSuccess, isFalse);
    });
  });

  group('git log', () {
    test('ne montre que l’historique atteignable sans --all', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'base');
      run(['git switch -c feature']);
      commitFile('b.txt', 'B', 'sur feature');
      run(['git switch main']);
      expect(
        engine.execute('git log --oneline').text,
        isNot(contains('sur feature')),
      );
      expect(
        engine.execute('git log --oneline --all').text,
        contains('sur feature'),
      );
    });

    test('décore les commits avec HEAD, branches et tags', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'base');
      run(['git tag v1']);
      expect(
        engine.execute('git log --oneline').text,
        contains('(HEAD -> main, tag: v1) base'),
      );
    });

    test('--graph dessine fourche et fusion', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'Base');
      run(['git switch -c feature']);
      commitFile('b.txt', 'B', 'Profil');
      run(['git switch main']);
      commitFile('c.txt', 'C', 'Accueil');
      run(['git merge feature']);

      final lines = engine
          .execute('git log --graph --all --oneline')
          .text
          .split('\n');

      expect(lines.first, startsWith('* '));
      expect(lines.first, contains('Fusion de feature'));
      expect(lines, contains(r'|\'));
      expect(lines, contains('|/'));
      expect(lines.last, startsWith('* '));
      expect(lines.last, endsWith('Base'));
    });
  });

  group('HEAD détachée', () {
    test('détache, protège les commandes risquées puis sauve un essai', () {
      run(['git init']);
      commitFile('a.txt', 'A1', 'a1');
      final first = repository.head!.id;
      commitFile('a.txt', 'A2', 'a2');

      final detach = engine.execute('git switch --detach $first');
      expect(detach.text, contains('détachée'));
      expect(repository.isDetached, isTrue);
      expect(repository.files['a.txt']!.content, 'A1');
      expect(engine.execute('git status').text, startsWith('HEAD détachée'));
      expect(repository.headLabel, contains(first));
      expect(engine.execute('git merge main').isSuccess, isFalse);

      commitFile('essai.txt', 'essai', 'Essai');
      expect(repository.branches['main'], isNot(repository.head!.id));
      engine.execute('git switch -c sauvetage');

      expect(repository.isDetached, isFalse);
      expect(repository.currentBranch, 'sauvetage');
      expect(repository.head!.message, 'Essai');
    });

    test('prévient quand un commit détaché va être abandonné', () {
      run(['git init']);
      commitFile('a.txt', 'A1', 'a1');
      run(['git switch --detach ${repository.head!.id}']);
      commitFile('essai.txt', 'essai', 'Essai');
      final orphan = repository.head!.id;

      final result = engine.execute('git switch main');

      expect(result.type, TerminalOutputType.warning);
      expect(result.text, contains('git branch sauvetage $orphan'));
      engine.execute('git branch sauvetage $orphan');
      expect(repository.branches['sauvetage'], orphan);
    });

    test('git switch exige --detach pour un commit, checkout l’accepte', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      final id = repository.head!.id;
      expect(engine.execute('git switch $id').isSuccess, isFalse);
      expect(engine.execute('git checkout $id').isSuccess, isTrue);
      expect(repository.isDetached, isTrue);
    });

    test('l’état détaché survit à la sauvegarde', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      run(['git switch --detach ${repository.head!.id}']);
      final restored = VirtualRepository.fromJson(repository.toJson());
      expect(restored.detachedHead, repository.detachedHead);
      expect(restored.head!.id, repository.head!.id);
    });
  });

  group('branches', () {
    test('git switch - revient à la branche précédente', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      run(['git switch -c feature', 'git switch main']);
      engine.execute('git switch -');
      expect(repository.currentBranch, 'feature');
      engine.execute('git switch -');
      expect(repository.currentBranch, 'main');
    });

    test('git checkout -b crée et active une branche', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      expect(engine.execute('git checkout -b fix/menu').isSuccess, isTrue);
      expect(repository.currentBranch, 'fix/menu');
    });

    test('push -u mémorise la branche suivie, affichée par branch -vv', () {
      run([
        'git init',
        'git add .',
        'git commit -m "Base"',
        'git remote add origin https://example.com/site.git',
      ]);
      final result = engine.execute('git push -u origin main');
      expect(result.isSuccess, isTrue);
      expect(repository.upstreams['main'], 'origin/main');
      expect(engine.execute('git branch -vv').text, contains('[origin/main]'));
      expect(engine.execute('git push -u inconnu main').isSuccess, isFalse);
    });

    test('les branches suivies survivent à la sauvegarde', () {
      run([
        'git init',
        'git remote add origin https://example.com/site.git',
        'git push -u origin main',
      ]);
      final restored = VirtualRepository.fromJson(repository.toJson());
      expect(restored.upstreams, <String, String>{'main': 'origin/main'});
    });
  });

  group('git reset', () {
    test('HEAD~3 recule de trois commits', () {
      run(['git init']);
      for (var i = 1; i <= 4; i++) {
        commitFile('f$i.txt', '$i', 'c$i');
      }
      engine.execute('git reset --soft HEAD~3');
      expect(repository.head!.message, 'c1');
      expect(repository.stagedFiles, <String>{'f2.txt', 'f3.txt', 'f4.txt'});
    });

    test('sans référence, reset retire seulement les fichiers préparés', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      engine.execute('echo "B" > a.txt');
      engine.execute('git add a.txt');
      engine.execute('git reset');
      expect(repository.head!.message, 'a');
      expect(repository.stagedFiles, isEmpty);
      expect(repository.files['a.txt']!.state, FileState.modified);
    });

    test('refuse une référence trop lointaine', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'a');
      commitFile('b.txt', 'B', 'b');
      expect(engine.execute('git reset --soft HEAD~5').isSuccess, isFalse);
      expect(repository.head!.message, 'b');
    });
  });

  group('missions', () {
    test('rejoindre un projet', () {
      run([
        'git clone https://github.com/equipe/site.git',
        'git remote -v',
        'git log --oneline',
      ]);
      expect(mission('clone-start').validator(repository), isTrue);
    });

    test('grand ménage', () {
      run([
        'git init',
        'echo "x" > brouillon.txt',
        'echo "y" > notes.txt',
        'git add .',
        'git commit -m "Ajoute les notes"',
        'git rm brouillon.txt',
        'git mv notes.txt NOTES.md',
      ]);
      expect(mission('tidy-files').validator(repository), isFalse);
      engine.execute('git commit -m "chore: range les notes"');
      expect(mission('tidy-files').validator(repository), isTrue);
    });

    test('publier et suivre', () {
      run([
        'git init',
        'git remote add origin https://example.com/site.git',
        'git switch -c feature/contact',
        'git push -u origin feature/contact',
      ]);
      expect(mission('publish-track').validator(repository), isFalse);
      engine.execute('git branch -vv');
      expect(mission('publish-track').validator(repository), isTrue);
    });

    test('essai à sauver', () {
      run(['git init']);
      commitFile('a.txt', 'A1', 'a1');
      final first = repository.head!.id;
      commitFile('a.txt', 'A2', 'a2');
      run(['git switch --detach $first']);
      commitFile('essai.txt', 'essai', 'Essai');
      expect(mission('detached-rescue').validator(repository), isFalse);
      engine.execute('git switch -c essai');
      expect(mission('detached-rescue').validator(repository), isTrue);
    });

    test('historique présentable', () {
      run(['git init']);
      commitFile('a.txt', 'A', 'base');
      commitFile('b.txt', 'B', 'wip 1');
      commitFile('c.txt', 'C', 'wip 2');
      commitFile('d.txt', 'D', 'wip 3');
      expect(mission('squash-wip').validator(repository), isFalse);
      run([
        'git reset --soft HEAD~3',
        'git commit -m "feat: ajoute le formulaire"',
      ]);
      expect(mission('squash-wip').validator(repository), isTrue);
      expect(
        repository.head!.snapshot.keys,
        containsAll(<String>['b.txt', 'c.txt', 'd.txt']),
      );
    });
  });
}
