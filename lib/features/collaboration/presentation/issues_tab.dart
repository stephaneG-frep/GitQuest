import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/quest_widgets.dart';
import '../data/collaboration_store.dart';
import '../domain/collaboration_models.dart';

class IssuesTab extends StatelessWidget {
  const IssuesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).collaborationStore;
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
                    onPressed: () => _createIssue(context, store),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Créer une issue'),
                  ),
                  const SizedBox(height: 14),
                  for (final issue in store.issues)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: QuestCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => IssueDetailScreen(issue: issue),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              issue.isClosed
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.adjust_rounded,
                              color: issue.isClosed
                                  ? AppColors.violet
                                  : AppColors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    issue.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 7,
                                    runSpacing: 6,
                                    children: [
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(issue.label),
                                      ),
                                      _PriorityChip(issue.priority),
                                      Text(
                                        '#${issue.id} • ${issue.comments.length} commentaire(s)',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
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

  Future<void> _createIssue(
    BuildContext context,
    CollaborationStore store,
  ) async {
    final title = TextEditingController();
    final description = TextEditingController();
    var priority = IssuePriority.medium;
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvelle issue'),
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
                    labelText: 'Description et résultat attendu',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<IssuePriority>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priorité'),
                  items: [
                    for (final value in IssuePriority.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(_priorityLabel(value)),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => priority = value ?? IssuePriority.medium),
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
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
    if (created == true && title.text.trim().isNotEmpty) {
      await store.createIssue(
        title: title.text.trim(),
        description: description.text.trim(),
        label: 'à trier',
        priority: priority,
      );
      if (context.mounted) {
        await AppScope.of(context).store.unlock('issue_author');
      }
    }
    title.dispose();
    description.dispose();
  }
}

class IssueDetailScreen extends StatefulWidget {
  const IssueDetailScreen({required this.issue, super.key});
  final SimulatedIssue issue;

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final comment = TextEditingController();

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Issue #${widget.issue.id}')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.issue.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          widget.issue.isClosed
                              ? Icons.check_rounded
                              : Icons.adjust_rounded,
                          size: 17,
                        ),
                        label: Text(
                          widget.issue.isClosed ? 'Fermée' : 'Ouverte',
                        ),
                      ),
                      Chip(label: Text(widget.issue.label)),
                      _PriorityChip(widget.issue.priority),
                    ],
                  ),
                  const SizedBox(height: 14),
                  QuestCard(
                    child: Text(
                      widget.issue.description.isEmpty
                          ? 'Aucune description.'
                          : widget.issue.description,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                  const AppSectionHeader('Discussion'),
                  for (final item in widget.issue.comments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
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
                  TextField(
                    controller: comment,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ajouter un commentaire',
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () async {
                      if (comment.text.trim().isEmpty) return;
                      await scope.collaborationStore.addIssueComment(
                        widget.issue,
                        scope.store.name,
                        comment.text.trim(),
                      );
                      comment.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Commenter'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await scope.collaborationStore.toggleIssue(widget.issue);
                      setState(() {});
                    },
                    icon: Icon(
                      widget.issue.isClosed
                          ? Icons.refresh_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      widget.issue.isClosed
                          ? 'Rouvrir l’issue'
                          : 'Fermer l’issue',
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
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip(this.priority);
  final IssuePriority priority;
  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      IssuePriority.low => AppColors.green,
      IssuePriority.medium => AppColors.orange,
      IssuePriority.high => Theme.of(context).colorScheme.error,
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.flag_outlined, size: 16, color: color),
      label: Text(_priorityLabel(priority)),
    );
  }
}

String _priorityLabel(IssuePriority priority) => switch (priority) {
  IssuePriority.low => 'Faible',
  IssuePriority.medium => 'Normale',
  IssuePriority.high => 'Haute',
};
