import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/quest_widgets.dart';
import '../../collaboration/presentation/collaboration_screen.dart';
import '../../terminal/presentation/terminal_screen.dart';
import '../data/project_content.dart';
import '../domain/project_models.dart';
import '../domain/project_validator.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.of(context).projectProgressStore;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Projets fil rouge',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Construis quelque chose de réel',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Chaque projet relie le terminal, le dépôt et GitHub Lab dans une aventure complète.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final project in projects)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: _ProjectCard(project: project),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});
  final ProjectDefinition project;

  @override
  Widget build(BuildContext context) {
    final completed = AppScope.of(context).projectProgressStore.completedSteps;
    final count = project.steps
        .where((step) => completed.contains(step.id))
        .length;
    final ratio = count / project.steps.length;
    final color = switch (project.id) {
      'portfolio' => AppColors.blue,
      'flutter-team' => AppColors.violet,
      _ => AppColors.green,
    };
    final icon = switch (project.id) {
      'portfolio' => Icons.web_rounded,
      'flutter-team' => Icons.groups_rounded,
      _ => Icons.volunteer_activism_rounded,
    };
    return QuestCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      project.subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: .12),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text('$count / ${project.steps.length} étapes'),
              const Spacer(),
              const Icon(Icons.bolt_rounded, size: 17, color: AppColors.orange),
              Text(' ${project.rewardXp} XP'),
            ],
          ),
        ],
      ),
    );
  }
}

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({required this.project, super.key});
  final ProjectDefinition project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final completed = scope.projectProgressStore.completedSteps;
    final completedCount = widget.project.steps
        .where((step) => completed.contains(step.id))
        .length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.project.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QuestCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF5B21B6)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.project.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.project.story,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$completedCount / ${widget.project.steps.length} étapes • ${widget.project.rewardXp} XP de récompense finale',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppSectionHeader('Feuille de route'),
                  for (final entry in widget.project.steps.indexed)
                    _ProjectStepCard(
                      step: entry.$2,
                      number: entry.$1 + 1,
                      complete: completed.contains(entry.$2.id),
                      locked:
                          entry.$1 > 0 &&
                          !completed.contains(
                            widget.project.steps[entry.$1 - 1].id,
                          ),
                      onCheck: () => _checkStep(entry.$2),
                      onPractice: () => _openWorkspace(entry.$2),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkStep(ProjectStepDefinition step) async {
    final scope = AppScope.of(context);
    final valid = ProjectValidator.isSatisfied(
      step,
      scope.repository,
      scope.collaborationStore,
    );
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'L’objectif n’est pas encore atteint. ${step.commandHint ?? 'Ouvre GitHub Lab et vérifie l’état demandé.'}',
          ),
        ),
      );
      return;
    }
    final added = await scope.projectProgressStore.complete(step.id);
    if (added) {
      await scope.store.rewardEvent('project-step:${step.id}', step.xp);
    }
    final allComplete = widget.project.steps.every(
      (item) => scope.projectProgressStore.completedSteps.contains(item.id),
    );
    if (allComplete) {
      await scope.store.rewardEvent(
        'project:${widget.project.id}',
        widget.project.rewardXp,
      );
      await scope.store.unlock('project_complete');
    }
    if (!mounted) return;
    setState(() {});
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          allComplete ? Icons.emoji_events_rounded : Icons.check_circle_rounded,
          color: allComplete ? AppColors.orange : AppColors.green,
          size: 48,
        ),
        title: Text(allComplete ? 'Projet terminé !' : 'Étape validée'),
        content: Text(
          allComplete
              ? 'Toutes les étapes sont terminées. Tu gagnes la récompense finale de ${widget.project.rewardXp} XP.'
              : 'Excellent. Tu gagnes ${step.xp} XP et l’étape suivante est déverrouillée.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWorkspace(ProjectStepDefinition step) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => step.opensCollaboration
            ? const CollaborationScreen()
            : TerminalScreen(embeddedMissionTitle: widget.project.title),
      ),
    );
    if (mounted) setState(() {});
  }
}

class _ProjectStepCard extends StatelessWidget {
  const _ProjectStepCard({
    required this.step,
    required this.number,
    required this.complete,
    required this.locked,
    required this.onCheck,
    required this.onPractice,
  });

  final ProjectStepDefinition step;
  final int number;
  final bool complete;
  final bool locked;
  final VoidCallback onCheck;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Opacity(
      opacity: locked ? .55 : 1,
      child: QuestCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: complete
                      ? AppColors.green.withValues(alpha: .16)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .12),
                  child: Icon(
                    complete
                        ? Icons.check_rounded
                        : locked
                        ? Icons.lock_outline_rounded
                        : Icons.flag_outlined,
                    color: complete
                        ? AppColors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÉTAPE $number • ${step.xp} XP',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(step.instruction, style: const TextStyle(height: 1.45)),
            if (step.commandHint != null && !locked) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFF080D18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  step.commandHint!,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            if (!complete && !locked) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPractice,
                      icon: Icon(
                        step.opensCollaboration
                            ? Icons.hub_rounded
                            : Icons.terminal_rounded,
                      ),
                      label: Text(
                        step.opensCollaboration ? 'GitHub Lab' : 'Terminal',
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onCheck,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Vérifier'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
