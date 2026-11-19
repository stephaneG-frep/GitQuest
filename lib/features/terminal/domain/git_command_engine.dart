import 'virtual_repository.dart';

enum TerminalOutputType { success, info, warning, error }

class CommandResult {
  const CommandResult(this.text, {this.type = TerminalOutputType.info});

  final String text;
  final TerminalOutputType type;
  bool get isSuccess => type != TerminalOutputType.error;
}

class GitCommandEngine {
  GitCommandEngine(this.repository, {this.onChanged});

  final VirtualRepository repository;
  final void Function(VirtualRepository repository)? onChanged;

  void resetRepository() {
    repository.reset();
    onChanged?.call(repository);
  }

  CommandResult editConflict(String path, String content) {
    if (!repository.conflicts.containsKey(path)) {
      return CommandResult(
        '$path n’est pas en conflit.',
        type: TerminalOutputType.error,
      );
    }
    repository.files[path] = VirtualFile(
      path,
      content,
      state: FileState.modified,
    );
    onChanged?.call(repository);
    return CommandResult(
      'Contenu personnalisé enregistré dans $path.\nVérifie-le, puis exécute git add $path.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult execute(String input) {
    final result = _execute(input);
    if (input.trim().isNotEmpty) {
      _recordResult(input, result);
      onChanged?.call(repository);
    }
    return result;
  }

  void _recordResult(String input, CommandResult result) {
    final args = _tokenize(input.trim());
    if (args.isEmpty) return;
    final command = args.first == 'git' && args.length > 1
        ? 'git ${args[1]}'
        : args.first;
    if (result.isSuccess) {
      repository.successfulCommands += 1;
      if (repository.pendingCommandErrors.remove(command)) {
        repository.correctedErrors += 1;
      }
    } else {
      repository.commandErrors += 1;
      repository.pendingCommandErrors.add(command);
    }
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    repository.dailyCommands.update(
      date,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }

  CommandResult _execute(String input) {
    final command = input.trim();
    if (command.isEmpty) return const CommandResult('');
    repository.addCommandToHistory(command);
    final args = _tokenize(command);
    if (args.isEmpty) return const CommandResult('');
    if (args.first == 'help') return _help();
    if (args.first == 'pwd') {
      return CommandResult('/home/gitquest/${repository.name}');
    }
    if (args.first == 'ls') {
      return CommandResult(repository.files.keys.join('  '));
    }
    if (args.first == 'touch') return _touch(args);
    if (args.first == 'cat') return _cat(args);
    if (args.first == 'echo') return _echo(args);
    if (args.first == 'clear') return const CommandResult('__CLEAR__');
    if (args.first == 'gitquest') return _scenario(args);
    if (args.first != 'git') {
      return CommandResult(
        'Commande inconnue : ${args.first}\nTape “help” pour voir les commandes disponibles.',
        type: TerminalOutputType.error,
      );
    }
    if (args.length == 1) {
      return const CommandResult(
        'Il manque une sous-commande. Essaie : git status',
        type: TerminalOutputType.error,
      );
    }
    if (repository.isDetached && _blockedWhenDetached.contains(args[1])) {
      return CommandResult(
        'HEAD est détachée sur ${repository.detachedHead}.\nCrée d’abord une branche avec git switch -c nom-branche, ou reviens sur une branche avec git switch main.',
        type: TerminalOutputType.error,
      );
    }
    return switch (args[1]) {
      'init' => _init(),
      'clone' => _clone(args),
      'bisect' => _bisect(args),
      'rm' => _rm(args),
      'mv' => _mv(args),
      'status' => _status(),
      'add' => _add(args),
      'commit' => _commit(args),
      'log' => _log(args),
      'branch' => _branch(args),
      'switch' || 'checkout' => _switch(args),
      'merge' => _merge(args),
      'diff' => _diff(args),
      'restore' => _restore(args),
      'reset' => _reset(args),
      'revert' => _revert(args),
      'stash' => _stash(args),
      'tag' => _tag(args),
      'reflog' => _reflog(),
      'cherry-pick' => _cherryPick(args),
      'rebase' => _rebase(args),
      'remote' => _remote(args),
      'push' || 'pull' || 'fetch' => _network(args),
      'comit' => const CommandResult(
        'Commande inconnue : git comit\nTu voulais probablement écrire :\ngit commit -m "Mon message"',
        type: TerminalOutputType.error,
      ),
      'stats' => const CommandResult(
        'Commande inconnue : git stats\nTu voulais probablement écrire : git status',
        type: TerminalOutputType.error,
      ),
      'chekout' => const CommandResult(
        'Commande inconnue : git chekout\nUtilise plutôt : git switch nom-branche',
        type: TerminalOutputType.error,
      ),
      _ => CommandResult(
        'Sous-commande Git non reconnue : ${args[1]}\nTape “help” pour consulter les commandes simulées.',
        type: TerminalOutputType.error,
      ),
    };
  }

  static const _blockedWhenDetached = <String>{
    'merge',
    'rebase',
    'reset',
    'revert',
    'cherry-pick',
    'stash',
    'push',
    'pull',
  };

  bool _refExists(String name) =>
      repository.branches.containsKey(name) ||
      repository.remoteBranches.containsKey(name);

  /// Resolves a branch, a remote branch (origin/main), a tag or a commit.
  String? _resolveRef(String name) {
    if (repository.branches.containsKey(name)) {
      return repository.branches[name];
    }
    return repository.remoteBranches[name] ??
        repository.tags[name] ??
        (name == 'HEAD' ? repository.headId : null) ??
        repository.commitByReference(name)?.id;
  }

  /// Commits reachable from [local] but not [remote], and the reverse.
  (int, int) _aheadBehind(String? local, String? remote) {
    final localSet = local == null ? <String>{} : _ancestorIds(local);
    final remoteSet = remote == null ? <String>{} : _ancestorIds(remote);
    return (
      localSet.difference(remoteSet).length,
      remoteSet.difference(localSet).length,
    );
  }

  String _plural(int count, String word) =>
      '$count $word${count > 1 ? 's' : ''}';

  String _trackingStatus(String branch, String upstream) {
    final remote = repository.remoteBranches[upstream];
    if (remote == null) return 'Ta branche suit $upstream.';
    final (ahead, behind) = _aheadBehind(repository.branches[branch], remote);
    if (ahead == 0 && behind == 0) {
      return 'Ta branche suit $upstream et elle est à jour.';
    }
    if (behind == 0) {
      return 'Ta branche suit $upstream : en avance de ${_plural(ahead, 'commit')}.\n  (utilise git push pour publier)';
    }
    if (ahead == 0) {
      return 'Ta branche suit $upstream : en retard de ${_plural(behind, 'commit')}.\n  (utilise git pull pour te mettre à jour)';
    }
    return 'Ta branche suit $upstream : elle a divergé, ${_plural(ahead, 'commit')} local(aux) et ${_plural(behind, 'commit')} distant(s).\n  (utilise git pull --rebase, puis git push)';
  }

  String _trackingLabel(String branch, String upstream) {
    final remote = repository.remoteBranches[upstream];
    if (remote == null) return upstream;
    final (ahead, behind) = _aheadBehind(repository.branches[branch], remote);
    final parts = <String>[
      if (ahead > 0) 'ahead $ahead',
      if (behind > 0) 'behind $behind',
    ];
    return parts.isEmpty ? upstream : '$upstream: ${parts.join(', ')}';
  }

  String get _branchLabel =>
      repository.isDetached ? 'HEAD détachée' : repository.currentBranch;

  List<String> _tokenize(String input) {
    final matches = RegExp(
      r'''[^\s"']+|"([^"]*)"|'([^']*)' ''',
    ).allMatches('$input ');
    return matches
        .map(
          (match) => match.group(1) ?? match.group(2) ?? match.group(0)!.trim(),
        )
        .where((value) => value.isNotEmpty)
        .toList();
  }

  CommandResult _help() => const CommandResult('''Commandes disponibles
  help, clear, pwd, ls, touch, cat, echo
  git init, clone, status, add, commit, log, diff
  git rm, mv
  git branch, switch, checkout, merge
  git restore, reset, revert, stash (pop, list), tag, reflog
  git cherry-pick, rebase
  git remote, push, pull, fetch
  git bisect start, bad, good, reset

Scénarios du laboratoire :
  gitquest collegue    une collègue pousse un commit sur le distant
  gitquest regression  prépare un historique contenant un bug

Astuce : commence par git init, puis git status.''');

  CommandResult _touch(List<String> args) {
    if (args.length < 2) {
      return const CommandResult(
        'Indique un fichier : touch notes.txt',
        type: TerminalOutputType.error,
      );
    }
    repository.files.putIfAbsent(args[1], () => VirtualFile(args[1], ''));
    return CommandResult(
      'Fichier ${args[1]} créé.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _cat(List<String> args) {
    if (args.length < 2 || !repository.files.containsKey(args[1])) {
      return const CommandResult(
        'Fichier introuvable.',
        type: TerminalOutputType.error,
      );
    }
    return CommandResult(repository.files[args[1]]!.content);
  }

  CommandResult _echo(List<String> args) {
    if (args.length < 4 || args[args.length - 2] != '>') {
      return const CommandResult(
        'Exemple : echo "Bonjour" > notes.txt',
        type: TerminalOutputType.error,
      );
    }
    final path = args.last;
    final content = args.sublist(1, args.length - 2).join(' ');
    final existing = repository.files[path];
    final file = repository.files.putIfAbsent(
      path,
      () => VirtualFile(path, content),
    );
    file.content = content;
    if (existing == null || existing.state == FileState.untracked) {
      file.state = FileState.untracked;
    } else if (!repository.stagedFiles.contains(path) &&
        repository.conflicts[path] == null &&
        repository.head?.snapshot[path] == content) {
      file.state = FileState.committed;
    } else {
      file.state = FileState.modified;
    }
    return CommandResult(
      '$path a été modifié.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _init() {
    if (repository.initialized) {
      return const CommandResult(
        'Dépôt Git déjà initialisé.',
        type: TerminalOutputType.warning,
      );
    }
    repository.initialized = true;
    return CommandResult(
      'Dépôt Git vide initialisé dans /home/gitquest/${repository.name}/.git/',
      type: TerminalOutputType.success,
    );
  }

  CommandResult? _requireRepository() => repository.initialized
      ? null
      : const CommandResult(
          'Ce dossier n’est pas encore un dépôt Git.\nCommence par : git init',
          type: TerminalOutputType.error,
        );

  CommandResult _status() {
    final error = _requireRepository();
    if (error != null) return error;
    final untracked = repository.files.values
        .where((file) => file.state == FileState.untracked)
        .map((file) => file.path)
        .toList();
    final modified = repository.files.values
        .where((file) => file.state == FileState.modified)
        .map((file) => file.path)
        .toList();
    final saved = repository.head?.snapshot ?? <String, String>{};
    final staged = <String>[
      for (final path in repository.stagedFiles)
        '${!repository.files.containsKey(path)
            ? 'D'
            : saved.containsKey(path)
            ? 'M'
            : 'A'}  $path',
      for (final path in repository.stagedRemovals) 'D  $path',
    ];
    final conflicted = repository.conflicts.keys.toList();
    final buffer = StringBuffer(
      repository.isDetached
          ? 'HEAD détachée sur ${repository.detachedHead}\n'
          : 'Sur la branche ${repository.currentBranch}\n',
    );
    final upstream = repository.isDetached
        ? null
        : repository.upstreams[repository.currentBranch];
    if (upstream != null) {
      buffer.writeln(_trackingStatus(repository.currentBranch, upstream));
    }
    if (repository.commits.isEmpty) {
      buffer.writeln('Aucun commit pour le moment');
    }
    if (staged.isNotEmpty) {
      buffer.writeln(
        '\nModifications qui seront validées :\n  ${staged.join('\n  ')}',
      );
    }
    if (conflicted.isNotEmpty) {
      buffer.writeln(
        '\nChemins non fusionnés :\n  U  ${conflicted.join('\n  U  ')}\n\nRésous chaque fichier, puis utilise git add.',
      );
    }
    if (repository.pendingRebase != null) {
      buffer.writeln(
        '\nRebase en cours sur ${repository.pendingRebase!.targetBranch}.\nRésous et prépare les fichiers, puis utilise git rebase --continue.',
      );
    }
    if (modified.isNotEmpty) {
      buffer.writeln(
        '\nModifications non indexées :\n  M  ${modified.join('\n  M  ')}',
      );
    }
    if (untracked.isNotEmpty) {
      buffer.writeln(
        '\nFichiers non suivis :\n  ?  ${untracked.join('\n  ?  ')}',
      );
    }
    if (staged.isEmpty &&
        modified.isEmpty &&
        untracked.isEmpty &&
        conflicted.isEmpty) {
      buffer.writeln('Rien à valider, la copie de travail est propre.');
    }
    return CommandResult(buffer.toString().trim());
  }

  CommandResult _add(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length < 3) {
      return const CommandResult(
        'Il manque le fichier à préparer.\nExemple : git add README.md\nOu : git add .',
        type: TerminalOutputType.error,
      );
    }
    final paths = args[2] == '.'
        ? repository.files.values
              .where((file) => file.state != FileState.committed)
              .map((file) => file.path)
              .toList()
        : args.sublist(2);
    if (paths.isEmpty) {
      return const CommandResult(
        'Aucun changement à préparer : la copie de travail est propre.',
        type: TerminalOutputType.warning,
      );
    }
    final missing = paths
        .where((path) => !repository.files.containsKey(path))
        .toList();
    if (missing.isNotEmpty) {
      return CommandResult(
        'Fichier introuvable : ${missing.first}',
        type: TerminalOutputType.error,
      );
    }
    for (final path in paths) {
      repository.stagedRemovals.remove(path);
      repository.stagedFiles.add(path);
      repository.files[path]!.state = FileState.staged;
      repository.conflicts.remove(path);
    }
    return CommandResult(
      '${paths.length} fichier(s) placé(s) dans la zone de préparation.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _commit(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    final messageIndex = args.indexOf('-m');
    final amend = args.contains('--amend');
    if (amend && repository.head == null) {
      return const CommandResult(
        'Aucun commit à modifier. Crée d’abord un premier commit.',
        type: TerminalOutputType.error,
      );
    }
    if (amend &&
        (repository.conflicts.isNotEmpty ||
            repository.pendingRebase != null ||
            repository.pendingMergeBranch != null)) {
      return const CommandResult(
        'Une fusion ou un rebase est en cours. Termine-le ou annule-le avant de modifier le dernier commit.',
        type: TerminalOutputType.error,
      );
    }
    if (amend) {
      final message = messageIndex >= 0 && messageIndex + 1 < args.length
          ? args[messageIndex + 1]
          : repository.head!.message;
      final commit = repository.amendHead(message);
      return CommandResult(
        '[$_branchLabel ${commit.id}] $message\nLe dernier commit a été remplacé. Son identifiant a changé.',
        type: TerminalOutputType.success,
      );
    }
    if (messageIndex < 0 || messageIndex + 1 >= args.length) {
      return const CommandResult(
        'Il manque un message.\nUtilise : git commit -m "Décris ton changement"',
        type: TerminalOutputType.error,
      );
    }
    if (repository.conflicts.isNotEmpty) {
      return const CommandResult(
        'La fusion contient encore des conflits. Résous-les avant de créer le commit.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.pendingRebase != null) {
      return const CommandResult(
        'Un rebase est en cours. Utilise git rebase --continue après avoir préparé les fichiers, ou git rebase --abort.',
        type: TerminalOutputType.error,
      );
    }
    if (!repository.hasStagedChanges) {
      return const CommandResult(
        'Aucun changement préparé.\nUtilise d’abord git add.',
        type: TerminalOutputType.error,
      );
    }
    final pendingMerge = repository.pendingMergeBranch;
    final currentHead = repository.head?.id;
    final incomingHead = pendingMerge == null
        ? null
        : repository.branches[pendingMerge];
    final commit = repository.createCommit(
      args[messageIndex + 1],
      parents:
          pendingMerge != null && currentHead != null && incomingHead != null
          ? <String>[currentHead, incomingHead]
          : null,
    );
    if (pendingMerge != null) {
      repository.mergedBranches.add(pendingMerge);
      repository.pendingMergeBranch = null;
    }
    return CommandResult(
      '[$_branchLabel ${commit.id}] ${commit.message}\n${commit.snapshot.length} fichier(s) enregistré(s).',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _log(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    final all = args.contains('--all');
    final reachable = all
        ? repository.commits.map((commit) => commit.id).toSet()
        : repository.headId == null
        ? <String>{}
        : _ancestorIds(repository.headId!);
    final shown = repository.commits.reversed
        .where((commit) => reachable.contains(commit.id))
        .toList();
    if (shown.isEmpty) {
      return const CommandResult(
        'Aucun commit dans l’historique.',
        type: TerminalOutputType.warning,
      );
    }
    final decorations = _decorations();
    String label(VirtualCommit commit) {
      final refs = decorations[commit.id];
      return refs == null ? '' : ' (${refs.join(', ')})';
    }

    if (args.contains('--graph')) {
      return CommandResult(_graph(shown, label));
    }
    final compact = args.contains('--oneline');
    return CommandResult(
      shown
          .map(
            (commit) => compact
                ? '${commit.id}${label(commit)} ${commit.message}'
                : 'commit ${commit.id}${label(commit)}\nAuteur: ${commit.author}\n\n    ${commit.message}',
          )
          .join('\n${compact ? '' : '\n'}'),
    );
  }

  /// References pointing to each commit: HEAD, branches and tags.
  Map<String, List<String>> _decorations() {
    final result = <String, List<String>>{};
    void add(String? id, String label) {
      if (id != null) result.putIfAbsent(id, () => <String>[]).add(label);
    }

    if (repository.isDetached) add(repository.detachedHead, 'HEAD');
    for (final entry in repository.branches.entries) {
      final isCurrent =
          !repository.isDetached && entry.key == repository.currentBranch;
      add(entry.value, isCurrent ? 'HEAD -> ${entry.key}' : entry.key);
    }
    for (final entry in repository.remoteBranches.entries) {
      add(entry.value, entry.key);
    }
    for (final entry in repository.tags.entries) {
      add(entry.value, 'tag: ${entry.key}');
    }
    for (final refs in result.values) {
      refs.sort((a, b) {
        int rank(String ref) => ref.startsWith('HEAD')
            ? 0
            : ref.startsWith('tag:')
            ? 2
            : 1;
        return rank(a).compareTo(rank(b));
      });
    }
    return result;
  }

  /// Draws a simplified text graph: one lane per line of development.
  String _graph(
    List<VirtualCommit> commits,
    String Function(VirtualCommit commit) label,
  ) {
    final lines = <String>[];
    final lanes = <String?>[];
    String row(int? commitLane) => List<String>.generate(
      lanes.length,
      (i) => i == commitLane ? '*' : (lanes[i] == null ? ' ' : '|'),
    ).join(' ').trimRight();

    void trim() {
      while (lanes.isNotEmpty && lanes.last == null) {
        lanes.removeLast();
      }
    }

    for (final commit in commits) {
      var lane = lanes.indexOf(commit.id);
      if (lane < 0) {
        lane = lanes.indexOf(null);
        if (lane < 0) {
          lanes.add(commit.id);
          lane = lanes.length - 1;
        } else {
          lanes[lane] = commit.id;
        }
      }
      // Other lanes waiting for this commit join it here.
      final joining = <int>[
        for (var i = lane + 1; i < lanes.length; i++)
          if (lanes[i] == commit.id) i,
      ];
      if (joining.isNotEmpty) {
        final chars = row(null).padRight(lanes.length * 2).split('');
        for (final i in joining) {
          chars[i * 2] = ' ';
          chars[i * 2 - 1] = '/';
          lanes[i] = null;
        }
        lines.add(chars.join().trimRight());
        trim();
      }
      lines.add('${row(lane)} ${commit.id}${label(commit)} ${commit.message}');
      lanes[lane] = commit.parentIds.firstOrNull;
      final extraParents = commit.parentIds.skip(1).toList();
      for (final parent in extraParents) {
        if (lanes.contains(parent)) continue;
        var target = lanes.indexOf(null);
        if (target < 0 || target < lane) {
          lanes.add(parent);
          target = lanes.length - 1;
        } else {
          lanes[target] = parent;
        }
        final chars = row(null).padRight(lanes.length * 2).split('');
        chars[target * 2] = ' ';
        chars[target * 2 - 1] = r'\';
        lines.add(chars.join().trimRight());
      }
      trim();
    }
    return lines.join('\n');
  }

  CommandResult _branch(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length == 2 || args[2] == '-v' || args[2] == '-vv') {
      final verbose = args.length > 2;
      final lines = <String>[
        if (repository.isDetached)
          '* (HEAD détachée sur ${repository.detachedHead})',
        for (final name in repository.branches.keys)
          [
            !repository.isDetached && name == repository.currentBranch
                ? '*'
                : ' ',
            name,
            if (verbose) repository.branches[name] ?? '(aucun commit)',
            if (args.length > 2 &&
                args[2] == '-vv' &&
                repository.upstreams[name] != null)
              '[${_trackingLabel(name, repository.upstreams[name]!)}]',
          ].join(' '),
      ];
      return CommandResult(lines.join('\n'));
    }
    if (args[2] == '-d' || args[2] == '-D') {
      if (args.length < 4) {
        return const CommandResult(
          'Indique la branche à supprimer.',
          type: TerminalOutputType.error,
        );
      }
      if (!repository.isDetached && args[3] == repository.currentBranch) {
        return const CommandResult(
          'Impossible de supprimer la branche courante.',
          type: TerminalOutputType.error,
        );
      }
      if (!repository.branches.containsKey(args[3])) {
        return CommandResult(
          'Branche introuvable : ${args[3]}',
          type: TerminalOutputType.error,
        );
      }
      final branchHead = repository.branches[args[3]];
      final currentHead = repository.headId;
      final merged =
          branchHead == null ||
          (currentHead != null && _isAncestor(branchHead, currentHead));
      if (args[2] == '-d' && !merged) {
        return CommandResult(
          'La branche ${args[3]} n’est pas entièrement fusionnée.\nFusionne-la d’abord, ou force la suppression avec git branch -D ${args[3]}.',
          type: TerminalOutputType.error,
        );
      }
      repository.branches.remove(args[3]);
      repository.upstreams.remove(args[3]);
      return CommandResult(
        'Branche ${args[3]} supprimée.',
        type: TerminalOutputType.success,
      );
    }
    if (repository.branches.containsKey(args[2])) {
      return const CommandResult(
        'Cette branche existe déjà.',
        type: TerminalOutputType.error,
      );
    }
    var startId = repository.headId;
    if (args.length > 3) {
      final start = repository.commitByReference(args[3]);
      if (start == null) {
        return CommandResult(
          'Commit introuvable : ${args[3]}',
          type: TerminalOutputType.error,
        );
      }
      startId = start.id;
    }
    repository.branches[args[2]] = startId;
    return CommandResult(
      'Branche ${args[2]} créée${args.length > 3 ? ' sur $startId' : ''}.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _switch(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length < 3) {
      return const CommandResult(
        'Indique une branche : git switch main',
        type: TerminalOutputType.error,
      );
    }
    if (args[2] == '--ours' || args[2] == '--theirs') {
      if (args.length < 4) {
        return const CommandResult(
          'Indique le fichier en conflit à résoudre.',
          type: TerminalOutputType.error,
        );
      }
      final path = args[3];
      final conflict = repository.conflicts[path];
      if (conflict == null) {
        return CommandResult(
          '$path n’est pas en conflit.',
          type: TerminalOutputType.error,
        );
      }
      final content = args[2] == '--ours'
          ? conflict.currentContent
          : conflict.incomingContent;
      repository.files[path] = VirtualFile(
        path,
        content ?? '',
        state: FileState.modified,
      );
      return CommandResult(
        'Version ${args[2] == '--ours' ? 'actuelle' : 'entrante'} choisie pour $path.\nVérifie le fichier, puis exécute git add $path.',
        type: TerminalOutputType.success,
      );
    }
    if (repository.conflicts.isNotEmpty || repository.pendingRebase != null) {
      return const CommandResult(
        'Termine ou annule l’opération en cours avant de changer de branche.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.hasStagedChanges ||
        repository.files.values.any(
          (file) => file.state == FileState.modified,
        )) {
      return const CommandResult(
        'Des changements locaux risquent d’être écrasés. Crée un commit ou utilise git stash avant de changer de branche.',
        type: TerminalOutputType.error,
      );
    }
    if (args[2] == '--detach' || args[2] == '-d') {
      if (args.length < 4) {
        return const CommandResult(
          'Indique le commit à explorer : git switch --detach abc1234',
          type: TerminalOutputType.error,
        );
      }
      return _detach(args[3]);
    }
    var targetIndex = 2;
    var created = false;
    if (args[2] == '-c' || (args[1] == 'checkout' && args[2] == '-b')) {
      if (args.length < 4) {
        return const CommandResult(
          'Indique le nom de la nouvelle branche.',
          type: TerminalOutputType.error,
        );
      }
      targetIndex = 3;
      if (repository.branches.containsKey(args[targetIndex])) {
        return const CommandResult(
          'Cette branche existe déjà.',
          type: TerminalOutputType.error,
        );
      }
      repository.branches[args[targetIndex]] = repository.headId;
      created = true;
    }
    var target = args[targetIndex];
    if (target == '-') {
      final previous = repository.previousBranch;
      if (previous == null || !repository.branches.containsKey(previous)) {
        return const CommandResult(
          'Aucune branche précédente où revenir.',
          type: TerminalOutputType.error,
        );
      }
      target = previous;
    }
    if (!repository.branches.containsKey(target)) {
      if (repository.commitByReference(target) != null) {
        if (args[1] == 'checkout') return _detach(target);
        return CommandResult(
          '$target est un commit, pas une branche.\nPour l’explorer, utilise git switch --detach $target',
          type: TerminalOutputType.error,
        );
      }
      return CommandResult(
        'Branche inconnue : $target\nCrée-la avec git switch -c $target',
        type: TerminalOutputType.error,
      );
    }
    final orphanWarning = _orphanWarning(target);
    if (!repository.isDetached && repository.currentBranch != target) {
      repository.previousBranch = repository.currentBranch;
    }
    repository
      ..detachedHead = null
      ..currentBranch = target;
    final targetHead = repository.head;
    if (targetHead != null && !created) {
      repository.checkoutSnapshot(targetHead.snapshot);
    }
    repository.addReflog('${targetHead?.id ?? '0000000'} checkout: $target');
    return CommandResult(
      '${created ? 'Nouvelle branche' : 'Basculement sur la branche'} “$target”.$orphanWarning',
      type: orphanWarning.isEmpty
          ? TerminalOutputType.success
          : TerminalOutputType.warning,
    );
  }

  CommandResult _detach(String reference) {
    final commit = repository.commitByReference(reference);
    if (commit == null) {
      return CommandResult(
        'Commit introuvable : $reference',
        type: TerminalOutputType.error,
      );
    }
    if (!repository.isDetached) {
      repository.previousBranch = repository.currentBranch;
    }
    repository.detachedHead = commit.id;
    repository.checkoutSnapshot(commit.snapshot);
    repository.addReflog('${commit.id} checkout: détachement sur ${commit.id}');
    return CommandResult(
      'HEAD est maintenant détachée sur ${commit.id} “${commit.message}”.\nTu peux explorer et faire des essais. Pour garder un commit créé ici, crée une branche : git switch -c nom-branche.\nPour revenir : git switch ${repository.previousBranch ?? 'main'}',
      type: TerminalOutputType.warning,
    );
  }

  /// Warns when leaving a detached HEAD whose commits no branch contains.
  String _orphanWarning(String targetBranch) {
    final detached = repository.detachedHead;
    if (detached == null) return '';
    final kept = repository.branches.values.whereType<String>().any(
      (id) => _isAncestor(detached, id),
    );
    if (kept) return '';
    return '\nAttention : le commit $detached n’appartient à aucune branche.\nPour le garder : git branch sauvetage $detached';
  }

  CommandResult _merge(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (repository.pendingRebase != null) {
      return const CommandResult(
        'Termine ou annule le rebase avant de lancer une fusion.',
        type: TerminalOutputType.error,
      );
    }
    if (args.length >= 3 && args[2] == '--abort') {
      if (repository.pendingMergeBranch == null) {
        return const CommandResult(
          'Aucune fusion en cours à annuler.',
          type: TerminalOutputType.warning,
        );
      }
      repository.checkoutSnapshot(
        repository.head?.snapshot ?? <String, String>{},
      );
      repository
        ..conflicts.clear()
        ..pendingMergeBranch = null;
      return const CommandResult(
        'Fusion annulée. La copie de travail a été restaurée.',
        type: TerminalOutputType.success,
      );
    }
    if (args.length < 3) {
      return const CommandResult(
        'Indique une branche à fusionner : git merge feature',
        type: TerminalOutputType.error,
      );
    }
    final source = args[2];
    if (!_refExists(source)) {
      return CommandResult(
        'Branche inconnue : $source',
        type: TerminalOutputType.error,
      );
    }
    if (source == repository.currentBranch) {
      return const CommandResult(
        'Impossible de fusionner une branche avec elle-même.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.pendingMergeBranch != null) {
      return const CommandResult(
        'Une fusion est déjà en cours. Résous-la ou utilise git merge --abort.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.hasStagedChanges ||
        repository.files.values.any(
          (file) => file.state == FileState.modified,
        )) {
      return const CommandResult(
        'La copie de travail doit être propre avant une fusion.',
        type: TerminalOutputType.error,
      );
    }
    final sourceHeadId = _resolveRef(source);
    final currentHeadId = repository.branches[repository.currentBranch];
    if (sourceHeadId == null || sourceHeadId == currentHeadId) {
      repository.mergedBranches.add(source);
      return const CommandResult(
        'Déjà à jour.',
        type: TerminalOutputType.success,
      );
    }
    final sourceHead = repository.commitByReference(sourceHeadId)!;
    if (currentHeadId == null || _isAncestor(currentHeadId, sourceHeadId)) {
      repository.branches[repository.currentBranch] = sourceHeadId;
      repository.checkoutSnapshot(sourceHead.snapshot);
      repository.mergedBranches.add(source);
      repository.addReflog('$sourceHeadId merge $source: fast-forward');
      return CommandResult(
        'Mise à jour en avance rapide vers $sourceHeadId.\nBranche $source fusionnée.',
        type: TerminalOutputType.success,
      );
    }
    if (_isAncestor(sourceHeadId, currentHeadId)) {
      repository.mergedBranches.add(source);
      return const CommandResult(
        'Déjà à jour.',
        type: TerminalOutputType.success,
      );
    }
    final currentHead = repository.commitByReference(currentHeadId)!;
    final base = _commonAncestor(currentHeadId, sourceHeadId);
    final baseSnapshot = base?.snapshot ?? <String, String>{};
    final merged = Map<String, String>.from(currentHead.snapshot);
    final conflicts = <String, MergeConflict>{};
    final paths = <String>{
      ...baseSnapshot.keys,
      ...currentHead.snapshot.keys,
      ...sourceHead.snapshot.keys,
    };
    for (final path in paths) {
      final original = baseSnapshot[path];
      final ours = currentHead.snapshot[path];
      final theirs = sourceHead.snapshot[path];
      final oursChanged = ours != original;
      final theirsChanged = theirs != original;
      if (oursChanged && theirsChanged && ours != theirs) {
        conflicts[path] = MergeConflict(
          path: path,
          baseContent: original,
          currentContent: ours,
          incomingContent: theirs,
          incomingBranch: source,
        );
        continue;
      }
      if (!oursChanged && theirsChanged) {
        if (theirs == null) {
          merged.remove(path);
        } else {
          merged[path] = theirs;
        }
      }
    }
    repository.checkoutSnapshot(merged);
    final mergedChanges = _changesBetween(currentHead.snapshot, merged);
    repository.stagedFiles.addAll(mergedChanges);
    for (final path in mergedChanges.where(repository.files.containsKey)) {
      repository.files[path]!.state = FileState.staged;
    }
    if (conflicts.isNotEmpty) {
      repository
        ..conflicts.addAll(conflicts)
        ..pendingMergeBranch = source;
      repository.addReflog(
        '$currentHeadId merge $source: conflit dans ${conflicts.keys.join(', ')}',
      );
      for (final conflict in conflicts.values) {
        repository.files[conflict.path] = VirtualFile(
          conflict.path,
          '<<<<<<< ${repository.currentBranch}\n${conflict.currentContent ?? ''}\n=======\n${conflict.incomingContent ?? ''}\n>>>>>>> $source',
          state: FileState.conflicted,
        );
      }
      return CommandResult(
        'Conflit de fusion dans ${conflicts.keys.join(', ')}.\nChoisis une version avec git checkout --ours fichier ou git checkout --theirs fichier, puis utilise git add et git commit.',
        type: TerminalOutputType.warning,
      );
    }
    repository.createCommit(
      'Fusion de $source',
      parents: <String>[currentHeadId, sourceHeadId],
    );
    repository.mergedBranches.add(source);
    return CommandResult(
      'Branche $source fusionnée dans ${repository.currentBranch}.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _cherryPick(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length < 3) {
      return const CommandResult(
        'Indique le commit à appliquer : git cherry-pick abc1234',
        type: TerminalOutputType.error,
      );
    }
    if (repository.head == null) {
      return const CommandResult(
        'Crée d’abord un commit de base.',
        type: TerminalOutputType.error,
      );
    }
    final picked = repository.commitByReference(args[2]);
    if (picked == null) {
      return CommandResult(
        'Commit introuvable : ${args[2]}',
        type: TerminalOutputType.error,
      );
    }
    final parent = picked.parentIds.firstOrNull == null
        ? null
        : repository.commitByReference(picked.parentIds.first);
    final base = parent?.snapshot ?? <String, String>{};
    final changes = _changesBetween(base, picked.snapshot);
    final current = repository.head!.snapshot;
    final conflicting = changes.where((path) {
      final currentValue = current[path];
      return currentValue != base[path] &&
          currentValue != picked.snapshot[path];
    }).toList();
    if (conflicting.isNotEmpty) {
      return CommandResult(
        'Cherry-pick interrompu : ${conflicting.join(', ')} a aussi changé sur la branche courante.\nCette simulation protège ton dépôt : fusionne ou restaure le fichier avant de réessayer.',
        type: TerminalOutputType.warning,
      );
    }
    final result = Map<String, String>.from(current);
    for (final path in changes) {
      final content = picked.snapshot[path];
      if (content == null) {
        result.remove(path);
      } else {
        result[path] = content;
      }
    }
    repository.checkoutSnapshot(result);
    repository.stagedFiles.addAll(changes);
    for (final path in changes.where(repository.files.containsKey)) {
      repository.files[path]!.state = FileState.staged;
    }
    final commit = repository.createCommit(picked.message);
    repository.addReflog('${commit.id} cherry-pick: ${picked.id}');
    return CommandResult(
      '[$_branchLabel ${commit.id}] ${commit.message}\nLe changement ${picked.id} a été rejoué sur la branche courante.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _rebase(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length >= 3 && args[2] == '--abort') {
      final operation = repository.pendingRebase;
      if (operation == null) {
        return const CommandResult(
          'Aucun rebase en cours à annuler.',
          type: TerminalOutputType.warning,
        );
      }
      final original = repository.commitByReference(operation.originalHeadId);
      repository.branches[repository.currentBranch] = operation.originalHeadId;
      repository.checkoutSnapshot(original?.snapshot ?? <String, String>{});
      repository
        ..conflicts.clear()
        ..pendingRebase = null;
      repository.addReflog('${operation.originalHeadId} rebase: abort');
      return const CommandResult(
        'Rebase annulé. La branche et les fichiers ont retrouvé leur état initial.',
        type: TerminalOutputType.success,
      );
    }
    if (args.length >= 3 && args[2] == '--continue') {
      final operation = repository.pendingRebase;
      if (operation == null) {
        return const CommandResult(
          'Aucun rebase en cours à continuer.',
          type: TerminalOutputType.warning,
        );
      }
      if (repository.conflicts.isNotEmpty) {
        return CommandResult(
          'Il reste ${repository.conflicts.length} conflit(s). Choisis ou édite chaque contenu, puis utilise git add.',
          type: TerminalOutputType.error,
        );
      }
      if (repository.stagedFiles.isEmpty) {
        return const CommandResult(
          'Prépare les fichiers résolus avec git add avant de continuer.',
          type: TerminalOutputType.error,
        );
      }
      final original = repository.commitByReference(
        operation.pendingCommitIds.first,
      )!;
      repository.createCommit(original.message);
      operation.pendingCommitIds.removeAt(0);
      return _replayRebase(operation);
    }
    if (repository.pendingRebase != null) {
      return const CommandResult(
        'Un rebase est déjà en cours. Utilise git rebase --continue ou git rebase --abort.',
        type: TerminalOutputType.error,
      );
    }
    if (args.length < 3) {
      return const CommandResult(
        'Indique la branche de base : git rebase main',
        type: TerminalOutputType.error,
      );
    }
    final targetBranch = args[2];
    if (!_refExists(targetBranch)) {
      return CommandResult(
        'Branche inconnue : $targetBranch',
        type: TerminalOutputType.error,
      );
    }
    if (targetBranch == repository.currentBranch) {
      return const CommandResult(
        'Impossible de rebaser une branche sur elle-même.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.hasStagedChanges ||
        repository.files.values.any(
          (file) =>
              file.state != FileState.committed &&
              file.state != FileState.untracked,
        )) {
      return const CommandResult(
        'La copie de travail doit être propre avant un rebase.',
        type: TerminalOutputType.error,
      );
    }
    final currentHeadId = repository.branches[repository.currentBranch];
    final targetHeadId = _resolveRef(targetBranch);
    if (currentHeadId == null || targetHeadId == null) {
      return const CommandResult(
        'Les deux branches doivent contenir au moins un commit.',
        type: TerminalOutputType.error,
      );
    }
    if (_isAncestor(currentHeadId, targetHeadId)) {
      repository.branches[repository.currentBranch] = targetHeadId;
      repository.checkoutSnapshot(
        repository.commitByReference(targetHeadId)!.snapshot,
      );
      return const CommandResult(
        'Branche mise à jour en avance rapide : aucun commit à rejouer.',
        type: TerminalOutputType.success,
      );
    }
    if (_isAncestor(targetHeadId, currentHeadId)) {
      return const CommandResult(
        'La branche repose déjà sur cette base : aucun commit à rejouer.',
        type: TerminalOutputType.success,
      );
    }
    final base = _commonAncestor(currentHeadId, targetHeadId);
    final currentHead = repository.commitByReference(currentHeadId)!;
    final targetHead = repository.commitByReference(targetHeadId)!;
    final commitsToReplay = <VirtualCommit>[];
    var cursor = currentHead;
    while (cursor.id != base?.id) {
      commitsToReplay.add(cursor);
      if (cursor.parentIds.isEmpty) break;
      final parent = repository.commitByReference(cursor.parentIds.first);
      if (parent == null) break;
      cursor = parent;
    }
    repository.branches[repository.currentBranch] = targetHeadId;
    repository.checkoutSnapshot(targetHead.snapshot);
    final operation = RebaseOperation(
      originalHeadId: currentHeadId,
      targetBranch: targetBranch,
      pendingCommitIds: commitsToReplay.reversed
          .map((commit) => commit.id)
          .toList(),
    );
    repository.pendingRebase = operation;
    return _replayRebase(operation);
  }

  CommandResult _replayRebase(RebaseOperation operation) {
    var replayed = 0;
    while (operation.pendingCommitIds.isNotEmpty) {
      final original = repository.commitByReference(
        operation.pendingCommitIds.first,
      )!;
      final parent = original.parentIds.firstOrNull == null
          ? null
          : repository.commitByReference(original.parentIds.first);
      final base = parent?.snapshot ?? <String, String>{};
      final changes = _changesBetween(base, original.snapshot);
      final current = repository.head?.snapshot ?? <String, String>{};
      final conflicting = changes
          .where(
            (path) =>
                current[path] != base[path] &&
                current[path] != original.snapshot[path],
          )
          .toSet();
      for (final path in changes.difference(conflicting)) {
        final content = original.snapshot[path];
        if (content == null) {
          repository.files.remove(path);
        } else {
          repository.files[path] = VirtualFile(
            path,
            content,
            state: FileState.staged,
          );
        }
        repository.stagedFiles.add(path);
      }
      if (conflicting.isNotEmpty) {
        for (final path in conflicting) {
          final conflict = MergeConflict(
            path: path,
            baseContent: base[path],
            currentContent: current[path],
            incomingContent: original.snapshot[path],
            incomingBranch: 'commit ${original.id}',
          );
          repository.conflicts[path] = conflict;
          repository.files[path] = VirtualFile(
            path,
            '<<<<<<< base ${operation.targetBranch}\n${conflict.currentContent ?? ''}\n=======\n${conflict.incomingContent ?? ''}\n>>>>>>> ${conflict.incomingBranch}',
            state: FileState.conflicted,
          );
        }
        repository.addReflog(
          '${repository.head?.id ?? '0000000'} rebase: conflit dans ${conflicting.join(', ')}',
        );
        return CommandResult(
          'Rebase interrompu pendant “${original.message}” : conflit dans ${conflicting.join(', ')}.\nChoisis ou édite chaque version, utilise git add, puis git rebase --continue. Pour revenir en arrière : git rebase --abort.',
          type: TerminalOutputType.warning,
        );
      }
      repository.stagedFiles.addAll(changes);
      repository.createCommit(original.message);
      operation.pendingCommitIds.removeAt(0);
      replayed += 1;
    }
    final target = operation.targetBranch;
    repository.pendingRebase = null;
    repository.addReflog('${repository.head!.id} rebase: onto $target');
    return CommandResult(
      'Rebase terminé sur $target${replayed > 0 ? ' après $replayed commit(s) rejoué(s)' : ''}.\nLes identifiants ont changé : ne republie pas sans vérifier l’historique.',
      type: TerminalOutputType.success,
    );
  }

  Set<String> _changesBetween(
    Map<String, String> before,
    Map<String, String> after,
  ) => <String>{
    ...before.keys,
    ...after.keys,
  }.where((path) => before[path] != after[path]).toSet();

  bool _isAncestor(String possibleAncestor, String descendant) =>
      _ancestorIds(descendant).contains(possibleAncestor);

  Set<String> _ancestorIds(String start) {
    final result = <String>{};
    final pending = <String>[start];
    while (pending.isNotEmpty) {
      final id = pending.removeLast();
      if (!result.add(id)) continue;
      final commit = repository.commitByReference(id);
      if (commit != null) pending.addAll(commit.parentIds);
    }
    return result;
  }

  VirtualCommit? _commonAncestor(String first, String second) {
    final secondAncestors = _ancestorIds(second);
    var cursor = repository.commitByReference(first);
    while (cursor != null) {
      if (secondAncestors.contains(cursor.id)) return cursor;
      cursor = cursor.parentIds.firstOrNull == null
          ? null
          : repository.commitByReference(cursor.parentIds.first);
    }
    return null;
  }

  CommandResult _diff(List<String> args) {
    final changed = repository.files.values
        .where(
          (file) =>
              file.state == FileState.modified ||
              file.state == FileState.staged,
        )
        .toList();
    if (changed.isEmpty) {
      return const CommandResult('Aucune différence à afficher.');
    }
    return CommandResult(
      changed
          .map(
            (file) =>
                'diff --git a/${file.path} b/${file.path}\n+ ${file.content}',
          )
          .join('\n'),
    );
  }

  CommandResult _restore(List<String> args) {
    if (args.length < 3) {
      return const CommandResult(
        'Indique un fichier à restaurer.',
        type: TerminalOutputType.error,
      );
    }
    final path = args.last;
    if (args.contains('--staged') && repository.stagedRemovals.remove(path)) {
      repository.files[path]?.state = FileState.committed;
      return CommandResult(
        'La suppression de $path a été retirée de la zone de préparation.',
        type: TerminalOutputType.success,
      );
    }
    if (!repository.files.containsKey(path)) {
      return const CommandResult(
        'Fichier introuvable.',
        type: TerminalOutputType.error,
      );
    }
    if (args.contains('--staged')) {
      repository.stagedFiles.remove(path);
      repository.files[path]!.state = FileState.modified;
      return CommandResult(
        '$path retiré de la zone de préparation.',
        type: TerminalOutputType.success,
      );
    }
    final snapshot = repository.head?.snapshot[path];
    if (snapshot == null) {
      return const CommandResult(
        'Aucune version enregistrée pour ce fichier.',
        type: TerminalOutputType.error,
      );
    }
    repository.files[path]!
      ..content = snapshot
      ..state = FileState.committed;
    return CommandResult('$path restauré.', type: TerminalOutputType.success);
  }

  CommandResult _reset(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (repository.head == null) {
      return const CommandResult(
        'Aucun commit à réinitialiser.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.pendingRebase != null) {
      return const CommandResult(
        'Un rebase est en cours. Utilise git rebase --continue ou git rebase --abort.',
        type: TerminalOutputType.error,
      );
    }
    final mode =
        args.where((arg) => arg.startsWith('--')).firstOrNull ?? '--mixed';
    if (!<String>{'--soft', '--mixed', '--hard'}.contains(mode)) {
      return CommandResult(
        'Mode inconnu : $mode\nUtilise --soft, --mixed ou --hard.',
        type: TerminalOutputType.error,
      );
    }
    final reference =
        args.skip(2).where((arg) => !arg.startsWith('-')).firstOrNull ?? 'HEAD';
    VirtualCommit? target;
    final relative = RegExp(r'^HEAD(?:~(\d+)|(\^))?$').firstMatch(reference);
    if (relative != null) {
      final steps = relative.group(1) != null
          ? int.parse(relative.group(1)!)
          : relative.group(2) != null
          ? 1
          : 0;
      target = repository.head;
      for (var step = 0; step < steps; step++) {
        final parentId = target!.parentIds.firstOrNull;
        if (parentId == null) {
          if (step == steps - 1) {
            target = null;
            break;
          }
          return CommandResult(
            'L’historique ne contient pas assez de commits pour $reference.',
            type: TerminalOutputType.error,
          );
        }
        target = repository.commitByReference(parentId);
      }
    } else {
      target = repository.commitByReference(reference);
      if (target == null) {
        return CommandResult(
          'Commit introuvable : $reference',
          type: TerminalOutputType.error,
        );
      }
    }
    final previous = repository.head!;
    final targetSnapshot = target?.snapshot ?? <String, String>{};
    repository.branches[repository.currentBranch] = target?.id;
    if (mode == '--soft') {
      final changed = <String>{
        ...repository.stagedFiles,
        ..._changesBetween(targetSnapshot, previous.snapshot),
      };
      repository.stagedFiles.addAll(changed);
      for (final path in changed.where(repository.files.containsKey)) {
        repository.files[path]!.state = FileState.staged;
      }
    } else if (mode == '--mixed') {
      repository.stagedFiles.clear();
      repository.stagedRemovals.clear();
      for (final file in repository.files.values) {
        final saved = targetSnapshot[file.path];
        file.state = saved == null
            ? FileState.untracked
            : saved == file.content
            ? FileState.committed
            : FileState.modified;
      }
    } else {
      repository.checkoutSnapshot(targetSnapshot);
      repository
        ..conflicts.clear()
        ..pendingMergeBranch = null;
    }
    repository.addReflog(
      '${target?.id ?? '0000000'} reset: moving from ${previous.id} to $reference',
    );
    final warning = mode == '--hard'
        ? '\nAttention : les changements non enregistrés ont été supprimés.'
        : '';
    return CommandResult(
      'HEAD pointe maintenant sur ${target?.id ?? 'l’état initial'} avec $mode.$warning',
      type: mode == '--hard'
          ? TerminalOutputType.warning
          : TerminalOutputType.success,
    );
  }

  CommandResult _revert(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length < 3) {
      return const CommandResult(
        'Indique le commit à annuler. Exemple : git revert HEAD',
        type: TerminalOutputType.error,
      );
    }
    final target = repository.commitByReference(args[2]);
    if (target == null) {
      return CommandResult(
        'Commit introuvable : ${args[2]}',
        type: TerminalOutputType.error,
      );
    }
    if (repository.conflicts.isNotEmpty ||
        repository.pendingRebase != null ||
        repository.pendingMergeBranch != null) {
      return const CommandResult(
        'Termine ou annule l’opération en cours avant un revert.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.hasStagedChanges ||
        repository.files.values.any(
          (file) => file.state == FileState.modified,
        )) {
      return const CommandResult(
        'La copie de travail doit être propre avant un revert. Crée un commit ou utilise git stash.',
        type: TerminalOutputType.error,
      );
    }
    final parent = target.parentIds.firstOrNull == null
        ? null
        : repository.commitByReference(target.parentIds.first);
    final before = parent?.snapshot ?? <String, String>{};
    final changes = _changesBetween(before, target.snapshot);
    if (changes.isEmpty) {
      return CommandResult(
        'Le commit ${target.id} n’introduit aucun changement à annuler.',
        type: TerminalOutputType.warning,
      );
    }
    final current = repository.head!.snapshot;
    final conflicting = changes
        .where((path) => current[path] != target.snapshot[path])
        .toList();
    if (conflicting.isNotEmpty) {
      return CommandResult(
        'Revert interrompu : ${conflicting.join(', ')} a encore changé après ${target.id}.\nCette simulation protège ton dépôt : annule d’abord les commits plus récents sur ce fichier.',
        type: TerminalOutputType.warning,
      );
    }
    for (final path in changes) {
      final content = before[path];
      if (content == null) {
        repository.files.remove(path);
      } else {
        repository.files[path] = VirtualFile(
          path,
          content,
          state: FileState.staged,
        );
      }
      repository.stagedFiles.add(path);
    }
    final commit = repository.createCommit('Annule “${target.message}”');
    return CommandResult(
      '[$_branchLabel ${commit.id}] ${commit.message}\nUn nouveau commit d’annulation a été créé : l’historique partagé reste intact.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _tag(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length == 2 || args.contains('--list')) {
      return repository.tags.isEmpty
          ? const CommandResult('Aucun tag pour le moment.')
          : CommandResult(repository.tags.keys.join('\n'));
    }
    if (repository.head == null) {
      return const CommandResult(
        'Crée un commit avant de poser un tag.',
        type: TerminalOutputType.error,
      );
    }
    final name = args[2];
    if (repository.tags.containsKey(name)) {
      return CommandResult(
        'Le tag $name existe déjà.',
        type: TerminalOutputType.error,
      );
    }
    repository.tags[name] = repository.head!.id;
    repository.addReflog('${repository.head!.id} tag: $name');
    return CommandResult(
      'Tag $name créé sur ${repository.head!.id}.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _reflog() {
    if (repository.reflog.isEmpty) {
      return const CommandResult('Le journal de références est vide.');
    }
    return CommandResult(
      repository.reflog.reversed.indexed
          .map((entry) => 'HEAD@{${entry.$1}} ${entry.$2}')
          .join('\n'),
    );
  }

  CommandResult _stash(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length > 2 && args[2] == 'list') {
      if (repository.stashes.isEmpty) {
        return const CommandResult('Aucun stash enregistré.');
      }
      return CommandResult(
        repository.stashes.reversed.indexed
            .map((entry) => 'stash@{${entry.$1}}: ${entry.$2.keys.join(', ')}')
            .join('\n'),
      );
    }
    if (args.length > 2 && args[2] == 'pop') {
      if (repository.stashes.isEmpty) {
        return const CommandResult(
          'Aucun stash à restaurer.',
          type: TerminalOutputType.warning,
        );
      }
      if (repository.conflicts.isNotEmpty || repository.pendingRebase != null) {
        return const CommandResult(
          'Termine ou annule l’opération en cours avant de restaurer un stash.',
          type: TerminalOutputType.error,
        );
      }
      final stash = repository.stashes.last;
      final overwritten = stash.keys.where((path) {
        final file = repository.files[path];
        return file != null &&
            (file.state == FileState.modified ||
                repository.stagedFiles.contains(path));
      }).toList();
      if (overwritten.isNotEmpty) {
        return CommandResult(
          'Tes changements locaux sur ${overwritten.join(', ')} seraient écrasés.\nCrée un commit ou restaure ces fichiers avant git stash pop.',
          type: TerminalOutputType.error,
        );
      }
      repository.stashes.removeLast();
      final saved = repository.head?.snapshot ?? <String, String>{};
      for (final entry in stash.entries) {
        repository.files[entry.key] = VirtualFile(
          entry.key,
          entry.value,
          state: saved.containsKey(entry.key)
              ? FileState.modified
              : FileState.untracked,
        );
      }
      return const CommandResult(
        'Modifications restaurées depuis le stash.',
        type: TerminalOutputType.success,
      );
    }
    if (repository.conflicts.isNotEmpty || repository.pendingRebase != null) {
      return const CommandResult(
        'Termine ou annule l’opération en cours avant de créer un stash.',
        type: TerminalOutputType.error,
      );
    }
    final changed = <String, String>{
      for (final file in repository.files.values.where(
        (file) =>
            file.state == FileState.modified ||
            repository.stagedFiles.contains(file.path),
      ))
        file.path: file.content,
    };
    if (changed.isEmpty) {
      return const CommandResult(
        'Aucune modification locale à mettre de côté.',
        type: TerminalOutputType.warning,
      );
    }
    repository.stashes.add(changed);
    final saved = repository.head?.snapshot ?? <String, String>{};
    for (final path in changed.keys) {
      repository.stagedFiles.remove(path);
      final content = saved[path];
      if (content == null) {
        repository.files.remove(path);
      } else {
        repository.files[path] = VirtualFile(
          path,
          content,
          state: FileState.committed,
        );
      }
    }
    return const CommandResult(
      'Modifications enregistrées dans le stash. La copie de travail est revenue au dernier commit.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _remote(List<String> args) {
    if (args.length == 2 || args.contains('-v')) {
      if (repository.remotes.isEmpty) {
        return const CommandResult('Aucun dépôt distant configuré.');
      }
      return CommandResult(
        repository.remotes.entries
            .map(
              (entry) =>
                  '${entry.key}\t${entry.value} (fetch)\n${entry.key}\t${entry.value} (push)',
            )
            .join('\n'),
      );
    }
    if (args.length >= 5 && args[2] == 'add') {
      repository.remotes[args[3]] = args[4];
      return CommandResult(
        'Dépôt distant ${args[3]} ajouté.',
        type: TerminalOutputType.success,
      );
    }
    return const CommandResult(
      'Exemple : git remote add origin https://example.com/projet.git',
      type: TerminalOutputType.error,
    );
  }

  CommandResult _network(List<String> args) {
    if (repository.remotes.isEmpty) {
      return const CommandResult(
        'Aucun dépôt distant configuré.\nAjoute-le avec git remote add origin URL.',
        type: TerminalOutputType.error,
      );
    }
    final positional = args
        .skip(2)
        .where((arg) => !arg.startsWith('-'))
        .toList();
    final upstream = repository.isDetached
        ? null
        : repository.upstreams[repository.currentBranch];
    final remote =
        positional.firstOrNull ??
        upstream?.split('/').first ??
        (repository.remotes.containsKey('origin')
            ? 'origin'
            : repository.remotes.keys.first);
    if (!repository.remotes.containsKey(remote)) {
      return CommandResult(
        'Dépôt distant inconnu : $remote\nVérifie la liste avec git remote -v',
        type: TerminalOutputType.error,
      );
    }
    return switch (args[1]) {
      'fetch' => _fetch(remote),
      'pull' => _pull(args, remote, positional),
      _ => _push(args, remote, positional, upstream),
    };
  }

  CommandResult _fetch(String remote) {
    final updates = <String>[];
    for (final entry in repository.serverBranches.entries) {
      if (!entry.key.startsWith('$remote/')) continue;
      final previous = repository.remoteBranches[entry.key];
      if (previous == entry.value) continue;
      repository.remoteBranches[entry.key] = entry.value;
      updates.add(
        previous == null
            ? '  * [nouvelle branche] ${entry.key}'
            : '  $previous..${entry.value}  ${entry.key}',
      );
    }
    if (updates.isEmpty) {
      return CommandResult(
        'Rien de nouveau sur $remote : tes références distantes sont à jour.',
        type: TerminalOutputType.success,
      );
    }
    return CommandResult(
      'Depuis ${repository.remotes[remote]} :\n${updates.join('\n')}\nTes fichiers n’ont pas changé. git status indique maintenant ton avance ou ton retard.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _pull(
    List<String> args,
    String remote,
    List<String> positional,
  ) {
    final branch = positional.length > 1
        ? positional[1]
        : repository.currentBranch;
    final fetched = _fetch(remote);
    final key = '$remote/$branch';
    if (repository.remoteBranches[key] == null) {
      return CommandResult(
        'Le dépôt distant ne contient pas encore de branche $branch.\nPublie-la d’abord avec git push -u $remote $branch.',
        type: TerminalOutputType.warning,
      );
    }
    final integration = args.contains('--rebase')
        ? _rebase(<String>['git', 'rebase', key])
        : _merge(<String>['git', 'merge', key]);
    return CommandResult(
      '${fetched.text}\n${integration.text}',
      type: integration.type,
    );
  }

  CommandResult _push(
    List<String> args,
    String remote,
    List<String> positional,
    String? upstream,
  ) {
    final setUpstream = args.contains('-u') || args.contains('--set-upstream');
    if (positional.isEmpty && upstream == null) {
      return CommandResult(
        'La branche ${repository.currentBranch} ne suit encore aucune branche distante.\nPublie-la avec : git push -u $remote ${repository.currentBranch}',
        type: TerminalOutputType.error,
      );
    }
    final branch = positional.length > 1
        ? positional[1]
        : positional.isEmpty
        ? upstream!.split('/').skip(1).join('/')
        : repository.currentBranch;
    if (!repository.branches.containsKey(branch)) {
      return CommandResult(
        'Branche locale inconnue : $branch',
        type: TerminalOutputType.error,
      );
    }
    final local = repository.branches[branch];
    if (local == null) {
      return CommandResult(
        'La branche $branch ne contient encore aucun commit : crée un commit avant de la publier.',
        type: TerminalOutputType.error,
      );
    }
    final key = '$remote/$branch';
    final server = repository.serverBranches[key];
    final force = args.contains('--force') || args.contains('-f');
    final lease = args.contains('--force-with-lease');
    var forced = false;
    if (server != null && server != local && !_isAncestor(server, local)) {
      if (lease && repository.remoteBranches[key] != server) {
        repository.rejectedPushes += 1;
        return CommandResult(
          '! [rejeté] $branch -> $branch (bail périmé)\n--force-with-lease a protégé le distant : il a changé depuis ta dernière récupération.\nLance git fetch $remote et examine les nouveaux commits avant de décider.',
          type: TerminalOutputType.error,
        );
      }
      if (!lease && !force) {
        repository.rejectedPushes += 1;
        return CommandResult(
          '! [rejeté] $branch -> $branch (non fast-forward)\nLe dépôt distant contient des commits que tu n’as pas.\nIntègre-les d’abord : git pull --rebase $remote $branch, puis pousse à nouveau.',
          type: TerminalOutputType.error,
        );
      }
      forced = true;
    }
    if (setUpstream) repository.upstreams[branch] = key;
    final tracking = setUpstream
        ? '\n$branch suit désormais $key : git push et git pull suffiront ensuite.'
        : '';
    if (server == local) {
      repository.remoteBranches[key] = local;
      return CommandResult(
        'Déjà à jour : $key contient déjà ton travail.$tracking',
        type: TerminalOutputType.success,
      );
    }
    repository.serverBranches[key] = local;
    repository.remoteBranches[key] = local;
    final range = server == null
        ? '* [nouvelle branche] $branch -> $branch'
        : '$server..$local  $branch -> $branch';
    return CommandResult(
      'Vers ${repository.remotes[remote]} :\n  $range$tracking${forced ? '\nAttention : l’historique distant a été réécrit. Préviens les personnes qui travaillent sur cette branche.' : ''}\nAucun accès réseau réel n’a été effectué.',
      type: forced ? TerminalOutputType.warning : TerminalOutputType.success,
    );
  }

  CommandResult _clone(List<String> args) {
    final positional = args
        .skip(2)
        .where((arg) => !arg.startsWith('-'))
        .toList();
    if (positional.isEmpty) {
      return const CommandResult(
        'Indique l’adresse du dépôt : git clone https://github.com/compte/projet.git',
        type: TerminalOutputType.error,
      );
    }
    final url = positional.first;
    final segments = url
        .split(RegExp(r'[/:]'))
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.length < 2) {
      return CommandResult(
        'Adresse de dépôt invalide : $url',
        type: TerminalOutputType.error,
      );
    }
    if (repository.initialized && repository.commits.isNotEmpty) {
      return const CommandResult(
        'Le laboratoire contient déjà un dépôt avec un historique.\nRéinitialise-le avec le bouton ↺ du terminal, puis relance git clone.',
        type: TerminalOutputType.error,
      );
    }
    final name = positional.length > 1
        ? positional[1]
        : segments.last.replaceAll(RegExp(r'\.git$'), '');
    // Cloning replaces the repository but keeps the learner's statistics.
    final history = List<String>.of(repository.commandHistory);
    final pendingErrors = Set<String>.of(repository.pendingCommandErrors);
    final daily = Map<String, int>.of(repository.dailyCommands);
    final successes = repository.successfulCommands;
    final errors = repository.commandErrors;
    final corrected = repository.correctedErrors;
    repository.reset();
    repository
      ..initialized = true
      ..successfulCommands = successes
      ..commandErrors = errors
      ..correctedErrors = corrected
      ..files.clear();
    repository.commandHistory.addAll(history);
    repository.pendingCommandErrors.addAll(pendingErrors);
    repository.dailyCommands.addAll(daily);
    repository.remotes['origin'] = url;
    final starter = <String, String>{
      'README.md': '# $name\n\nProjet cloné depuis $url.\n',
      'CONTRIBUTING.md':
          '# Contribuer\n\nCrée une branche, puis ouvre une pull request.\n',
    };
    for (final entry in starter.entries) {
      repository.files[entry.key] = VirtualFile(
        entry.key,
        entry.value,
        state: FileState.staged,
      );
      repository.stagedFiles.add(entry.key);
    }
    final commit = repository.createCommit('Initial commit');
    repository.upstreams['main'] = 'origin/main';
    repository.serverBranches['origin/main'] = commit.id;
    repository.remoteBranches['origin/main'] = commit.id;
    repository.addReflog('${commit.id} clone: from $url');
    return CommandResult(
      'Clonage dans « $name »...\nRéception des objets : 100 %, terminé.\nLa branche main suit origin/main.\nSimulation : aucun accès réseau réel n’a été effectué.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _rm(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    final cached = args.contains('--cached');
    final paths = args.skip(2).where((arg) => !arg.startsWith('-')).toList();
    if (paths.isEmpty) {
      return const CommandResult(
        'Indique le fichier à supprimer : git rm brouillon.txt',
        type: TerminalOutputType.error,
      );
    }
    final saved = repository.head?.snapshot ?? <String, String>{};
    for (final path in paths) {
      if (!saved.containsKey(path)) {
        return CommandResult(
          '$path n’est pas suivi par Git : il n’y a rien à retirer de l’historique.',
          type: TerminalOutputType.error,
        );
      }
      final file = repository.files[path];
      if (!cached && file != null && file.content != saved[path]) {
        return CommandResult(
          '$path contient des modifications non enregistrées.\nValide-les, restaure le fichier, ou utilise git rm --cached $path pour le garder sur le disque.',
          type: TerminalOutputType.error,
        );
      }
    }
    for (final path in paths) {
      if (cached) {
        repository.stagedFiles.remove(path);
        repository.stagedRemovals.add(path);
        repository.files[path]?.state = FileState.untracked;
      } else {
        repository.files.remove(path);
        repository.stagedRemovals.remove(path);
        repository.stagedFiles.add(path);
      }
    }
    return CommandResult(
      cached
          ? '${paths.join(', ')} ne sera plus suivi, mais reste sur le disque.\nPense à l’ajouter dans .gitignore.'
          : 'Suppression de ${paths.join(', ')} préparée. Crée un commit pour l’enregistrer.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _mv(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length < 4) {
      return const CommandResult(
        'Indique l’ancien et le nouveau nom : git mv notes.txt NOTES.md',
        type: TerminalOutputType.error,
      );
    }
    final source = args[2];
    final destination = args[3];
    final file = repository.files[source];
    if (file == null) {
      return CommandResult(
        'Fichier introuvable : $source',
        type: TerminalOutputType.error,
      );
    }
    final saved = repository.head?.snapshot ?? <String, String>{};
    if (!saved.containsKey(source) &&
        !repository.stagedFiles.contains(source)) {
      return CommandResult(
        '$source n’est pas suivi par Git. Ajoute-le d’abord avec git add.',
        type: TerminalOutputType.error,
      );
    }
    if (repository.files.containsKey(destination)) {
      return CommandResult(
        '$destination existe déjà.',
        type: TerminalOutputType.error,
      );
    }
    repository.files.remove(source);
    if (saved.containsKey(source)) {
      repository.stagedFiles.add(source);
    } else {
      repository.stagedFiles.remove(source);
    }
    repository.files[destination] = VirtualFile(
      destination,
      file.content,
      state: FileState.staged,
    );
    repository.stagedFiles.add(destination);
    return CommandResult(
      '$source renommé en $destination. Le renommage est préparé pour le prochain commit.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _bisect(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    final action = args.length > 2 ? args[2] : '';
    final session = repository.bisect;
    if (action == 'start') {
      if (session != null) {
        return const CommandResult(
          'Une recherche est déjà en cours. Termine-la avec git bisect reset.',
          type: TerminalOutputType.error,
        );
      }
      if (repository.head == null) {
        return const CommandResult(
          'Crée d’abord quelques commits avant de lancer une recherche.',
          type: TerminalOutputType.error,
        );
      }
      if (repository.hasStagedChanges ||
          repository.conflicts.isNotEmpty ||
          repository.files.values.any(
            (file) => file.state == FileState.modified,
          )) {
        return const CommandResult(
          'La copie de travail doit être propre avant git bisect start.',
          type: TerminalOutputType.error,
        );
      }
      repository.bisect = BisectSession(
        returnBranch: repository.isDetached ? null : repository.currentBranch,
        returnDetached: repository.detachedHead,
      );
      return const CommandResult(
        'Recherche lancée.\nIndique un commit mauvais (git bisect bad) et un commit bon (git bisect good <commit>).',
        type: TerminalOutputType.success,
      );
    }
    if (session == null) {
      return const CommandResult(
        'Aucune recherche en cours. Commence par git bisect start.',
        type: TerminalOutputType.error,
      );
    }
    switch (action) {
      case 'reset':
        repository.bisect = null;
        final branch = session.returnBranch;
        if (branch != null && repository.branches.containsKey(branch)) {
          repository
            ..detachedHead = null
            ..currentBranch = branch;
        } else {
          repository.detachedHead = session.returnDetached;
        }
        repository.checkoutSnapshot(
          repository.head?.snapshot ?? <String, String>{},
        );
        return CommandResult(
          'Recherche terminée. Retour sur ${repository.headLabel}.',
          type: TerminalOutputType.success,
        );
      case 'bad':
      case 'good':
        final reference = args.length > 3 ? args[3] : 'HEAD';
        final id = _resolveRef(reference);
        if (id == null) {
          return CommandResult(
            'Commit introuvable : $reference',
            type: TerminalOutputType.error,
          );
        }
        if (action == 'bad') {
          session.bad = id;
        } else {
          session.good.add(id);
        }
        return _bisectStep(session);
      default:
        return const CommandResult(
          'Utilise git bisect start, bad, good ou reset.',
          type: TerminalOutputType.error,
        );
    }
  }

  CommandResult _bisectStep(BisectSession session) {
    final bad = session.bad;
    if (bad == null) {
      return const CommandResult(
        'Indique maintenant un commit mauvais : git bisect bad',
      );
    }
    if (session.good.isEmpty) {
      return const CommandResult(
        'Indique maintenant un commit bon : git bisect good <commit ou tag>',
      );
    }
    final excluded = <String>{
      for (final good in session.good) ..._ancestorIds(good),
    };
    final suspects = _ancestorIds(bad).difference(excluded);
    final candidates = repository.commits
        .where((commit) => suspects.contains(commit.id))
        .toList();
    if (candidates.isEmpty) {
      return const CommandResult(
        'Le commit mauvais est un ancêtre d’un commit bon : vérifie tes réponses, puis recommence avec git bisect reset.',
        type: TerminalOutputType.error,
      );
    }
    if (candidates.length == 1) {
      final culprit = candidates.single;
      repository.bisectCulprit = culprit.id;
      return CommandResult(
        '${culprit.id} est le premier commit fautif : « ${culprit.message} ».\nExamine-le, puis termine avec git bisect reset.',
        type: TerminalOutputType.success,
      );
    }
    final next = candidates[(candidates.length - 1) ~/ 2];
    repository.detachedHead = next.id;
    repository.checkoutSnapshot(next.snapshot);
    var steps = 0;
    for (var left = candidates.length; left > 1; left = (left + 1) ~/ 2) {
      steps += 1;
    }
    return CommandResult(
      'Bisect : ${_plural(candidates.length, 'commit')} suspect(s), environ ${_plural(steps, 'étape')} restante(s).\nHEAD est sur ${next.id} « ${next.message} ».\nTeste ce commit (par exemple cat app.js), puis réponds git bisect good ou git bisect bad.',
      type: TerminalOutputType.info,
    );
  }

  static const _colleague = 'Camille (collègue)';

  CommandResult _scenario(List<String> args) {
    final name = args.length > 1 ? args[1] : '';
    switch (name) {
      case 'collegue':
        return _colleaguePush(args);
      case 'regression':
        return _regression();
      default:
        return const CommandResult(
          'Scénarios du laboratoire :\n  gitquest collegue [branche]  une collègue pousse un commit sur le distant\n  gitquest regression          prépare un historique contenant un bug à retrouver avec git bisect',
        );
    }
  }

  CommandResult _colleaguePush(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (repository.remotes.isEmpty) {
      return const CommandResult(
        'Ajoute d’abord un dépôt distant : git remote add origin URL',
        type: TerminalOutputType.error,
      );
    }
    final remote = repository.remotes.containsKey('origin')
        ? 'origin'
        : repository.remotes.keys.first;
    final branch = args.length > 2 ? args[2] : 'main';
    final key = '$remote/$branch';
    final base = repository.serverBranches[key];
    if (base == null) {
      return CommandResult(
        'Le distant ne contient pas encore la branche $branch.\nPublie-la d’abord : git push -u $remote $branch',
        type: TerminalOutputType.error,
      );
    }
    final parent = repository.commitByReference(base)!;
    final notes = parent.snapshot['NOTES-equipe.md'] ?? '# Notes d’équipe\n';
    final count = repository.commits
        .where((commit) => commit.author == _colleague)
        .length;
    final commit = repository.addForeignCommit(
      message: 'docs: complète les notes d’équipe (${count + 1})',
      author: _colleague,
      parentIds: <String>[base],
      snapshot: <String, String>{
        ...parent.snapshot,
        'NOTES-equipe.md': '$notes- Contribution de Camille n°${count + 1}\n',
      },
    );
    repository.serverBranches[key] = commit.id;
    return CommandResult(
      'Camille a poussé ${commit.id} « ${commit.message} » sur $key.\nTon dépôt local ne le sait pas encore : utilise git fetch puis git status.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _regression() {
    final error = _requireRepository();
    if (error != null) return error;
    if (repository.isDetached ||
        repository.bisect != null ||
        repository.pendingRebase != null ||
        repository.conflicts.isNotEmpty ||
        repository.hasStagedChanges ||
        repository.files.values.any(
          (file) => file.state == FileState.modified,
        )) {
      return const CommandResult(
        'Place-toi sur une branche avec une copie de travail propre avant de lancer le scénario.',
        type: TerminalOutputType.error,
      );
    }
    const total = 8;
    final bugAt = 3 + DateTime.now().microsecond % 4;
    final lines = <String>['// Calcul du panier'];
    String? first;
    for (var step = 1; step <= total; step++) {
      lines.add('function etape$step() { return $step; }');
      if (step == bugAt) {
        lines.add('// bug : le total oublie la livraison');
      }
      repository.files['app.js'] = VirtualFile(
        'app.js',
        '${lines.join('\n')}\n',
        state: FileState.staged,
      );
      repository.stagedFiles.add('app.js');
      final commit = repository.createCommit(
        'feat: étape $step du calcul du panier',
      );
      first ??= commit.id;
    }
    repository.tags['version-saine'] = first!;
    return CommandResult(
      '$total commits ajoutés sur ${repository.currentBranch}.\nLe tag version-saine marque le premier, qui fonctionne. Le dernier contient un bug : app.js contient le mot « bug ».\nRetrouve le commit fautif : git bisect start → git bisect bad → git bisect good version-saine',
      type: TerminalOutputType.success,
    );
  }
}
