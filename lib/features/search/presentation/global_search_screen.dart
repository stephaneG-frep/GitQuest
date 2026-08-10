import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/learning_models.dart';
import '../../../core/widgets/quest_widgets.dart';
import '../../../data/seed/learning_content.dart';
import '../../../data/seed/missions.dart';
import '../../learning/learning_path_screen.dart';
import '../../missions/missions_screen.dart';
import '../../projects/data/project_content.dart';
import '../../projects/domain/project_models.dart';
import '../../projects/presentation/projects_screen.dart';
import '../../tools/data/tool_content.dart';
import '../../tools/presentation/tools_screen.dart';

enum _ResultType { lesson, mission, project, command, definition, error }

class _SearchResult {
  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.data,
  });

  final _ResultType type;
  final String title;
  final String subtitle;
  final Object data;
}

class _FrequentError {
  const _FrequentError(this.title, this.explanation, this.correction);

  final String title;
  final String explanation;
  final String correction;
}

const _frequentErrors = <_FrequentError>[
  _FrequentError(
    'git comit',
    'La sous-commande commit contient deux « m ».',
    'git commit -m "Message"',
  ),
  _FrequentError(
    'Commit sans git add',
    'Un commit ne prend que les versions présentes dans la zone de préparation.',
    'git add <fichier> puis git commit -m "Message"',
  ),
  _FrequentError(
    'Branche introuvable',
    'La branche demandée n’existe pas encore ou son nom est différent.',
    'git branch puis git switch <branche>',
  ),
  _FrequentError(
    'Conflit de fusion',
    'Git attend que chaque fichier en conflit soit résolu et préparé.',
    'git status puis git add <fichier> et git commit',
  ),
  _FrequentError(
    'Push refusé',
    'La branche distante contient peut-être des commits absents localement.',
    'git pull --rebase puis git push',
  ),
  _FrequentError(
    'Detached HEAD',
    'HEAD pointe sur un commit au lieu de suivre une branche.',
    'git switch -c branche-sauvetage',
  ),
  _FrequentError(
    'Fichier supprimé par erreur',
    'Une version suivie peut être restaurée depuis HEAD.',
    'git restore <fichier>',
  ),
  _FrequentError(
    'Mauvais dernier commit',
    'Le dernier commit local peut être corrigé avant partage.',
    'git commit --amend -m "Nouveau message"',
  ),
];

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    final results = _search(query);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recherche globale',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => query = value),
              onSubmitted: store.rememberSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Leçon, commande, notion, mission…',
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer',
                        onPressed: () {
                          controller.clear();
                          setState(() => query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          Expanded(
            child: query.trim().isEmpty
                ? _RecentSearches(
                    searches: store.recentSearches,
                    onSelected: _useQuery,
                    onClear: store.clearRecentSearches,
                  )
                : _SearchResults(
                    results: results,
                    query: query,
                    onSelected: _openResult,
                  ),
          ),
        ],
      ),
    );
  }

  void _useQuery(String value) {
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => query = value);
  }

  Future<void> _openResult(_SearchResult result) async {
    await AppScope.of(context).store.rememberSearch(query);
    if (!mounted) return;
    final route = switch (result.type) {
      _ResultType.lesson => MaterialPageRoute<void>(
        builder: (_) => LessonScreen(lesson: result.data as Lesson),
      ),
      _ResultType.mission => MaterialPageRoute<void>(
        builder: (_) => MissionDetailScreen(mission: result.data as Mission),
      ),
      _ResultType.project => MaterialPageRoute<void>(
        builder: (_) =>
            ProjectDetailScreen(project: result.data as ProjectDefinition),
      ),
      _ResultType.command => MaterialPageRoute<void>(
        builder: (_) => ToolsScreen(
          initialIndex: 1,
          initialQuery: (result.data as CommandReference).command,
        ),
      ),
      _ResultType.definition => MaterialPageRoute<void>(
        builder: (_) => ToolsScreen(
          initialIndex: 2,
          initialQuery: (result.data as GlossaryEntry).term,
        ),
      ),
      _ResultType.error => MaterialPageRoute<void>(
        builder: (_) => ToolsScreen(
          initialQuery: (result.data as _FrequentError).correction,
        ),
      ),
    };
    await Navigator.of(context).push(route);
  }
}

