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

  CommandResult execute(String input) {
    final result = _execute(input);
    if (input.trim().isNotEmpty) {
      onChanged?.call(repository);
    }
    return result;
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
    final buffer = StringBuffer('Sur la branche ${repository.currentBranch}\n');
    if (repository.commits.isEmpty) {
      buffer.writeln('Aucun commit pour le moment');
    }
    if (staged.isNotEmpty) {
      buffer.writeln(
        '\nModifications qui seront validées :\n  A  ${staged.join('\n  A  ')}',
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
    if (staged.isEmpty && modified.isEmpty && untracked.isEmpty) {
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
    if (repository.stagedFiles.isEmpty) {
      return const CommandResult(
        'Aucun changement préparé.\nUtilise d’abord git add.',
        type: TerminalOutputType.error,
      );
    }
    final commit = repository.createCommit(args[messageIndex + 1]);
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
    return CommandResult(
      'Basculement sur la branche “$target”.',
      type: TerminalOutputType.success,
    );
  }

  CommandResult _merge(List<String> args) {
    final error = _requireRepository();
    if (error != null) return error;
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
    final sourceHead = repository.branches[source];
    if (sourceHead == null ||
        sourceHead == repository.branches[repository.currentBranch]) {
      repository.mergedBranches.add(source);
      return const CommandResult(
        'Déjà à jour.',
        type: TerminalOutputType.success,
      );
    }
    final currentHead = repository.branches[repository.currentBranch];
    repository.branches[repository.currentBranch] = sourceHead;
    repository.mergedBranches.add(source);
    if (currentHead != null) {
      repository.createCommit(
        'Fusion de $source',
        parents: <String>[currentHead, sourceHead],
      );
    }
    return CommandResult(
      'Branche $source fusionnée dans ${repository.currentBranch}.',
      type: TerminalOutputType.success,
    );
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
