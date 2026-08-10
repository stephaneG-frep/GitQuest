import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/collaboration_models.dart';

class CollaborationStore extends ChangeNotifier {
  static const _storageKey = 'gitquest_collaboration_v1';

  final List<SimulatedIssue> issues = <SimulatedIssue>[];
  final List<SimulatedPullRequest> pullRequests = <SimulatedPullRequest>[];
  int _nextIssueId = 1;
  int _nextPullRequestId = 1;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) {
      _seed();
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      issues.addAll(
        (json['issues'] as List<dynamic>).map(
          (value) => SimulatedIssue.fromJson(value as Map<String, dynamic>),
        ),
      );
      pullRequests.addAll(
        (json['pullRequests'] as List<dynamic>).map(
          (value) =>
              SimulatedPullRequest.fromJson(value as Map<String, dynamic>),
        ),
      );
      _nextIssueId = json['nextIssueId'] as int? ?? issues.length + 1;
      _nextPullRequestId =
          json['nextPullRequestId'] as int? ?? pullRequests.length + 1;
    } on Object catch (e, s) {
      // Invalid local data is replaced with the initial GitHub Lab content.
      debugPrint('Erreur de chargement du CollaborationStore: $e\n$s');
      issues.clear();
      pullRequests.clear();
      _seed();
    }
  }

  void _seed() {
    issues.addAll(<SimulatedIssue>[
      SimulatedIssue(
        id: 1,
        title: 'Améliorer le guide de démarrage',
        description:
            'Ajouter un exemple simple de premier commit dans le README.',
        label: 'documentation',
        priority: IssuePriority.medium,
        comments: <CollaborationComment>[
          CollaborationComment(
            author: 'Nora · mainteneuse',
            message: 'Bonne première contribution : le périmètre est clair.',
            createdAt: DateTime.now(),
          ),
        ],
      ),
      SimulatedIssue(
        id: 2,
        title: 'Corriger le contraste du bouton principal',
        description:
            'Le texte est difficile à lire dans le thème clair. Vérifier aussi le mode sombre.',
        label: 'accessibilité',
        priority: IssuePriority.high,
      ),
    ]);
    _nextIssueId = 3;
    _nextPullRequestId = 1;
  }

  Future<void> createIssue({
    required String title,
    required String description,
    required String label,
    required IssuePriority priority,
  }) async {
    issues.insert(
      0,
      SimulatedIssue(
        id: _nextIssueId++,
        title: title,
        description: description,
        label: label,
        priority: priority,
      ),
    );
    await _changed();
  }

  Future<void> toggleIssue(SimulatedIssue issue) async {
    issue.isClosed = !issue.isClosed;
    await _changed();
  }

  Future<void> createPullRequest({
    required String title,
    required String description,
    required String sourceBranch,
    required String targetBranch,
    int? linkedIssueId,
  }) async {
    pullRequests.insert(
      0,
      SimulatedPullRequest(
        id: _nextPullRequestId++,
        title: title,
        description: description,
        sourceBranch: sourceBranch,
        targetBranch: targetBranch,
        linkedIssueId: linkedIssueId,
      ),
    );
    await _changed();
  }

  Future<void> addIssueComment(
    SimulatedIssue issue,
    String author,
    String message,
  ) async {
    issue.comments.add(
      CollaborationComment(
        author: author,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    await _changed();
  }

  Future<void> addPullRequestComment(
    SimulatedPullRequest pullRequest,
    String author,
    String message,
  ) async {
    pullRequest.comments.add(
      CollaborationComment(
        author: author,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    await _changed();
  }

  Future<void> review(
    SimulatedPullRequest pullRequest,
    PullRequestStatus status,
  ) async {
    pullRequest.status = status;
    await _changed();
  }

  Future<void> markMerged(SimulatedPullRequest pullRequest) async {
    pullRequest.status = PullRequestStatus.merged;
    if (pullRequest.linkedIssueId case final int issueId) {
      final linked = issues.where((issue) => issue.id == issueId).firstOrNull;
      if (linked != null) linked.isClosed = true;
    }
    await _changed();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'formatVersion': 1,
    'nextIssueId': _nextIssueId,
    'nextPullRequestId': _nextPullRequestId,
    'issues': issues.map((issue) => issue.toJson()).toList(),
    'pullRequests': pullRequests
        .map((pullRequest) => pullRequest.toJson())
        .toList(),
  };

  Future<void> restoreFromJson(Map<String, dynamic> json) async {
    final restoredIssues = (json['issues'] as List<dynamic>? ?? <dynamic>[])
        .map((value) => SimulatedIssue.fromJson(value as Map<String, dynamic>))
        .toList();
    final restoredPullRequests =
        (json['pullRequests'] as List<dynamic>? ?? <dynamic>[])
            .map(
              (value) =>
                  SimulatedPullRequest.fromJson(value as Map<String, dynamic>),
            )
            .toList();
    issues
      ..clear()
      ..addAll(restoredIssues);
    pullRequests
      ..clear()
      ..addAll(restoredPullRequests);
    _nextIssueId = json['nextIssueId'] as int? ?? issues.length + 1;
    _nextPullRequestId =
        json['nextPullRequestId'] as int? ?? pullRequests.length + 1;
    await _changed();
  }

  Future<void> _changed() async {
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(toJson()));
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
