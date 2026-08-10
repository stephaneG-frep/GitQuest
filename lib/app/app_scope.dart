import 'package:flutter/widgets.dart';

import '../core/storage/local_progress_store.dart';
import '../core/notifications/reminder_service.dart';
import '../features/collaboration/data/collaboration_store.dart';
import '../features/projects/data/project_progress_store.dart';
import '../features/terminal/domain/git_command_engine.dart';
import '../features/terminal/domain/virtual_repository.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    required this.store,
    required this.repository,
    required this.engine,
    required this.collaborationStore,
    required this.projectProgressStore,
    this.reminderScheduler,
    required super.child,
    super.key,
  });

  final LocalProgressStore store;
  final VirtualRepository repository;
  final GitCommandEngine engine;
  final CollaborationStore collaborationStore;
  final ProjectProgressStore projectProgressStore;
  final ReminderScheduler? reminderScheduler;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      store != oldWidget.store ||
      repository != oldWidget.repository ||
      collaborationStore != oldWidget.collaborationStore ||
      projectProgressStore != oldWidget.projectProgressStore ||
      reminderScheduler != oldWidget.reminderScheduler;
}
