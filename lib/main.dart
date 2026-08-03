import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/storage/local_progress_store.dart';
import 'core/storage/virtual_repository_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalProgressStore();
  final repositoryStore = VirtualRepositoryStore();
  await store.load();
  final repository = await repositoryStore.load();
  runApp(
    GitQuestApp(
      store: store,
      repository: repository,
      repositoryStore: repositoryStore,
    ),
  );
}
