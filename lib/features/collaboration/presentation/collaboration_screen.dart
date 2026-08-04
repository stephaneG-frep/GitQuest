import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/quest_widgets.dart';
import 'issues_tab.dart';
import 'pull_requests_tab.dart';

class CollaborationScreen extends StatelessWidget {
  const CollaborationScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GitHub Lab', style: TextStyle(fontWeight: FontWeight.w900)),
            Text(
              'Simulation locale',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: const _CollaborationTabs(),
      ),
      body: const TabBarView(
        children: [
          _RemoteRepositoryTab(),
          IssuesTab(),
          PullRequestsTab(),
          _ReleasesTab(),
        ],
      ),
    ),
  );
}

class _CollaborationTabs extends StatelessWidget
    implements PreferredSizeWidget {
  const _CollaborationTabs();

  @override
  Size get preferredSize => const Size.fromHeight(54);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    if (compact) {
      return const TabBar(
        tabs: [
          Tab(
            icon: Tooltip(message: 'Dépôt', child: Icon(Icons.folder_outlined)),
          ),
          Tab(
            icon: Tooltip(message: 'Issues', child: Icon(Icons.adjust_rounded)),
          ),
          Tab(
            icon: Tooltip(
              message: 'Pull requests',
              child: Icon(Icons.call_merge_rounded),
            ),
          ),
          Tab(
            icon: Tooltip(
              message: 'Releases',
              child: Icon(Icons.new_releases_outlined),
            ),
          ),
        ],
      );
    }
    return const TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        Tab(icon: Icon(Icons.folder_outlined), text: 'Dépôt'),
        Tab(icon: Icon(Icons.adjust_rounded), text: 'Issues'),
        Tab(icon: Icon(Icons.call_merge_rounded), text: 'Pull requests'),
        Tab(icon: Icon(Icons.new_releases_outlined), text: 'Releases'),
      ],
    );
  }
}

class _RemoteRepositoryTab extends StatelessWidget {
  const _RemoteRepositoryTab();

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF4C1D95)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.public_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'gitquest-academy / atelier',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Un espace distant fictif pour apprendre à collaborer sans compte ni connexion réseau.',
                        style: TextStyle(color: Colors.white70, height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _WhiteChip('${repository.commits.length} commits'),
                          _WhiteChip('${repository.branches.length} branches'),
                          _WhiteChip('${repository.tags.length} releases'),
                        ],
                      ),
                    ],
                  ),
                ),
                const AppSectionHeader('Branches'),
                QuestCard(
                  child: Column(
                    children: [
                      for (final branch in repository.branches.entries)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            branch.key == repository.currentBranch
                                ? Icons.adjust_rounded
                                : Icons.account_tree_outlined,
                            color: branch.key == repository.currentBranch
                                ? AppColors.green
                                : AppColors.violet,
                          ),
                          title: Text(
                            branch.key,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(branch.value ?? 'Aucun commit'),
                          trailing: branch.key == repository.currentBranch
                              ? const Chip(label: Text('locale'))
                              : null,
                        ),
                    ],
                  ),
                ),
                const AppSectionHeader('Fichiers publiés'),
                QuestCard(
                  child: repository.head == null
                      ? const EmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: 'Aucun commit publié',
                          message:
                              'Crée un commit dans le terminal pour alimenter ce dépôt pédagogique.',
                        )
                      : Column(
                          children: [
                            for (final path in repository.head!.snapshot.keys)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.description_outlined,
                                  color: AppColors.blue,
                                ),
                                title: Text(path),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReleasesTab extends StatefulWidget {
  const _ReleasesTab();

  @override
  State<_ReleasesTab> createState() => _ReleasesTabState();
}

class _ReleasesTabState extends State<_ReleasesTab> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final repository = scope.repository;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: repository.head == null ? null : _createRelease,
                  icon: const Icon(Icons.new_releases_rounded),
                  label: const Text('Préparer une release'),
                ),
                const SizedBox(height: 14),
                if (repository.tags.isEmpty)
                  const QuestCard(
                    child: EmptyState(
                      icon: Icons.sell_outlined,
                      title: 'Aucune release',
                      message:
                          'Une release associe un nom de version durable à un commit.',
                    ),
                  )
                else
                  for (final tag in repository.tags.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: QuestCard(
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0x2222C55E),
                              child: Icon(
                                Icons.new_releases_rounded,
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tag.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    'Commit ${tag.value} • publiée localement',
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createRelease() async {
    final controller = TextEditingController(text: 'v1.0.0');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle release'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Version',
            helperText: 'Utilise de préférence le format v1.2.3.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Publier'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    final result = AppScope.of(context).engine.execute('git tag $name');
    setState(() {});
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

class _WhiteChip extends StatelessWidget {
  const _WhiteChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(label, style: const TextStyle(color: Colors.white)),
  );
}
