import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/app/app.dart';
import 'package:gitquest/app/app_scope.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:gitquest/core/notifications/reminder_service.dart';
import 'package:gitquest/features/profile/profile_screen.dart';
import 'package:gitquest/features/projects/data/project_progress_store.dart';
import 'package:gitquest/features/projects/presentation/projects_screen.dart';
import 'package:gitquest/features/search/presentation/global_search_screen.dart';
import 'package:gitquest/features/settings/settings_screen.dart';
import 'package:gitquest/features/statistics/presentation/statistics_screen.dart';
import 'package:gitquest/features/collaboration/data/collaboration_store.dart';
import 'package:gitquest/features/collaboration/domain/collaboration_models.dart';
import 'package:gitquest/features/collaboration/presentation/collaboration_screen.dart';
import 'package:gitquest/features/collaboration/presentation/pull_requests_tab.dart';
import 'package:gitquest/features/help/presentation/help_screen.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';
import 'package:gitquest/features/terminal/presentation/terminal_screen.dart';
import 'package:gitquest/features/tools/presentation/tools_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('affiche l’onboarding au premier lancement', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(GitQuestApp(store: LocalProgressStore()));
    expect(find.text('Bienvenue dans GitQuest'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('affiche la navigation principale après onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = LocalProgressStore()..onboardingComplete = true;
    await tester.pumpWidget(GitQuestApp(store: store));
    await tester.pumpAndSettle();
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Parcours'), findsOneWidget);
    expect(find.byIcon(Icons.terminal_outlined), findsOneWidget);
  });

  testWidgets('le mode d’emploi est accessible et lisible sur le Honor', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;

    await tester.pumpWidget(GitQuestApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mode d’emploi'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpScreen), findsOneWidget);
    expect(find.text('Mode d’emploi'), findsOneWidget);
    expect(find.text('Démarrage rapide'), findsOneWidget);
    expect(find.text('Ouvre Parcours'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('le profil tient sur un écran mobile étroit', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();
    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Badges'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Badges'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active un rappel quotidien depuis les paramètres', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final scheduler = _FakeReminderScheduler();
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        reminderScheduler: scheduler,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Rappel quotidien'));
    await tester.tap(find.text('Rappel quotidien'));
    await tester.pumpAndSettle();

    expect(store.reminderEnabled, isTrue);
    expect(scheduler.permissionRequested, isTrue);
    expect(scheduler.scheduledAt, (19, 0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('GitHub Lab reste utilisable sur le Honor', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final collaboration = CollaborationStore();
    await collaboration.load();
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: collaboration,
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(home: CollaborationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GitHub Lab'), findsOneWidget);
    await tester.tap(find.byTooltip('Issues'));
    await tester.pumpAndSettle();
    expect(find.text('Créer une issue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la CI d’une pull request fonctionne sur le Honor', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final progress = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "Base"');
    engine.execute('git switch -c feature/ci');
    engine.execute('touch ci.md');
    engine.execute('git add .');
    engine.execute('git commit -m "Ajoute la CI"');
    final collaboration = CollaborationStore();
    await collaboration.load();
    await collaboration.createPullRequest(
      title: 'Ajoute la CI',
      description: 'Vérifie la proposition.',
      sourceBranch: 'feature/ci',
      targetBranch: 'main',
    );
    final pullRequest = collaboration.pullRequests.single;

    await tester.pumpWidget(
      AppScope(
        store: progress,
        repository: repository,
        engine: engine,
        collaborationStore: collaboration,
        projectProgressStore: ProjectProgressStore(),
        child: MaterialApp(
          home: PullRequestDetailScreen(pullRequest: pullRequest),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Lancer les contrôles CI'),
      find.byType(ListView),
      const Offset(0, -250),
    );
    await tester.ensureVisible(find.text('Lancer les contrôles CI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lancer les contrôles CI'));
    await tester.pump();
    expect(find.text('CI en cours…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(pullRequest.checksPassed, isTrue);
    expect(
      pullRequest.checks.where((check) => check.status == CheckStatus.success),
      hasLength(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('le terminal tient en paysage avec le clavier ouvert', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(812, 369);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(812, 369),
              viewInsets: EdgeInsets.only(bottom: 190),
            ),
            child: TerminalScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip('Exécuter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('le terminal exécute une commande avec Entrée et le bouton', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(home: TerminalScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'git init');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('Dépôt Git vide initialisé'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'git status');
    await tester.tap(find.byTooltip('Exécuter'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sur la branche main'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('le terminal tient dans le shell du Honor en paysage', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(812, 369);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;

    await tester.pumpWidget(GitQuestApp(store: store));
    await tester.tap(find.byIcon(Icons.terminal_outlined));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Exécuter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('les projets restent lisibles sur le Honor', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(home: ProjectsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Portfolio personnel'), findsOneWidget);
    expect(find.text('Application Flutter collaborative'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la boîte à outils reste utilisable sur le Honor', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(home: ToolsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Boîte à outils Git'), findsOneWidget);
    expect(find.text('Assistant'), findsOneWidget);
    expect(find.text('Créer un nouveau dépôt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('les statistiques restent lisibles sur le Honor', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(home: StatisticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Statistiques'), findsOneWidget);
    expect(find.text('Vue d’ensemble'), findsOneWidget);
    final exception = tester.takeException();
    expect(
      exception,
      isNull,
      reason: exception is FlutterError ? exception.toStringDeep() : null,
    );
  });

  testWidgets('la recherche globale trouve une commande sur le Honor', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(369, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalProgressStore()..onboardingComplete = true;
    final repository = VirtualRepository();

    await tester.pumpWidget(
      AppScope(
        store: store,
        repository: repository,
        engine: GitCommandEngine(repository),
        collaborationStore: CollaborationStore(),
        projectProgressStore: ProjectProgressStore(),
        child: const MaterialApp(home: GlobalSearchScreen()),
      ),
    );
    await tester.enterText(
      find.byType(TextField),
      'annuler le dernier commit sans perdre',
    );
    await tester.pumpAndSettle();

    expect(find.text('Recherche globale'), findsOneWidget);
    expect(find.text('git reset --soft HEAD~1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeReminderScheduler implements ReminderScheduler {
  bool permissionRequested = false;
  (int, int)? scheduledAt;

  @override
  Future<void> cancel() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequested = true;
    return true;
  }

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    scheduledAt = (hour, minute);
  }
}
