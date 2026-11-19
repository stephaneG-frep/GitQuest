import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_info.dart';

enum ThemePreference { system, light, dark }

class LocalProgressStore extends ChangeNotifier {
  static const _profileKey = 'gitquest_profile_v1';
  static const minTextScale = 0.9;
  static const maxTextScale = 1.3;

  /// Throws if [data] cannot be read as a profile. Nothing is modified.
  static void validateJson(Map<String, dynamic> data) {
    LocalProgressStore()._readJson(data);
  }

  String name = 'Explorateur';
  bool onboardingComplete = false;
  ThemePreference themePreference = ThemePreference.dark;
  double textScale = 1;
  int dailyGoal = 10;
  bool reminderEnabled = false;
  int reminderHour = 19;
  int reminderMinute = 0;
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
  final List<String> recentSearches = <String>[];

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_profileKey);
    if (raw == null) return;
    try {
      final loaded = LocalProgressStore()
        .._readJson(jsonDecode(raw) as Map<String, dynamic>);
      _copyFrom(loaded);
    } on Object catch (error) {
      // Invalid local data is ignored so the application can still start.
      debugPrint(
        'Profil local illisible, valeurs par défaut utilisées : $error',
      );
    }
    _expireStreak(DateTime.now());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'formatVersion': 1,
    'appVersion': gitQuestVersion,
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
      'reminderEnabled': reminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
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
      'recentSearches': recentSearches,
    },
  };

  String exportJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Future<String?> importJson(String raw) async {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['formatVersion'] != 1) {
        return 'Ce fichier n’est pas une sauvegarde GitQuest compatible.';
      }
      _copyFrom(LocalProgressStore().._readJson(decoded));
      await save();
      notifyListeners();
      return null;
    } on Object {
      return 'La sauvegarde est illisible ou incomplète.';
    }
  }

  Future<void> restoreFromJson(
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    // Parsing into a separate store first: a malformed file throws before
    // the current profile is modified.
    final imported = LocalProgressStore().._readJson(data);
    if (!merge) {
      _copyFrom(imported);
    } else {
      xp = xp > imported.xp ? xp : imported.xp;
      streak = streak > imported.streak ? streak : imported.streak;
      bestStreak = bestStreak > imported.bestStreak
          ? bestStreak
          : imported.bestStreak;
      onboardingComplete = onboardingComplete || imported.onboardingComplete;
      completedLessons.addAll(imported.completedLessons);
      completedMissions.addAll(imported.completedMissions);
      unlockedAchievements.addAll(imported.unlockedAchievements);
      favoriteCommands.addAll(imported.favoriteCommands);
      rewardedEvents.addAll(imported.rewardedEvents);
      for (final entry in imported.dailyActivity.entries) {
        dailyActivity.update(
          entry.key,
          (value) => value > entry.value ? value : entry.value,
          ifAbsent: () => entry.value,
        );
      }
      for (final entry in imported.dailyXp.entries) {
        dailyXp.update(
          entry.key,
          (value) => value > entry.value ? value : entry.value,
          ifAbsent: () => entry.value,
        );
      }
      for (final search in imported.recentSearches.reversed) {
        recentSearches
          ..remove(search)
          ..insert(0, search);
      }
      if (recentSearches.length > 8) {
        recentSearches.removeRange(8, recentSearches.length);
      }
    }
    await _changed();
  }

  void _copyFrom(LocalProgressStore other) {
    name = other.name;
    onboardingComplete = other.onboardingComplete;
    themePreference = other.themePreference;
    textScale = other.textScale;
    dailyGoal = other.dailyGoal;
    reminderEnabled = other.reminderEnabled;
    reminderHour = other.reminderHour;
    reminderMinute = other.reminderMinute;
    xp = other.xp;
    streak = other.streak;
    bestStreak = other.bestStreak;
    lastActivityDate = other.lastActivityDate;
    void copySet(Set<String> target, Set<String> source) => target
      ..clear()
      ..addAll(source);
    void copyMap(Map<String, int> target, Map<String, int> source) => target
      ..clear()
      ..addAll(source);
    copySet(completedLessons, other.completedLessons);
    copySet(completedMissions, other.completedMissions);
    copySet(unlockedAchievements, other.unlockedAchievements);
    copySet(favoriteCommands, other.favoriteCommands);
    copySet(rewardedEvents, other.rewardedEvents);
    copyMap(dailyActivity, other.dailyActivity);
    copyMap(dailyXp, other.dailyXp);
    recentSearches
      ..clear()
      ..addAll(other.recentSearches);
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
    textScale = ((settings['textScale'] as num?)?.toDouble() ?? textScale)
        .clamp(minTextScale, maxTextScale);
    dailyGoal = (settings['dailyGoal'] as int? ?? dailyGoal).clamp(1, 1000);
    reminderEnabled = settings['reminderEnabled'] as bool? ?? false;
    reminderHour = (settings['reminderHour'] as int? ?? 19).clamp(0, 23);
    reminderMinute = (settings['reminderMinute'] as int? ?? 0).clamp(0, 59);
    onboardingComplete = progress['onboardingComplete'] as bool? ?? false;
    _replace(completedLessons, progress['completedLessons']);
    _replace(completedMissions, progress['completedMissions']);
    _replace(unlockedAchievements, progress['achievements']);
    _replace(favoriteCommands, progress['favorites']);
    _replace(rewardedEvents, progress['rewardedEvents']);
    _replaceIntMap(dailyActivity, progress['dailyActivity']);
    _replaceIntMap(dailyXp, progress['dailyXp']);
    _replaceList(recentSearches, progress['recentSearches']);
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

  void _replaceList(List<String> target, Object? values) {
    target
      ..clear()
      ..addAll((values as List<dynamic>? ?? <dynamic>[]).whereType<String>());
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
      if (completedLessons.length >= 10) {
        unlockedAchievements.add('ten_lessons');
      }
      if (completedLessons.length >= 20) {
        unlockedAchievements.add('twenty_lessons');
      }
      if (completedLessons.length >= 40) {
        unlockedAchievements.add('forty_lessons');
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
    textScale = value.clamp(minTextScale, maxTextScale);
    await _changed();
  }

  Future<void> updateName(String value) async {
    if (value.trim().isNotEmpty) name = value.trim();
    await _changed();
  }

  Future<void> updateReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    reminderEnabled = enabled;
    reminderHour = hour.clamp(0, 23);
    reminderMinute = minute.clamp(0, 59);
    await _changed();
  }

  Future<void> toggleFavorite(String command) async {
    favoriteCommands.contains(command)
        ? favoriteCommands.remove(command)
        : favoriteCommands.add(command);
    await _changed();
  }

  Future<void> rememberSearch(String query) async {
    final value = query.trim();
    if (value.isEmpty) return;
    recentSearches
      ..removeWhere((item) => item.toLowerCase() == value.toLowerCase())
      ..insert(0, value);
    if (recentSearches.length > 8) {
      recentSearches.removeRange(8, recentSearches.length);
    }
    await _changed();
  }

  Future<void> clearRecentSearches() async {
    if (recentSearches.isEmpty) return;
    recentSearches.clear();
    await _changed();
  }

  Future<void> reset() async {
    name = 'Explorateur';
    onboardingComplete = false;
    themePreference = ThemePreference.dark;
    textScale = 1;
    dailyGoal = 10;
    reminderEnabled = false;
    reminderHour = 19;
    reminderMinute = 0;
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
    recentSearches.clear();
    await _changed();
  }

  /// Number of calendar days between the last activity and [now],
  /// independent of daylight saving time changes.
  int? _daysSinceLastActivity(DateTime now) {
    final previous = lastActivityDate == null
        ? null
        : DateTime.tryParse(lastActivityDate!);
    if (previous == null) return null;
    return DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(previous.year, previous.month, previous.day))
        .inDays;
  }

  /// A streak that was not continued yesterday is shown as broken.
  void _expireStreak(DateTime now) {
    final days = _daysSinceLastActivity(now);
    if (days != null && days > 1) streak = 0;
  }

  void _recordActivity(int earnedXp) {
    final now = DateTime.now();
    final today = _dateKey(now);
    if (lastActivityDate != today) {
      final days = _daysSinceLastActivity(now);
      if (days == 1) {
        streak += 1;
      } else if (days != null || streak < 1) {
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
