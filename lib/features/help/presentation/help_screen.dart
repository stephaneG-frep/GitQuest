import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/quest_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mode d’emploi')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QuestCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF4C1D95)],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Bienvenue dans GitQuest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Apprends une notion, expérimente-la dans le terminal, puis valide-la avec une mission. Tout fonctionne localement et sans risque pour tes vrais fichiers.',
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const AppSectionHeader('Démarrage rapide'),
                const QuestCard(
                  child: Column(
                    children: [
                      _GuideStep(
                        number: 1,
                        title: 'Ouvre Parcours',
                        description:
                            'Choisis la première leçon, réponds aux exercices et gagne tes premiers XP.',
                      ),
                      Divider(height: 28),
                      _GuideStep(
                        number: 2,
                        title: 'Essaie le Terminal',
                        description:
                            'Tape git init puis valide avec Entrée ou le bouton vert.',
                      ),
                      Divider(height: 28),
                      _GuideStep(
                        number: 3,
                        title: 'Relève une Mission',
                        description:
                            'Lis les objectifs, ouvre son terminal puis utilise Vérifier le dépôt.',
                      ),
                      Divider(height: 28),
                      _GuideStep(
                        number: 4,
                        title: 'Construis un Projet',
                        description:
                            'Enchaîne terminal, dépôt et GitHub Lab dans une aventure complète.',
                      ),
                    ],
                  ),
                ),
                const AppSectionHeader('Les espaces de GitQuest'),
                const _HelpTopic(
                  icon: Icons.route_rounded,
                  color: AppColors.blue,
                  title: 'Parcours et XP',
                  summary: '40 leçons réparties sur sept niveaux.',
                  details:
                      'Chaque leçon présente une notion puis un questionnaire. Réponds une première fois pour voir la correction, corrige si nécessaire, puis termine la leçon pour recevoir 50 XP. Ta progression est enregistrée automatiquement.',
                ),
                const _HelpTopic(
                  icon: Icons.terminal_rounded,
                  color: AppColors.green,
                  title: 'Terminal sécurisé',
                  summary: 'Un laboratoire Git entièrement simulé.',
                  details:
                      'Les commandes ne touchent jamais aux fichiers réels du téléphone. Commence par git init, utilise git status quand tu hésites et tape help pour afficher les commandes disponibles. L’icône de branche en haut ouvre le dépôt visuel.',
                ),
                const _HelpTopic(
                  icon: Icons.flag_rounded,
                  color: AppColors.violet,
                  title: 'Missions',
                  summary: '25 défis validés sur le résultat obtenu.',
                  details:
                      'Tu peux choisir tes propres commandes : GitQuest vérifie l’état final du dépôt. Trois indices progressifs sont disponibles. Le dépôt est partagé avec le terminal principal, donc tu peux préparer une mission à plusieurs endroits.',
                ),
                const _HelpTopic(
                  icon: Icons.hub_rounded,
                  color: AppColors.orange,
                  title: 'GitHub Lab',
                  summary: 'Issues, pull requests, revues, CI et releases.',
                  details:
                      'Crée d’abord une branche et un commit dans le terminal. Ouvre ensuite une pull request, lance les contrôles CI, approuve la revue puis fusionne. La protection de main peut exiger revue et CI réussie.',
                ),
                const _HelpTopic(
                  icon: Icons.map_rounded,
                  color: AppColors.violet,
                  title: 'Projets fil rouge',
                  summary: 'Des scénarios complets en plusieurs étapes.',
                  details:
                      'Chaque étape indique où agir et vérifie le véritable dépôt ou GitHub Lab. Les étapes doivent être accomplies dans l’ordre et la progression reprend automatiquement.',
                ),
                const _HelpTopic(
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.blue,
                  title: 'Boîte à outils',
                  summary: 'Assistant, aide-mémoire et glossaire.',
                  details:
                      'Décris ta situation pour trouver une commande, consulte les risques et exemples, ajoute tes commandes favorites ou recherche une définition Git et GitHub.',
                ),
                const AppSectionHeader('Sauvegarde et réglages'),
                const QuestCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.settings_outlined),
                        title: Text('Où sont les paramètres ?'),
                        subtitle: Text(
                          'Profil → roue dentée. Tu peux modifier le thème, le texte et le rappel quotidien.',
                        ),
                      ),
                      Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.backup_outlined),
                        title: Text('Comment protéger ma progression ?'),
                        subtitle: Text(
                          'Dans Paramètres, utilise Partager une sauvegarde complète. Le fichier .gitquest permet de tout restaurer.',
                        ),
                      ),
                      Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.restart_alt_rounded),
                        title: Text('Comment recommencer le terminal ?'),
                        subtitle: Text(
                          'Utilise l’icône de réinitialisation dans le terminal. Cela efface uniquement le dépôt virtuel, pas les leçons.',
                        ),
                      ),
                    ],
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

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final int number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundColor: AppColors.green.withValues(alpha: .15),
        foregroundColor: AppColors.green,
        child: Text(
          '$number',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(description, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    ],
  );
}

class _HelpTopic extends StatelessWidget {
  const _HelpTopic({
    required this.icon,
    required this.color,
    required this.title,
    required this.summary,
    required this.details,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String summary;
  final String details;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: QuestCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(summary),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(details, style: const TextStyle(height: 1.5))],
      ),
    ),
  );
}
