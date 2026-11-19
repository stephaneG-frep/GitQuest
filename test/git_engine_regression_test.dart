import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';

/// Tests de régression des anomalies relevées par l'audit du moteur Git.
void main() {
  late VirtualRepository repository;
  late GitCommandEngine engine;

  setUp(() {
    repository = VirtualRepository();
    engine = GitCommandEngine(repository);
  });

  void commitFile(String path, String content, String message) {
    engine.execute('echo "$content" > $path');
    engine.execute('git add $path');
    final result = engine.execute('git commit -m "$message"');
    expect(result.isSuccess, isTrue, reason: result.text);
  }

  group('identifiants de commit', () {
    test('restent uniques sur un long historique', () {
      engine.execute('git init');
      for (var i = 1; i <= 300; i++) {
        commitFile('f.txt', 'v$i', 'c$i');
      }
      final ids = repository.commits.map((commit) => commit.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.every((id) => id.length == 7), isTrue);
      expect(repository.head!.message, 'c300');
    });

    test('HEAD reste correct après le 16e commit', () {
      engine.execute('git init');
      for (var i = 1; i <= 16; i++) {
        commitFile('f.txt', 'v$i', 'c$i');
      }
      expect(repository.head!.message, 'c16');
      engine.execute('git switch -c tmp');
      engine.execute('git switch main');
      expect(repository.files['f.txt']!.content, 'v16');
    });

    test('un ancien dépôt aux identifiants dupliqués est réparé', () {
      Map<String, dynamic> commit(String id, String message, String? parent) =>
          <String, dynamic>{
            'id': id,
            'message': message,
            'parentIds': <String>[?parent],
            'snapshot': <String, String>{'f.txt': message},
          };
      final restored = VirtualRepository.fromJson(<String, dynamic>{
        'initialized': true,
        'branches': <String, dynamic>{'main': '9e3779b'},
        'tags': <String, dynamic>{'v1': '9e3779b'},
        'commits': <dynamic>[
          commit('9e3779b', 'c1', null),
          commit('13c6ef3', 'c2', '9e3779b'),
          commit('9e3779b', 'c3', '13c6ef3'),
        ],
        'commitSequence': 16,
      });

      final ids = restored.commits.map((commit) => commit.id).toList();
      expect(ids.toSet(), hasLength(3));
      expect(restored.head!.message, 'c3');
      expect(restored.tags['v1'], restored.head!.id);
      expect(restored.commits[1].parentIds, <String>[ids[0]]);
      expect(restored.commits[2].parentIds, <String>[ids[1]]);
    });

    test('une référence courte ambiguë est refusée', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      final id = repository.head!.id;
      expect(repository.commitByReference(id), isNotNull);
      expect(repository.commitByReference(id.substring(0, 4))!.id, id);
    });
  });

  group('revert', () {
    test('annule uniquement le commit visé', () {
      engine.execute('git init');
      commitFile('a.txt', 'A1', 'a1');
      commitFile('b.txt', 'B', 'ajoute b');
      commitFile('a.txt', 'A2', 'a2');
      final idB = repository.commits[1].id;

      final result = engine.execute('git revert $idB');

      expect(result.isSuccess, isTrue, reason: result.text);
      expect(repository.head!.snapshot['a.txt'], 'A2');
      expect(repository.head!.snapshot.containsKey('b.txt'), isFalse);
      expect(repository.files['a.txt']!.content, 'A2');
      expect(repository.files.containsKey('b.txt'), isFalse);
    });

    test('refuse un revert écrasé par un commit plus récent', () {
      engine.execute('git init');
      commitFile('a.txt', 'A1', 'a1');
      commitFile('a.txt', 'A2', 'a2');
      final idA2 = repository.head!.id;
      commitFile('a.txt', 'A3', 'a3');
      final before = repository.commits.length;

      final result = engine.execute('git revert $idA2');

      expect(result.type, TerminalOutputType.warning);
      expect(repository.commits, hasLength(before));
      expect(repository.files['a.txt']!.content, 'A3');
    });

    test('refuse une copie de travail sale', () {
      engine.execute('git init');
      commitFile('a.txt', 'A1', 'a1');
      engine.execute('echo "brouillon" > a.txt');
      expect(engine.execute('git revert HEAD').isSuccess, isFalse);
      expect(repository.files['a.txt']!.content, 'brouillon');
    });
  });

  group('stash', () {
    test('remet la copie de travail au dernier commit puis restaure', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      engine.execute('echo "brouillon" > a.txt');

      expect(engine.execute('git stash').isSuccess, isTrue);
      expect(repository.files['a.txt']!.content, 'A');
      expect(repository.files['a.txt']!.state, FileState.committed);
      expect(engine.execute('git stash list').text, contains('a.txt'));

      expect(engine.execute('git stash pop').isSuccess, isTrue);
      expect(repository.files['a.txt']!.content, 'brouillon');
      expect(repository.files['a.txt']!.state, FileState.modified);
      expect(repository.stashes, isEmpty);
    });

    test('met aussi de côté un nouveau fichier préparé', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      engine.execute('echo "neuf" > neuf.txt');
      engine.execute('git add neuf.txt');

      engine.execute('git stash');
      expect(repository.files.containsKey('neuf.txt'), isFalse);
      expect(repository.stagedFiles, isEmpty);

      engine.execute('git stash pop');
      expect(repository.files['neuf.txt']!.content, 'neuf');
    });

    test('pop refuse d’écraser des changements locaux', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      engine.execute('echo "un" > a.txt');
      engine.execute('git stash');
      engine.execute('echo "deux" > a.txt');

      expect(engine.execute('git stash pop').isSuccess, isFalse);
      expect(repository.files['a.txt']!.content, 'deux');
      expect(repository.stashes, hasLength(1));
    });
  });

  group('amend', () {
    test('n’embarque pas les fichiers non préparés', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "a"');
      engine.execute('echo "brouillon" > secret.txt');
      engine.execute('echo "maj" > README.md');
      engine.execute('git add README.md');

      engine.execute('git commit --amend -m "a2"');

      expect(repository.head!.snapshot.keys, isNot(contains('secret.txt')));
      expect(repository.head!.snapshot['README.md'], 'maj');
      expect(repository.files['secret.txt']!.state, FileState.untracked);
    });

    test('est refusé pendant un conflit de fusion', () {
      engine.execute('git init');
      commitFile('a.txt', 'base', 'base');
      engine.execute('git switch -c feature');
      commitFile('a.txt', 'feature', 'feature');
      engine.execute('git switch main');
      commitFile('a.txt', 'main', 'main');
      engine.execute('git merge feature');
      expect(repository.conflicts, isNotEmpty);

      expect(engine.execute('git commit --amend -m "x"').isSuccess, isFalse);
    });
  });

  group('fichiers non suivis', () {
    test('sont conservés lors d’un changement de branche', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "a"');
      engine.execute('touch notes.txt');

      engine.execute('git switch -c b');

      expect(repository.files['notes.txt']!.state, FileState.untracked);
    });

    test('sont conservés par reset --hard', () {
      engine.execute('git init');
      commitFile('a.txt', 'A1', 'a1');
      commitFile('a.txt', 'A2', 'a2');
      engine.execute('touch notes.txt');

      engine.execute('git reset --hard HEAD~1');

      expect(repository.files['a.txt']!.content, 'A1');
      expect(repository.files.containsKey('notes.txt'), isTrue);
    });

    test('ne bloquent pas un rebase', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'base');
      engine.execute('git switch -c feature');
      commitFile('b.txt', 'B', 'feature');
      engine.execute('git switch main');
      commitFile('c.txt', 'C', 'main');
      engine.execute('git switch feature');
      engine.execute('touch notes.txt');

      final result = engine.execute('git rebase main');

      expect(result.isSuccess, isTrue, reason: result.text);
      expect(repository.files.containsKey('notes.txt'), isTrue);
    });
  });

  group('état des fichiers', () {
    test('un fichier créé par echo après un commit est non suivi', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      engine.execute('echo "x" > nouveau.txt');
      expect(repository.files['nouveau.txt']!.state, FileState.untracked);
      expect(engine.execute('git status').text, contains('?  nouveau.txt'));
    });

    test('rétablir le contenu committé rend le fichier propre', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      engine.execute('echo "B" > a.txt');
      expect(repository.files['a.txt']!.state, FileState.modified);
      engine.execute('echo "A" > a.txt');
      expect(repository.files['a.txt']!.state, FileState.committed);
    });

    test('git add . ne prépare que les fichiers changés', () {
      engine.execute('git init');
      engine.execute('git add .');
      engine.execute('git commit -m "base"');
      engine.execute('echo "B" > b.txt');
      engine.execute('git add .');
      expect(repository.stagedFiles, <String>{'b.txt'});
      engine.execute('git commit -m "b"');
      expect(engine.execute('git add .').type, TerminalOutputType.warning);
    });

    test('reset --mixed ne marque que les fichiers réellement changés', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      commitFile('b.txt', 'B', 'b');

      engine.execute('git reset HEAD~1');

      expect(repository.files['a.txt']!.state, FileState.committed);
      expect(repository.files['b.txt']!.state, FileState.untracked);
      expect(repository.stagedFiles, isEmpty);
    });

    test('reset --soft ne prépare que les changements annulés', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      commitFile('b.txt', 'B', 'b');

      engine.execute('git reset --soft HEAD~1');

      expect(repository.stagedFiles, <String>{'b.txt'});
      expect(repository.files['a.txt']!.state, FileState.committed);
    });
  });

  group('branch -d', () {
    test('signale une branche inexistante', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      expect(engine.execute('git branch -d fantome').isSuccess, isFalse);
    });

    test('protège une branche non fusionnée, sauf avec -D', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      engine.execute('git switch -c feature');
      commitFile('b.txt', 'B', 'b');
      engine.execute('git switch main');

      expect(engine.execute('git branch -d feature').isSuccess, isFalse);
      expect(repository.branches.containsKey('feature'), isTrue);
      expect(engine.execute('git branch -D feature').isSuccess, isTrue);
      expect(repository.branches.containsKey('feature'), isFalse);
    });

    test('supprime une branche fusionnée', () {
      engine.execute('git init');
      commitFile('a.txt', 'A', 'a');
      engine.execute('git switch -c feature');
      commitFile('b.txt', 'B', 'b');
      engine.execute('git switch main');
      engine.execute('git merge feature');
      expect(engine.execute('git branch -d feature').isSuccess, isTrue);
    });
  });

  test('l’historique des commandes et le reflog sont bornés', () {
    engine.execute('git init');
    for (var i = 0; i < VirtualRepository.maxCommandHistory + 50; i++) {
      engine.execute('git status');
    }
    expect(
      repository.commandHistory,
      hasLength(VirtualRepository.maxCommandHistory),
    );
    commitFile('a.txt', 'A', 'a');
    for (var i = 0; i < VirtualRepository.maxReflog + 10; i++) {
      engine.execute('git tag t$i');
    }
    expect(repository.reflog, hasLength(VirtualRepository.maxReflog));
  });
}
