import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/quest_widgets.dart';
import '../../terminal/domain/git_command_engine.dart';
import '../data/collaboration_store.dart';
import '../domain/collaboration_models.dart';

class PullRequestsTab extends StatelessWidget {
  const PullRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final store = scope.collaborationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: () => _createPullRequest(context, store),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Ouvrir une pull request'),
                  ),
                  const SizedBox(height: 14),
                  if (store.pullRequests.isEmpty)
                    const QuestCard(
                      child: EmptyState(
                        icon: Icons.call_merge_rounded,
                        title: 'Aucune pull request',
                        message:
                            'Crée une branche et un commit dans le terminal, puis propose leur fusion ici.',
                      ),
                    )
                  else
                    for (final pullRequest in store.pullRequests)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: QuestCard(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PullRequestDetailScreen(
                                pullRequest: pullRequest,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _statusIcon(pullRequest.status),
                                color: _statusColor(
                                  context,
                                  pullRequest.status,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pullRequest.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '#${pullRequest.id} • ${pullRequest.sourceBranch} → ${pullRequest.targetBranch}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    _StatusChip(pullRequest.status),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPullRequest(
    BuildContext context,
    CollaborationStore store,
  ) async {
    final scope = AppScope.of(context);
    final repository = scope.repository;
    final sources = repository.branches.keys
        .where((branch) => branch != 'main')
        .toList();
    if (sources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Crée d’abord une branche dans le terminal, par exemple git switch -c feature/profil.',
          ),
        ),
      );
      return;
    }
    final title = TextEditingController();
    final description = TextEditingController();
    var source = sources.first;
    int? linkedIssueId;
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvelle pull request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description des changements',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: source,
                  decoration: const InputDecoration(
                    labelText: 'Branche source',
                  ),
                  items: [
                    for (final branch in sources)
                      DropdownMenuItem(value: branch, child: Text(branch)),
                  ],
                  onChanged: (value) =>
                      setState(() => source = value ?? source),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: linkedIssueId,
                  decoration: const InputDecoration(labelText: 'Issue liée'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Aucune')),
                    for (final issue in store.issues.where(
                      (issue) => !issue.isClosed,
                    ))
                      DropdownMenuItem(
                        value: issue.id,
                        child: Text(
                          '#${issue.id} ${issue.title}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => linkedIssueId = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ouvrir'),
            ),
          ],
        ),
      ),
    );
    if (created == true && title.text.trim().isNotEmpty) {
      await store.createPullRequest(
        title: title.text.trim(),
        description: description.text.trim(),
        sourceBranch: source,
        targetBranch: 'main',
        linkedIssueId: linkedIssueId,
      );
      if (context.mounted) {
        await AppScope.of(context).store.unlock('collaborator');
      }
    }
    title.dispose();
    description.dispose();
  }
}

class PullRequestDetailScreen extends StatefulWidget {
  const PullRequestDetailScreen({required this.pullRequest, super.key});
  final SimulatedPullRequest pullRequest;

  @override
  State<PullRequestDetailScreen> createState() =>
      _PullRequestDetailScreenState();
}

