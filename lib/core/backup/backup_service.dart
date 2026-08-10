import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/collaboration/data/collaboration_store.dart';
import '../../features/projects/data/project_progress_store.dart';
import '../../features/terminal/domain/virtual_repository.dart';
import '../storage/local_progress_store.dart';
import '../storage/virtual_repository_store.dart';

enum BackupImportMode { merge, replace }

class BackupPreview {
  const BackupPreview({
    required this.formatVersion,
    required this.exportedAt,
    required this.name,
    required this.xp,
    required this.lessons,
    required this.missions,
    required this.commits,
    required this.issues,
    required this.pullRequests,
    required this.projectSteps,
    required this.isLegacy,
  });

  final int formatVersion;
  final DateTime? exportedAt;
  final String name;
  final int xp;
  final int lessons;
  final int missions;
  final int commits;
  final int issues;
  final int pullRequests;
  final int projectSteps;
  final bool isLegacy;
}

class ParsedBackup {
  const ParsedBackup({required this.json, required this.preview});

  final Map<String, dynamic> json;
  final BackupPreview preview;
}

class BackupService {
  BackupService({
    required this.profile,
    required this.repository,
    required this.collaboration,
    required this.projects,
  });

  static const automaticBackupKey = 'gitquest_automatic_backup_v2';

  final LocalProgressStore profile;
  final VirtualRepository repository;
  final CollaborationStore collaboration;
  final ProjectProgressStore projects;

  Map<String, dynamic> createJson() => <String, dynamic>{
    'formatVersion': 2,
    'appVersion': '1.0.0',
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'profile': profile.toJson(),
    'repository': repository.toJson(),
    'collaboration': collaboration.toJson(),
    'projects': <String, dynamic>{
      'completedSteps': projects.completedSteps.toList(),
    },
  };

  String exportJson() =>
      const JsonEncoder.withIndent(' ').convert(createJson());

  ParsedBackup parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Le fichier ne contient pas un objet JSON.');
    }
    final version = decoded['formatVersion'];
    if (version != 1 && version != 2) {
      throw const FormatException('Version de sauvegarde non compatible.');
    }
    final isLegacy = version == 1;
    final profileJson = isLegacy
        ? decoded
        : decoded['profile'] as Map<String, dynamic>?;
    if (profileJson == null ||
        profileJson['profile'] is! Map<String, dynamic>) {
      throw const FormatException('Le profil de la sauvegarde est incomplet.');
    }
    final profileData = profileJson['profile'] as Map<String, dynamic>;
    final progress =
        profileJson['progress'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final repositoryJson =
        decoded['repository'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final collaborationJson =
        decoded['collaboration'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final projectsJson =
        decoded['projects'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final preview = BackupPreview(
      formatVersion: version as int,
      exportedAt: DateTime.tryParse(decoded['exportedAt'] as String? ?? ''),
      name: profileData['name'] as String? ?? 'Explorateur',
      xp: profileData['xp'] as int? ?? 0,
      lessons: _listLength(progress['completedLessons']),
      missions: _listLength(progress['completedMissions']),
      commits: _listLength(repositoryJson['commits']),
      issues: _listLength(collaborationJson['issues']),
      pullRequests: _listLength(collaborationJson['pullRequests']),
      projectSteps: _listLength(projectsJson['completedSteps']),
      isLegacy: isLegacy,
    );
    return ParsedBackup(json: decoded, preview: preview);
  }

  Future<void> import(ParsedBackup backup, BackupImportMode mode) async {
    final merge = mode == BackupImportMode.merge;
    if (!merge) await _saveAutomaticBackup();
    final data = backup.json;
    final profileJson = backup.preview.isLegacy
        ? data
        : data['profile'] as Map<String, dynamic>;
    await profile.restoreFromJson(profileJson, merge: merge);
    final projectData = data['projects'] as Map<String, dynamic>?;
    if (projectData != null) {
      await projects.restore(
        (projectData['completedSteps'] as List<dynamic>? ?? <dynamic>[])
            .whereType<String>(),
        merge: merge,
      );
    }
    if (merge || backup.preview.isLegacy) return;
    final repositoryJson = data['repository'] as Map<String, dynamic>?;
    if (repositoryJson != null) {
      repository.restoreFromJson(repositoryJson);
      await VirtualRepositoryStore().save(repository);
    }
    final collaborationJson = data['collaboration'] as Map<String, dynamic>?;
    if (collaborationJson != null) {
      await collaboration.restoreFromJson(collaborationJson);
    }
  }

  Future<ParsedBackup?> loadAutomaticBackup() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(automaticBackupKey);
    return raw == null ? null : parse(raw);
  }

  Future<void> _saveAutomaticBackup() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(automaticBackupKey, exportJson());
  }
}

int _listLength(Object? value) => value is List<dynamic> ? value.length : 0;
