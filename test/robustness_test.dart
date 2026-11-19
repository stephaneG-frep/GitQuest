import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/core/app_info.dart';
import 'package:gitquest/core/backup/backup_service.dart';
import 'package:gitquest/core/storage/local_progress_store.dart';
import 'package:gitquest/features/collaboration/data/collaboration_store.dart';
import 'package:gitquest/features/projects/data/project_progress_store.dart';
import 'package:gitquest/features/terminal/domain/git_command_engine.dart';
import 'package:gitquest/features/terminal/domain/virtual_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests de régression : import, démarrage, version et série de jours.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<(BackupService, LocalProgressStore, VirtualRepository)>
  createService() async {
    final profile = LocalProgressStore()..name = 'Ada';
    final repository = VirtualRepository();
    GitCommandEngine(repository)
      ..execute('git init')
      ..execute('git add .')
      ..execute('git commit -m "Actuel"');
    final collaboration = CollaborationStore();
    await collaboration.load();
    return (
      BackupService(
        profile: profile,
        repository: repository,
        collaboration: collaboration,
        projects: ProjectProgressStore(),
      ),
      profile,
      repository,
    );
  }

  test('la version de l’application correspond au pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([^+\s]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(gitQuestVersion, version);
  });

  test('l’export inscrit la version courante', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final (service, _, _) = await createService();
    expect(service.createJson()['appVersion'], gitQuestVersion);
  });

  group('import corrompu', () {
    test('un profil mal typé est refusé avant toute modification', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final (service, profile, repository) = await createService();
      final json = service.createJson();
      (json['profile'] as Map<String, dynamic>)['profile'] = <String, dynamic>{
        'name': 42,
        'xp': 'beaucoup',
      };

      expect(
        () => service.parse(jsonEncode(json)),
        throwsA(isA<FormatException>()),
      );
      expect(profile.name, 'Ada');
      expect(repository.commits.single.message, 'Actuel');
    });

    test('un dépôt mal formé est refusé dès l’aperçu', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final (service, profile, repository) = await createService();
      final json = service.createJson();
      json['repository'] = <String, dynamic>{
        'commits': <dynamic>['pas un commit'],
      };

      expect(
        () => service.parse(jsonEncode(json)),
        throwsA(isA<FormatException>()),
      );
      expect(repository.commits.single.message, 'Actuel');
    });

    test('des issues mal formées sont refusées dès l’aperçu', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final (service, _, _) = await createService();
      final json = service.createJson();
      json['collaboration'] = <String, dynamic>{
        'issues': <dynamic>[42],
      };

      expect(
        () => service.parse(jsonEncode(json)),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'restoreFromJson ne modifie rien si les données sont invalides',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final profile = LocalProgressStore()..name = 'Ada';
        await profile.completeLesson('versioning');

        await expectLater(
          profile.restoreFromJson(<String, dynamic>{
            'profile': <String, dynamic>{'name': 'Grace'},
            'progress': <String, dynamic>{
              'dailyXp': <String, dynamic>{'2026-01-01': 'dix'},
            },
          }),
          throwsA(anything),
        );
        expect(profile.name, 'Ada');
        expect(profile.completedLessons, contains('versioning'));
      },
    );

    test('la taille de texte importée est bornée', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final profile = LocalProgressStore();
      await profile.restoreFromJson(<String, dynamic>{
        'settings': <String, dynamic>{'textScale': 5, 'dailyGoal': -3},
      });
      expect(profile.textScale, LocalProgressStore.maxTextScale);
      expect(profile.dailyGoal, 1);
      await profile.updateTextScale(0.1);
      expect(profile.textScale, LocalProgressStore.minTextScale);
    });
  });

  group('démarrage', () {
    test('un profil local corrompu n’empêche pas le lancement', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'gitquest_profile_v1': jsonEncode(<String, dynamic>{
          'profile': <String, dynamic>{'name': 12},
        }),
      });
      final profile = LocalProgressStore();
      await profile.load();
      expect(profile.name, 'Explorateur');
    });

    test('un JSON local illisible n’empêche pas le lancement', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'gitquest_profile_v1': '{pas du json',
      });
      final profile = LocalProgressStore();
      await profile.load();
      expect(profile.onboardingComplete, isFalse);
    });
  });

  group('série de jours', () {
    Future<LocalProgressStore> loadWith(
      DateTime lastActivity,
      int streak,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'gitquest_profile_v1': jsonEncode(<String, dynamic>{
          'profile': <String, dynamic>{
            'streak': streak,
            'bestStreak': streak,
            'lastActivityDate': dateKey(lastActivity),
          },
        }),
      });
      final profile = LocalProgressStore();
      await profile.load();
      return profile;
    }

    test('est rompue après un jour sans activité', () async {
      final now = DateTime.now();
      final profile = await loadWith(
        DateTime(now.year, now.month, now.day - 3),
        5,
      );
      expect(profile.streak, 0);
      expect(profile.bestStreak, 5);
      await profile.completeLesson('versioning');
      expect(profile.streak, 1);
    });

    test('continue si la dernière activité date d’hier', () async {
      final now = DateTime.now();
      final profile = await loadWith(
        DateTime(now.year, now.month, now.day - 1),
        5,
      );
      expect(profile.streak, 5);
      await profile.completeLesson('versioning');
      expect(profile.streak, 6);
    });
  });
}
