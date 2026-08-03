import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader(this.title, {this.action, super.key});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ?action,
      ],
    ),
  );
}

class QuestCard extends StatelessWidget {
  const QuestCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.gradient,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Ink(
        decoration: gradient == null ? null : BoxDecoration(gradient: gradient),
        padding: padding,
        child: child,
      ),
    ),
  );
}

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({required this.xp, super.key});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final inLevel = xp % 250;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: inLevel / 250,
            minHeight: 9,
            backgroundColor: Colors.white.withValues(alpha: .16),
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '$inLevel / 250 XP vers le prochain niveau',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class GitQuestLogo extends StatelessWidget {
  const GitQuestLogo({this.size = 58, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.blue, AppColors.violet],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(size * .3),
      boxShadow: [
        BoxShadow(
          color: AppColors.blue.withValues(alpha: .25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Icon(
      Icons.account_tree_rounded,
      color: Colors.white,
      size: size * .55,
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}
