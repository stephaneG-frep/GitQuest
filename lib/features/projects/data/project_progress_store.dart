import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectProgressStore extends ChangeNotifier {
  static const _storageKey = 'gitquest_projects_v1';

  final Set<String> completedSteps = <String>{};

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) return;
    try {
      completedSteps.addAll(
        (jsonDecode(raw) as List<dynamic>).whereType<String>(),
      );
    } on Object {
      completedSteps.clear();
    }
  }

  Future<bool> complete(String stepId) async {
    if (!completedSteps.add(stepId)) return false;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(completedSteps.toList()),
    );
    return true;
  }

  Future<void> clear() async {
    completedSteps.clear();
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  Future<void> restore(Iterable<String> stepIds, {bool merge = false}) async {
    if (!merge) completedSteps.clear();
    completedSteps.addAll(stepIds);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(completedSteps.toList()),
    );
  }
}
