import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exporte et importe une progression versionnée', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final source = LocalProgressStore()
      ..name = 'Ada'
      ..xp = 240
      ..completedLessons.add('versioning');
    final raw = source.exportJson();
    expect(jsonDecode(raw), containsPair('formatVersion', 1));

    final target = LocalProgressStore();
    expect(await target.importJson(raw), isNull);
    expect(target.name, 'Ada');
    expect(target.xp, 240);
    expect(target.completedLessons, contains('versioning'));
  });

  test('rejette un format inconnu', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = LocalProgressStore();
    expect(await store.importJson('{"formatVersion": 99}'), isNotNull);
  });

  test(
    'enregistre l’activité quotidienne et le meilleur enchaînement',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = LocalProgressStore();

      await store.completeLesson('versioning');
      await store.completeMission('first-repo', 120);

      expect(store.dailyActivity.values.single, 2);
      expect(store.dailyXp.values.single, 170);
      expect(store.bestStreak, greaterThanOrEqualTo(store.streak));

      final restored = LocalProgressStore();
      await restored.load();
      expect(restored.dailyActivity, store.dailyActivity);
      expect(restored.dailyXp, store.dailyXp);
    },
  );
}
