import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:gitquest/data/seed/learning_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('le catalogue contient des identifiants et réponses valides', () {
    expect(lessons, hasLength(40));
    final lessonIds = lessons.map((lesson) => lesson.id).toSet();
    final exercises = lessons.expand((lesson) => lesson.exercises).toList();
    final exerciseIds = exercises.map((exercise) => exercise.id).toSet();

    expect(lessonIds, hasLength(lessons.length));
    expect(exerciseIds, hasLength(exercises.length));
    expect(exercises, hasLength(55));
    expect(
      exercises.every(
        (exercise) =>
            exercise.answer >= 0 && exercise.answer < exercise.options.length,
      ),
      isTrue,
    );
    for (var level = 1; level <= 7; level++) {
      expect(
        lessons.where((lesson) => lesson.level == level),
        isNotEmpty,
        reason: 'Le niveau $level doit proposer au moins une leçon.',
      );
    }
  });

  test('les jalons de progression débloquent leurs badges', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = LocalProgressStore();

    for (final lesson in lessons) {
      await store.completeLesson(lesson.id);
    }

    expect(store.completedLessons, hasLength(40));
    expect(store.unlockedAchievements, contains('ten_lessons'));
    expect(store.unlockedAchievements, contains('twenty_lessons'));
    expect(store.unlockedAchievements, contains('forty_lessons'));
  });
}
