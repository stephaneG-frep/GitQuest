enum FileState { untracked, modified, staged, committed, conflicted }

class VirtualFile {
  VirtualFile(this.path, this.content, {this.state = FileState.untracked});

  final String path;
  String content;
  FileState state;

  VirtualFile copy() => VirtualFile(path, content, state: state);
}

class VirtualCommit {
  const VirtualCommit({
    required this.id,
    required this.message,
    required this.author,
    required this.createdAt,
    required this.parentIds,
    required this.snapshot,
  });

  final String id;
  final String message;
  final String author;
  final DateTime createdAt;
  final List<String> parentIds;
  final Map<String, String> snapshot;
}

class MergeConflict {
  const MergeConflict({
    required this.path,
    required this.baseContent,
    required this.currentContent,
    required this.incomingContent,
    required this.incomingBranch,
  });

  final String path;
  final String? baseContent;
  final String? currentContent;
  final String? incomingContent;
  final String incomingBranch;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'path': path,
    'baseContent': baseContent,
    'currentContent': currentContent,
    'incomingContent': incomingContent,
    'incomingBranch': incomingBranch,
  };

  factory MergeConflict.fromJson(Map<String, dynamic> json) => MergeConflict(
    path: json['path'] as String,
    baseContent: json['baseContent'] as String?,
    currentContent: json['currentContent'] as String?,
    incomingContent: json['incomingContent'] as String?,
    incomingBranch: json['incomingBranch'] as String,
  );
}

class VirtualRepository {
  VirtualRepository({this.name = 'atelier'}) {
    files['README.md'] = VirtualFile('README.md', '# Mon aventure GitQuest\n');
  }

  final String name;
  bool initialized = false;
  String currentBranch = 'main';
  final Map<String, VirtualFile> files = <String, VirtualFile>{};
  final Set<String> stagedFiles = <String>{};
  final List<VirtualCommit> commits = <VirtualCommit>[];
  final Map<String, String?> branches = <String, String?>{'main': null};
  final Map<String, String> remotes = <String, String>{};
  final Map<String, String> tags = <String, String>{};
  final Set<String> mergedBranches = <String>{};
  final List<Map<String, String>> stashes = <Map<String, String>>[];
  final List<String> commandHistory = <String>[];
  int successfulCommands = 0;
  int commandErrors = 0;
  int correctedErrors = 0;
  final Set<String> pendingCommandErrors = <String>{};
  final Map<String, int> dailyCommands = <String, int>{};
  final List<String> reflog = <String>[];
  final Map<String, MergeConflict> conflicts = <String, MergeConflict>{};
  String? pendingMergeBranch;
  int _commitSequence = 0;

  VirtualCommit createCommit(String message, {List<String>? parents}) {
    _commitSequence += 1;
    final id = (_commitSequence * 2654435761).toRadixString(16).substring(0, 7);
    final commit = VirtualCommit(
      id: id,
      message: message,
      author: 'Explorateur GitQuest',
      createdAt: DateTime.now(),
      parentIds:
          parents ??
          <String>[
            if (branches[currentBranch] case final String parent) parent,
          ],
      snapshot: <String, String>{
        for (final file in files.values) file.path: file.content,
      },
    );
    commits.add(commit);
    branches[currentBranch] = id;
    reflog.add('$id commit: $message');
    for (final path in stagedFiles) {
      files[path]?.state = FileState.committed;
    }
    stagedFiles.clear();
    return commit;
  }

  VirtualCommit amendHead(String message) {
    final previous = head!;
    final previousIndex = commits.indexOf(previous);
    _commitSequence += 1;
    final id = (_commitSequence * 2654435761).toRadixString(16).substring(0, 7);
    final snapshot = stagedFiles.isEmpty
        ? previous.snapshot
        : <String, String>{
            for (final file in files.values) file.path: file.content,
          };
    final amended = VirtualCommit(
      id: id,
      message: message,
      author: previous.author,
      createdAt: DateTime.now(),
      parentIds: previous.parentIds,
      snapshot: snapshot,
    );
    commits[previousIndex] = amended;
    branches[currentBranch] = id;
    for (final path in stagedFiles) {
      files[path]?.state = FileState.committed;
    }
    stagedFiles.clear();
    reflog.add('$id commit (amend): $message');
    return amended;
  }

