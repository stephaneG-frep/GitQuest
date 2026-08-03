import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/home_shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/models/learning_models.dart';
import '../../core/widgets/quest_widgets.dart';
import '../../data/seed/learning_content.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    return ScreenFrame(
      title: 'Parcours',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          Text(
            'Ton expédition Git',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${store.completedLessons.length} / ${lessons.length} leçons terminées',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          for (final level in levels) _LevelSection(level: level),
        ],
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.level});
  final LearningLevel level;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    final levelLessons = lessons
        .where((lesson) => lesson.level == level.number)
        .toList();
    final complete = levelLessons
        .where((lesson) => store.completedLessons.contains(lesson.id))
        .length;
    final locked = levelLessons.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: QuestCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    level.color.withValues(alpha: .22),
                    level.color.withValues(alpha: .04),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: level.color.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(level.icon, color: level.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NIVEAU ${level.number}',
                          style: TextStyle(
                            color: level.color,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          level.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          level.description,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    locked ? 'Bientôt' : '$complete/${levelLessons.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (!locked)
              ...levelLessons.indexed.map((entry) {
                final done = store.completedLessons.contains(entry.$2.id);
                return Column(
                  children: [
                    if (entry.$1 > 0) const Divider(height: 1, indent: 76),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 7,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: done
                            ? AppColors.green.withValues(alpha: .15)
                            : level.color.withValues(alpha: .13),
                        child: Icon(
                          done ? Icons.check_rounded : Icons.play_arrow_rounded,
                          color: done ? AppColors.green : level.color,
                        ),
                      ),
                      title: Text(
                        entry.$2.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${entry.$2.minutes} min • ${entry.$2.exercises.length} exercice${entry.$2.exercises.length > 1 ? 's' : ''}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LessonScreen(lesson: entry.$2),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            if (locked)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Le contenu complet de ce niveau arrivera dans la prochaine extension.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({required this.lesson, super.key});
  final Lesson lesson;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final Map<String, int> answers = <String, int>{};
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    final correct = widget.lesson.exercises
        .where((exercise) => answers[exercise.id] == exercise.answer)
        .length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.subtitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text('${widget.lesson.minutes} minutes'),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: AppColors.orange,
                      ),
                      const Text(' 50 XP'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  for (final block in widget.lesson.blocks)
                    _LessonBlockView(block: block),
                  if (widget.lesson.exercises.isNotEmpty) ...[
                    const AppSectionHeader('À toi de jouer'),
                    for (final exercise in widget.lesson.exercises)
                      _ExerciseCard(
                        exercise: exercise,
                        selected: answers[exercise.id],
                        checked: checked,
                        onSelected: (value) => setState(() {
                          answers[exercise.id] = value;
                          checked = false;
                        }),
                      ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: answers.length < widget.lesson.exercises.length
                          ? null
                          : () async {
                              if (!checked) {
                                setState(() => checked = true);
                                return;
                              }
                              if (correct == widget.lesson.exercises.length) {
                                await AppScope.of(
                                  context,
                                ).store.completeLesson(widget.lesson.id);
                                if (!context.mounted) return;
                                await showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    icon: const Icon(
                                      Icons.celebration_rounded,
                                      color: AppColors.green,
                                      size: 52,
                                    ),
                                    title: const Text('Leçon terminée !'),
                                    content: const Text(
                                      'Excellent travail. Tu gagnes 50 XP et ton parcours est mis à jour.',
                                    ),
                                    actions: [
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Continuer'),
                                      ),
                                    ],
                                  ),
                                );
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                      icon: Icon(
                        checked
                            ? Icons.flag_rounded
                            : Icons.fact_check_outlined,
                      ),
                      label: Text(
                        checked
                            ? (correct == widget.lesson.exercises.length
                                  ? 'Terminer la leçon'
                                  : 'Corriger mes réponses')
                            : 'Vérifier mes réponses',
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
}

class _LessonBlockView extends StatelessWidget {
  const _LessonBlockView({required this.block});
  final LessonBlock block;
  @override
  Widget build(BuildContext context) {
    if (block.type == LessonBlockType.command) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF080D18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF27334B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.terminal_rounded,
                  color: AppColors.green,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SelectableText(
                    block.content,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFE2E8F0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (block.caption != null)
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
              ],
            ),
            if (block.caption != null) ...[
              const SizedBox(height: 10),
              Text(
                block.caption!,
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ],
        ),
      );
    }
    final (icon, color, title) = switch (block.type) {
      LessonBlockType.analogy => (
        Icons.lightbulb_outline_rounded,
        AppColors.violet,
        'Une image simple',
      ),
      LessonBlockType.tip => (
        Icons.tips_and_updates_outlined,
        AppColors.green,
        'Conseil',
      ),
      LessonBlockType.warning => (
        Icons.warning_amber_rounded,
        AppColors.orange,
        'À retenir',
      ),
      _ => (Icons.subject_rounded, Theme.of(context).colorScheme.primary, ''),
    };
    if (block.type == LessonBlockType.text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Text(
          block.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(block.content, style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.selected,
    required this.checked,
    required this.onSelected,
  });
  final Exercise exercise;
  final int? selected;
  final bool checked;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    final correct = selected == exercise.answer;
    return QuestCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.question,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          RadioGroup<int>(
            groupValue: selected,
            onChanged: (value) {
              if (!checked && value != null) {
                onSelected(value);
              }
            },
            child: Column(
              children: [
                for (final option in exercise.options.indexed)
                  RadioListTile<int>(
                    value: option.$1,
                    enabled: !checked,
                    title: Text(option.$2),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
            ),
          ),
          if (checked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    (correct
                            ? AppColors.green
                            : Theme.of(context).colorScheme.error)
                        .withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${correct ? 'Correct. ' : 'Pas encore. '}${exercise.explanation}',
                style: TextStyle(
                  color: correct
                      ? AppColors.green
                      : Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
