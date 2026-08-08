import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../core/storage/local_progress_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).store;
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Section(
            title: 'Profil',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Pseudonyme'),
                subtitle: Text(store.name),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _editName(context, store),
              ),
            ],
          ),
          _Section(
            title: 'Apparence',
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Thème'),
                trailing: DropdownButton<ThemePreference>(
                  value: store.themePreference,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemePreference.system,
                      child: Text('Système'),
                    ),
                    DropdownMenuItem(
                      value: ThemePreference.light,
                      child: Text('Clair'),
                    ),
                    DropdownMenuItem(
                      value: ThemePreference.dark,
                      child: Text('Sombre'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) store.updateTheme(value);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields_rounded),
                title: const Text('Taille du texte'),
                subtitle: Slider(
                  value: store.textScale,
                  min: .9,
                  max: 1.3,
                  divisions: 4,
                  label: '${(store.textScale * 100).round()} %',
                  onChanged: store.updateTextScale,
                ),
              ),
            ],
          ),
          _Section(
            title: 'Données',
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file_rounded),
                title: const Text('Exporter la progression'),
                subtitle: const Text('Copier une sauvegarde JSON versionnée'),
                onTap: () => _export(context, store),
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Importer une progression'),
                subtitle: const Text('Coller une sauvegarde GitQuest'),
                onTap: () => _import(context, store),
              ),
              ListTile(
                leading: Icon(
                  Icons.restart_alt_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Réinitialiser toutes les données',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _reset(context, store),
              ),
            ],
          ),
          _Section(
            title: 'À propos',
            children: const [
              ListTile(
                leading: Icon(Icons.shield_outlined),
                title: Text('Confidentialité locale'),
                subtitle: Text(
                  'Aucune donnée personnelle, publicité ou analyse distante.',
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('GitQuest'),
                subtitle: Text('Version 1.0.0 • MVP hors connexion'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, LocalProgressStore store) async {
    final controller = TextEditingController(text: store.name);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ton pseudonyme'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) await store.updateName(value);
  }

  Future<void> _export(BuildContext context, LocalProgressStore store) async {
    final data = store.exportJson();
    await Clipboard.setData(ClipboardData(text: data));
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sauvegarde copiée'),
        content: const Text(
          'Le JSON GitQuest versionné est dans le presse-papiers. Enregistre-le dans un fichier .gitquest pour le conserver.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context, LocalProgressStore store) async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer une sauvegarde'),
        content: SizedBox(
          width: 600,
          child: TextField(
            controller: controller,
            minLines: 7,
            maxLines: 14,
            decoration: const InputDecoration(
              hintText: 'Colle ici le contenu du fichier .gitquest',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Vérifier et importer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (raw == null || !context.mounted) return;
    final error = await store.importJson(raw);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Progression importée avec succès.'),
        backgroundColor: error == null
            ? Colors.green
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _reset(BuildContext context, LocalProgressStore store) async {
    final projectProgressStore = AppScope.of(context).projectProgressStore;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tout recommencer ?'),
            content: const Text(
              'Cette opération efface le profil, l’XP, les leçons, les missions, les projets et les badges. Exporte d’abord une sauvegarde si nécessaire.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await projectProgressStore.clear();
      await store.reset();
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    ),
  );
}