  VirtualCommit? commitByReference(String reference) {
    if (reference == 'HEAD') return head;
    return commits
        .where((commit) => commit.id.startsWith(reference))
        .firstOrNull;
  }

  void checkoutSnapshot(Map<String, String> snapshot) {
    files
      ..clear()
      ..addEntries(
        snapshot.entries.map(
          (entry) => MapEntry(
            entry.key,
            VirtualFile(entry.key, entry.value, state: FileState.committed),
          ),
        ),
      );
    stagedFiles.clear();
  }

  VirtualCommit? get head {
    final id = branches[currentBranch];
    if (id == null) return null;
    return commits.where((commit) => commit.id == id).firstOrNull;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'initialized': initialized,
    'currentBranch': currentBranch,
    'files': <String, dynamic>{
      for (final file in files.values)
        file.path: <String, String>{
          'content': file.content,
          'state': file.state.name,
        },
    },
    'stagedFiles': stagedFiles.toList(),
    'branches': branches,
    'remotes': remotes,
    'tags': tags,
    'mergedBranches': mergedBranches.toList(),
    'stashes': stashes,
    'commandHistory': commandHistory,
    'successfulCommands': successfulCommands,
    'commandErrors': commandErrors,
    'correctedErrors': correctedErrors,
    'pendingCommandErrors': pendingCommandErrors.toList(),
    'dailyCommands': dailyCommands,
    'reflog': reflog,
    'pendingMergeBranch': pendingMergeBranch,
    'conflicts': conflicts.map(
      (path, conflict) => MapEntry(path, conflict.toJson()),
    ),
    'commitSequence': _commitSequence,
    'commits': commits
        .map(
          (commit) => <String, dynamic>{
            'id': commit.id,
            'message': commit.message,
            'author': commit.author,
            'createdAt': commit.createdAt.toIso8601String(),
            'parentIds': commit.parentIds,
            'snapshot': commit.snapshot,
          },
        )
        .toList(),
  };

