import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/app/app.dart';
import 'package:gitquest/app/app_scope.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:gitquest/features/profile/profile_screen.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';
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
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Badges'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