class _PullRequestDetailScreenState extends State<PullRequestDetailScreen> {
  final comment = TextEditingController();

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final repository = scope.repository;
    final sourceHead = repository.branches[widget.pullRequest.sourceBranch];
    final targetHead = repository.branches[widget.pullRequest.targetBranch];
    final sourceCommit = sourceHead == null
        ? null
        : repository.commitByReference(sourceHead);
    final targetCommit = targetHead == null
        ? null
        : repository.commitByReference(targetHead);
    final changedFiles =
        <String>{
              ...?sourceCommit?.snapshot.keys,
              ...?targetCommit?.snapshot.keys,
            }
            .where(
              (path) =>
                  sourceCommit?.snapshot[path] != targetCommit?.snapshot[path],
            )
            .toList();
    final finished =
        widget.pullRequest.status == PullRequestStatus.merged ||
        widget.pullRequest.status == PullRequestStatus.closed;
    return Scaffold(
      appBar: AppBar(title: Text('Pull request #${widget.pullRequest.id}')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.pullRequest.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(widget.pullRequest.status),
                      Chip(
                        avatar: const Icon(
                          Icons.account_tree_outlined,
                          size: 17,
                        ),
                        label: Text(
                          '${widget.pullRequest.sourceBranch} → ${widget.pullRequest.targetBranch}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  QuestCard(
                    child: Text(
                      widget.pullRequest.description.isEmpty
                          ? 'Aucune description.'
                          : widget.pullRequest.description,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                  const AppSectionHeader('Changements proposés'),
                  QuestCard(
                    child: sourceCommit == null
                        ? const Text(
                            'La branche source n’existe plus dans le dépôt virtuel.',
                          )
                        : Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.commit_rounded),
                                title: Text(sourceCommit.message),
                                subtitle: Text(sourceCommit.id),
                              ),
                              const Divider(),
                              if (changedFiles.isEmpty)
                                const Text(
                                  'Aucun fichier différent de la cible.',
                                )
                              else
                                for (final path in changedFiles)
                                  ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.description_outlined,
                                      color: AppColors.blue,
                                    ),
                                    title: Text(path),
                                  ),
                            ],
                          ),
                  ),
                  const AppSectionHeader('Revue de code'),
                  if (!finished)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _review(
                            scope.collaborationStore,
                            PullRequestStatus.approved,
                          ),
                          icon: const Icon(Icons.verified_rounded),
                          label: const Text('Approuver'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _review(
                            scope.collaborationStore,
                            PullRequestStatus.changesRequested,
                          ),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Demander des changements'),
                        ),
                      ],
                    ),
                  for (final item in widget.pullRequest.comments)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: QuestCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(item.message),
                          ],
                        ),
                      ),
                    ),
                  if (!finished) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: comment,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Commentaire de revue',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _addComment,
                      icon: const Icon(Icons.comment_outlined),
                      label: const Text('Ajouter le commentaire'),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed:
                          widget.pullRequest.status ==
                              PullRequestStatus.approved
                          ? _merge
                          : null,
                      icon: const Icon(Icons.call_merge_rounded),
                      label: const Text('Fusionner la pull request'),
                    ),
                    if (widget.pullRequest.status != PullRequestStatus.approved)
                      const Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: Text(
                          'Une approbation est nécessaire avant la fusion.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _review(
    CollaborationStore store,
    PullRequestStatus status,
  ) async {
    final progress = AppScope.of(context).store;
    await store.review(widget.pullRequest, status);
    await progress.unlock('reviewer');
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addComment() async {
    if (comment.text.trim().isEmpty) return;
    final scope = AppScope.of(context);
    await scope.collaborationStore.addPullRequestComment(
      widget.pullRequest,
      scope.store.name,
      comment.text.trim(),
    );
    comment.clear();
    setState(() {});
  }

  Future<void> _merge() async {
    final scope = AppScope.of(context);
    final switchResult = scope.engine.execute(
      'git switch ${widget.pullRequest.targetBranch}',
    );
    if (!switchResult.isSuccess) {
      _showResult(switchResult);
      return;
    }
    final mergeResult = scope.engine.execute(
      'git merge ${widget.pullRequest.sourceBranch}',
    );
    if (mergeResult.isSuccess && scope.repository.conflicts.isEmpty) {
      await scope.collaborationStore.markMerged(widget.pullRequest);
    }
    if (!mounted) return;
    _showResult(mergeResult);
    setState(() {});
  }

  void _showResult(CommandResult result) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.text),
        backgroundColor: result.isSuccess
            ? AppColors.green
            : Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final PullRequestStatus status;
  @override
  Widget build(BuildContext context) => Chip(
    visualDensity: VisualDensity.compact,
    avatar: Icon(
      _statusIcon(status),
      size: 16,
      color: _statusColor(context, status),
    ),
    label: Text(_statusLabel(status)),
  );
}

IconData _statusIcon(PullRequestStatus status) => switch (status) {
  PullRequestStatus.merged => Icons.call_merge_rounded,
  PullRequestStatus.approved => Icons.verified_rounded,
  PullRequestStatus.changesRequested => Icons.rate_review_outlined,
  PullRequestStatus.closed => Icons.cancel_outlined,
  PullRequestStatus.draft => Icons.edit_note_rounded,
  PullRequestStatus.open => Icons.adjust_rounded,
};

Color _statusColor(BuildContext context, PullRequestStatus status) =>
    switch (status) {
      PullRequestStatus.merged => AppColors.violet,
      PullRequestStatus.approved => AppColors.green,
      PullRequestStatus.changesRequested => AppColors.orange,
      PullRequestStatus.closed => Theme.of(context).colorScheme.error,
      PullRequestStatus.draft => Theme.of(context).colorScheme.outline,
      PullRequestStatus.open => AppColors.green,
    };

String _statusLabel(PullRequestStatus status) => switch (status) {
  PullRequestStatus.draft => 'Brouillon',
  PullRequestStatus.open => 'Ouverte',
  PullRequestStatus.changesRequested => 'Changements demandés',
  PullRequestStatus.approved => 'Approuvée',
  PullRequestStatus.merged => 'Fusionnée',
  PullRequestStatus.closed => 'Fermée',
};
