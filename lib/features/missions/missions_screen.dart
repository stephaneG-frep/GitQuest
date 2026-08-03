import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/home_shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/models/learning_models.dart';
import '../../core/widgets/quest_widgets.dart';
import '../../data/seed/missions.dart';
import '../terminal/presentation/terminal_screen.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    return ScreenFrame(
      title: 'Missions',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          Text(
            'Mets tes réflexes à l’épreuve',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            '${store.completedMissions.length} / ${missions.length} missions accomplies',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          for (final mission in missions)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: QuestCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MissionDetailScreen(mission: mission),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.violet.withValues(alpha: .28),
                            AppColors.blue.withValues(alpha: .16),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        store.completedMissions.contains(mission.id)
                            ? Icons.check_rounded
                            : Icons.flag_rounded,
                        color: store.completedMissions.contains(mission.id)
                            ? AppColors.green
                            : AppColors.violet,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${mission.objectives.length} objectifs • ${mission.xp} XP',
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
            ),
        ],
      ),
    );
  }
}

class MissionDetailScreen extends StatefulWidget {
  const MissionDetailScreen({required this.mission, super.key});
  final Mission mission;
  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  int hintsShown = 0;
  String? feedback;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    final complete = store.completedMissions.contains(widget.mission.id);
    return Scaffold(
      appBar: AppBar(title: Text(widget.mission.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuestCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF312E81), Color(0xFF1E3A8A)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          widget.mission.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.mission.context,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Chip(
                          avatar: const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.orange,
                            size: 18,
                          ),
                          label: Text('${widget.mission.xp} XP'),
                        ),
                      ],
                    ),
                  ),
                  const AppSectionHeader('Objectifs'),
                  QuestCard(
                    child: Column(
                      children: [
                        for (final objective in widget.mission.objectives)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                              children: [
                                Icon(
                                  complete
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: complete
                                      ? AppColors.green
                                      : Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(objective)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const AppSectionHeader('Besoin d’un indice ?'),
                  if (hintsShown == 0)
                    Text(
                      'Trois niveaux progressifs. Chaque indice supplémentaire réduit légèrement la récompense.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  for (var i = 0; i < hintsShown; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(widget.mission.hints[i])),
                        ],
                      ),
                    ),
                  if (hintsShown < widget.mission.hints.length)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => hintsShown += 1),
                      icon: const Icon(Icons.lightbulb_outline_rounded),
                      label: Text('Afficher l’indice ${hintsShown + 1}'),
                    ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TerminalScreen(
                              embeddedMissionTitle: widget.mission.title,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.terminal_rounded),
                      label: Text(
                        complete
                            ? 'Retourner au terminal'
                            : 'Ouvrir le terminal de mission',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: complete ? null : _validate,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Vérifier le dépôt'),
                    ),
                  ),
                  if (feedback != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          feedback!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
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

  Future<void> _validate() async {
    final scope = AppScope.of(context);
    if (!widget.mission.validator(scope.repository)) {
      setState(
        () => feedback =
            'Le dépôt n’atteint pas encore l’état demandé. Consulte git status, relis les objectifs ou révèle un indice. Les commandes exactes importent moins que le résultat final.',
      );
      return;
    }
    final reward = (widget.mission.xp - hintsShown * 10).clamp(
      40,
      widget.mission.xp,
    );
    await scope.store.completeMission(widget.mission.id, reward);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.emoji_events_rounded,
          color: AppColors.orange,
          size: 54,
        ),
        title: const Text('Mission accomplie !'),
        content: Text('L’état du dépôt est correct. Tu gagnes $reward XP.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Super !'),
          ),
        ],
      ),
    );
    setState(() => feedback = null);
  }
}
