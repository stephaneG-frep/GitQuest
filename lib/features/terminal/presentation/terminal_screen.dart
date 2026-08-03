import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../app/home_shell.dart';
import '../../../app/theme/app_theme.dart';
import '../domain/git_command_engine.dart';
import '../domain/virtual_repository.dart';

class TerminalEntry {
  const TerminalEntry(this.command, this.result);
  final String command;
  final CommandResult result;
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({this.embeddedMissionTitle, super.key});
  final String? embeddedMissionTitle;

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final input = TextEditingController();
  final focusNode = FocusNode();
  final scroll = ScrollController();
  final entries = <TerminalEntry>[];
  int historyIndex = -1;

  static const suggestions = [
    'git',
    'status',
    'add .',
    'commit -m ""',
    'log --oneline',
    'branch',
    'switch -c ',
    'merge ',
    'commit --amend -m ""',
    'revert HEAD',
    'tag v1.0.0',
  ];

  @override
  void dispose() {
    input.dispose();
    focusNode.dispose();
    scroll.dispose();
    super.dispose();
  }

  void execute() {
    final command = input.text.trim();
    if (command.isEmpty) return;
    final result = AppScope.of(context).engine.execute(command);
    if (result.text == '__CLEAR__') {
      entries.clear();
    } else {
      entries.add(TerminalEntry(command, result));
    }
    unlockForCommand(context, command);
    input.clear();
    historyIndex = -1;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
    focusNode.requestFocus();
  }

  void useSuggestion(String value) {
    final current = input.text;
    input.text = current.isEmpty || value == 'git' ? value : '$current $value';
    input.selection = TextSelection.collapsed(offset: input.text.length);
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final wide = MediaQuery.sizeOf(context).width > 920;
    final terminal = _terminal(repository);
    return ScreenFrame(
      title: widget.embeddedMissionTitle ?? 'Terminal',
      actions: [
        IconButton(
          tooltip: 'Copier la session',
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: entries
                    .map(
                      (entry) =>
                          r'$ '
                          '${entry.command}\n${entry.result.text}',
                    )
                    .join('\n'),
              ),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Session copiée.')));
          },
          icon: const Icon(Icons.copy_all_outlined),
        ),
        IconButton(
          tooltip: 'Réinitialiser le dépôt',
          onPressed: () => _confirmReset(repository),
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ],
      floatingActionButton: wide
          ? null
          : FloatingActionButton.small(
              tooltip: 'Voir le dépôt',
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => FractionallySizedBox(
                  heightFactor: .78,
                  child: RepositoryPanel(repository: repository),
                ),
              ),
              child: const Icon(Icons.account_tree_rounded),
            ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: wide
            ? Row(
                children: [
                  Expanded(flex: 3, child: terminal),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: RepositoryPanel(repository: repository),
                  ),
                ],
              )
            : terminal,
      ),
    );
  }

  Widget _terminal(VirtualRepository repository) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF080D18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF27334B)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          color: const Color(0xFF111827),
          child: Row(
            children: [
              for (final color in [
                const Color(0xFFEF4444),
                const Color(0xFFF59E0B),
                const Color(0xFF22C55E),
              ])
                Container(
                  width: 11,
                  height: 11,
                  margin: const EdgeInsets.only(right: 7),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${repository.name} — ${repository.currentBranch}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Aide',
                color: Colors.white70,
                onPressed: () {
                  input.text = 'help';
                  execute();
                },
                icon: const Icon(Icons.help_outline_rounded, size: 20),
              ),
            ],
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? const _TerminalWelcome()
              : ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _EntryView(entry: entries[index]),
                ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Row(
            children: [
              for (final suggestion in suggestions)
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF1D263D),
                    side: BorderSide.none,
                    label: Text(
                      suggestion,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontFamily: 'monospace',
                      ),
                    ),
                    onPressed: () => useSuggestion(suggestion),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 8, 10, 10),
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            border: Border(top: BorderSide(color: Color(0xFF27334B))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                r'$',
                style: TextStyle(
                  color: AppColors.green,
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.arrowUp):
                        _previousCommand,
                    const SingleActivator(LogicalKeyboardKey.arrowDown):
                        _nextCommand,
                  },
                  child: TextField(
                    controller: input,
                    focusNode: focusNode,
                    autofocus: true,
                    onSubmitted: (_) => execute(),
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontFamily: 'monospace',
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      hintText: 'git status',
                      hintStyle: TextStyle(color: Color(0xFF64748B)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Exécuter',
                onPressed: execute,
                color: AppColors.green,
                icon: const Icon(Icons.arrow_circle_right_rounded, size: 30),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _previousCommand() {
    final history = AppScope.of(context).repository.commandHistory;
    if (history.isEmpty) return;
    historyIndex = (historyIndex + 1).clamp(0, history.length - 1);
    input.text = history[history.length - 1 - historyIndex];
    input.selection = TextSelection.collapsed(offset: input.text.length);
  }

  void _nextCommand() {
    if (historyIndex <= 0) {
      historyIndex = -1;
      input.clear();
      return;
    }
    historyIndex -= 1;
    final history = AppScope.of(context).repository.commandHistory;
    input.text = history[history.length - 1 - historyIndex];
  }

  Future<void> _confirmReset(VirtualRepository repository) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Réinitialiser le laboratoire ?'),
            content: const Text(
              'Le dépôt virtuel et l’historique du terminal seront effacés. Ta progression pédagogique reste intacte.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      setState(() {
        AppScope.of(context).engine.resetRepository();
        entries.clear();
      });
    }
  }
}

