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
    repository.commandHistory.add(command);
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
    return switch (args[1]) {
      'init' => _init(),
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
  git init, status, add, commit, log, diff
  git branch, switch, checkout, merge
  git restore, reset, revert, stash, tag, reflog
  git cherry-pick, rebase
  git remote, push, pull, fetch

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
    final file = repository.files.putIfAbsent(
      path,
      () => VirtualFile(path, content),
    );
    file
      ..content = content
      ..state = repository.commits.isEmpty
          ? FileState.untracked
          : FileState.modified;
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
    final staged = repository.stagedFiles.toList();
    final conflicted = repository.conflicts.keys.toList();
    final buffer = StringBuffer('Sur la branche ${repository.currentBranch}\n');
    if (repository.commits.isEmpty) {
      buffer.writeln('Aucun commit pour le moment');
    }
    if (staged.isNotEmpty) {
      buffer.writeln(
        '\nModifications qui seront validées :\n  A  ${staged.join('\n  A  ')}',
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
        ? repository.files.keys.toList()
        : args.sublist(2);
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
    if (amend) {
      final message = messageIndex >= 0 && messageIndex + 1 < args.length
          ? args[messageIndex + 1]
          : repository.head!.message;
      final commit = repository.amendHead(message);
      return CommandResult(
        '[${repository.currentBranch} ${commit.id}] $message\nLe dernier commit a été remplacé. Son identifiant a changé.',
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
    if (repository.stagedFiles.isEmpty) {
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
      '[${repository.currentBranch} ${commit.id}] ${commit.message}\n${commit.snapshot.length} fichier(s) enregistré(s).',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _log(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (repository.commits.isEmpty) {
      return const CommandResult(
        'Aucun commit dans l’historique.',
        type: TerminalOutputType.warning,
      );
    }
    final compact = args.contains('--oneline');
    return CommandResult(
      repository.commits.reversed
          .map(
            (commit) => compact
                ? '${commit.id} ${commit.message}'
                : 'commit ${commit.id}\nAuteur: ${commit.author}\n\n    ${commit.message}',
          )
          .join('\n${compact ? '' : '\n'}'),
    );
  }

  CommandResult _branch(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
    if (args.length == 2) {
      return CommandResult(
        repository.branches.keys
            .map(
              (name) => '${name == repository.currentBranch ? '*' : ' '} $name',
            )
            .join('\n'),
      );
    }
    if (args[2] == '-d') {
      if (args.length < 4) {
        return const CommandResult(
          'Indique la branche à supprimer.',
          type: TerminalOutputType.error,
        );
      }
      if (args[3] == repository.currentBranch) {
        return const CommandResult(
          'Impossible de supprimer la branche courante.',
          type: TerminalOutputType.error,
        );
      }
      repository.branches.remove(args[3]);
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
    repository.branches[args[2]] =
        repository.branches[repository.currentBranch];
    return CommandResult(
      'Branche ${args[2]} créée.',
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
    if (repository.stagedFiles.isNotEmpty ||
        repository.files.values.any(
          (file) => file.state == FileState.modified,
        )) {
      return const CommandResult(
        'Des changements locaux risquent d’être écrasés. Crée un commit ou utilise git stash avant de changer de branche.',
        type: TerminalOutputType.error,
      );
    }
    var targetIndex = 2;
    if (args[2] == '-c') {
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
      repository.branches[args[targetIndex]] =
          repository.branches[repository.currentBranch];
    }
    final target = args[targetIndex];
    if (!repository.branches.containsKey(target)) {
      return CommandResult(
        'Branche inconnue : $target\nCrée-la avec git switch -c $target',
        type: TerminalOutputType.error,
      );
    }
    repository.currentBranch = target;
    final targetHead = repository.head;
    if (targetHead != null) {
      repository.checkoutSnapshot(targetHead.snapshot);
    }
    repository.reflog.add('${targetHead?.id ?? '0000000'} checkout: $target');
    return CommandResult(
      'Basculement sur la branche “$target”.',
      type: TerminalOutputType.success,
    );
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
    if (!repository.branches.containsKey(source)) {
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
    if (repository.stagedFiles.isNotEmpty ||
        repository.files.values.any(
          (file) => file.state == FileState.modified,
        )) {
      return const CommandResult(
        'La copie de travail doit être propre avant une fusion.',
        type: TerminalOutputType.error,
      );
    }
    final sourceHeadId = repository.branches[source];
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
      repository.reflog.add('$sourceHeadId merge $source: fast-forward');
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
    if (conflicts.isNotEmpty) {
      repository
        ..conflicts.addAll(conflicts)
        ..pendingMergeBranch = source;
      repository.reflog.add(
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
    repository.reflog.add('${commit.id} cherry-pick: ${picked.id}');
    return CommandResult(
      '[${repository.currentBranch} ${commit.id}] ${commit.message}\nLe changement ${picked.id} a été rejoué sur la branche courante.',
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
      repository.reflog.add('${operation.originalHeadId} rebase: abort');
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
    if (!repository.branches.containsKey(targetBranch)) {
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
    if (repository.stagedFiles.isNotEmpty ||
        repository.files.values.any(
          (file) => file.state != FileState.committed,
        )) {
      return const CommandResult(
        'La copie de travail doit être propre avant un rebase.',
        type: TerminalOutputType.error,
      );
    }
    final currentHeadId = repository.branches[repository.currentBranch];
    final targetHeadId = repository.branches[targetBranch];
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
        repository.reflog.add(
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
    repository.reflog.add('${repository.head!.id} rebase: onto $target');
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
    final mode =
        args.where((arg) => arg.startsWith('--')).firstOrNull ?? '--mixed';
    if (!<String>{'--soft', '--mixed', '--hard'}.contains(mode)) {
      return CommandResult(
        'Mode inconnu : $mode\nUtilise --soft, --mixed ou --hard.',
        type: TerminalOutputType.error,
      );
    }
    final reference =
        args
            .where(
              (arg) =>
                  arg == 'HEAD~1' ||
                  (!arg.startsWith('-') && arg != 'git' && arg != 'reset'),
            )
            .firstOrNull ??
        'HEAD~1';
    VirtualCommit? target;
    if (reference == 'HEAD~1') {
      final parentId = repository.head!.parentIds.firstOrNull;
      target = parentId == null ? null : repository.commitByReference(parentId);
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
    repository.branches[repository.currentBranch] = target?.id;
    if (mode == '--soft') {
      repository.stagedFiles.addAll(repository.files.keys);
      for (final file in repository.files.values) {
        file.state = FileState.staged;
      }
    } else if (mode == '--mixed') {
      repository.stagedFiles.clear();
      for (final file in repository.files.values) {
        file.state = FileState.modified;
      }
    } else {
      repository
        ..files.clear()
        ..stagedFiles.clear();
      for (final entry
          in target?.snapshot.entries ?? const <MapEntry<String, String>>[]) {
        repository.files[entry.key] = VirtualFile(
          entry.key,
          entry.value,
          state: FileState.committed,
        );
      }
    }
    repository.reflog.add(
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
    final parent = target.parentIds.firstOrNull == null
        ? null
        : repository.commitByReference(target.parentIds.first);
    repository.files.clear();
    for (final entry
        in parent?.snapshot.entries ?? const <MapEntry<String, String>>[]) {
      repository.files[entry.key] = VirtualFile(
        entry.key,
        entry.value,
        state: FileState.staged,
      );
      repository.stagedFiles.add(entry.key);
    }
    if (parent == null) {
      repository.stagedFiles.addAll(target.snapshot.keys);
    }
    final commit = repository.createCommit('Annule “${target.message}”');
    return CommandResult(
      '[${repository.currentBranch} ${commit.id}] ${commit.message}\nUn nouveau commit d’annulation a été créé : l’historique partagé reste intact.',
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
    repository.reflog.add('${repository.head!.id} tag: $name');
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
    if (args.length > 2 && args[2] == 'pop') {
      if (repository.stashes.isEmpty) {
        return const CommandResult(
          'Aucun stash à restaurer.',
          type: TerminalOutputType.warning,
        );
      }
      final stash = repository.stashes.removeLast();
      for (final entry in stash.entries) {
        repository.files[entry.key] = VirtualFile(
          entry.key,
          entry.value,
          state: FileState.modified,
        );
      }
      return const CommandResult(
        'Modifications restaurées depuis le stash.',
        type: TerminalOutputType.success,
      );
    }
    final changed = <String, String>{
      for (final file in repository.files.values.where(
        (file) => file.state == FileState.modified,
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
    for (final path in changed.keys) {
      repository.files[path]!.state = FileState.committed;
    }
    return const CommandResult(
      'Modifications enregistrées dans le stash.',
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
    return CommandResult(
      '${args[1]} simulé avec succès. Aucun accès réseau réel n’a été effectué.',
      type: TerminalOutputType.success,
    );
  }
}
