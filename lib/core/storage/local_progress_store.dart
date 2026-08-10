import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { system, light, dark }

class LocalProgressStore extends ChangeNotifier {
  static const _profileKey = 'gitquest_profile_v1';

  String name = 'Explorateur';
  bool onboardingComplete = false;
  ThemePreference themePreference = ThemePreference.dark;
  double textScale = 1;
  int dailyGoal = 10;
  int xp = 0;
  int streak = 1;
  int bestStreak = 1;
  String? lastActivityDate;
  final Set<String> completedLessons = <String>{};
  final Set<String> completedMissions = <String>{};
  final Set<String> unlockedAchievements = <String>{};
  final Set<String> favoriteCommands = <String>{};
  final Set<String> rewardedEvents = <String>{};
  final Map<String, int> dailyActivity = <String, int>{};
  final Map<String, int> dailyXp = <String, int>{};

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_profileKey);
    if (raw == null) return;
    try {
      _readJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      // Invalid local data is ignored so the application can still start.
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'formatVersion': 1,
    'appVersion': '1.0.0',
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'profile': <String, dynamic>{
      'name': name,
      'xp': xp,
      'streak': streak,
      'bestStreak': bestStreak,
      'lastActivityDate': lastActivityDate,
    },
    'settings': <String, dynamic>{
      'theme': themePreference.name,
      'textScale': textScale,
      'dailyGoal': dailyGoal,
    },
    'progress': <String, dynamic>{
      'onboardingComplete': onboardingComplete,
      'completedLessons': completedLessons.toList(),
      'completedMissions': completedMissions.toList(),
      'achievements': unlockedAchievements.toList(),
      'favorites': favoriteCommands.toList(),
      'rewardedEvents': rewardedEvents.toList(),
      'dailyActivity': dailyActivity,
      'dailyXp': dailyXp,
    },
  };

  String exportJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Future<String?> importJson(String raw) async {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['formatVersion'] != 1) {
        return 'Ce fichier n’est pas une sauvegarde GitQuest compatible.';
      }
      _readJson(decoded);
      await save();
      notifyListeners();
      return null;
    } on Object {
      return 'La sauvegarde est illisible ou incomplète.';
    }
  }

  void _readJson(Map<String, dynamic> data) {
    final profile =
        data['profile'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final settings =
        data['settings'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final progress =
        data['progress'] as Map<String, dynamic>? ?? <String, dynamic>{};
    name = profile['name'] as String? ?? name;
    xp = profile['xp'] as int? ?? xp;
    streak = profile['streak'] as int? ?? streak;
    bestStreak = profile['bestStreak'] as int? ?? streak;
    lastActivityDate = profile['lastActivityDate'] as String?;
    themePreference =
        ThemePreference.values
            .where((value) => value.name == settings['theme'])
            .firstOrNull ??
        themePreference;
    textScale = (settings['textScale'] as num?)?.toDouble() ?? textScale;
    dailyGoal = settings['dailyGoal'] as int? ?? dailyGoal;
    onboardingComplete = progress['onboardingComplete'] as bool? ?? false;
    _replace(completedLessons, progress['completedLessons']);
    _replace(completedMissions, progress['completedMissions']);
    _replace(unlockedAchievements, progress['achievements']);
    _replace(favoriteCommands, progress['favorites']);
    _replace(rewardedEvents, progress['rewardedEvents']);
    _replaceIntMap(dailyActivity, progress['dailyActivity']);
    _replaceIntMap(dailyXp, progress['dailyXp']);
  }

  void _replace(Set<String> target, Object? values) {
    target
      ..clear()
      ..addAll((values as List<dynamic>? ?? <dynamic>[]).whereType<String>());
  }

  void _replaceIntMap(Map<String, int> target, Object? values) {
    target.clear();
    if (values case final Map<String, dynamic> map) {
      target.addAll(
        map.map((key, value) => MapEntry(key, (value as num).toInt())),
      );
    }
  }

  Future<void> save() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_profileKey, jsonEncode(toJson()));
  }

  Future<void> finishOnboarding({
    required String profileName,
    required int goal,
  }) async {
    name = profileName.trim().isEmpty ? 'Explorateur' : profileName.trim();
    dailyGoal = goal;
    onboardingComplete = true;
    await _changed();
  }

  Future<void> completeLesson(String id) async {
    if (completedLessons.add(id)) {
      xp += 50;
      _recordActivity(50);
      unlockedAchievements.add('first_step');
      if (completedLessons.length >= 5) {
        unlockedAchievements.add('five_lessons');
      }
      await _changed();
    }
  }

  Future<void> completeMission(String id, int reward) async {
    if (completedMissions.add(id)) {
      xp += reward;
      _recordActivity(reward);
      await _changed();
    }
  }

  Future<void> unlock(String id) async {
    if (unlockedAchievements.add(id)) await _changed();
  }

  Future<void> rewardEvent(String eventId, int amount) async {
    if (rewardedEvents.add(eventId)) {
      xp += amount;
      _recordActivity(amount);
      await _changed();
    }
  }

  Future<void> updateTheme(ThemePreference value) async {
    themePreference = value;
    await _changed();
  }

  Future<void> updateTextScale(double value) async {
    textScale = value;
    await _changed();
  }

  Future<void> updateName(String value) async {
    if (value.trim().isNotEmpty) name = value.trim();
    await _changed();
  }

  Future<void> toggleFavorite(String command) async {
    favoriteCommands.contains(command)
        ? favoriteCommands.remove(command)
        : favoriteCommands.add(command);
    await _changed();
  }

  Future<void> reset() async {
    name = 'Explorateur';
    onboardingComplete = false;
    themePreference = ThemePreference.dark;
    textScale = 1;
    dailyGoal = 10;
    xp = 0;
    streak = 1;
    bestStreak = 1;
    lastActivityDate = null;
    completedLessons.clear();
    completedMissions.clear();
    unlockedAchievements.clear();
    favoriteCommands.clear();
    rewardedEvents.clear();
    dailyActivity.clear();
    dailyXp.clear();
    await _changed();
  }

  void _recordActivity(int earnedXp) {
    final now = DateTime.now();
    final today = _dateKey(now);
    if (lastActivityDate != today) {
      final previous = lastActivityDate == null
          ? null
          : DateTime.tryParse(lastActivityDate!);
      if (previous != null && now.difference(previous).inDays == 1) {
        streak += 1;
      } else if (previous != null) {
        streak = 1;
      }
      lastActivityDate = today;
      if (streak > bestStreak) bestStreak = streak;
    }
    dailyActivity.update(today, (value) => value + 1, ifAbsent: () => 1);
    dailyXp.update(
      today,
      (value) => value + earnedXp,
      ifAbsent: () => earnedXp,
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _changed() async {
    notifyListeners();
    await save();
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
