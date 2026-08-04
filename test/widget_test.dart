import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/app/app.dart';
import 'package:gitquest/app/app_scope.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:gitquest/features/profile/profile_screen.dart';
import 'package:gitquest/features/projects/data/project_progress_store.dart';
import 'package:gitquest/features/projects/presentation/projects_screen.dart';
import 'package:gitquest/features/collaboration/data/collaboration_store.dart';
import 'package:gitquest/features/collaboration/presentation/collaboration_screen.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';
import 'package:gitquest/features/terminal/presentation/terminal_screen.dart';
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

    expect(find.text('Badges'), findsOneWidget);
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
}