class _TerminalWelcome extends StatelessWidget {
  const _TerminalWelcome();
  @override
  Widget build(BuildContext context) => const Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.terminal_rounded, color: AppColors.green, size: 52),
          SizedBox(height: 16),
          Text(
            'Laboratoire sécurisé',
            style: TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aucune commande système réelle n’est exécutée.\nEssaie “git init” ou “help”.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), height: 1.5),
          ),
        ],
      ),
    ),
  );
}

class _EntryView extends StatelessWidget {
  const _EntryView({required this.entry});
  final TerminalEntry entry;
  @override
  Widget build(BuildContext context) {
    final color = switch (entry.result.type) {
      TerminalOutputType.success => const Color(0xFF86EFAC),
      TerminalOutputType.error => const Color(0xFFFCA5A5),
      TerminalOutputType.warning => const Color(0xFFFCD34D),
      TerminalOutputType.info => const Color(0xFFCBD5E1),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'gitquest@academy ~/atelier (${AppScope.of(context).repository.currentBranch})',
            style: const TextStyle(
              color: Color(0xFF60A5FA),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            r'$ '
            '${entry.command}',
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            entry.result.text,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class RepositoryPanel extends StatelessWidget {
  const RepositoryPanel({required this.repository, super.key});
  final VirtualRepository repository;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.account_tree_rounded, color: AppColors.violet),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Dépôt virtuel',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ),
              Chip(
                avatar: const Icon(
                  Icons.circle,
                  size: 10,
                  color: AppColors.green,
                ),
                label: Text(repository.currentBranch),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: repository.initialized
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'FICHIERS',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 8),
                    for (final file in repository.files.values)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          _fileIcon(file.state),
                          color: _fileColor(file.state),
                          size: 20,
                        ),
                        title: Text(file.path),
                        trailing: Text(
                          _fileLabel(file.state),
                          style: TextStyle(
                            color: _fileColor(file.state),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'HISTORIQUE',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 12),
                    if (repository.commits.isEmpty)
                      Text(
                        'Aucun commit. Ton histoire commence ici.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    for (final commit in repository.commits.reversed)
                      _CommitNode(
                        commit: commit,
                        isHead: repository.head?.id == commit.id,
                      ),
                    if (repository.branches.length > 1) ...[
                      const SizedBox(height: 16),
                      Text(
                        'BRANCHES',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(letterSpacing: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        children: [
                          for (final branch in repository.branches.keys)
                            Chip(
                              label: Text(branch),
                              avatar: Icon(
                                branch == repository.currentBranch
                                    ? Icons.adjust_rounded
                                    : Icons.circle_outlined,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (repository.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'TAGS',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(letterSpacing: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        children: [
                          for (final tag in repository.tags.entries)
                            Chip(
                              avatar: const Icon(Icons.sell_outlined, size: 16),
                              label: Text('${tag.key} · ${tag.value}'),
                            ),
                        ],
                      ),
                    ],
                  ],
                )
              : const _TerminalWelcome(),
        ),
      ],
    ),
  );
}

class _CommitNode extends StatelessWidget {
  const _CommitNode({required this.commit, required this.isHead});
  final VirtualCommit commit;
  final bool isHead;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: isHead ? AppColors.green : AppColors.violet,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).cardColor,
                    width: 2,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.violet.withValues(alpha: .35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      commit.id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.violet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isHead)
                      const Padding(
                        padding: EdgeInsets.only(left: 7),
                        child: Text(
                          'HEAD',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  commit.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

IconData _fileIcon(FileState state) => switch (state) {
  FileState.staged => Icons.add_circle_outline_rounded,
  FileState.modified => Icons.edit_outlined,
  FileState.conflicted => Icons.warning_amber_rounded,
  _ => Icons.description_outlined,
};
Color _fileColor(FileState state) => switch (state) {
  FileState.staged => AppColors.green,
  FileState.modified => AppColors.orange,
  FileState.conflicted => const Color(0xFFEF4444),
  FileState.untracked => const Color(0xFF94A3B8),
  FileState.committed => AppColors.blue,
};
String _fileLabel(FileState state) => switch (state) {
  FileState.staged => 'A',
  FileState.modified => 'M',
  FileState.conflicted => 'U',
  FileState.untracked => '?',
  FileState.committed => '✓',
};
