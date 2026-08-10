import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/storage/local_progress_store.dart';
import 'core/storage/virtual_repository_store.dart';
import 'core/notifications/reminder_service.dart';
import 'features/collaboration/data/collaboration_store.dart';
import 'features/projects/data/project_progress_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalProgressStore();
  final repositoryStore = VirtualRepositoryStore();
  final collaborationStore = CollaborationStore();
  final projectProgressStore = ProjectProgressStore();
  final reminderService = LocalReminderService();
  await store.load();
  await collaborationStore.load();
  await projectProgressStore.load();
  final repository = await repositoryStore.load();
  try {
    await reminderService.initialize();
    if (store.reminderEnabled) {
      await reminderService.scheduleDaily(
        hour: store.reminderHour,
        minute: store.reminderMinute,
      );
    }
  } on Object {
    // A notification failure must never prevent the offline app from starting.
  }
  runApp(
    GitQuestApp(
      store: store,
      repository: repository,
      repositoryStore: repositoryStore,
      collaborationStore: collaborationStore,
      projectProgressStore: projectProgressStore,
      reminderScheduler: reminderService,
    ),
  );
}
