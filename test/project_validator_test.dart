import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/features/collaboration/data/collaboration_store.dart';
import 'package:gitquest/features/collaboration/domain/collaboration_models.dart';
import 'package:gitquest/features/projects/data/project_content.dart';
import 'package:gitquest/features/projects/domain/project_models.dart';
import 'package:gitquest/features/projects/domain/project_validator.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('valide les étapes portfolio sur le dépôt réel', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    final collaboration = CollaborationStore();
    await collaboration.load();
    final portfolio = projects.first;

    expect(
      ProjectValidator.isSatisfied(
        portfolio.steps.first,
        repository,
        collaboration,
      ),
      isFalse,
    );
    engine.execute('git init');
    expect(
      ProjectValidator.isSatisfied(
        portfolio.steps.first,
        repository,
        collaboration,
      ),
      isTrue,
    );
    engine.execute('git add README.md');
    engine.execute('git commit -m "Présente le portfolio"');
    expect(
      ProjectValidator.isSatisfied(
        portfolio.steps[1],
        repository,
        collaboration,
      ),
      isTrue,
    );
  });

  test('reconnaît un commit conventionnel et une collaboration', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    final collaboration = CollaborationStore();
    await collaboration.load();
    final team = projects[1];
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "feat: améliore le contraste"');
    await collaboration.createIssue(
      title: 'Améliorer le contraste',
      description: 'Rendre le bouton lisible.',
      label: 'accessibilité',
      priority: IssuePriority.high,
    );

    expect(
      ProjectValidator.isSatisfied(team.steps[1], repository, collaboration),
      isTrue,
    );
    expect(
      ProjectValidator.isSatisfied(team.steps[3], repository, collaboration),
      isTrue,
    );
  });

  test('le projet GitHub Pages se valide étape par étape', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    final collaboration = CollaborationStore();
    await collaboration.load();
    final pages = projects.singleWhere((p) => p.id == 'github-pages-site');
    final commandsByStep = <List<String>>[
      ['git init'],
      [
        'echo "<h1>Bienvenue</h1>" > index.html',
        'git add index.html',
        'git commit -m "feat: ajoute la page d’accueil"',
      ],
      ['git switch -c feature/style'],
      [
        'echo "body" > style.css',
        'git add style.css',
        'git commit -m "feat: ajoute le style"',
      ],
      ['git switch main', 'git merge feature/style'],
      ['git remote add origin https://github.com/pseudo/pseudo.github.io.git'],
      ['git push -u origin main'],
      ['git tag v1.0.0'],
    ];
    expect(pages.steps, hasLength(commandsByStep.length));
    for (var i = 0; i < pages.steps.length; i++) {
      final step = pages.steps[i];
      expect(
        ProjectValidator.isSatisfied(step, repository, collaboration),
        isFalse,
        reason: '${step.id} ne doit pas être validée trop tôt',
      );
      for (final command in commandsByStep[i]) {
        engine.execute(command);
      }
      expect(
        ProjectValidator.isSatisfied(step, repository, collaboration),
        isTrue,
        reason: step.id,
      );
    }
  });

  test(
    'les issues d’exemple ne valident pas la création d’une issue',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final collaboration = CollaborationStore();
      await collaboration.load();
      final step = projects
          .expand((project) => project.steps)
          .firstWhere(
            (step) => step.requirement == ProjectRequirement.issueCreated,
          );
      expect(
        ProjectValidator.isSatisfied(step, VirtualRepository(), collaboration),
        isFalse,
      );
    },
  );
}
