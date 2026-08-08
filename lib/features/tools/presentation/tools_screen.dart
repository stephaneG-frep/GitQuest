import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/quest_widgets.dart';
import '../data/tool_content.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({this.initialIndex = 0, super.key});

  final int initialIndex;

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final searchController = TextEditingController();
  String query = '';
  String category = 'Toutes';
  bool favoritesOnly = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final matchingCommands = commandReferences
        .where(
          (item) =>
              normalizedQuery.isEmpty ||
              item.searchableText.contains(normalizedQuery),
        )
        .toList();
    final matchingTerms = glossaryEntries
        .where(
          (item) =>
              normalizedQuery.isEmpty ||
              item.searchableText.contains(normalizedQuery),
        )
        .toList();
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex < 0
          ? 0
          : widget.initialIndex > 2
          ? 2
          : widget.initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Boîte à outils Git',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.auto_awesome_rounded), text: 'Assistant'),
              Tab(icon: Icon(Icons.terminal_rounded), text: 'Commandes'),
              Tab(icon: Icon(Icons.menu_book_rounded), text: 'Glossaire'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: searchController,
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Ex. annuler un commit, branche, HEAD…',
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer la recherche',
                          onPressed: () {
                            searchController.clear();
                            setState(() => query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AssistantTab(
                    entries: matchingCommands,
                    onCopy: _copy,
                    onFavorite: _toggleFavorite,
                  ),
                  _CommandsTab(
                    entries: matchingCommands,
                    category: category,
                    favoritesOnly: favoritesOnly,
                    onCategoryChanged: (value) =>
                        setState(() => category = value),
                    onFavoritesChanged: (value) =>
                        setState(() => favoritesOnly = value),
                    onCopy: _copy,
                    onFavorite: _toggleFavorite,
                  ),
                  _GlossaryTab(entries: matchingTerms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copy(String command) async {
    await Clipboard.setData(ClipboardData(text: command));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Commande copiée : $command')));
  }

  Future<void> _toggleFavorite(String command) async {
    await AppScope.of(context).store.toggleFavorite(command);
    if (mounted) setState(() {});
  }
}

class _AssistantTab extends StatelessWidget {
  const _AssistantTab({
    required this.entries,
    required this.onCopy,
    required this.onFavorite,
  });

  final List<CommandReference> entries;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onFavorite;

  @override
  Widget build(BuildContext context) => _ResultsList(
    emptyMessage: 'Décris autrement ce que tu veux faire avec Git.',
    children: [
      if (entries.isNotEmpty)
        QuestCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF5B21B6)],
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.white, size: 30),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Écris ton intention : l’assistant propose une commande locale, sans envoyer aucune donnée.',
                  style: TextStyle(color: Colors.white, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      for (final entry in entries)
        _CommandCard(
          entry: entry,
          onCopy: onCopy,
          onFavorite: onFavorite,
          showSituation: true,
        ),
    ],
  );
}

class _CommandsTab extends StatelessWidget {
  const _CommandsTab({
    required this.entries,
    required this.category,
    required this.favoritesOnly,
    required this.onCategoryChanged,
    required this.onFavoritesChanged,
    required this.onCopy,
    required this.onFavorite,
  });

  final List<CommandReference> entries;
  final String category;
  final bool favoritesOnly;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onFavoritesChanged;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onFavorite;

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).store.favoriteCommands;
    final categories = <String>[
      'Toutes',
      ...{for (final item in commandReferences) item.category},
    ];
    final filtered = entries
        .where((item) => category == 'Toutes' || item.category == category)
        .where((item) => !favoritesOnly || favorites.contains(item.command))
        .toList();
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              FilterChip(
                avatar: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Favoris'),
                selected: favoritesOnly,
                onSelected: onFavoritesChanged,
              ),
              const SizedBox(width: 8),
              for (final item in categories) ...[
                ChoiceChip(
                  label: Text(item),
                  selected: category == item,
                  onSelected: (_) => onCategoryChanged(item),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Expanded(
          child: _ResultsList(
            emptyMessage: favoritesOnly
                ? 'Aucune commande favorite dans cette sélection.'
                : 'Aucune commande ne correspond à cette recherche.',
            children: [
              for (final entry in filtered)
                _CommandCard(
                  entry: entry,
                  onCopy: onCopy,
                  onFavorite: onFavorite,
                  showSituation: false,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.entry,
    required this.onCopy,
    required this.onFavorite,
    required this.showSituation,
  });

  final CommandReference entry;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onFavorite;
  final bool showSituation;

  @override
  Widget build(BuildContext context) {
    final favorite = AppScope.of(
      context,
    ).store.favoriteCommands.contains(entry.command);
    final riskColor = switch (entry.risk) {
      CommandRisk.safe => AppColors.green,
      CommandRisk.caution => AppColors.orange,
      CommandRisk.danger => Theme.of(context).colorScheme.error,
    };
    final riskLabel = switch (entry.risk) {
      CommandRisk.safe => 'Sans danger',
      CommandRisk.caution => 'Prudence',
      CommandRisk.danger => 'Destructif',
    };
    return QuestCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: riskColor.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.terminal_rounded, color: riskColor),
        ),
        title: Text(
          showSituation ? entry.situation : entry.command,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          showSituation ? entry.command : '${entry.category} • ${entry.level}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: showSituation ? 'monospace' : null,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Row(
            children: [
              _RiskChip(label: riskLabel, color: riskColor),
              const Spacer(),
              IconButton(
                tooltip: favorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                onPressed: () => onFavorite(entry.command),
                icon: Icon(
                  favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: favorite ? AppColors.orange : null,
                ),
              ),
              IconButton(
                tooltip: 'Copier la commande',
                onPressed: () => onCopy(entry.command),
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
          _Detail(label: 'Explication', value: entry.explanation),
          _Detail(label: 'Résultat', value: entry.result),
          _Detail(label: 'Exemple', value: entry.example, monospace: true),
          if (entry.variants.isNotEmpty)
            _Detail(
              label: 'Variantes',
              value: entry.variants.join('  •  '),
              monospace: true,
            ),
          if (entry.warning != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(entry.warning!)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GlossaryTab extends StatelessWidget {
  const _GlossaryTab({required this.entries});

  final List<GlossaryEntry> entries;

  @override
  Widget build(BuildContext context) => _ResultsList(
    emptyMessage: 'Aucune définition ne correspond à cette recherche.',
    children: [
      for (final entry in entries)
        QuestCard(
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.blue.withValues(alpha: .13),
              child: Text(
                entry.term.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            title: Text(
              entry.term,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              entry.definition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Exemple : ${entry.example}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.children, required this.emptyMessage});

  final List<Widget> children;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
    children: children.isEmpty
        ? [
            const SizedBox(height: 70),
            const Icon(Icons.search_off_rounded, size: 48),
            const SizedBox(height: 12),
            Text(emptyMessage, textAlign: TextAlign.center),
          ]
        : [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final child in children)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: child,
                      ),
                  ],
                ),
              ),
            ),
          ],
  );
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label\n',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                height: 1.4,
                fontFamily: monospace ? 'monospace' : null,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
