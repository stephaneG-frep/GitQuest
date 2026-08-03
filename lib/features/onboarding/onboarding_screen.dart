import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/quest_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  final nameController = TextEditingController();
  int page = 0;
  int goal = 10;

  static const pages = <({IconData icon, String title, String text, Color color})>[
    (
      icon: Icons.rocket_launch_rounded,
      title: 'Bienvenue dans GitQuest',
      text:
          'Apprends Git et GitHub avec des cours, des missions et un terminal interactif.',
      color: AppColors.blue,
    ),
    (
      icon: Icons.history_edu_rounded,
      title: 'Comprendre',
      text:
          'Git conserve l’historique local de ton projet. Tu avances sans peur de perdre ton travail.',
      color: AppColors.violet,
    ),
    (
      icon: Icons.terminal_rounded,
      title: 'Expérimenter',
      text:
          'Teste de vraies commandes dans un dépôt virtuel sécurisé, sans toucher aux fichiers de ton appareil.',
      color: AppColors.green,
    ),
    (
      icon: Icons.military_tech_rounded,
      title: 'Progresser',
      text:
          'Gagne de l’XP, débloque des badges et deviens autonome, une petite victoire après l’autre.',
      color: AppColors.orange,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = page == pages.length;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: [
                  const GitQuestLogo(size: 44),
                  const SizedBox(width: 12),
                  Text(
                    'GitQuest',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  if (!last)
                    TextButton(
                      onPressed: () => controller.animateToPage(
                        pages.length,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('Passer'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (value) => setState(() => page = value),
                children: [
                  for (final item in pages) _IntroPage(item: item),
                  _ProfilePage(
                    nameController: nameController,
                    goal: goal,
                    onGoalChanged: (value) => setState(() => goal = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length + 1,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: index == page ? 28 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == page
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!last) {
                          await controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                          );
                        } else {
                          await AppScope.of(context).store.finishOnboarding(
                            profileName: nameController.text,
                            goal: goal,
                          );
                        }
                      },
                      icon: Icon(
                        last ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                      ),
                      label: Text(last ? 'Commencer l’aventure' : 'Continuer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.item});

  final ({IconData icon, String title, String text, Color color}) item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                item.color.withValues(alpha: .26),
                item.color.withValues(alpha: .03),
              ],
            ),
          ),
          child: Icon(item.icon, size: 76, color: item.color),
        ),
        const SizedBox(height: 40),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            item.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.nameController,
    required this.goal,
    required this.onGoalChanged,
  });

  final TextEditingController nameController;
  final int goal;
  final ValueChanged<int> onGoalChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(28, 56, 28, 24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prépare ton aventure',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Ces réglages restent sur ton appareil.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Prénom ou pseudonyme',
                prefixIcon: Icon(Icons.person_outline_rounded),
                hintText: 'Explorateur',
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Objectif quotidien',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                for (final value in [5, 10, 15, 20])
                  ChoiceChip(
                    label: Text('$value min'),
                    selected: goal == value,
                    onSelected: (_) => onGoalChanged(value),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const QuestCard(
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aucun compte, aucun tracker : ta progression reste locale et exportable.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
