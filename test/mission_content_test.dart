import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/models/learning_models.dart';
import 'package:gitquest/data/seed/missions.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';

void main() {
  test('le catalogue propose quinze missions cohérentes', () {
    expect(missions, hasLength(15));
    expect(missions.map((mission) => mission.id).toSet(), hasLength(15));
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
}

Mission _mission(String id) =>
    missions.firstWhere((mission) => mission.id == id);
