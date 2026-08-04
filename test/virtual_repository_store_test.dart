import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/storage/virtual_repository_store.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persiste et recharge tout le dépôt virtuel', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = VirtualRepositoryStore();
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "Base persistée"');
    engine.execute('git tag v1.0.0');
    engine.execute('git remote add origin https://example.com/repo.git');

    await store.save(repository);
    final restored = await store.load();

    expect(restored.initialized, isTrue);
    expect(restored.head!.message, 'Base persistée');
    expect(restored.tags, containsPair('v1.0.0', restored.head!.id));
    expect(restored.remotes, contains('origin'));
    expect(restored.commandHistory, contains('git tag v1.0.0'));
  });

  test('conserve une fusion conflictuelle en cours', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = VirtualRepositoryStore();
    final repository = VirtualRepository();
    final engine = GitCommandEngine(repository);
    engine.execute('git init');
    engine.execute('git add .');
    engine.execute('git commit -m "Base"');
    engine.execute('git switch -c feature/theme');
    engine.execute('echo "Feature" > README.md');
    engine.execute('git add .');
    engine.execute('git commit -m "Feature"');
    engine.execute('git switch main');
    engine.execute('echo "Main" > README.md');
    engine.execute('git add .');
    engine.execute('git commit -m "Main"');
    engine.execute('git merge feature/theme');

    await store.save(repository);
    final restored = await store.load();

    expect(restored.pendingMergeBranch, 'feature/theme');
    expect(restored.conflicts, contains('README.md'));
    expect(restored.files['README.md']!.state, FileState.conflicted);
  });
}
