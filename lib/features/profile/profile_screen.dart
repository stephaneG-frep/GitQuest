import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/home_shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/quest_widgets.dart';
import '../../data/seed/learning_content.dart';
import '../projects/data/project_content.dart';
import '../settings/settings_screen.dart';
import '../statistics/presentation/statistics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    final level = store.xp ~/ 250 + 1;
    return ScreenFrame(
      title: 'Profil',
      actions: [
        IconButton(
          tooltip: 'Statistiques',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const StatisticsScreen()),
          ),
          icon: const Icon(Icons.insights_rounded),
        ),
        IconButton(
          tooltip: 'Paramètres',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.blue, AppColors.violet],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  store.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Niveau $level • ${store.xp} XP',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth <= 650;
              final progress = AppScope.of(context).projectProgressStore;
              return ListenableBuilder(
                listenable: progress,
                builder: (context, _) {
                  final completedProjects = projects
                      .where(
                        (project) => project.steps.every(
                          (step) => progress.completedSteps.contains(step.id),
                        ),
                      )
                      .length;
                  return GridView.count(
                    crossAxisCount: compact ? 2 : 5,
                    mainAxisExtent: compact ? 124 : 116,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Stat(
                        Icons.menu_book_rounded,
                        '${store.completedLessons.length}',
                        'Leçons',
                      ),
                      _Stat(
                        Icons.flag_rounded,
                        '${store.completedMissions.length}',
                        'Missions',
                      ),
                      _Stat(
                        Icons.map_rounded,
                        '$completedProjects / ${projects.length}',
                        'Projets',
                      ),
                      _Stat(
                        Icons.local_fire_department_rounded,
                        '${store.streak}',
                        'Série',
                      ),
                      _Stat(
                        Icons.terminal_rounded,
                        '${AppScope.of(context).repository.commandHistory.length}',
                        'Commandes',
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          QuestCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatisticsScreen()),
            ),
            child: const Row(
              children: [
                Icon(Icons.insights_rounded, color: AppColors.blue),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toutes mes statistiques',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text('Activité, progression et commandes utilisées'),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const AppSectionHeader('Badges'),
          QuestCard(
            child: Wrap(
              spacing: 14,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: [
                for (final badge in achievements)
                  SizedBox(
                    width: 94,
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color:
                                (store.unlockedAchievements.contains(badge.id)
                                        ? AppColors.orange
                                        : Theme.of(context).colorScheme.outline)
                                    .withValues(alpha: .14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            badge.icon,
                            color: store.unlockedAchievements.contains(badge.id)
                                ? AppColors.orange
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          badge.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!store.unlockedAchievements.contains(badge.id))
                          Text(
                            badge.description,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          QuestCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings_outlined),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paramètres et sauvegarde',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text('Thème, accessibilité, export et import'),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => QuestCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