List<_SearchResult> _search(String rawQuery) {
  final query = _normalize(rawQuery);
  if (query.isEmpty) return const <_SearchResult>[];
  bool matches(Iterable<String> values) =>
      _normalize(values.join(' ')).contains(query);
  return <_SearchResult>[
    for (final lesson in lessons)
      if (matches(<String>[
        lesson.title,
        lesson.subtitle,
        ...lesson.blocks.map((block) => block.content),
      ]))
        _SearchResult(
          type: _ResultType.lesson,
          title: lesson.title,
          subtitle: '${lesson.minutes} min • Niveau ${lesson.level}',
          data: lesson,
        ),
    for (final mission in missions)
      if (matches(<String>[
        mission.title,
        mission.context,
        ...mission.objectives,
        ...mission.hints,
      ]))
        _SearchResult(
          type: _ResultType.mission,
          title: mission.title,
          subtitle: '${mission.objectives.length} objectifs • ${mission.xp} XP',
          data: mission,
        ),
    for (final project in projects)
      if (matches(<String>[
        project.title,
        project.subtitle,
        project.story,
        ...project.steps.map((step) => '${step.title} ${step.instruction}'),
      ]))
        _SearchResult(
          type: _ResultType.project,
          title: project.title,
          subtitle: project.subtitle,
          data: project,
        ),
    for (final command in commandReferences)
      if (_normalize(command.searchableText).contains(query))
        _SearchResult(
          type: _ResultType.command,
          title: command.command,
          subtitle: command.situation,
          data: command,
        ),
    for (final entry in glossaryEntries)
      if (_normalize(entry.searchableText).contains(query))
        _SearchResult(
          type: _ResultType.definition,
          title: entry.term,
          subtitle: entry.definition,
          data: entry,
        ),
    for (final error in _frequentErrors)
      if (matches(<String>[error.title, error.explanation, error.correction]))
        _SearchResult(
          type: _ResultType.error,
          title: error.title,
          subtitle: error.explanation,
          data: error,
        ),
  ];
}

String _normalize(String value) {
  var result = value.toLowerCase().trim();
  const replacements = <String, String>{
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
  };
  for (final replacement in replacements.entries) {
    result = result.replaceAll(replacement.key, replacement.value);
  }
  return result;
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.searches,
    required this.onSelected,
    required this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
    children: [
      if (searches.isEmpty)
        const EmptyState(
          icon: Icons.travel_explore_rounded,
          title: 'Explore tout GitQuest',
          message:
              'Recherche une commande, une notion, une leçon, une mission ou un projet.',
        )
      else ...[
        AppSectionHeader(
          'Recherches récentes',
          action: TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Effacer'),
          ),
        ),
        for (final search in searches)
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(search),
            trailing: const Icon(Icons.north_west_rounded, size: 18),
            onTap: () => onSelected(search),
          ),
      ],
    ],
  );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.results,
    required this.query,
    required this.onSelected,
  });

  final List<_SearchResult> results;
  final String query;
  final ValueChanged<_SearchResult> onSelected;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Aucun résultat',
        message:
            'Aucun contenu ne correspond à « $query ». Essaie un terme plus court.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${results.length} résultat${results.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                for (final type in _ResultType.values)
                  if (results.any((result) => result.type == type)) ...[
                    AppSectionHeader(_categoryLabel(type)),
                    QuestCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final result in results.where(
                            (item) => item.type == type,
                          ))
                            ListTile(
                              leading: Icon(
                                _categoryIcon(type),
                                color: _categoryColor(type),
                              ),
                              title: Text(
                                result.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                result.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => onSelected(result),
                            ),
                        ],
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _categoryLabel(_ResultType type) => switch (type) {
  _ResultType.lesson => 'Leçons',
  _ResultType.mission => 'Missions',
  _ResultType.project => 'Projets',
  _ResultType.command => 'Commandes',
  _ResultType.definition => 'Définitions',
  _ResultType.error => 'Erreurs fréquentes',
};

IconData _categoryIcon(_ResultType type) => switch (type) {
  _ResultType.lesson => Icons.menu_book_rounded,
  _ResultType.mission => Icons.flag_rounded,
  _ResultType.project => Icons.map_rounded,
  _ResultType.command => Icons.terminal_rounded,
  _ResultType.definition => Icons.school_rounded,
  _ResultType.error => Icons.build_circle_rounded,
};

Color _categoryColor(_ResultType type) => switch (type) {
  _ResultType.lesson => AppColors.blue,
  _ResultType.mission => AppColors.violet,
  _ResultType.project => AppColors.orange,
  _ResultType.command => AppColors.green,
  _ResultType.definition => AppColors.blue,
  _ResultType.error => AppColors.orange,
};
