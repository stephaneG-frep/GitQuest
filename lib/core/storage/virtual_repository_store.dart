import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/terminal/domain/virtual_repository.dart';

class VirtualRepositoryStore {
  static const _repositoryKey = 'gitquest_virtual_repository_v1';

  Future<VirtualRepository> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_repositoryKey);
    if (raw == null) return VirtualRepository();
    try {
      return VirtualRepository.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return VirtualRepository();
    }
  }

  Future<void> save(VirtualRepository repository) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _repositoryKey,
      jsonEncode(repository.toJson()),
    );
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_repositoryKey);
  }
}