  factory VirtualRepository.fromJson(Map<String, dynamic> json) {
    final repository = VirtualRepository(
      name: json['name'] as String? ?? 'atelier',
    );
    repository
      ..initialized = json['initialized'] as bool? ?? false
      ..currentBranch = json['currentBranch'] as String? ?? 'main'
      ..files.clear();
    final rawFiles =
        json['files'] as Map<String, dynamic>? ?? <String, dynamic>{};
    for (final entry in rawFiles.entries) {
      if (entry.value is String) {
        repository.files[entry.key] = VirtualFile(
          entry.key,
          entry.value as String,
        );
        continue;
      }
      final file = entry.value as Map<String, dynamic>;
      repository.files[entry.key] = VirtualFile(
        entry.key,
        file['content'] as String? ?? '',
        state:
            FileState.values
                .where((state) => state.name == file['state'])
                .firstOrNull ??
            FileState.untracked,
      );
    }
    repository.stagedFiles.addAll(
      (json['stagedFiles'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>(),
    );
    repository.branches
      ..clear()
      ..addAll(
        (json['branches'] as Map<String, dynamic>? ??
                <String, dynamic>{'main': null})
            .map((key, value) => MapEntry(key, value as String?)),
      );
    repository.remotes.addAll(
      (json['remotes'] as Map<String, dynamic>? ?? <String, dynamic>{}).map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
    repository.tags.addAll(
      (json['tags'] as Map<String, dynamic>? ?? <String, dynamic>{}).map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
    repository.mergedBranches.addAll(
      (json['mergedBranches'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>(),
    );
    for (final stash in json['stashes'] as List<dynamic>? ?? <dynamic>[]) {
      repository.stashes.add(
        (stash as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as String),
        ),
      );
    }
    repository.commandHistory.addAll(
      (json['commandHistory'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>(),
    );
    repository
      ..successfulCommands =
          json['successfulCommands'] as int? ?? repository.commandHistory.length
      ..commandErrors = json['commandErrors'] as int? ?? 0
      ..correctedErrors = json['correctedErrors'] as int? ?? 0;
    repository.pendingCommandErrors.addAll(
      (json['pendingCommandErrors'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>(),
    );
    repository.dailyCommands.addAll(
      (json['dailyCommands'] as Map<String, dynamic>? ?? <String, dynamic>{})
          .map((key, value) => MapEntry(key, (value as num).toInt())),
    );
    repository.reflog.addAll(
      (json['reflog'] as List<dynamic>? ?? <dynamic>[]).whereType<String>(),
    );
    repository.pendingMergeBranch = json['pendingMergeBranch'] as String?;
    final rawConflicts =
        json['conflicts'] as Map<String, dynamic>? ?? <String, dynamic>{};
    repository.conflicts.addAll(
      rawConflicts.map(
        (path, value) => MapEntry(
          path,
          MergeConflict.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
    for (final raw in json['commits'] as List<dynamic>? ?? <dynamic>[]) {
      final commit = raw as Map<String, dynamic>;
      repository.commits.add(
        VirtualCommit(
          id: commit['id'] as String,
          message: commit['message'] as String,
          author: commit['author'] as String? ?? 'Explorateur GitQuest',
          createdAt:
              DateTime.tryParse(commit['createdAt'] as String? ?? '') ??
              DateTime.now(),
          parentIds: (commit['parentIds'] as List<dynamic>? ?? <dynamic>[])
              .whereType<String>()
              .toList(),
          snapshot:
              (commit['snapshot'] as Map<String, dynamic>? ??
                      <String, dynamic>{})
                  .map((key, value) => MapEntry(key, value as String)),
        ),
      );
    }
    repository._commitSequence =
        json['commitSequence'] as int? ?? repository.commits.length;
    if (repository.files.isEmpty) {
      repository.files['README.md'] = VirtualFile(
        'README.md',
        '# Mon aventure GitQuest\n',
      );
    }
    return repository;
  }

  void restoreFromJson(Map<String, dynamic> json) {
    final restored = VirtualRepository.fromJson(json);
    initialized = restored.initialized;
    currentBranch = restored.currentBranch;
    files
      ..clear()
      ..addAll(restored.files);
    stagedFiles
      ..clear()
      ..addAll(restored.stagedFiles);
    commits
      ..clear()
      ..addAll(restored.commits);
    branches
      ..clear()
      ..addAll(restored.branches);
    remotes
      ..clear()
      ..addAll(restored.remotes);
    tags
      ..clear()
      ..addAll(restored.tags);
    mergedBranches
      ..clear()
      ..addAll(restored.mergedBranches);
    stashes
      ..clear()
      ..addAll(restored.stashes);
    commandHistory
      ..clear()
      ..addAll(restored.commandHistory);
    successfulCommands = restored.successfulCommands;
    commandErrors = restored.commandErrors;
    correctedErrors = restored.correctedErrors;
    pendingCommandErrors
      ..clear()
      ..addAll(restored.pendingCommandErrors);
    dailyCommands
      ..clear()
      ..addAll(restored.dailyCommands);
    reflog
      ..clear()
      ..addAll(restored.reflog);
    conflicts
      ..clear()
      ..addAll(restored.conflicts);
    pendingMergeBranch = restored.pendingMergeBranch;
    _commitSequence = restored._commitSequence;
  }

  void reset() {
    initialized = false;
    currentBranch = 'main';
    files
      ..clear()
      ..['README.md'] = VirtualFile('README.md', '# Mon aventure GitQuest\n');
    stagedFiles.clear();
    commits.clear();
    branches
      ..clear()
      ..['main'] = null;
    remotes.clear();
    tags.clear();
    mergedBranches.clear();
    stashes.clear();
    commandHistory.clear();
    successfulCommands = 0;
    commandErrors = 0;
    correctedErrors = 0;
    pendingCommandErrors.clear();
    dailyCommands.clear();
    reflog.clear();
    conflicts.clear();
    pendingMergeBranch = null;
    _commitSequence = 0;
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
