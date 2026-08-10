import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/backup/backup_service.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:gitquest/features/collaboration/data/collaboration_store.dart';
import 'package:gitquest/features/collaboration/domain/collaboration_models.dart';
import 'package:gitquest/features/projects/data/project_progress_store.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exporte puis restaure tous les blocs GitQuest', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final profile = LocalProgressStore()..name = 'Ada';
    await profile.completeLesson('versioning');
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "Sauvegarde"');
    final collaboration = CollaborationStore();
    await collaboration.load();
    await collaboration.createIssue(
      title: 'Issue exportée',
      description: 'Vérifier la sauvegarde.',
      label: 'test',
      priority: IssuePriority.low,
    );
    final projects = ProjectProgressStore();
    await projects.complete('portfolio-init');
    final service = BackupService(
      profile: profile,
      repository: repository,
      collaboration: collaboration,
      projects: projects,
    );

    final parsed = service.parse(service.exportJson());
    expect(parsed.preview.formatVersion, 2);
    expect(parsed.preview.name, 'Ada');
    expect(parsed.preview.lessons, 1);
    expect(parsed.preview.commits, 1);
    expect(parsed.preview.issues, 3);
    expect(parsed.preview.projectSteps, 1);

    profile.name = 'Grace';
    repository.reset();
    await projects.clear();
    await service.import(parsed, BackupImportMode.replace);

    expect(profile.name, 'Ada');
    expect(repository.commits.single.message, 'Sauvegarde');
    expect(
      collaboration.issues.any((issue) => issue.title == 'Issue exportée'),
      isTrue,
    );
    expect(projects.completedSteps, contains('portfolio-init'));
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(BackupService.automaticBackupKey), isNotNull);
  });

  test('fusionne la progression sans remplacer le dépôt actuel', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final importedProfile = LocalProgressStore();
    await importedProfile.completeLesson('versioning');
    final importedRepository = VirtualRepository();
    GitCommandEngine(importedRepository)
      ..execute('git init')
      ..execute('git add .')
      ..execute('git commit -m "Importé"');
    final importedCollaboration = CollaborationStore();
    await importedCollaboration.load();
    final importedProjects = ProjectProgressStore();
    await importedProjects.complete('portfolio-init');
    final exported = BackupService(
      profile: importedProfile,
      repository: importedRepository,
      collaboration: importedCollaboration,
      projects: importedProjects,
    ).exportJson();

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final currentProfile = LocalProgressStore();
    await currentProfile.completeMission('first-repo', 120);
    final currentRepository = VirtualRepository();
    final currentEngine = GitCommandEngine(currentRepository);
    currentEngine.execute('git init');
    final currentCollaboration = CollaborationStore();
    await currentCollaboration.load();
    final currentProjects = ProjectProgressStore();
    final service = BackupService(
      profile: currentProfile,
      repository: currentRepository,
      collaboration: currentCollaboration,
      projects: currentProjects,
    );

    await service.import(service.parse(exported), BackupImportMode.merge);

    expect(currentProfile.completedLessons, contains('versioning'));
    expect(currentProfile.completedMissions, contains('first-repo'));
    expect(currentRepository.commits, isEmpty);
    expect(currentProjects.completedSteps, contains('portfolio-init'));
  });

  test('accepte une sauvegarde historique de version 1', () {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final profile = LocalProgressStore()..name = 'Linus';
    final service = BackupService(
      profile: profile,
      repository: VirtualRepository(),
      collaboration: CollaborationStore(),
      projects: ProjectProgressStore(),
    );

    final parsed = service.parse(profile.exportJson());

    expect(parsed.preview.isLegacy, isTrue);
    expect(parsed.preview.name, 'Linus');
    expect(parsed.preview.commits, 0);
  });
}
