enum IssuePriority { low, medium, high }

enum PullRequestStatus {
  draft,
  open,
  changesRequested,
  approved,
  merged,
  closed,
}

enum CheckStatus { queued, running, success, failure }

class PullRequestCheck {
  PullRequestCheck({
    required this.name,
    this.status = CheckStatus.queued,
    this.details = 'En attente du lancement de la CI.',
  });

  final String name;
  CheckStatus status;
  String details;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'status': status.name,
    'details': details,
  };

  factory PullRequestCheck.fromJson(Map<String, dynamic> json) =>
      PullRequestCheck(
        name: json['name'] as String,
        status: CheckStatus.values.byName(
          json['status'] as String? ?? CheckStatus.queued.name,
        ),
        details: json['details'] as String? ?? 'En attente.',
      );
}

List<PullRequestCheck> defaultPullRequestChecks() => <PullRequestCheck>[
  PullRequestCheck(name: 'Analyse statique'),
  PullRequestCheck(name: 'Tests automatisés'),
  PullRequestCheck(name: 'Compilation Android'),
];

class CollaborationComment {
  const CollaborationComment({
    required this.author,
    required this.message,
    required this.createdAt,
  });

  final String author;
  final String message;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'author': author,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CollaborationComment.fromJson(Map<String, dynamic> json) =>
      CollaborationComment(
        author: json['author'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class SimulatedIssue {
  SimulatedIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.label,
    required this.priority,
    this.isClosed = false,
    List<CollaborationComment>? comments,
  }) : comments = comments ?? <CollaborationComment>[];

  final int id;
  final String title;
  final String description;
  final String label;
  final IssuePriority priority;
  bool isClosed;
  final List<CollaborationComment> comments;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'label': label,
    'priority': priority.name,
    'isClosed': isClosed,
    'comments': comments.map((comment) => comment.toJson()).toList(),
  };

  factory SimulatedIssue.fromJson(Map<String, dynamic> json) => SimulatedIssue(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    label: json['label'] as String,
    priority: IssuePriority.values.byName(json['priority'] as String),
    isClosed: json['isClosed'] as bool? ?? false,
    comments: (json['comments'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (value) =>
              CollaborationComment.fromJson(value as Map<String, dynamic>),
        )
        .toList(),
  );
}

class SimulatedPullRequest {
  SimulatedPullRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceBranch,
    required this.targetBranch,
    this.linkedIssueId,
    this.status = PullRequestStatus.open,
    this.checkedCommitId,
    List<CollaborationComment>? comments,
    List<PullRequestCheck>? checks,
  }) : comments = comments ?? <CollaborationComment>[],
       checks = checks ?? defaultPullRequestChecks();

  final int id;
  final String title;
  final String description;
  final String sourceBranch;
  final String targetBranch;
  final int? linkedIssueId;
  PullRequestStatus status;
  String? checkedCommitId;
  final List<CollaborationComment> comments;
  final List<PullRequestCheck> checks;

  bool get checksPassed =>
      checks.isNotEmpty &&
      checks.every((check) => check.status == CheckStatus.success);

  bool get checksRunning =>
      checks.any((check) => check.status == CheckStatus.running);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'sourceBranch': sourceBranch,
    'targetBranch': targetBranch,
    'linkedIssueId': linkedIssueId,
    'status': status.name,
    'checkedCommitId': checkedCommitId,
    'comments': comments.map((comment) => comment.toJson()).toList(),
    'checks': checks.map((check) => check.toJson()).toList(),
  };

  factory SimulatedPullRequest.fromJson(Map<String, dynamic> json) =>
      SimulatedPullRequest(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        sourceBranch: json['sourceBranch'] as String,
        targetBranch: json['targetBranch'] as String,
        linkedIssueId: json['linkedIssueId'] as int?,
        status: PullRequestStatus.values.byName(json['status'] as String),
        checkedCommitId: json['checkedCommitId'] as String?,
        comments: (json['comments'] as List<dynamic>? ?? <dynamic>[])
            .map(
              (value) =>
                  CollaborationComment.fromJson(value as Map<String, dynamic>),
            )
            .toList(),
        checks: json['checks'] == null
            ? null
            : (json['checks'] as List<dynamic>)
                  .map(
                    (value) => PullRequestCheck.fromJson(
                      value as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
      );
}
