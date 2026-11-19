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

class RebaseOperation {
  RebaseOperation({
    required this.originalHeadId,
    required this.targetBranch,
    required this.pendingCommitIds,
  });

  final String originalHeadId;
  final String targetBranch;
  final List<String> pendingCommitIds;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'originalHeadId': originalHeadId,
    'targetBranch': targetBranch,
    'pendingCommitIds': pendingCommitIds,
  };

  factory RebaseOperation.fromJson(Map<String, dynamic> json) =>
      RebaseOperation(
        originalHeadId: json['originalHeadId'] as String,
        targetBranch: json['targetBranch'] as String,
        pendingCommitIds:
            (json['pendingCommitIds'] as List<dynamic>? ?? <dynamic>[])
                .whereType<String>()
                .toList(),
      );
}

/// An ongoing `git bisect` search.
class BisectSession {
  BisectSession({this.returnBranch, this.returnDetached});

  /// Where `git bisect reset` returns: a branch, or a detached commit.
  final String? returnBranch;
  final String? returnDetached;
  String? bad;
  final List<String> good = <String>[];

  Map<String, dynamic> toJson() => <String, dynamic>{
    'returnBranch': returnBranch,
    'returnDetached': returnDetached,
    'bad': bad,
    'good': good,
  };

  factory BisectSession.fromJson(Map<String, dynamic> json) =>
      BisectSession(
          returnBranch: json['returnBranch'] as String?,
          returnDetached: json['returnDetached'] as String?,
        )
        ..bad = json['bad'] as String?
        ..good.addAll(
          (json['good'] as List<dynamic>? ?? <dynamic>[]).whereType<String>(),
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
  RebaseOperation? pendingRebase;

  /// Commit pointed to directly by HEAD when it is detached from any branch.
  String? detachedHead;

  /// Branch that `git switch -` returns to.
  String? previousBranch;

  /// Tracked files removed from the index while kept on disk (`git rm --cached`).
  final Set<String> stagedRemovals = <String>{};

  /// Remote branch followed by each local branch, e.g. main → origin/main.
  final Map<String, String> upstreams = <String, String>{};

  /// Local copies of the remote branches (`origin/main`), updated by fetch,
  /// pull and push.
  final Map<String, String> remoteBranches = <String, String>{};

  /// Simulated state of the server itself. Other contributors (see
  /// `gitquest collegue`) change it without the local repository knowing.
  final Map<String, String> serverBranches = <String, String>{};

  /// Number of pushes refused because the server had unknown commits.
  int rejectedPushes = 0;

  BisectSession? bisect;

  /// First faulty commit found by the last bisect search.
  String? bisectCulprit;
  int _commitSequence = 0;

  bool get isDetached => detachedHead != null;

  bool get hasStagedChanges =>
      stagedFiles.isNotEmpty || stagedRemovals.isNotEmpty;

  /// Label shown in the prompt and the repository panel.
  String get headLabel =>
      isDetached ? 'HEAD détachée ${detachedHead!}' : currentBranch;

  String? get headId => detachedHead ?? branches[currentBranch];

  void _moveHead(String id) {
    if (isDetached) {
      detachedHead = id;
    } else {
      branches[currentBranch] = id;
    }
  }

  static const maxCommandHistory = 1000;
  static const maxReflog = 300;

  /// Generates a unique 7-character identifier.
  ///
  /// Multiplying by an odd constant modulo 2^28 is a bijection, so each
  /// sequence number below 2^28 yields a distinct identifier.
  String _nextCommitId() {
    final existing = commits.map((commit) => commit.id).toSet();
    while (true) {
      _commitSequence += 1;
      final id = ((_commitSequence * 2654435761) & 0xFFFFFFF)
          .toRadixString(16)
          .padLeft(7, '0');
      if (!existing.contains(id)) return id;
    }
  }

  /// Returns [base] updated with the content of the staged files.
  Map<String, String> snapshotWithStaged(Map<String, String> base) {
    final snapshot = Map<String, String>.from(base);
    for (final path in stagedFiles) {
      final file = files[path];
      if (file == null) {
        snapshot.remove(path);
      } else {
        snapshot[path] = file.content;
      }
    }
    for (final path in stagedRemovals) {
      snapshot.remove(path);
    }
    return snapshot;
  }

  void addReflog(String entry) {
    reflog.add(entry);
    if (reflog.length > maxReflog) {
      reflog.removeRange(0, reflog.length - maxReflog);
    }
  }

  void addCommandToHistory(String command) {
    commandHistory.add(command);
    if (commandHistory.length > maxCommandHistory) {
      commandHistory.removeRange(0, commandHistory.length - maxCommandHistory);
    }
  }

  VirtualCommit createCommit(String message, {List<String>? parents}) {
    final id = _nextCommitId();
    final snapshot = snapshotWithStaged(head?.snapshot ?? const {});
    final commit = VirtualCommit(
      id: id,
      message: message,
      author: 'Explorateur GitQuest',
      createdAt: DateTime.now(),
      parentIds:
          parents ?? <String>[if (headId case final String parent) parent],
      snapshot: snapshot,
    );
    commits.add(commit);
    _moveHead(id);
    addReflog('$id commit: $message');
    for (final path in stagedFiles) {
      files[path]?.state = FileState.committed;
    }
    stagedFiles.clear();
    stagedRemovals.clear();
    return commit;
  }

  /// Adds a commit without touching HEAD, the index or the working copy.
  /// Used to simulate work published by someone else.
  VirtualCommit addForeignCommit({
    required String message,
    required String author,
    required List<String> parentIds,
    required Map<String, String> snapshot,
  }) {
    final commit = VirtualCommit(
      id: _nextCommitId(),
      message: message,
      author: author,
      createdAt: DateTime.now(),
      parentIds: parentIds,
      snapshot: snapshot,
    );
    commits.add(commit);
    return commit;
  }

  VirtualCommit amendHead(String message) {
    final previous = head!;
    final previousIndex = commits.indexOf(previous);
    final id = _nextCommitId();
    final snapshot = snapshotWithStaged(previous.snapshot);
    final amended = VirtualCommit(
      id: id,
      message: message,
      author: previous.author,
      createdAt: DateTime.now(),
      parentIds: previous.parentIds,
      snapshot: snapshot,
    );
    commits[previousIndex] = amended;
    _moveHead(id);
    for (final path in stagedFiles) {
      files[path]?.state = FileState.committed;
    }
    stagedFiles.clear();
    stagedRemovals.clear();
    addReflog('$id commit (amend): $message');
    return amended;
  }

  VirtualCommit? commitByReference(String reference) {
    if (reference == 'HEAD') return head;
    final exact = commits.where((commit) => commit.id == reference).firstOrNull;
    if (exact != null || reference.isEmpty) return exact;
    final matches = commits
        .where((commit) => commit.id.startsWith(reference))
        .toList();
    return matches.length == 1 ? matches.single : null;
  }

  /// Replaces the tracked files with [snapshot].
  ///
  /// Like Git, untracked files that do not exist in the snapshot are kept.
  void checkoutSnapshot(Map<String, String> snapshot) {
    final untracked = files.values
        .where(
          (file) =>
              file.state == FileState.untracked &&
              !stagedFiles.contains(file.path) &&
              !snapshot.containsKey(file.path),
        )
        .toList();
    files
      ..clear()
      ..addEntries(
        snapshot.entries.map(
          (entry) => MapEntry(
            entry.key,
            VirtualFile(entry.key, entry.value, state: FileState.committed),
          ),
        ),
      )
      ..addEntries(untracked.map((file) => MapEntry(file.path, file)));
    stagedFiles.clear();
    stagedRemovals.clear();
  }

  VirtualCommit? get head {
    final id = headId;
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
    'stagedRemovals': stagedRemovals.toList(),
    'detachedHead': detachedHead,
    'previousBranch': previousBranch,
    'upstreams': upstreams,
    'remoteBranches': remoteBranches,
    'serverBranches': serverBranches,
    'rejectedPushes': rejectedPushes,
    'bisect': bisect?.toJson(),
    'bisectCulprit': bisectCulprit,
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
    'pendingRebase': pendingRebase?.toJson(),
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
    repository.stagedRemovals.addAll(
      (json['stagedRemovals'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>(),
    );
    repository
      ..detachedHead = json['detachedHead'] as String?
      ..previousBranch = json['previousBranch'] as String?;
    repository.upstreams.addAll(
      (json['upstreams'] as Map<String, dynamic>? ?? <String, dynamic>{}).map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
    repository.remoteBranches.addAll(
      (json['remoteBranches'] as Map<String, dynamic>? ?? <String, dynamic>{})
          .map((key, value) => MapEntry(key, value as String)),
    );
    repository.serverBranches.addAll(
      (json['serverBranches'] as Map<String, dynamic>? ?? <String, dynamic>{})
          .map((key, value) => MapEntry(key, value as String)),
    );
    repository
      ..rejectedPushes = json['rejectedPushes'] as int? ?? 0
      ..bisectCulprit = json['bisectCulprit'] as String?;
    if (json['bisect'] case final Map<String, dynamic> bisectJson) {
      repository.bisect = BisectSession.fromJson(bisectJson);
    }
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
    if (json['pendingRebase'] case final Map<String, dynamic> rebaseJson) {
      repository.pendingRebase = RebaseOperation.fromJson(rebaseJson);
    }
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
    repository._repairDuplicateCommitIds();
    if (repository.files.isEmpty) {
      repository.files['README.md'] = VirtualFile(
        'README.md',
        '# Mon aventure GitQuest\n',
      );
    }
    return repository;
  }

  /// Older versions could give two commits the same identifier (commit n and
  /// commit 16n). Each duplicate receives a new identifier and references are
  /// remapped: a parent points to the latest earlier commit with that id,
  /// branches, tags and pending operations point to the latest one.
  void _repairDuplicateCommitIds() {
    final ids = commits.map((commit) => commit.id).toList();
    if (ids.toSet().length == ids.length) return;
    final seen = <String>{};
    final newIds = <String>[];
    for (final id in ids) {
      if (seen.add(id)) {
        newIds.add(id);
        continue;
      }
      newIds.add(_nextCommitId());
    }
    String resolveBefore(String id, int index) {
      for (var i = index - 1; i >= 0; i--) {
        if (ids[i] == id) return newIds[i];
      }
      return id;
    }

    String resolveLatest(String id) {
      final index = ids.lastIndexOf(id);
      return index < 0 ? id : newIds[index];
    }

    final repaired = <VirtualCommit>[
      for (var i = 0; i < commits.length; i++)
        VirtualCommit(
          id: newIds[i],
          message: commits[i].message,
          author: commits[i].author,
          createdAt: commits[i].createdAt,
          parentIds: commits[i].parentIds
              .map((parent) => resolveBefore(parent, i))
              .toList(),
          snapshot: commits[i].snapshot,
        ),
    ];
    commits
      ..clear()
      ..addAll(repaired);
    for (final branch in branches.keys.toList()) {
      final target = branches[branch];
      if (target != null) branches[branch] = resolveLatest(target);
    }
    for (final tag in tags.keys.toList()) {
      tags[tag] = resolveLatest(tags[tag]!);
    }
    for (final refs in <Map<String, String>>[remoteBranches, serverBranches]) {
      for (final key in refs.keys.toList()) {
        refs[key] = resolveLatest(refs[key]!);
      }
    }
    if (detachedHead case final String id) detachedHead = resolveLatest(id);
    final rebase = pendingRebase;
    if (rebase != null) {
      pendingRebase = RebaseOperation(
        originalHeadId: resolveLatest(rebase.originalHeadId),
        targetBranch: rebase.targetBranch,
        pendingCommitIds: rebase.pendingCommitIds.map(resolveLatest).toList(),
      );
    }
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
    stagedRemovals
      ..clear()
      ..addAll(restored.stagedRemovals);
    upstreams
      ..clear()
      ..addAll(restored.upstreams);
    detachedHead = restored.detachedHead;
    previousBranch = restored.previousBranch;
    remoteBranches
      ..clear()
      ..addAll(restored.remoteBranches);
    serverBranches
      ..clear()
      ..addAll(restored.serverBranches);
    rejectedPushes = restored.rejectedPushes;
    bisect = restored.bisect;
    bisectCulprit = restored.bisectCulprit;
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
    pendingRebase = restored.pendingRebase;
    _commitSequence = restored._commitSequence;
  }

  void reset() {
    initialized = false;
    currentBranch = 'main';
    files
      ..clear()
      ..['README.md'] = VirtualFile('README.md', '# Mon aventure GitQuest\n');
    stagedFiles.clear();
    stagedRemovals.clear();
    upstreams.clear();
    remoteBranches.clear();
    serverBranches.clear();
    rejectedPushes = 0;
    bisect = null;
    bisectCulprit = null;
    detachedHead = null;
    previousBranch = null;
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
    pendingRebase = null;
    _commitSequence = 0;
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
