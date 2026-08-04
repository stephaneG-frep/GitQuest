import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/quest_widgets.dart';
import '../../data/seed/learning_content.dart';
import '../collaboration/presentation/collaboration_screen.dart';
import '../projects/data/project_content.dart';
import '../projects/presentation/projects_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({required this.onNavigate, super.key});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    final nextLesson = lessons
        .where((lesson) => !store.completedLessons.contains(lesson.id))
        .firstOrNull;
    final level = (store.xp ~/ 250) + 1;
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            GitQuestLogo(size: 38),
            SizedBox(width: 12),
            Text('GitQuest', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Aide-mémoire',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const _QuickHelp())),
            icon: const Icon(Icons.menu_book_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour ${store.name} 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prêt à construire ton historique ?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                QuestCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${store.xp} XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Niveau $level',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _rankFor(level),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 18),
                      XpProgressBar(xp: store.xp),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final twoColumns = constraints.maxWidth > 680;
                    final cards = [
                      _MetricCard(
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.orange,
                        value:
                            '${store.streak} jour${store.streak > 1 ? 's' : ''}',
                        label: 'Série actuelle',
                      ),
                      _MetricCard(
                        icon: Icons.track_changes_rounded,
                        color: AppColors.green,
                        value:
                            '${(store.completedLessons.length * 7).clamp(0, store.dailyGoal)} / ${store.dailyGoal} min',
                        label: 'Objectif quotidien',
                      ),
                    ];
                    return twoColumns
                        ? Row(
                            children: [
                              Expanded(child: cards[0]),
                              const SizedBox(width: 12),
                              Expanded(child: cards[1]),
                            ],
                          )
                        : Column(children: cards);
                  },
                ),
                const AppSectionHeader('Continuer l’aventure'),
                QuestCard(
                  onTap: () => onNavigate(1),
                  child: nextLesson == null
                      ? const Row(
                          children: [
                            Icon(
                              Icons.celebration_rounded,
                              color: AppColors.green,
                            ),
                            SizedBox(width: 12),
                            Text('Toutes les leçons du MVP sont terminées !'),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.blue,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextLesson.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${nextLesson.minutes} min • Niveau ${nextLesson.level}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                ),
                const AppSectionHeader('Projet en cours'),
                ListenableBuilder(
                  listenable: AppScope.of(context).projectProgressStore,
                  builder: (context, _) {
                    final completed = AppScope.of(
                      context,
                    ).projectProgressStore.completedSteps;
                    final activeProject = projects
                        .where(
                          (project) => !project.steps.every(
                            (step) => completed.contains(step.id),
                          ),
                        )
                        .firstOrNull;
                    final nextStep = activeProject?.steps
                        .where((step) => !completed.contains(step.id))
                        .firstOrNull;
                    final completedProjects = projects
                        .where(
                          (project) => project.steps.every(
                            (step) => completed.contains(step.id),
                          ),
                        )
                        .length;
                    return QuestCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProjectsScreen(),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.violet.withValues(alpha: .14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              activeProject == null
                                  ? Icons.emoji_events_rounded
                                  : Icons.map_rounded,
                              color: activeProject == null
                                  ? AppColors.orange
                                  : AppColors.violet,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeProject?.title ??
                                      'Tous les projets sont terminés !',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextStep == null
                                      ? '$completedProjects / ${projects.length} projets accomplis'
                                      : 'Prochaine étape : ${nextStep.title}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    );
                  },
                ),
                const AppSectionHeader('Raccourcis'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Shortcut(
                      icon: Icons.terminal_rounded,
                      title: 'Terminal',
                      subtitle: 'Expérimenter',
                      color: AppColors.green,
                      onTap: () => onNavigate(2),
                    ),
                    _Shortcut(
                      icon: Icons.flag_rounded,
                      title: 'Missions',
                      subtitle: 'Relever un défi',
                      color: AppColors.violet,
                      onTap: () => onNavigate(3),
                    ),
                    _Shortcut(
                      icon: Icons.menu_book_rounded,
                      title: 'Aide-mémoire',
                      subtitle: 'Trouver une commande',
                      color: AppColors.blue,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const _QuickHelp(),
                        ),
                      ),
                    ),
                    _Shortcut(
                      icon: Icons.hub_rounded,
                      title: 'GitHub Lab',
                      subtitle: 'Issues et pull requests',
                      color: AppColors.orange,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CollaborationScreen(),
                        ),
                      ),
                    ),
                    _Shortcut(
                      icon: Icons.map_rounded,
                      title: 'Projets',
                      subtitle: 'Construire de bout en bout',
                      color: AppColors.violet,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProjectsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _rankFor(int level) => switch (level) {
  1 => 'Curieux du code',
  2 => 'Explorateur Git',
  3 => 'Gardien du dépôt',
  4 => 'Artisan du commit',
  5 => 'Maître des branches',
  _ => 'Architecte de l’historique',
};

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => QuestCard(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    child: QuestCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuickHelp extends StatefulWidget {
  const _QuickHelp();
  @override
  State<_QuickHelp> createState() => _QuickHelpState();
}

class _QuickHelpState extends State<_QuickHelp> {
  String query = '';
  static const commands = <(String, String)>[
    ('git init', 'Initialiser un dépôt'),
    ('git status', 'Voir l’état des fichiers'),
    ('git add .', 'Tout placer dans le staging'),
    ('git commit -m "Message"', 'Créer un commit'),
    ('git log --oneline', 'Afficher l’historique compact'),
    ('git diff', 'Voir les différences'),
    ('git switch -c branche', 'Créer et activer une branche'),
    ('git merge branche', 'Fusionner une branche'),
    (
      'git checkout --ours fichier',
      'Garder la version actuelle pendant un conflit',
    ),
    (
      'git checkout --theirs fichier',
      'Garder la version entrante pendant un conflit',
    ),
    ('git restore fichier', 'Restaurer un fichier'),
    ('git commit --amend -m "Message"', 'Corriger le dernier commit'),
    ('git reset --soft HEAD~1', 'Retirer un commit sans perdre les fichiers'),
    ('git revert HEAD', 'Annuler proprement un commit partagé'),
    ('git stash', 'Mettre le travail de côté'),
    ('git tag v1.0.0', 'Marquer une version'),
    ('git reflog', 'Retrouver les déplacements de HEAD'),
    ('git cherry-pick identifiant', 'Rejouer un commit ciblé'),
    ('git rebase main', 'Rejouer sa branche au-dessus de main'),
    ('git remote -v', 'Lister les dépôts distants'),
    ('git push -u origin main', 'Publier la branche main'),
  ];
  @override
  Widget build(BuildContext context) {
    final filtered = commands
        .where(
          (item) => '${item.$1} ${item.$2}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Aide-mémoire Git')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Commande ou intention…',
            ),
          ),
          const SizedBox(height: 14),
          for (final command in filtered)
            Card(
              child: ListTile(
                leading: const Icon(Icons.terminal_rounded),
                title: SelectableText(
                  command.$1,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(command.$2),
              ),
            ),
        ],
      ),
    );
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
