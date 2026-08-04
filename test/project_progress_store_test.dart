import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:gitquest/features/projects/data/project_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'persiste une étape et ne récompense un événement qu’une fois',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final projects = ProjectProgressStore();
      final profile = LocalProgressStore();

      expect(await projects.complete('portfolio-init'), isTrue);
      expect(await projects.complete('portfolio-init'), isFalse);
      await profile.rewardEvent('project-step:portfolio-init', 30);
      await profile.rewardEvent('project-step:portfolio-init', 30);

      final restored = ProjectProgressStore();
      await restored.load();
      expect(restored.completedSteps, contains('portfolio-init'));
      expect(profile.xp, 30);

      await restored.clear();
      final cleared = ProjectProgressStore();
      await cleared.load();
      expect(cleared.completedSteps, isEmpty);
    },
  );
}
