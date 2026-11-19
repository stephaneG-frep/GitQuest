import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_scope.dart';
import '../../core/backup/backup_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../help/presentation/help_screen.dart';

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
            title: 'Rappel d’apprentissage',
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Rappel quotidien'),
                subtitle: Text(
                  store.reminderEnabled
                      ? 'Programmé chaque jour à ${_formatTime(store.reminderHour, store.reminderMinute)}'
                      : 'Désactivé • aucune notification envoyée',
                ),
                value: store.reminderEnabled,
                onChanged: (enabled) =>
                    _toggleReminder(context, store, enabled),
              ),
              ListTile(
                enabled: store.reminderEnabled,
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('Heure du rappel'),
                trailing: Text(
                  _formatTime(store.reminderHour, store.reminderMinute),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                onTap: store.reminderEnabled
                    ? () => _pickReminderTime(context, store)
                    : null,
              ),
            ],
          ),
          _Section(
            title: 'Données',
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file_rounded),
                title: const Text('Partager une sauvegarde complète'),
                subtitle: const Text(
                  'Profil, dépôt, GitHub Lab et projets dans un fichier',
                ),
                onTap: () => _export(context),
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Importer un fichier .gitquest'),
                subtitle: const Text('Vérifier puis fusionner ou remplacer'),
                onTap: () => _importFile(context),
              ),
              ListTile(
                leading: const Icon(Icons.content_paste_rounded),
                title: const Text('Coller une ancienne sauvegarde'),
                subtitle: const Text('Compatible avec le JSON de la version 1'),
                onTap: () => _importPastedJson(context),
              ),
              ListTile(
                leading: const Icon(Icons.restore_rounded),
                title: const Text('Annuler le dernier remplacement'),
                subtitle: const Text('Restaurer la sauvegarde automatique'),
                onTap: () => _restoreAutomaticBackup(context),
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
            title: 'Aide',
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: const Text('Mode d’emploi'),
                subtitle: const Text(
                  'Démarrage rapide et présentation de chaque espace',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
                ),
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
                subtitle: Text('Version 1.1.0 • Apprentissage hors connexion'),
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

  String _formatTime(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Future<void> _toggleReminder(
    BuildContext context,
    LocalProgressStore store,
    bool enabled,
  ) async {
    final scheduler = AppScope.of(context).reminderScheduler;
    if (scheduler == null) {
      _showReminderMessage(
        context,
        'Les notifications ne sont pas disponibles sur cette plateforme.',
      );
      return;
    }
    try {
      if (!enabled) {
        await scheduler.cancel();
        await store.updateReminder(
          enabled: false,
          hour: store.reminderHour,
          minute: store.reminderMinute,
        );
        return;
      }
      final granted = await scheduler.requestPermission();
      if (!granted) {
        if (context.mounted) {
          _showReminderMessage(
            context,
            'Autorise les notifications pour activer le rappel.',
          );
        }
        return;
      }
      await scheduler.scheduleDaily(
        hour: store.reminderHour,
        minute: store.reminderMinute,
      );
      await store.updateReminder(
        enabled: true,
        hour: store.reminderHour,
        minute: store.reminderMinute,
      );
    } on Object {
      if (context.mounted) {
        _showReminderMessage(
          context,
          'Impossible de programmer le rappel sur cet appareil.',
        );
      }
    }
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    LocalProgressStore store,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: store.reminderHour,
        minute: store.reminderMinute,
      ),
      helpText: 'Heure du rappel GitQuest',
    );
    if (selected == null || !context.mounted) return;
    final scheduler = AppScope.of(context).reminderScheduler;
    if (scheduler == null) return;
    try {
      await scheduler.scheduleDaily(
        hour: selected.hour,
        minute: selected.minute,
      );
      await store.updateReminder(
        enabled: true,
        hour: selected.hour,
        minute: selected.minute,
      );
    } on Object {
      if (context.mounted) {
        _showReminderMessage(
          context,
          'Impossible de modifier l’heure du rappel.',
        );
      }
    }
  }

  void _showReminderMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Applies the reminder settings that an import may have changed.
  Future<void> _syncReminder(AppScope scope) async {
    final scheduler = scope.reminderScheduler;
    if (scheduler == null) return;
    try {
      if (scope.store.reminderEnabled) {
        await scheduler.scheduleDaily(
          hour: scope.store.reminderHour,
          minute: scope.store.reminderMinute,
        );
      } else {
        await scheduler.cancel();
      }
    } on Object {
      // The import succeeded; a notification failure must not undo it.
    }
  }

  BackupService _backupService(BuildContext context) {
    final scope = AppScope.of(context);
    return BackupService(
      profile: scope.store,
      repository: scope.repository,
      collaboration: scope.collaborationStore,
      projects: scope.projectProgressStore,
    );
  }

  Future<void> _export(BuildContext context) async {
    final data = _backupService(context).exportJson();
    final now = DateTime.now();
    final fileName =
        'gitquest-${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}.gitquest';
    await Clipboard.setData(ClipboardData(text: data));
    if (!context.mounted) return;
    final renderObject = context.findRenderObject();
    final renderBox = renderObject is RenderBox ? renderObject : null;
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Sauvegarde GitQuest',
          subject: 'Ma sauvegarde GitQuest',
          text: 'Sauvegarde complète GitQuest',
          files: <XFile>[
            XFile.fromData(
              Uint8List.fromList(utf8.encode(data)),
              mimeType: 'application/json',
            ),
          ],
          fileNameOverrides: <String>[fileName],
          sharePositionOrigin: renderBox == null
              ? null
              : renderBox.localToGlobal(Offset.zero) & renderBox.size,
        ),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sauvegarde créée. Une copie JSON est aussi dans le presse-papiers.',
          ),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le partage n’est pas disponible, mais le JSON a été copié.',
          ),
        ),
      );
    }
  }

  Future<void> _importFile(BuildContext context) async {
    const typeGroup = XTypeGroup(
      label: 'Sauvegarde GitQuest',
      extensions: <String>['gitquest', 'json'],
      mimeTypes: <String>['application/json', 'text/plain'],
      uniformTypeIdentifiers: <String>['public.json', 'public.data'],
      webWildCards: <String>['application/json', 'text/plain'],
    );
    try {
      final file = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[typeGroup],
        confirmButtonText: 'Importer',
      );
      if (file == null || !context.mounted) return;
      final raw = await file.readAsString();
      if (!context.mounted) return;
      await _previewAndImport(context, raw);
    } on Object catch (error) {
      if (!context.mounted) return;
      _showImportError(context, error);
    }
  }

  Future<void> _importPastedJson(BuildContext context) async {
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
    await _previewAndImport(context, raw);
  }

  Future<void> _restoreAutomaticBackup(BuildContext context) async {
    try {
      final backup = await _backupService(context).loadAutomaticBackup();
      if (!context.mounted) return;
      if (backup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune sauvegarde automatique disponible.'),
          ),
        );
        return;
      }
      await _showPreview(context, backup);
    } on Object catch (error) {
      if (!context.mounted) return;
      _showImportError(context, error);
    }
  }

  Future<void> _previewAndImport(BuildContext context, String raw) async {
    try {
      final backup = _backupService(context).parse(raw);
      await _showPreview(context, backup);
    } on Object catch (error) {
      if (!context.mounted) return;
      _showImportError(context, error);
    }
  }

  Future<void> _showPreview(BuildContext context, ParsedBackup backup) async {
    final preview = backup.preview;
    final mode = await showDialog<BackupImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vérifier la sauvegarde'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${preview.name} • ${preview.xp} XP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PreviewChip('${preview.lessons} leçons'),
                    _PreviewChip('${preview.missions} missions'),
                    _PreviewChip('${preview.commits} commits'),
                    _PreviewChip('${preview.issues} issues'),
                    _PreviewChip('${preview.pullRequests} PR'),
                    _PreviewChip('${preview.projectSteps} étapes projet'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  preview.isLegacy
                      ? 'Ancien format : seul le profil et sa progression seront importés.'
                      : 'Fusionner conserve le dépôt et GitHub Lab actuels, et réunit les progressions. Remplacer restaure tous les blocs du fichier.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Avant un remplacement, GitQuest crée automatiquement un point de retour.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, BackupImportMode.merge),
            child: const Text('Fusionner'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, BackupImportMode.replace),
            child: const Text('Remplacer'),
          ),
        ],
      ),
    );
    if (mode == null || !context.mounted) return;
    final scope = AppScope.of(context);
    await _backupService(context).import(backup, mode);
    await _syncReminder(scope);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == BackupImportMode.merge
              ? 'Progressions fusionnées avec succès.'
              : 'Sauvegarde complète restaurée avec succès.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showImportError(BuildContext context, Object error) {
    final message = error is FormatException
        ? error.message
        : 'Impossible de lire cette sauvegarde.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _reset(BuildContext context, LocalProgressStore store) async {
    final projectProgressStore = AppScope.of(context).projectProgressStore;
    final reminderScheduler = AppScope.of(context).reminderScheduler;
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
      await reminderScheduler?.cancel();
      await projectProgressStore.clear();
      await store.reset();
    }
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
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
