import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/quest_widgets.dart';
import '../../../data/seed/learning_content.dart';
import '../../projects/data/project_content.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final store = scope.store;
    final repository = scope.repository;
    final completedProjects = projects
        .where(
          (project) => project.steps.every(
            (step) =>
                scope.projectProgressStore.completedSteps.contains(step.id),
          ),
        )
        .length;
    final learningMinutes = lessons
        .where((lesson) => store.completedLessons.contains(lesson.id))
        .fold<int>(0, (total, lesson) => total + lesson.minutes);
    final level = store.xp ~/ 250 + 1;
    final weekly = _weeklyActivity(
      store.dailyActivity,
      repository.dailyCommands,
    );
    final topCommands = _topCommands(repository.commandHistory);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistiques',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QuestCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF6D28D9)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Niveau $level',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                '${store.xp} XP accumulés',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppSectionHeader('Vue d’ensemble'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 850
                          ? 5
                          : constraints.maxWidth >= 560
                          ? 3
                          : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        mainAxisExtent: 108,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _Metric(
                            Icons.schedule_rounded,
                            '$learningMinutes min',
                            'Apprentissage',
                          ),
                          _Metric(
                            Icons.menu_book_rounded,
                            '${store.completedLessons.length}',
                            'Leçons',
                          ),
                          _Metric(
                            Icons.flag_rounded,
                            '${store.completedMissions.length}',
                            'Missions',
                          ),
                          _Metric(
                            Icons.map_rounded,
                            '$completedProjects / ${projects.length}',
                            'Projets',
                          ),
                          _Metric(
                            Icons.terminal_rounded,
                            '${repository.commandHistory.length}',
                            'Commandes',
                          ),
                          _Metric(
                            Icons.check_circle_rounded,
                            '${repository.successfulCommands}',
                            'Réussies',
                          ),
                          _Metric(
                            Icons.build_circle_rounded,
                            '${repository.correctedErrors}',
                            'Erreurs corrigées',
                          ),
                          _Metric(
                            Icons.military_tech_rounded,
                            '$level',
                            'Niveau',
                          ),
                          _Metric(
                            Icons.bolt_rounded,
                            '${store.xp}',
                            'XP total',
                          ),
                          _Metric(
                            Icons.local_fire_department_rounded,
                            '${store.streak} / ${store.bestStreak}',
                            'Série / record',
                          ),
                        ],
                      );
                    },
                  ),
                  const AppSectionHeader('Sept derniers jours'),
                  _WeeklyChart(points: weekly),
                  const AppSectionHeader('Progression par thème'),
                  QuestCard(
                    child: Column(
                      children: [
                        for (final learningLevel in levels)
                          if (lessons.any(
                            (lesson) => lesson.level == learningLevel.number,
                          ))
                            _LevelProgress(
                              title: learningLevel.title,
                              color: learningLevel.color,
                              completed: lessons
                                  .where(
                                    (lesson) =>
                                        lesson.level == learningLevel.number,
                                  )
                                  .where(
                                    (lesson) => store.completedLessons.contains(
                                      lesson.id,
                                    ),
                                  )
                                  .length,
                              total: lessons
                                  .where(
                                    (lesson) =>
                                        lesson.level == learningLevel.number,
                                  )
                                  .length,
                            ),
                      ],
                    ),
                  ),
                  const AppSectionHeader('Commandes les plus utilisées'),
                  QuestCard(
                    child: topCommands.isEmpty
                        ? const _EmptyCommands()
                        : Column(
                            children: [
                              for (final entry in topCommands.indexed)
                                _CommandUsage(
                                  position: entry.$1 + 1,
                                  command: entry.$2.$1,
                                  count: entry.$2.$2,
                                  maximum: topCommands.first.$2,
                                ),
                            ],
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

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => QuestCard(
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 25),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

class _WeeklyPoint {
  const _WeeklyPoint(this.date, this.activities, this.commands);

  final DateTime date;
  final int activities;
  final int commands;
  int get total => activities + commands;
}

List<_WeeklyPoint> _weeklyActivity(
  Map<String, int> activities,
  Map<String, int> commands,
) {
  final today = DateTime.now();
  return List<_WeeklyPoint>.generate(7, (index) {
    final date = DateTime(today.year, today.month, today.day - 6 + index);
    final key =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return _WeeklyPoint(date, activities[key] ?? 0, commands[key] ?? 0);
  });
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.points});

  final List<_WeeklyPoint> points;

  @override
  Widget build(BuildContext context) {
    final maximum = math.max(
      1,
      points.fold<int>(0, (value, point) => math.max(value, point.total)),
    );
    final hasActivity = points.any((point) => point.total > 0);
    return QuestCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _Legend(color: AppColors.violet, label: 'Apprentissage'),
              _Legend(color: AppColors.green, label: 'Commandes'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final point in points)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${point.total}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: math.max(4, 100 * point.total / maximum),
                            decoration: BoxDecoration(
                              gradient: point.total == 0
                                  ? null
                                  : const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.green,
                                        AppColors.violet,
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(6),
                              color: point.total == 0
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _weekday(point.date.weekday),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!hasActivity) ...[
            const SizedBox(height: 8),
            Text(
              'Le suivi quotidien commence avec cette version. Termine une activité ou utilise le terminal pour remplir le graphique.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

class _LevelProgress extends StatelessWidget {
  const _LevelProgress({
    required this.title,
    required this.color,
    required this.completed,
    required this.total,
  });

  final String title;
  final Color color;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text('$completed / $total'),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            minHeight: 8,
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
        ),
      ],
    ),
  );
}

List<(String, int)> _topCommands(List<String> history) {
  final usage = <String, int>{};
  for (final raw in history) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) continue;
    final command = parts.first == 'git' && parts.length > 1
        ? 'git ${parts[1]}'
        : parts.first;
    usage.update(command, (value) => value + 1, ifAbsent: () => 1);
  }
  final result = usage.entries.map((entry) => (entry.key, entry.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
  return result.take(5).toList();
}

class _CommandUsage extends StatelessWidget {
  const _CommandUsage({
    required this.position,
    required this.command,
    required this.count,
    required this.maximum,
  });

  final int position;
  final String command;
  final int count;
  final int maximum;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      children: [
        CircleAvatar(
          radius: 15,
          child: Text('$position', style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                command,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(value: count / maximum, minHeight: 6),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text('$count×', style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _EmptyCommands extends StatelessWidget {
  const _EmptyCommands();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 18),
    child: Column(
      children: [
        Icon(Icons.terminal_rounded, size: 38),
        SizedBox(height: 10),
        Text(
          'Utilise le terminal pour découvrir tes commandes favorites.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

String _weekday(int weekday) => const <String>[
  'lun',
  'mar',
  'mer',
  'jeu',
  'ven',
  'sam',
  'dim',
][weekday - 1];
