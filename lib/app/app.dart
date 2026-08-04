import 'package:flutter/material.dart';

import '../core/storage/local_progress_store.dart';
import '../core/storage/virtual_repository_store.dart';
import '../features/collaboration/data/collaboration_store.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/terminal/domain/git_command_engine.dart';
import '../features/terminal/domain/virtual_repository.dart';
import 'app_scope.dart';
import 'home_shell.dart';
import 'theme/app_theme.dart';

class GitQuestApp extends StatefulWidget {
  const GitQuestApp({
    required this.store,
    this.repository,
    this.repositoryStore,
    this.collaborationStore,
    super.key,
  });

  final LocalProgressStore store;
  final VirtualRepository? repository;
  final VirtualRepositoryStore? repositoryStore;
  final CollaborationStore? collaborationStore;

  @override
  State<GitQuestApp> createState() => _GitQuestAppState();
}

class _GitQuestAppState extends State<GitQuestApp> {
  late final VirtualRepository repository =
      widget.repository ?? VirtualRepository();
  late final GitCommandEngine engine = GitCommandEngine(
    repository,
    onChanged: (value) => widget.repositoryStore?.save(value),
  );
  late final CollaborationStore collaborationStore =
      widget.collaborationStore ?? CollaborationStore();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final themeMode = switch (widget.store.themePreference) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      };
      return AppScope(
        store: widget.store,
        repository: repository,
        engine: engine,
        collaborationStore: collaborationStore,
        child: MaterialApp(
          title: 'GitQuest',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: themeMode,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(widget.store.textScale)),
            child: child!,
          ),
          home: widget.store.onboardingComplete
              ? const HomeShell()
              : const OnboardingScreen(),
        ),
      );
    },
  );
}
