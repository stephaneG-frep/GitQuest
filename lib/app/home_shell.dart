import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/learning/learning_path_screen.dart';
import '../features/missions/missions_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/terminal/presentation/terminal_screen.dart';
import 'app_scope.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  static const destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Accueil',
    ),
    NavigationDestination(
      icon: Icon(Icons.route_outlined),
      selectedIcon: Icon(Icons.route_rounded),
      label: 'Parcours',
    ),
    NavigationDestination(
      icon: Icon(Icons.terminal_outlined),
      selectedIcon: Icon(Icons.terminal_rounded),
      label: 'Terminal',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag_rounded),
      label: 'Missions',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(onNavigate: (value) => setState(() => index = value)),
      const LearningPathScreen(),
      const TerminalScreen(),
      const MissionsScreen(),
      const ProfileScreen(),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 820;
    final content = IndexedStack(index: index, children: pages);
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: MediaQuery.sizeOf(context).width >= 1120,
                selectedIndex: index,
                onDestinationSelected: (value) => setState(() => index = value),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Icon(
                    Icons.account_tree_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 34,
                  ),
                ),
                destinations: [
                  for (final item in destinations)
                    NavigationRailDestination(
                      icon: item.icon,
                      selectedIcon: item.selectedIcon,
                      label: Text(item.label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }
    return Scaffold(
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        labelBehavior: MediaQuery.sizeOf(context).width < 420
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: destinations,
      ),
    );
  }
}

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      actions: actions,
      scrolledUnderElevation: 0,
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: child,
      ),
    ),
    floatingActionButton: floatingActionButton,
  );
}

Future<void> unlockForCommand(BuildContext context, String command) async {
  final store = AppScope.of(context).store;
  if (command == 'git init') await store.unlock('first_repo');
  if (command.startsWith('git add')) await store.unlock('staging');
  if (command.startsWith('git commit')) await store.unlock('first_commit');
  if (command.startsWith('git log')) await store.unlock('historian');
  if (command.startsWith('git branch') || command.startsWith('git switch -c')) {
    await store.unlock('branch');
  }
  if (command.startsWith('git merge')) await store.unlock('merge');
}
