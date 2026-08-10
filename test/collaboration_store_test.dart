import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/features/collaboration/data/collaboration_store.dart';
import 'package:gitquest/features/collaboration/domain/collaboration_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persiste issues, pull requests et revues', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = CollaborationStore();
    await store.load();
    await store.createIssue(
      title: 'Ajouter un test',
      description: 'Couvrir la nouvelle fonctionnalité.',
      label: 'qualité',
      priority: IssuePriority.high,
    );
    final issue = store.issues.first;
    await store.createPullRequest(
      title: 'test: couvre la fonctionnalité',
      description: 'Ajoute un scénario automatisé.',
      sourceBranch: 'feature/tests',
      targetBranch: 'main',
      linkedIssueId: issue.id,
    );
    await store.review(store.pullRequests.first, PullRequestStatus.approved);

    final restored = CollaborationStore();
    await restored.load();

    expect(
      restored.issues.any((item) => item.title == 'Ajouter un test'),
      isTrue,
    );
    expect(restored.pullRequests.single.status, PullRequestStatus.approved);
    expect(restored.pullRequests.single.linkedIssueId, issue.id);
  });

  test('fusionner une pull request ferme son issue liée', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = CollaborationStore();
    await store.load();
    final issue = store.issues.first;
    await store.createPullRequest(
      title: 'Corrige la documentation',
      description: 'Résout l’issue.',
      sourceBranch: 'docs',
      targetBranch: 'main',
      linkedIssueId: issue.id,
    );

    await store.markMerged(store.pullRequests.first);

    expect(store.pullRequests.first.status, PullRequestStatus.merged);
    expect(issue.isClosed, isTrue);
  });

  test('persiste la protection de branche et les contrôles CI', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = CollaborationStore();
    await store.load();
    await store.createPullRequest(
      title: 'Ajoute la CI',
      description: 'Vérifie chaque proposition.',
      sourceBranch: 'feature/ci',
      targetBranch: 'main',
    );
    final pullRequest = store.pullRequests.single;
    await store.review(pullRequest, PullRequestStatus.approved);

    expect(store.canMerge(pullRequest, currentCommitId: 'abc1234'), isFalse);
    await store.runChecks(
      pullRequest,
      commitId: 'abc1234',
      hasChanges: true,
      hasConflictMarkers: false,
    );
    expect(store.canMerge(pullRequest, currentCommitId: 'abc1234'), isTrue);
    expect(store.canMerge(pullRequest, currentCommitId: 'def5678'), isFalse);

    final restored = CollaborationStore();
    await restored.load();
    expect(restored.branchProtectionEnabled, isTrue);
    expect(restored.pullRequests.single.checksPassed, isTrue);
    expect(restored.pullRequests.single.checkedCommitId, 'abc1234');
  });

  test('la CI refuse les marqueurs de conflit', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = CollaborationStore();
    await store.load();
    await store.createPullRequest(
      title: 'Conflit restant',
      description: 'Contient un conflit non résolu.',
      sourceBranch: 'feature/conflit',
      targetBranch: 'main',
    );
    final pullRequest = store.pullRequests.single;

    await store.runChecks(
      pullRequest,
      commitId: 'abc1234',
      hasChanges: true,
      hasConflictMarkers: true,
    );

    expect(pullRequest.checksPassed, isFalse);
    expect(
      pullRequest.checks.where((check) => check.status == CheckStatus.failure),
      hasLength(2),
    );
  });
}
