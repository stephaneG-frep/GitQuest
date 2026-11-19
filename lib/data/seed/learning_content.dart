import 'package:flutter/material.dart';

import '../../core/models/learning_models.dart';

const levels = <LearningLevel>[
  LearningLevel(
    number: 1,
    title: 'Explorateur Git',
    description: 'Comprendre, configurer et initialiser',
    icon: Icons.explore_rounded,
    color: Color(0xFF3B82F6),
  ),
  LearningLevel(
    number: 2,
    title: 'Artisan du commit',
    description: 'Préparer et photographier ton travail',
    icon: Icons.camera_alt_rounded,
    color: Color(0xFF8B5CF6),
  ),
  LearningLevel(
    number: 3,
    title: 'Maître des branches',
    description: 'Explorer plusieurs chemins sans risque',
    icon: Icons.account_tree_rounded,
    color: Color(0xFF22C55E),
  ),
  LearningLevel(
    number: 4,
    title: 'Voyageur distant',
    description: 'Synchroniser avec un dépôt distant',
    icon: Icons.cloud_sync_rounded,
    color: Color(0xFFF59E0B),
  ),
  LearningLevel(
    number: 5,
    title: 'Collaborateur GitHub',
    description: 'Issues, pull requests et revue',
    icon: Icons.groups_rounded,
    color: Color(0xFFEC4899),
  ),
  LearningLevel(
    number: 6,
    title: 'Maîtrise avancée',
    description: 'Réparer et réorganiser l’historique',
    icon: Icons.auto_fix_high_rounded,
    color: Color(0xFF06B6D4),
  ),
  LearningLevel(
    number: 7,
    title: 'Git professionnel',
    description: 'Workflows, sécurité et livraison',
    icon: Icons.workspace_premium_rounded,
    color: Color(0xFFF97316),
  ),
  LearningLevel(
    number: 8,
    title: 'GitHub en pratique',
    description: 'Jetons, SSH, Pages, profil et Actions pas à pas',
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFF84CC16),
  ),
];

const lessons = <Lesson>[
  Lesson(
    id: 'versioning',
    level: 1,
    title: 'Pourquoi versionner ?',
    subtitle: 'Garde une mémoire fiable de ton projet',
    minutes: 6,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Le versionnage enregistre les étapes importantes d’un projet. Tu peux comprendre quand, pourquoi et par qui une modification a été faite.',
      ),
      LessonBlock(
        LessonBlockType.analogy,
        'Imagine un album de photos : chaque commit capture un état cohérent de ton projet.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Fais des commits petits, cohérents et décrits avec un message précis.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e01',
        question: 'À quoi sert principalement le versionnage ?',
        options: [
          'Compresser les fichiers',
          'Conserver un historique',
          'Publier automatiquement',
        ],
        answer: 1,
        explanation:
            'Git conserve des états successifs et permet de comprendre leur évolution.',
      ),
      Exercise(
        id: 'e02',
        question: 'Un commit ressemble surtout à…',
        options: ['Une photo du projet', 'Un mot de passe', 'Un serveur'],
        answer: 0,
        explanation:
            'Un commit photographie les changements préparés à un instant précis.',
      ),
    ],
  ),
  Lesson(
    id: 'git-github',
    level: 1,
    title: 'Git ou GitHub ?',
    subtitle: 'Deux outils complémentaires, pas identiques',
    minutes: 7,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Git est le moteur de versionnage installé sur ta machine. GitHub est un service en ligne qui héberge des dépôts Git et facilite la collaboration.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Tu peux utiliser Git sans GitHub et travailler entièrement hors connexion.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e03',
        question: 'Lequel fonctionne entièrement en local ?',
        options: ['Git', 'GitHub uniquement', 'Une pull request'],
        answer: 0,
        explanation:
            'Git est un logiciel local. Un hébergeur distant est facultatif.',
      ),
      Exercise(
        id: 'e56',
        question: 'Quel service héberge des dépôts en ligne pour collaborer ?',
        options: ['Git', 'GitHub', 'Le terminal'],
        answer: 1,
        explanation:
            'GitHub héberge des dépôts Git et ajoute issues, pull requests et revues.',
      ),
    ],
  ),
  Lesson(
    id: 'configuration',
    level: 1,
    title: 'Configurer son identité',
    subtitle: 'Signer clairement ses futurs commits',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'git --version',
        caption: 'Vérifie que Git est installé.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git config --global user.name "Ada Lovelace"',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git config --global user.email "ada@example.com"',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e04',
        question: 'Quelle option applique la configuration à tous tes dépôts ?',
        options: ['--everywhere', '--global', '--remote'],
        answer: 1,
        explanation:
            '--global enregistre l’identité par défaut de ton utilisateur.',
      ),
      Exercise(
        id: 'e57',
        question: 'Pourquoi configurer user.name et user.email ?',
        options: [
          'Pour signer chaque commit avec ton identité',
          'Pour accélérer Git',
          'Pour se connecter à Internet',
        ],
        answer: 0,
        explanation:
            'Ces informations sont inscrites dans chaque commit que tu crées.',
      ),
    ],
  ),
  Lesson(
    id: 'init-status',
    level: 1,
    title: 'Créer un dépôt',
    subtitle: 'Initialiser puis observer sans modifier',
    minutes: 9,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'git init',
        caption: 'Initialise un dépôt dans le dossier courant.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git status',
        caption: 'Affiche la branche et l’état des fichiers.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'git status est sans danger : utilise-le dès que tu doutes.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e05',
        question: 'Quelle commande initialise un dépôt ?',
        options: ['git start', 'git init', 'git new'],
        answer: 1,
        explanation:
            'git init crée les métadonnées du dépôt dans le dossier courant.',
      ),
      Exercise(
        id: 'e06',
        question: 'git status modifie-t-il les fichiers ?',
        options: ['Oui', 'Non'],
        answer: 1,
        explanation: 'C’est une commande d’inspection : elle ne modifie rien.',
      ),
    ],
  ),
  Lesson(
    id: 'staging',
    level: 2,
    title: 'La zone de préparation',
    subtitle: 'Choisir ce qui entrera dans le commit',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.analogy,
        'Le staging est un panier : tu y places exactement les changements destinés à la prochaine photo.',
      ),
      LessonBlock(LessonBlockType.command, 'git add README.md'),
      LessonBlock(
        LessonBlockType.command,
        'git add .',
        caption: 'Prépare tous les changements du dossier.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e07',
        question: 'Que fait git add ?',
        options: [
          'Supprime un fichier',
          'Prépare un changement',
          'Crée une branche',
        ],
        answer: 1,
        explanation: 'git add place le contenu courant dans l’index.',
      ),
      Exercise(
        id: 'e08',
        question: 'Pour préparer tous les fichiers ?',
        options: ['git add .', 'git all', 'git commit .'],
        answer: 0,
        explanation: 'Le point représente le dossier courant.',
      ),
    ],
  ),
  Lesson(
    id: 'commit',
    level: 2,
    title: 'Créer un commit utile',
    subtitle: 'Une étape claire et retrouvable',
    minutes: 11,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'git commit -m "Ajoute la page contact"',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Le message explique l’intention. Préfère “Corrige la validation du formulaire” à “modifs”.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e09',
        question: 'Que contient un commit ?',
        options: [
          'Tous les fichiers du disque',
          'Les changements préparés',
          'Uniquement son message',
        ],
        answer: 1,
        explanation: 'Le commit enregistre le snapshot de l’index.',
      ),
      Exercise(
        id: 'e10',
        question: 'Quel message est le plus utile ?',
        options: ['Divers', 'Fix', 'Corrige le calcul du total'],
        answer: 2,
        explanation: 'Un message précis décrit immédiatement l’intention.',
      ),
    ],
  ),
  Lesson(
    id: 'history',
    level: 2,
    title: 'Lire l’historique',
    subtitle: 'Retrouver les décisions du projet',
    minutes: 7,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git log --oneline'),
      LessonBlock(
        LessonBlockType.text,
        'Chaque ligne présente un identifiant court et le message du commit.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e11',
        question: 'Quelle option compacte l’historique ?',
        options: ['--small', '--oneline', '--shorter'],
        answer: 1,
        explanation: '--oneline affiche un commit par ligne.',
      ),
      Exercise(
        id: 'e58',
        question:
            'Quelle commande affiche l’historique de la branche courante ?',
        options: ['git status', 'git log', 'git diff'],
        answer: 1,
        explanation:
            'git log liste les commits atteignables depuis HEAD, du plus récent au plus ancien.',
      ),
    ],
  ),
  Lesson(
    id: 'branches',
    level: 3,
    title: 'Créer une branche',
    subtitle: 'Isoler une idée sans casser main',
    minutes: 12,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git branch feature/profile'),
      LessonBlock(LessonBlockType.command, 'git switch feature/profile'),
      LessonBlock(
        LessonBlockType.command,
        'git switch -c feature/login',
        caption: 'Crée et active la branche en une commande.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e12',
        question: 'Une branche permet surtout de…',
        options: [
          'Isoler une ligne de travail',
          'Effacer l’historique',
          'Installer Git',
        ],
        answer: 0,
        explanation:
            'Une branche est un pointeur mobile vers une ligne de commits.',
      ),
      Exercise(
        id: 'e13',
        question: 'Créer et activer une branche ?',
        options: [
          'git switch -c demo',
          'git branch --use demo',
          'git checkout only',
        ],
        answer: 0,
        explanation: 'switch -c crée puis active la nouvelle branche.',
      ),
    ],
  ),
  Lesson(
    id: 'merge',
    level: 3,
    title: 'Fusionner sans mystère',
    subtitle: 'Réunir deux chemins de travail',
    minutes: 12,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git switch main'),
      LessonBlock(LessonBlockType.command, 'git merge feature/profile'),
      LessonBlock(
        LessonBlockType.warning,
        'Place-toi sur la branche qui doit recevoir les changements avant de fusionner.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e14',
        question: 'Pour intégrer feature dans main, où se placer ?',
        options: ['Sur main', 'Sur feature', 'N’importe où'],
        answer: 0,
        explanation: 'La branche courante reçoit les changements.',
      ),
      Exercise(
        id: 'e59',
        question:
            'Quelle commande intègre feature/profile dans la branche courante ?',
        options: [
          'git merge feature/profile',
          'git switch feature/profile',
          'git branch feature/profile',
        ],
        answer: 0,
        explanation:
            'merge intègre l’historique de la branche indiquée dans la branche courante.',
      ),
    ],
  ),
  Lesson(
    id: 'remotes',
    level: 4,
    title: 'Le dépôt distant',
    subtitle: 'Partager et synchroniser',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'git remote add origin https://example.com/projet.git',
      ),
      LessonBlock(LessonBlockType.command, 'git push -u origin main'),
      LessonBlock(
        LessonBlockType.text,
        'origin est un nom conventionnel donné au dépôt distant principal.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e15',
        question: 'Que désigne souvent origin ?',
        options: [
          'Le premier commit',
          'Le dépôt distant principal',
          'La branche locale',
        ],
        answer: 1,
        explanation: 'origin est un alias local pour une URL distante.',
      ),
      Exercise(
        id: 'e60',
        question: 'Quelle commande liste les dépôts distants configurés ?',
        options: ['git remote -v', 'git log --remote', 'git status -r'],
        answer: 0,
        explanation:
            'git remote -v affiche chaque distant avec ses adresses de récupération et d’envoi.',
      ),
    ],
  ),
  Lesson(
    id: 'github-issues',
    level: 5,
    title: 'Organiser avec les issues',
    subtitle: 'Transformer un besoin en travail clair',
    minutes: 9,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Une issue décrit un besoin, un bug ou une amélioration. Un bon titre résume le résultat attendu et la description fournit le contexte utile.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Ajoute un label et une priorité pour permettre à l’équipe de trier le travail sans relire chaque description.',
      ),
      LessonBlock(
        LessonBlockType.analogy,
        'Une issue est une fiche de quête : elle explique le problème, les contraintes et la condition de réussite.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e16',
        question: 'Quel titre d’issue est le plus utile ?',
        options: ['Ça ne marche pas', 'Bug', 'Corrige le contraste du bouton'],
        answer: 2,
        explanation:
            'Un titre précis permet de comprendre immédiatement le résultat attendu.',
      ),
      Exercise(
        id: 'e17',
        question: 'À quoi sert principalement un label ?',
        options: [
          'Classer le travail',
          'Fusionner une branche',
          'Créer un tag',
        ],
        answer: 0,
        explanation:
            'Les labels regroupent les issues par nature, domaine ou priorité.',
      ),
    ],
  ),
  Lesson(
    id: 'pull-requests',
    level: 5,
    title: 'Proposer une pull request',
    subtitle: 'Présenter un changement avant sa fusion',
    minutes: 11,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Une pull request compare une branche source à une branche cible. Elle ouvre un espace de discussion autour des commits et fichiers proposés.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Une petite pull request avec une description claire est plus rapide à comprendre, tester et relire.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Vérifie toujours le sens source → cible. Pour intégrer une fonctionnalité, feature est la source et main la cible.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e18',
        question: 'Que compare une pull request ?',
        options: [
          'Deux branches',
          'Deux mots de passe',
          'Deux dépôts supprimés',
        ],
        answer: 0,
        explanation:
            'La proposition montre la différence entre la source et la cible.',
      ),
      Exercise(
        id: 'e19',
        question: 'Pour intégrer feature dans main, quelle est la cible ?',
        options: ['feature', 'main', 'origin'],
        answer: 1,
        explanation: 'main est la branche qui recevra les changements.',
      ),
    ],
  ),
  Lesson(
    id: 'reviews-ci',
    level: 5,
    title: 'Revue, CI et protection',
    subtitle: 'Sécuriser la branche principale',
    minutes: 12,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'La revue humaine vérifie l’intention et la lisibilité. La CI exécute automatiquement des contrôles reproductibles comme l’analyse, les tests et la compilation.',
      ),
      LessonBlock(
        LessonBlockType.analogy,
        'La protection de branche est une porte à deux serrures : l’approbation humaine et les contrôles automatisés.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Un nouveau commit invalide les anciens résultats de CI : les contrôles doivent porter sur la version réellement fusionnée.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e20',
        question: 'La CI remplace-t-elle entièrement la revue humaine ?',
        options: ['Oui', 'Non'],
        answer: 1,
        explanation:
            'Les contrôles automatiques et la compréhension humaine sont complémentaires.',
      ),
      Exercise(
        id: 'e21',
        question: 'Pourquoi relancer la CI après un nouveau commit ?',
        options: [
          'Pour tester la dernière version',
          'Pour renommer la branche',
          'Pour fermer l’issue',
        ],
        answer: 0,
        explanation:
            'Un résultat ancien ne garantit rien sur le nouveau contenu.',
      ),
    ],
  ),
  Lesson(
    id: 'repair-history',
    level: 6,
    title: 'Réparer sans paniquer',
    subtitle: 'Choisir amend, reset ou revert',
    minutes: 13,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'git commit --amend -m "Message corrigé"',
        caption: 'Remplace le dernier commit local.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git reset --soft HEAD~1',
        caption: 'Déplace HEAD et conserve les changements préparés.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git revert HEAD',
        caption: 'Ajoute une annulation sans effacer l’historique partagé.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Sur une branche déjà partagée, préfère revert : les autres membres conservent un historique cohérent.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e22',
        question: 'Quelle commande convient à un commit déjà partagé ?',
        options: ['git revert HEAD', 'git init', 'git remote add'],
        answer: 0,
        explanation: 'revert crée une annulation traçable et collaborative.',
      ),
      Exercise(
        id: 'e23',
        question: 'Que conserve reset --soft ?',
        options: ['Les changements préparés', 'Rien', 'Uniquement les tags'],
        answer: 0,
        explanation:
            'Le commit est retiré de la branche, mais son contenu reste dans l’index.',
      ),
    ],
  ),
  Lesson(
    id: 'cherry-pick',
    level: 6,
    title: 'Rejouer un changement ciblé',
    subtitle: 'Importer un commit sans toute la branche',
    minutes: 10,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git log --oneline'),
      LessonBlock(LessonBlockType.command, 'git cherry-pick a1b2c3d'),
      LessonBlock(
        LessonBlockType.text,
        'cherry-pick applique le changement introduit par un commit et crée un nouveau commit sur la branche courante.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Utilise-le pour un correctif ciblé. Pour intégrer toute une ligne de travail, une fusion est généralement plus lisible.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e24',
        question: 'Que faut-il fournir à git cherry-pick ?',
        options: ['Un identifiant de commit', 'Une URL', 'Un mot de passe'],
        answer: 0,
        explanation: 'Git doit savoir précisément quel commit rejouer.',
      ),
      Exercise(
        id: 'e25',
        question: 'Le commit rejoué garde-t-il forcément le même identifiant ?',
        options: ['Oui', 'Non'],
        answer: 1,
        explanation:
            'Son parent change, donc son nouvel identifiant est généralement différent.',
      ),
    ],
  ),
  Lesson(
    id: 'rebase',
    level: 6,
    title: 'Rebaser avec méthode',
    subtitle: 'Rejouer une branche sur une base récente',
    minutes: 14,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git rebase main'),
      LessonBlock(
        LessonBlockType.text,
        'Le rebase déplace la base logique de ta branche puis recrée ses commits un à un au-dessus de main.',
      ),
      LessonBlock(LessonBlockType.command, 'git rebase --continue'),
      LessonBlock(LessonBlockType.command, 'git rebase --abort'),
      LessonBlock(
        LessonBlockType.warning,
        'Évite de rebaser une branche publique utilisée par d’autres personnes : les identifiants de commits sont réécrits.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e26',
        question: 'Après avoir résolu et préparé un conflit de rebase ?',
        options: [
          'git rebase --continue',
          'git init',
          'git branch --delete-all',
        ],
        answer: 0,
        explanation:
            'La continuation reprend le rejeu des commits encore en attente.',
      ),
      Exercise(
        id: 'e27',
        question: 'Que fait git rebase --abort ?',
        options: [
          'Restaure l’état avant le rebase',
          'Supprime le dépôt',
          'Fusionne automatiquement',
        ],
        answer: 0,
        explanation:
            'L’annulation remet la branche et les fichiers dans leur état initial.',
      ),
    ],
  ),
  Lesson(
    id: 'team-workflows',
    level: 7,
    title: 'Choisir un workflow d’équipe',
    subtitle: 'Organiser les branches sans ralentir le projet',
    minutes: 12,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'GitHub Flow utilise une branche courte par changement, une pull request, des contrôles, puis une fusion rapide vers main.',
      ),
      LessonBlock(
        LessonBlockType.analogy,
        'Le workflow est le code de la route de l’équipe : il ne produit pas le travail, mais évite les collisions.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Choisis des noms explicites comme feature/profil ou fix/contraste et supprime les branches intégrées devenues inutiles.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Les branches très longues accumulent les divergences et rendent les revues comme les fusions plus difficiles.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e28',
        question: 'Quel enchaînement correspond à GitHub Flow ?',
        options: [
          'Branche → pull request → contrôles → fusion',
          'Tag → suppression du dépôt',
          'Commit directement sur main uniquement',
        ],
        answer: 0,
        explanation:
            'Une branche courte isole le changement jusqu’à sa validation.',
      ),
      Exercise(
        id: 'e29',
        question: 'Pourquoi préférer des branches courtes ?',
        options: [
          'Elles limitent les divergences',
          'Elles changent le mot de passe',
          'Elles remplacent les tests',
        ],
        answer: 0,
        explanation:
            'Des intégrations fréquentes réduisent la taille des conflits et des revues.',
      ),
    ],
  ),
  Lesson(
    id: 'conventional-commits',
    level: 7,
    title: 'Écrire des commits conventionnels',
    subtitle: 'Rendre l’historique lisible et automatisable',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'git commit -m "feat: ajoute le profil"',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git commit -m "fix: corrige le contraste"',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Un préfixe comme feat, fix, docs, test ou refactor indique la nature du changement. Le reste du message décrit son intention.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Le format partagé facilite la génération de notes de version et la recherche dans un historique volumineux.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e30',
        question: 'Quel message annonce une correction ?',
        options: ['fix: corrige le menu', 'divers', 'feat: ajoute le menu'],
        answer: 0,
        explanation: 'Le type fix signale explicitement une correction.',
      ),
      Exercise(
        id: 'e31',
        question: 'Quel est l’intérêt principal du préfixe ?',
        options: [
          'Identifier la nature du changement',
          'Chiffrer les fichiers',
          'Créer une branche distante',
        ],
        answer: 0,
        explanation:
            'Une convention stable rend l’historique plus facile à lire et exploiter.',
      ),
    ],
  ),
  Lesson(
    id: 'semantic-releases',
    level: 7,
    title: 'Livrer une version',
    subtitle: 'Tags, SemVer et notes de publication',
    minutes: 12,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Le versionnage sémantique suit MAJEUR.MINEUR.CORRECTIF : rupture incompatible, nouvelle fonctionnalité compatible, puis correction compatible.',
      ),
      LessonBlock(LessonBlockType.command, 'git tag v2.1.3'),
      LessonBlock(
        LessonBlockType.text,
        'Une release associe généralement un tag immuable à des notes expliquant les changements utiles pour les utilisateurs.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Crée le tag sur le commit réellement validé par la CI, pas sur une copie de travail encore modifiée.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e32',
        question: 'Quelle partie augmenter pour une correction compatible ?',
        options: ['MAJEUR', 'MINEUR', 'CORRECTIF'],
        answer: 2,
        explanation:
            'Dans 2.1.3, le dernier nombre représente le niveau correctif.',
      ),
      Exercise(
        id: 'e33',
        question: 'À quoi sert un tag de version ?',
        options: [
          'Nommer durablement un commit livré',
          'Modifier tous les fichiers',
          'Remplacer la CI',
        ],
        answer: 0,
        explanation:
            'Le tag fournit un repère stable vers l’état exact publié.',
      ),
    ],
  ),
  Lesson(
    id: 'git-security',
    level: 7,
    title: 'Protéger secrets et historique',
    subtitle: 'Prévenir plutôt que nettoyer',
    minutes: 11,
    blocks: [
      LessonBlock(
        LessonBlockType.warning,
        'Un secret commité reste récupérable dans l’historique même si le fichier est ensuite supprimé. Il faut immédiatement révoquer la clé exposée.',
      ),
      LessonBlock(
        LessonBlockType.text,
        '.gitignore empêche d’ajouter par erreur les fichiers générés, configurations locales et fichiers de secrets qui ne doivent pas être versionnés.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Utilise des variables d’environnement et le gestionnaire de secrets de la plateforme CI. Active aussi la revue et la protection de branche.',
      ),
      LessonBlock(
        LessonBlockType.analogy,
        'Supprimer un secret du dernier commit sans le révoquer revient à retirer une clé publiée d’une affiche sans changer la serrure.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e34',
        question: 'Première action après avoir publié une clé secrète ?',
        options: ['La révoquer', 'Renommer la branche', 'Créer un tag'],
        answer: 0,
        explanation:
            'La clé doit devenir inutilisable, car des copies peuvent déjà exister.',
      ),
      Exercise(
        id: 'e35',
        question: 'Où stocker un secret utilisé par la CI ?',
        options: [
          'Dans un gestionnaire de secrets',
          'Dans README.md',
          'Dans le message du commit',
        ],
        answer: 0,
        explanation:
            'La plateforme injecte le secret sans l’inscrire dans le dépôt.',
      ),
    ],
  ),
  Lesson(
    id: 'ignore-files',
    level: 1,
    title: 'Ignorer les bons fichiers',
    subtitle: 'Garder le dépôt propre dès le départ',
    minutes: 7,
    blocks: [
      LessonBlock(LessonBlockType.command, 'touch .gitignore'),
      LessonBlock(
        LessonBlockType.text,
        '.gitignore décrit les fichiers générés ou locaux que Git ne doit pas proposer au suivi, comme build/, .env ou les caches.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e36',
        question: 'Quel fichier contient les règles d’exclusion ?',
        options: ['.gitignore', '.gitkeep', 'README.md'],
        answer: 0,
        explanation: '.gitignore centralise les motifs ignorés par Git.',
      ),
      Exercise(
        id: 'e61',
        question: 'Lequel n’a généralement pas sa place dans le dépôt ?',
        options: [
          'README.md',
          'Un fichier .env contenant des mots de passe',
          'Le code source',
        ],
        answer: 1,
        explanation:
            'Les secrets et fichiers locaux doivent être exclus avec .gitignore.',
      ),
    ],
  ),
  Lesson(
    id: 'inspect-worktree',
    level: 1,
    title: 'Inspecter avant d’agir',
    subtitle: 'Développer de bons réflexes sans risque',
    minutes: 6,
    blocks: [
      LessonBlock(LessonBlockType.command, 'pwd'),
      LessonBlock(LessonBlockType.command, 'ls'),
      LessonBlock(
        LessonBlockType.tip,
        'Commence par identifier le dossier et son contenu, puis utilise git status avant toute commande qui modifie l’état.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e37',
        question: 'Quelle commande Git inspecte la copie de travail ?',
        options: ['git status', 'git reset --hard', 'git commit'],
        answer: 0,
        explanation: 'git status observe sans modifier les fichiers.',
      ),
      Exercise(
        id: 'e62',
        question: 'Quelle commande affiche le dossier courant ?',
        options: ['ls', 'pwd', 'cat'],
        answer: 1,
        explanation:
            'pwd affiche le chemin du dossier dans lequel tu te trouves.',
      ),
    ],
  ),
  Lesson(
    id: 'read-diff',
    level: 2,
    title: 'Lire les différences',
    subtitle: 'Relire exactement ce qui a changé',
    minutes: 8,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git diff'),
      LessonBlock(
        LessonBlockType.text,
        'Les lignes précédées de + sont ajoutées et celles précédées de - sont retirées. Relire le diff évite les changements accidentels.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e38',
        question: 'Dans un diff, que signifie une ligne préfixée par + ?',
        options: ['Ajoutée', 'Supprimée', 'Ignorée'],
        answer: 0,
        explanation: 'Le signe + représente le contenu ajouté.',
      ),
      Exercise(
        id: 'e63',
        question: 'Que montre git diff sans option ?',
        options: [
          'Les changements non préparés',
          'Les commits distants',
          'La liste des branches',
        ],
        answer: 0,
        explanation:
            'Sans option, git diff compare la copie de travail à la zone de préparation.',
      ),
    ],
  ),
  Lesson(
    id: 'restore-file',
    level: 2,
    title: 'Restaurer un fichier',
    subtitle: 'Annuler une modification locale ciblée',
    minutes: 8,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git restore README.md'),
      LessonBlock(
        LessonBlockType.warning,
        'La restauration remplace le contenu non enregistré du fichier. Vérifie git diff avant de perdre un travail utile.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e39',
        question: 'git restore README.md agit sur…',
        options: [
          'Le fichier ciblé',
          'Toutes les branches',
          'Le dépôt distant',
        ],
        answer: 0,
        explanation: 'La commande restaure uniquement le chemin indiqué.',
      ),
      Exercise(
        id: 'e64',
        question:
            'Quelle commande retire un fichier de la zone de préparation sans perdre son contenu ?',
        options: [
          'git restore --staged fichier',
          'git reset --hard',
          'git rm fichier',
        ],
        answer: 0,
        explanation:
            '--staged agit seulement sur l’index : tes modifications restent dans le fichier.',
      ),
    ],
  ),
  Lesson(
    id: 'atomic-commits',
    level: 2,
    title: 'Construire des commits atomiques',
    subtitle: 'Une intention cohérente par étape',
    minutes: 9,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Un commit atomique regroupe un seul changement logique. Il peut être relu, annulé ou déplacé sans emporter du travail sans rapport.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Utilise git add fichier par fichier et relis git status avant de créer le commit.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e40',
        question: 'Pourquoi séparer deux changements sans rapport ?',
        options: [
          'Pour faciliter revue et annulation',
          'Pour supprimer main',
          'Pour désactiver Git',
        ],
        answer: 0,
        explanation: 'Chaque commit reste compréhensible et réutilisable.',
      ),
      Exercise(
        id: 'e65',
        question:
            'Tu as corrigé un bug et renommé une variable ailleurs. Que faire ?',
        options: [
          'Un seul commit « divers »',
          'Deux commits séparés',
          'Ne rien committer',
        ],
        answer: 1,
        explanation:
            'Deux changements sans rapport méritent deux commits relisibles séparément.',
      ),
    ],
  ),
  Lesson(
    id: 'branch-names',
    level: 3,
    title: 'Nommer ses branches',
    subtitle: 'Faire comprendre le travail au premier regard',
    minutes: 6,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git switch -c fix/navigation'),
      LessonBlock(
        LessonBlockType.tip,
        'Un préfixe court comme feature/, fix/ ou docs/ suivi d’un objectif précis facilite la navigation dans le dépôt.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e41',
        question: 'Quel nom est le plus explicite ?',
        options: ['branche2', 'test', 'fix/navigation-mobile'],
        answer: 2,
        explanation: 'Le nom décrit la nature et l’objectif du travail.',
      ),
      Exercise(
        id: 'e66',
        question: 'Quel préfixe convient à une correction de bug ?',
        options: ['feature/', 'fix/', 'docs/'],
        answer: 1,
        explanation: 'fix/ signale immédiatement une correction.',
      ),
    ],
  ),
  Lesson(
    id: 'fast-forward',
    level: 3,
    title: 'Comprendre le fast-forward',
    subtitle: 'Fusionner quand les histoires ne divergent pas',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Si main n’a pas avancé depuis la création de feature, Git peut simplement déplacer le pointeur de main vers le dernier commit de feature.',
      ),
      LessonBlock(LessonBlockType.command, 'git merge feature/profil'),
    ],
    exercises: [
      Exercise(
        id: 'e42',
        question: 'Un fast-forward crée-t-il forcément un commit de fusion ?',
        options: ['Oui', 'Non'],
        answer: 1,
        explanation: 'Git peut seulement avancer le pointeur de branche.',
      ),
      Exercise(
        id: 'e67',
        question: 'Quand un fast-forward est-il possible ?',
        options: [
          'Quand la branche cible n’a pas avancé depuis la création de l’autre',
          'Quand les deux branches ont divergé',
          'Jamais avec main',
        ],
        answer: 0,
        explanation: 'Sans divergence, Git n’a qu’à avancer le pointeur.',
      ),
    ],
  ),
  Lesson(
    id: 'conflict-method',
    level: 3,
    title: 'Résoudre un conflit méthodiquement',
    subtitle: 'Comprendre avant de choisir une version',
    minutes: 11,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Lis les deux versions, compose le résultat final, prépare le fichier avec git add puis termine la fusion par un commit.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Ne supprime pas aveuglément les marqueurs : le bon résultat peut combiner les deux contributions.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e43',
        question: 'Après avoir résolu le contenu d’un conflit ?',
        options: ['git add fichier', 'git init', 'git remote -v'],
        answer: 0,
        explanation: 'git add indique à Git que le fichier est résolu.',
      ),
      Exercise(
        id: 'e68',
        question: 'Que signifient les marqueurs <<<<<<< et >>>>>>> ?',
        options: [
          'Une erreur de syntaxe du langage',
          'Les deux versions en conflit à départager',
          'Des commentaires à conserver',
        ],
        answer: 1,
        explanation:
            'Ils délimitent la version courante et la version entrante ; ils doivent disparaître du résultat final.',
      ),
    ],
  ),
  Lesson(
    id: 'fetch-first',
    level: 4,
    title: 'Observer avec fetch',
    subtitle: 'Récupérer sans intégrer immédiatement',
    minutes: 8,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git fetch origin'),
      LessonBlock(
        LessonBlockType.text,
        'fetch met à jour les références distantes sans modifier ta branche ni ta copie de travail.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e44',
        question: 'fetch modifie-t-il directement les fichiers courants ?',
        options: ['Oui', 'Non'],
        answer: 1,
        explanation:
            'Il récupère les informations distantes sans les intégrer.',
      ),
      Exercise(
        id: 'e69',
        question:
            'Après git fetch, comment intégrer les changements récupérés ?',
        options: ['git merge origin/main', 'git init', 'git stash'],
        answer: 0,
        explanation:
            'fetch met à jour origin/main ; merge ou rebase l’intègre ensuite à ta branche.',
      ),
    ],
  ),
  Lesson(
    id: 'pull-safely',
    level: 4,
    title: 'Intégrer avec pull',
    subtitle: 'Mettre sa branche à jour consciemment',
    minutes: 9,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git pull origin main'),
      LessonBlock(
        LessonBlockType.tip,
        'Travaille avec une copie propre et inspecte d’abord les changements distants lorsque l’intégration peut être complexe.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e45',
        question: 'pull combine généralement quelles actions ?',
        options: [
          'Récupération et intégration',
          'Tag et suppression',
          'Init et commit',
        ],
        answer: 0,
        explanation: 'pull récupère puis intègre les changements distants.',
      ),
      Exercise(
        id: 'e70',
        question: 'Pourquoi avoir une copie de travail propre avant pull ?',
        options: [
          'Pour ne pas mélanger tes changements locaux avec l’intégration',
          'Parce que pull efface tout',
          'Ce n’est pas utile',
        ],
        answer: 0,
        explanation:
            'Une copie propre rend l’intégration et les éventuels conflits plus lisibles.',
      ),
    ],
  ),
  Lesson(
    id: 'push-upstream',
    level: 4,
    title: 'Publier une branche',
    subtitle: 'Partager les commits au bon endroit',
    minutes: 8,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git push -u origin feature/profil'),
      LessonBlock(
        LessonBlockType.text,
        'L’option -u associe la branche locale à sa branche distante afin de simplifier les prochains push et pull.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e46',
        question: 'Que mémorise principalement l’option -u ?',
        options: [
          'La branche distante suivie',
          'Le mot de passe',
          'Le dernier conflit',
        ],
        answer: 0,
        explanation: 'Elle configure la branche amont utilisée par défaut.',
      ),
      Exercise(
        id: 'e71',
        question: 'Une fois -u utilisé, que suffit-il de taper ensuite ?',
        options: ['git push', 'git push --all --force', 'git remote add'],
        answer: 0,
        explanation:
            'La branche distante est mémorisée : git push et git pull suffisent.',
      ),
    ],
  ),
  Lesson(
    id: 'issue-lifecycle',
    level: 5,
    title: 'Faire vivre une issue',
    subtitle: 'Du signalement à la résolution',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Une issue évolue grâce aux précisions, décisions et liens vers le travail réalisé. Elle est fermée lorsque le résultat attendu est atteint.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Lie la pull request à son issue pour conserver la trace entre besoin, discussion et code livré.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e47',
        question: 'Pourquoi lier une pull request à une issue ?',
        options: [
          'Conserver la traçabilité',
          'Supprimer les commits',
          'Éviter la CI',
        ],
        answer: 0,
        explanation: 'Le besoin et sa solution restent reliés.',
      ),
      Exercise(
        id: 'e72',
        question: 'Quand fermer une issue ?',
        options: [
          'Dès sa création',
          'Quand le résultat attendu est atteint',
          'Jamais',
        ],
        answer: 1,
        explanation:
            'L’issue se ferme lorsque le besoin décrit est satisfait, idéalement via la pull request liée.',
      ),
    ],
  ),
  Lesson(
    id: 'pr-description',
    level: 5,
    title: 'Rédiger une bonne proposition',
    subtitle: 'Aider la personne qui relit',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Une bonne description explique le problème, la solution choisie, la manière de tester et les éventuelles limites.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Ajoute des captures ou exemples quand le comportement visuel ou fonctionnel serait difficile à imaginer.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e48',
        question: 'Que doit expliquer une description de pull request ?',
        options: [
          'Le pourquoi et le test',
          'Uniquement le nom',
          'Le mot de passe CI',
        ],
        answer: 0,
        explanation:
            'Le contexte et la vérification accélèrent une revue fiable.',
      ),
      Exercise(
        id: 'e73',
        question: 'Qu’est-ce qui aide le plus la personne qui relit ?',
        options: [
          'Le titre « modifs »',
          'Les étapes pour tester le changement',
          'Aucune description',
        ],
        answer: 1,
        explanation:
            'Savoir comment tester permet de vérifier rapidement le comportement.',
      ),
    ],
  ),
  Lesson(
    id: 'review-feedback',
    level: 5,
    title: 'Donner un retour utile',
    subtitle: 'Améliorer le code sans bloquer la collaboration',
    minutes: 9,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Un commentaire de revue décrit un risque observable, explique son impact et propose si possible une piste concrète.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Distingue les changements obligatoires des simples suggestions et commente le code, jamais la personne.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e49',
        question: 'Quel retour est le plus constructif ?',
        options: [
          'Ce contrôle accepte une valeur vide ; ajoutons un test',
          'Mauvais code',
          'Refais tout',
        ],
        answer: 0,
        explanation: 'Il localise le risque et propose une action vérifiable.',
      ),
      Exercise(
        id: 'e74',
        question: 'Comment signaler une simple préférence de style ?',
        options: [
          'Comme un blocage obligatoire',
          'Comme une suggestion facultative',
          'Ne jamais la mentionner',
        ],
        answer: 1,
        explanation:
            'Distinguer suggestion et obligation évite de bloquer inutilement une pull request.',
      ),
    ],
  ),
  Lesson(
    id: 'use-reflog',
    level: 6,
    title: 'Retrouver une référence avec reflog',
    subtitle: 'Voir les déplacements récents de HEAD',
    minutes: 9,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git reflog'),
      LessonBlock(
        LessonBlockType.text,
        'Le reflog enregistre localement les déplacements de références causés par commit, amend, reset, checkout ou rebase.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e50',
        question: 'Le reflog aide surtout à retrouver…',
        options: [
          'Un ancien emplacement de HEAD',
          'Une issue GitHub',
          'Un mot de passe',
        ],
        answer: 0,
        explanation: 'Il conserve le journal local des mouvements récents.',
      ),
      Exercise(
        id: 'e75',
        question: 'Le reflog est-il partagé avec le dépôt distant ?',
        options: ['Oui, à chaque push', 'Non, il reste local'],
        answer: 1,
        explanation: 'Le reflog est un journal propre à ton dépôt local.',
      ),
    ],
  ),
  Lesson(
    id: 'stash-work',
    level: 6,
    title: 'Mettre un travail de côté',
    subtitle: 'Changer de contexte sans commit provisoire',
    minutes: 9,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git stash'),
      LessonBlock(LessonBlockType.command, 'git stash pop'),
      LessonBlock(
        LessonBlockType.tip,
        'Le stash est temporaire. Pour un travail durable ou partagé, préfère une branche et un commit clair.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e51',
        question: 'Quelle commande restaure le dernier stash ?',
        options: ['git stash pop', 'git restore --all', 'git push'],
        answer: 0,
        explanation: 'stash pop applique puis retire la sauvegarde temporaire.',
      ),
      Exercise(
        id: 'e76',
        question: 'Quelle commande liste les stash enregistrés ?',
        options: ['git stash list', 'git log --stash', 'git status --all'],
        answer: 0,
        explanation:
            'git stash list affiche chaque entrée, de la plus récente à la plus ancienne.',
      ),
    ],
  ),
  Lesson(
    id: 'reset-modes',
    level: 6,
    title: 'Comparer les modes de reset',
    subtitle: 'Déplacer HEAD avec le bon niveau de conservation',
    minutes: 11,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        '--soft conserve l’index, --mixed retire les changements de l’index et --hard restaure aussi les fichiers.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'reset --hard détruit les modifications non enregistrées. Vérifie status et crée une sauvegarde si tu hésites.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e52',
        question: 'Quel mode est le plus destructeur ?',
        options: ['--soft', '--mixed', '--hard'],
        answer: 2,
        explanation:
            '--hard remplace également le contenu de la copie de travail.',
      ),
      Exercise(
        id: 'e77',
        question: 'Quel mode garde les changements préparés dans l’index ?',
        options: ['--soft', '--mixed', '--hard'],
        answer: 0,
        explanation:
            '--soft déplace seulement la branche : l’index et les fichiers sont conservés.',
      ),
    ],
  ),
  Lesson(
    id: 'diagnose-ci',
    level: 7,
    title: 'Diagnostiquer une CI rouge',
    subtitle: 'Lire le premier échec utile',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Identifie le job en échec, lis son premier message pertinent, reproduis localement si possible puis corrige la cause plutôt que le symptôme.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Une compilation peut échouer parce qu’un test ou une analyse précédente a déjà révélé le vrai problème.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e53',
        question: 'Première étape face à une CI rouge ?',
        options: [
          'Identifier le job en échec',
          'Fusionner quand même',
          'Supprimer les tests',
        ],
        answer: 0,
        explanation: 'Le job et son journal localisent la source du problème.',
      ),
      Exercise(
        id: 'e78',
        question:
            'Une CI passe en local mais échoue en ligne. Piste probable ?',
        options: [
          'Une différence d’environnement ou de version',
          'Git est cassé',
          'Il faut supprimer la CI',
        ],
        answer: 0,
        explanation:
            'Versions d’outils, variables ou fichiers non versionnés expliquent souvent l’écart.',
      ),
    ],
  ),
  Lesson(
    id: 'release-notes',
    level: 7,
    title: 'Écrire des notes de version',
    subtitle: 'Expliquer la valeur livrée',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Les notes de version regroupent nouveautés, corrections, changements incompatibles et éventuelles étapes de migration.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Écris pour les utilisateurs du projet : décris les effets visibles plutôt qu’une simple liste d’identifiants de commits.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e54',
        question: 'Que faut-il signaler clairement dans une release ?',
        options: [
          'Les ruptures incompatibles',
          'Les secrets CI',
          'Les fichiers ignorés locaux',
        ],
        answer: 0,
        explanation:
            'Les utilisateurs doivent pouvoir anticiper une migration.',
      ),
      Exercise(
        id: 'e79',
        question: 'À qui s’adressent d’abord les notes de version ?',
        options: [
          'Aux utilisateurs du projet',
          'Uniquement au compilateur',
          'Aux robots de recherche',
        ],
        answer: 0,
        explanation:
            'Elles décrivent les effets visibles pour celles et ceux qui utilisent le projet.',
      ),
    ],
  ),
  Lesson(
    id: 'repository-hygiene',
    level: 7,
    title: 'Entretenir un dépôt durable',
    subtitle: 'Réduire le bruit et la dette collective',
    minutes: 9,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Un dépôt sain possède un README actuel, des branches courtes, des releases identifiables et des automatisations reproductibles.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Archive les décisions importantes dans le dépôt et supprime régulièrement les branches déjà fusionnées.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e55',
        question: 'Quel élément favorise un dépôt durable ?',
        options: [
          'Un README à jour',
          'Des branches éternelles',
          'Des secrets committés',
        ],
        answer: 0,
        explanation:
            'La documentation maintenue réduit la dépendance à la mémoire orale.',
      ),
      Exercise(
        id: 'e80',
        question: 'Que faire d’une branche déjà fusionnée ?',
        options: [
          'La garder indéfiniment',
          'La supprimer',
          'La renommer en main',
        ],
        answer: 1,
        explanation:
            'Supprimer les branches fusionnées garde la liste lisible.',
      ),
    ],
  ),
  Lesson(
    id: 'remove-rename',
    level: 2,
    title: 'Supprimer et renommer un fichier suivi',
    subtitle: 'Garder l’historique cohérent quand l’arborescence change',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Supprimer un fichier suivi à la main laisse Git constater une suppression qu’il faut encore préparer. git rm supprime le fichier et prépare cette suppression en une seule étape.',
      ),
      LessonBlock(LessonBlockType.command, 'git rm brouillon.txt'),
      LessonBlock(LessonBlockType.command, 'git mv notes.txt NOTES.md'),
      LessonBlock(
        LessonBlockType.text,
        'git mv renomme le fichier et prépare à la fois l’ancien et le nouveau nom. Le commit suivant enregistre le renommage.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'git rm --cached fichier arrête le suivi tout en gardant le fichier sur le disque : pratique pour un fichier ajouté par erreur, à compléter ensuite dans .gitignore.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e81',
        question:
            'Quelle commande arrête le suivi d’un fichier sans le supprimer du disque ?',
        options: [
          'git rm fichier',
          'git rm --cached fichier',
          'git restore fichier',
        ],
        answer: 1,
        explanation: '--cached retire le fichier de l’index seulement.',
      ),
      Exercise(
        id: 'e82',
        question: 'Que prépare git mv ancien nouveau ?',
        options: [
          'Rien, il faut tout refaire à la main',
          'La suppression de l’ancien nom et l’ajout du nouveau',
          'Un commit automatique',
        ],
        answer: 1,
        explanation: 'Le renommage est préparé ; il reste à créer le commit.',
      ),
    ],
  ),
  Lesson(
    id: 'history-graph',
    level: 3,
    title: 'Lire l’historique en graphe',
    subtitle: 'Visualiser branches et fusions dans le terminal',
    minutes: 8,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git log --oneline --graph --all'),
      LessonBlock(
        LessonBlockType.text,
        'Chaque astérisque est un commit. Les traits verticaux et obliques relient chaque commit à ses parents : une fourche marque le départ d’une branche, une jonction une fusion.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Les étiquettes entre parenthèses indiquent où pointent HEAD, les branches et les tags.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Sans --all, git log ne montre que l’historique atteignable depuis HEAD : les commits d’une autre branche n’y apparaissent pas.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e83',
        question: 'Quelle option affiche aussi les autres branches ?',
        options: ['--all', '--short', '--quiet'],
        answer: 0,
        explanation:
            '--all parcourt toutes les références, pas seulement HEAD.',
      ),
      Exercise(
        id: 'e84',
        question: 'Que signale (HEAD -> main) à côté d’un commit ?',
        options: [
          'Le commit le plus ancien',
          'Le commit sur lequel tu travailles, via la branche main',
          'Un commit supprimé',
        ],
        answer: 1,
        explanation: 'HEAD pointe sur main, qui pointe sur ce commit.',
      ),
    ],
  ),
  Lesson(
    id: 'detached-head',
    level: 3,
    title: 'Comprendre la HEAD détachée',
    subtitle: 'Explorer un ancien commit sans perdre ton travail',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Habituellement, HEAD désigne une branche. Quand tu te places directement sur un commit, HEAD est « détachée » : elle pointe sur le commit lui-même.',
      ),
      LessonBlock(LessonBlockType.command, 'git switch --detach a1b2c3d'),
      LessonBlock(
        LessonBlockType.analogy,
        'C’est comme feuilleter une ancienne version d’un document : tu peux regarder et faire des essais, mais aucune étiquette de branche ne suit tes nouveaux commits.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Un commit créé en HEAD détachée n’appartient à aucune branche. Une fois reparti ailleurs, il devient difficile à retrouver.',
      ),
      LessonBlock(LessonBlockType.command, 'git switch -c sauvetage'),
      LessonBlock(
        LessonBlockType.tip,
        'Pour garder un essai fait en HEAD détachée, crée une branche à cet endroit avant de repartir. git switch - revient à la branche précédente.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e85',
        question: 'Que désigne HEAD dans l’état détaché ?',
        options: ['Une branche', 'Directement un commit', 'Le dépôt distant'],
        answer: 1,
        explanation: 'HEAD pointe sur un commit précis au lieu d’une branche.',
      ),
      Exercise(
        id: 'e86',
        question: 'Comment garder un commit créé en HEAD détachée ?',
        options: [
          'git switch -c nouvelle-branche',
          'git reset --hard',
          'git stash',
        ],
        answer: 0,
        explanation: 'Une branche donne un nom durable au commit.',
      ),
    ],
  ),
  Lesson(
    id: 'clone-project',
    level: 4,
    title: 'Cloner un projet existant',
    subtitle: 'Récupérer un dépôt complet avec son historique',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'git clone https://github.com/exemple/projet.git',
      ),
      LessonBlock(
        LessonBlockType.text,
        'clone télécharge tout l’historique, crée la copie de travail de la branche principale et configure automatiquement le distant origin.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'La branche locale main suit déjà origin/main : git pull et git push fonctionnent sans autre réglage.',
      ),
      LessonBlock(LessonBlockType.command, 'git remote -v'),
      LessonBlock(
        LessonBlockType.tip,
        'Dans GitQuest, le laboratoire contient un seul dépôt : réinitialise-le avec le bouton du terminal avant de cloner.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e87',
        question: 'Que configure git clone automatiquement ?',
        options: ['Le distant origin', 'Une clé SSH', 'Une pull request'],
        answer: 0,
        explanation: 'clone enregistre l’adresse d’origine sous le nom origin.',
      ),
      Exercise(
        id: 'e88',
        question: 'Faut-il lancer git init avant git clone ?',
        options: ['Oui', 'Non'],
        answer: 1,
        explanation: 'clone crée lui-même le dépôt.',
      ),
    ],
  ),
  Lesson(
    id: 'fork-contribute',
    level: 4,
    title: 'Contribuer avec un fork',
    subtitle: 'Proposer un changement à un projet qui n’est pas le tien',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Sans droit d’écriture sur un projet, tu crées sur GitHub un fork : une copie du dépôt dans ton compte, sur laquelle tu peux pousser.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git clone https://github.com/toi/projet.git',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git remote add upstream https://github.com/auteur/projet.git',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Par convention, origin désigne ton fork et upstream le dépôt original. Tu pousses ta branche sur origin, puis tu ouvres une pull request vers upstream.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Avant une nouvelle contribution, récupère les nouveautés avec git fetch upstream, puis intègre upstream/main.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e89',
        question: 'Que désigne souvent upstream dans un fork ?',
        options: ['Ton fork', 'Le dépôt original', 'Ta branche locale'],
        answer: 1,
        explanation: 'upstream pointe vers le projet d’origine.',
      ),
      Exercise(
        id: 'e90',
        question: 'Où pousses-tu ta branche de contribution ?',
        options: [
          'Sur ton fork (origin)',
          'Directement sur le dépôt original',
          'Nulle part',
        ],
        answer: 0,
        explanation:
            'Sans droits sur l’original, tu pousses sur ton fork puis tu ouvres une pull request.',
      ),
    ],
  ),
  Lesson(
    id: 'github-auth',
    level: 4,
    title: 'S’authentifier auprès de GitHub',
    subtitle: 'Clé SSH ou jeton : pousser sans mot de passe',
    minutes: 9,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'GitHub n’accepte plus le mot de passe du compte pour git push. Deux solutions : un jeton d’accès personnel en HTTPS, ou une clé SSH.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'ssh-keygen -t ed25519 -C "ada@example.com"',
      ),
      LessonBlock(
        LessonBlockType.text,
        'La clé publique, dans le fichier .pub, s’ajoute dans les réglages GitHub. La clé privée reste sur ta machine. L’adresse du dépôt prend alors la forme git@github.com:compte/projet.git.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Ne partage jamais ta clé privée ni ton jeton, et ne les committe pas : traite-les comme des mots de passe.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Donne à un jeton uniquement les droits nécessaires et une date d’expiration.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e91',
        question: 'Quelle partie d’une clé SSH ajoutes-tu sur GitHub ?',
        options: ['La clé publique', 'La clé privée', 'Les deux'],
        answer: 0,
        explanation:
            'Seule la clé publique est partagée ; la clé privée ne quitte pas ta machine.',
      ),
      Exercise(
        id: 'e92',
        question: 'Un jeton a été committé par erreur. Que faire ?',
        options: [
          'Rien, le dépôt est privé',
          'Le révoquer immédiatement puis nettoyer l’historique',
          'Le renommer',
        ],
        answer: 1,
        explanation: 'Un secret publié doit être considéré comme compromis.',
      ),
    ],
  ),
  Lesson(
    id: 'push-rejected',
    level: 4,
    title: 'Quand le push est refusé',
    subtitle: 'Comprendre et résoudre un rejet non fast-forward',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Si le distant contient des commits que tu n’as pas, git push est refusé : envoyer ta branche effacerait le travail des autres.',
      ),
      LessonBlock(LessonBlockType.command, 'git pull --rebase origin main'),
      LessonBlock(
        LessonBlockType.text,
        'Récupère et intègre d’abord les changements distants, résous les éventuels conflits, vérifie que tout fonctionne, puis pousse à nouveau.',
      ),
      LessonBlock(LessonBlockType.command, 'git push origin main'),
      LessonBlock(
        LessonBlockType.warning,
        'git push --force écrase l’historique distant. Sur une branche partagée, c’est presque toujours une erreur ; si tu as réécrit ta propre branche, préfère --force-with-lease.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Pour t’entraîner dans GitQuest : publie main avec git push -u origin main, tape gitquest collegue pour qu’une collègue pousse un commit, crée ton propre commit puis essaie git push.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e93',
        question: 'Pourquoi un push est-il refusé en non fast-forward ?',
        options: [
          'Le distant contient des commits absents de ta branche',
          'Ton message de commit est trop long',
          'Le réseau est trop lent',
        ],
        answer: 0,
        explanation:
            'Git refuse d’écraser des commits que tu n’as pas encore intégrés.',
      ),
      Exercise(
        id: 'e94',
        question: 'Quelle option de force est la plus prudente ?',
        options: ['--force', '--force-with-lease'],
        answer: 1,
        explanation:
            'Elle refuse d’écraser si le distant a changé depuis ta dernière récupération.',
      ),
    ],
  ),
  Lesson(
    id: 'tracking-status',
    level: 4,
    title: 'Avance et retard sur le distant',
    subtitle: 'Lire ahead et behind avant de synchroniser',
    minutes: 8,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git branch -vv'),
      LessonBlock(
        LessonBlockType.text,
        'Chaque branche affiche la branche distante qu’elle suit. « ahead 2 » signifie deux commits locaux à pousser ; « behind 3 », trois commits distants à récupérer.',
      ),
      LessonBlock(LessonBlockType.command, 'git status'),
      LessonBlock(
        LessonBlockType.text,
        'git status résume la même information pour la branche courante, d’après la dernière récupération.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Ces compteurs ne contactent pas le serveur : lance git fetch pour les rafraîchir.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Dans GitQuest, gitquest collegue simule un commit publié par quelqu’un d’autre : git fetch puis git status affichent alors ton retard.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e95',
        question: '« ahead 2 » signifie…',
        options: [
          'Deux commits locaux pas encore poussés',
          'Deux commits distants à récupérer',
          'Deux branches en trop',
        ],
        answer: 0,
        explanation:
            'Ta branche a deux commits d’avance sur sa branche distante.',
      ),
      Exercise(
        id: 'e96',
        question: 'Comment rafraîchir ces compteurs ?',
        options: ['git fetch', 'git init', 'git tag'],
        answer: 0,
        explanation:
            'fetch met à jour les références distantes utilisées pour le calcul.',
      ),
    ],
  ),
  Lesson(
    id: 'squash-history',
    level: 6,
    title: 'Regrouper ses commits',
    subtitle: 'Présenter un historique clair avant la revue',
    minutes: 12,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Pendant le travail, on accumule souvent des commits « wip » ou « oups ». Avant la pull request, les regrouper en un commit clair facilite la relecture.',
      ),
      LessonBlock(LessonBlockType.command, 'git reset --soft HEAD~3'),
      LessonBlock(
        LessonBlockType.command,
        'git commit -m "feat: ajoute le formulaire de contact"',
      ),
      LessonBlock(
        LessonBlockType.text,
        'reset --soft recule la branche de trois commits en gardant tous leurs changements préparés : un seul commit les enregistre ensuite.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'git rebase -i HEAD~3 offre la même chose de façon interactive, avec pick, squash ou reword dans un éditeur. Sur GitHub, « Squash and merge » regroupe au moment de la fusion.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Ne regroupe que des commits encore locaux, ou préviens l’équipe : réécrire un historique publié oblige les autres à se resynchroniser.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e97',
        question: 'Après git reset --soft HEAD~3, où sont les changements ?',
        options: ['Perdus', 'Préparés dans l’index', 'Dans un stash'],
        answer: 1,
        explanation:
            '--soft garde les changements préparés, prêts pour un nouveau commit.',
      ),
      Exercise(
        id: 'e98',
        question: 'Quand éviter de regrouper des commits ?',
        options: [
          'Quand ils sont déjà sur une branche partagée',
          'Quand ils sont encore locaux',
          'Quand leurs messages contiennent des fautes',
        ],
        answer: 0,
        explanation:
            'Réécrire un historique partagé perturbe les autres contributeurs.',
      ),
    ],
  ),
  Lesson(
    id: 'find-regression',
    level: 7,
    title: 'Trouver un bug avec bisect',
    subtitle: 'Chercher le commit fautif par dichotomie',
    minutes: 11,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Une fonctionnalité marchait il y a un mois et ne marche plus ? git bisect cherche le commit fautif en coupant l’historique en deux à chaque étape.',
      ),
      LessonBlock(LessonBlockType.command, 'git bisect start'),
      LessonBlock(LessonBlockType.command, 'git bisect bad'),
      LessonBlock(LessonBlockType.command, 'git bisect good v1.0.0'),
      LessonBlock(
        LessonBlockType.text,
        'Git te place sur un commit intermédiaire : teste, puis réponds git bisect good ou git bisect bad. En une dizaine d’étapes, tu isoles un commit parmi un millier.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Termine toujours par git bisect reset pour revenir sur ta branche.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Pour t’entraîner, tape gitquest regression : huit commits sont créés, l’un d’eux introduit un bug dans app.js. Le tag version-saine marque un commit sain.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e99',
        question: 'Sur 1000 commits, combien d’étapes faut-il environ ?',
        options: ['10', '100', '500'],
        answer: 0,
        explanation:
            'Chaque étape divise l’intervalle par deux : 2 puissance 10 vaut environ 1000.',
      ),
      Exercise(
        id: 'e100',
        question: 'Quelle commande termine la recherche ?',
        options: ['git bisect reset', 'git bisect stop', 'git reset --hard'],
        answer: 0,
        explanation: 'bisect reset ramène HEAD sur la branche de départ.',
      ),
    ],
  ),
  Lesson(
    id: 'create-token',
    level: 8,
    title: 'Créer un jeton d’accès personnel',
    subtitle: 'Le « mot de passe » à utiliser pour git push en HTTPS',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'GitHub refuse le mot de passe du compte pour Git en HTTPS. À la place, tu crées un jeton d’accès personnel (token) : une longue clé que Git utilise comme mot de passe.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Sur github.com :\n1. Clique sur ta photo de profil, puis Settings.\n2. Tout en bas du menu de gauche : Developer settings.\n3. Personal access tokens → Fine-grained tokens.\n4. Generate new token : donne un nom, une date d’expiration et choisis le ou les dépôts concernés.\n5. Dans Repository permissions, règle Contents sur Read and write.\n6. Generate token, puis copie le jeton immédiatement.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'GitHub n’affiche le jeton qu’une seule fois. Range-le dans un gestionnaire de mots de passe. Si tu le perds, supprime-le et crées-en un nouveau.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Les jetons classiques (Tokens (classic)) existent encore : coche alors au minimum la case repo. Les jetons fine-grained sont plus sûrs, car limités aux dépôts choisis.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e101',
        question: 'Où crée-t-on un jeton sur GitHub ?',
        options: [
          'Settings → Developer settings → Personal access tokens',
          'Dans l’onglet Issues du dépôt',
          'Avec git config',
        ],
        answer: 0,
        explanation:
            'Developer settings se trouve tout en bas des réglages du compte.',
      ),
      Exercise(
        id: 'e102',
        question:
            'Quelle permission permet de pousser du code avec un jeton fine-grained ?',
        options: [
          'Contents : Read and write',
          'Issues : Read-only',
          'Metadata seulement',
        ],
        answer: 0,
        explanation:
            'Contents donne accès aux fichiers et aux commits du dépôt.',
      ),
    ],
  ),
  Lesson(
    id: 'use-token',
    level: 8,
    title: 'Utiliser son jeton avec Git',
    subtitle: 'Le coller au bon moment et ne pas le retaper',
    minutes: 9,
    blocks: [
      LessonBlock(LessonBlockType.command, 'git push origin main'),
      LessonBlock(
        LessonBlockType.text,
        'Git demande Username : saisis ton identifiant GitHub. Pour Password, colle le jeton, pas le mot de passe du compte. Rien ne s’affiche pendant la saisie : c’est normal.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git config --global credential.helper cache',
      ),
      LessonBlock(
        LessonBlockType.text,
        'cache garde le jeton en mémoire pendant 15 minutes. La valeur store l’enregistre en clair dans ~/.git-credentials : pratique, mais à réserver à un ordinateur personnel.',
      ),
      LessonBlock(LessonBlockType.command, 'gh auth login'),
      LessonBlock(
        LessonBlockType.tip,
        'Le plus simple reste GitHub CLI, l’outil officiel : gh auth login ouvre le navigateur, crée l’accès et configure Git automatiquement.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'N’écris jamais le jeton dans l’adresse du dépôt (https://jeton@github.com/…) : il finirait dans .git/config et dans l’historique du terminal.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e103',
        question: 'Que colles-tu quand Git demande Password ?',
        options: [
          'Le mot de passe du compte GitHub',
          'Le jeton d’accès personnel',
          'Rien',
        ],
        answer: 1,
        explanation: 'GitHub n’accepte que le jeton (ou une clé SSH) pour Git.',
      ),
      Exercise(
        id: 'e104',
        question: 'Quelle commande configure l’accès avec GitHub CLI ?',
        options: ['gh auth login', 'git login', 'git token add'],
        answer: 0,
        explanation:
            'gh auth login guide toute la connexion depuis le navigateur.',
      ),
    ],
  ),
  Lesson(
    id: 'ssh-setup',
    level: 8,
    title: 'Configurer une clé SSH pas à pas',
    subtitle: 'S’authentifier une fois pour toutes',
    minutes: 11,
    blocks: [
      LessonBlock(
        LessonBlockType.command,
        'ssh-keygen -t ed25519 -C "ton-email@example.com"',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Appuie sur Entrée pour accepter l’emplacement proposé, puis choisis une phrase de passe. Deux fichiers sont créés : id_ed25519 (clé privée) et id_ed25519.pub (clé publique).',
      ),
      LessonBlock(
        LessonBlockType.command,
        'cat ~/.ssh/id_ed25519.pub',
        caption: 'Copie toute la ligne affichée.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Sur github.com :\n1. Photo de profil → Settings.\n2. SSH and GPG keys → New SSH key.\n3. Donne un titre (par exemple « Ordinateur portable ») et colle le contenu du fichier .pub.\n4. Add SSH key.',
      ),
      LessonBlock(LessonBlockType.command, 'ssh -T git@github.com'),
      LessonBlock(
        LessonBlockType.text,
        'Si GitHub répond « Hi pseudo! You’ve successfully authenticated », c’est gagné. Pour un dépôt déjà cloné en HTTPS, change son adresse :',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git remote set-url origin git@github.com:pseudo/projet.git',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Ne copie jamais le fichier sans .pub : c’est ta clé privée.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e105',
        question: 'Quel fichier colles-tu sur GitHub ?',
        options: ['id_ed25519', 'id_ed25519.pub', 'known_hosts'],
        answer: 1,
        explanation: 'Seule la clé publique, en .pub, se partage.',
      ),
      Exercise(
        id: 'e106',
        question: 'Quelle commande teste la connexion SSH à GitHub ?',
        options: ['ssh -T git@github.com', 'git ssh test', 'ping github.com'],
        answer: 0,
        explanation:
            'GitHub répond avec ton identifiant si la clé est reconnue.',
      ),
    ],
  ),
  Lesson(
    id: 'github-pages',
    level: 8,
    title: 'Publier un site avec GitHub Pages',
    subtitle: 'Mettre en ligne un site statique gratuitement',
    minutes: 10,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'GitHub Pages publie gratuitement les fichiers HTML, CSS et JavaScript d’un dépôt. Il faut un fichier index.html à la racine, ou dans un dossier docs/.',
      ),
      LessonBlock(LessonBlockType.command, 'git add index.html'),
      LessonBlock(
        LessonBlockType.command,
        'git commit -m "feat: ajoute la page d’accueil"',
      ),
      LessonBlock(LessonBlockType.command, 'git push origin main'),
      LessonBlock(
        LessonBlockType.text,
        'Sur la page du dépôt :\n1. Settings → Pages.\n2. Dans Build and deployment, Source : Deploy from a branch.\n3. Branch : main et dossier / (root), puis Save.\n4. Patiente une à deux minutes : l’adresse du site s’affiche en haut de la page.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Un site de projet est publié à l’adresse https://pseudo.github.io/nom-du-depot/.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Chaque push sur main met le site à jour. L’onglet Actions montre la progression du déploiement.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Avec un compte gratuit, le dépôt doit être public pour utiliser Pages : tout son contenu est visible.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e107',
        question: 'Quel fichier sert de page d’accueil ?',
        options: ['README.md', 'index.html', 'main.css'],
        answer: 1,
        explanation: 'Pages affiche index.html à la racine du dossier publié.',
      ),
      Exercise(
        id: 'e108',
        question: 'Où active-t-on GitHub Pages ?',
        options: [
          'Settings → Pages du dépôt',
          'Avec une commande git pages',
          'Dans les issues',
        ],
        answer: 0,
        explanation: 'Le réglage Pages se trouve dans les paramètres du dépôt.',
      ),
    ],
  ),
  Lesson(
    id: 'user-site',
    level: 8,
    title: 'Créer ton site pseudo.github.io',
    subtitle: 'Une adresse personnelle à la racine',
    minutes: 8,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Un dépôt nommé exactement pseudo.github.io, où pseudo est ton identifiant GitHub, devient ton site personnel, publié à l’adresse https://pseudo.github.io.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Étapes :\n1. Sur GitHub, bouton + → New repository.\n2. Repository name : pseudo.github.io, avec ton identifiant exact en minuscules.\n3. Choisis Public et coche Add a README file.\n4. Create repository, puis clone-le.',
      ),
      LessonBlock(
        LessonBlockType.command,
        'git clone https://github.com/pseudo/pseudo.github.io.git',
      ),
      LessonBlock(
        LessonBlockType.command,
        'echo "<h1>Bonjour</h1>" > index.html',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Ajoute index.html, crée un commit et pousse : le site apparaît en général en quelques minutes. En cas de doute, vérifie Settings → Pages.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Un compte n’a qu’un site personnel, mais peut avoir autant de sites de projet que de dépôts.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e109',
        question: 'Comment doit s’appeler le dépôt de ton site personnel ?',
        options: ['site-perso', 'pseudo.github.io', 'github-pages'],
        answer: 1,
        explanation: 'Le nom exact pseudo.github.io active le site personnel.',
      ),
      Exercise(
        id: 'e110',
        question: 'Quelle adresse aura le site du dépôt demo ?',
        options: [
          'https://pseudo.github.io/demo/',
          'https://demo.github.com',
          'https://github.io/demo',
        ],
        answer: 0,
        explanation:
            'Un site de projet est publié dans un sous-dossier de ton adresse personnelle.',
      ),
    ],
  ),
  Lesson(
    id: 'profile-readme',
    level: 8,
    title: 'Personnaliser ton profil GitHub',
    subtitle: 'Le README affiché sur ta page de profil',
    minutes: 7,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Un dépôt public portant exactement ton identifiant (pseudo/pseudo) est spécial : son README.md s’affiche en haut de ta page de profil.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Étapes :\n1. + → New repository.\n2. Repository name : ton identifiant exact. GitHub affiche un message indiquant qu’il s’agit d’un dépôt spécial.\n3. Public, coche Add a README file, puis Create repository.\n4. Modifie README.md : présentation, technologies, projets favoris.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Le README s’écrit en Markdown : # pour un titre, - pour une liste, [texte](lien) pour un lien.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e111',
        question: 'Quel dépôt alimente la page de profil ?',
        options: [
          'Un dépôt nommé comme ton identifiant',
          'N’importe quel dépôt épinglé',
          'Le dépôt pseudo.github.io',
        ],
        answer: 0,
        explanation: 'Seul le dépôt pseudo/pseudo est affiché sur le profil.',
      ),
      Exercise(
        id: 'e112',
        question: 'Dans quel format écrit-on un README ?',
        options: ['Markdown', 'PDF', 'Word'],
        answer: 0,
        explanation: 'GitHub affiche le Markdown mis en forme.',
      ),
    ],
  ),
  Lesson(
    id: 'first-action',
    level: 8,
    title: 'Automatiser avec GitHub Actions',
    subtitle: 'Lancer les tests à chaque push',
    minutes: 12,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'GitHub Actions exécute des tâches sur les serveurs de GitHub à chaque événement : push, pull request, publication d’une version… Un workflow est un fichier YAML placé dans .github/workflows/.',
      ),
      LessonBlock(LessonBlockType.command, 'mkdir -p .github/workflows'),
      LessonBlock(
        LessonBlockType.command,
        'name: CI\non: [push, pull_request]\njobs:\n  tests:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n      - run: npm ci\n      - run: npm test',
        caption:
            'Contenu du fichier .github/workflows/ci.yml (projet JavaScript).',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Après le push, l’onglet Actions du dépôt affiche chaque exécution : une coche verte si tout passe, une croix rouge sinon. Les pull requests affichent le même résultat.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'Commence par un seul job simple. Les modèles de l’onglet Actions → New workflow sont un bon point de départ pour chaque langage.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e113',
        question: 'Où place-t-on un fichier de workflow ?',
        options: ['.github/workflows/', 'src/', '.git/hooks/'],
        answer: 0,
        explanation: 'GitHub lit les workflows uniquement dans ce dossier.',
      ),
      Exercise(
        id: 'e114',
        question: 'Où voit-on le résultat d’un workflow ?',
        options: ['Dans l’onglet Actions', 'Dans git log', 'Dans le README'],
        answer: 0,
        explanation: 'Chaque exécution y est détaillée, étape par étape.',
      ),
    ],
  ),
  Lesson(
    id: 'repo-secrets',
    level: 8,
    title: 'Stocker un secret pour la CI',
    subtitle: 'Utiliser une clé sans l’écrire dans le code',
    minutes: 9,
    blocks: [
      LessonBlock(
        LessonBlockType.text,
        'Un workflow a parfois besoin d’une clé, par exemple pour déployer ou appeler une API. Elle ne doit jamais être écrite dans le dépôt : on la range dans les secrets du dépôt.',
      ),
      LessonBlock(
        LessonBlockType.text,
        'Étapes :\n1. Page du dépôt → Settings.\n2. Secrets and variables → Actions.\n3. New repository secret : un nom en majuscules (par exemple API_KEY) et sa valeur.\n4. Add secret.',
      ),
      LessonBlock(
        LessonBlockType.command,
        '- run: ./deploy.sh\n  env:\n    API_KEY: \${{ secrets.API_KEY }}',
        caption: 'Utilisation du secret dans une étape du workflow.',
      ),
      LessonBlock(
        LessonBlockType.tip,
        'GitHub masque automatiquement la valeur des secrets dans les journaux d’exécution.',
      ),
      LessonBlock(
        LessonBlockType.warning,
        'Un secret déjà committé reste dans l’historique : révoque-le, génère une nouvelle clé, puis range uniquement la nouvelle dans les secrets.',
      ),
    ],
    exercises: [
      Exercise(
        id: 'e115',
        question: 'Où ranger une clé d’API utilisée par la CI ?',
        options: [
          'Settings → Secrets and variables → Actions',
          'Dans le README',
          'Dans un commit',
        ],
        answer: 0,
        explanation:
            'Les secrets du dépôt sont chiffrés et invisibles dans le code.',
      ),
      Exercise(
        id: 'e116',
        question: 'Comment un workflow lit-il le secret API_KEY ?',
        options: [
          '\${{ secrets.API_KEY }}',
          'Dans le fichier README',
          'git secret API_KEY',
        ],
        answer: 0,
        explanation:
            'La syntaxe secrets.NOM injecte la valeur au moment de l’exécution.',
      ),
    ],
  ),
];

const achievements = <Achievement>[
  Achievement(
    'first_step',
    'Premier pas',
    'Terminer une leçon',
    Icons.directions_walk_rounded,
  ),
  Achievement(
    'first_repo',
    'Premier dépôt',
    'Exécuter git init',
    Icons.inventory_2_rounded,
  ),
  Achievement(
    'first_commit',
    'Premier commit',
    'Créer ton premier commit',
    Icons.camera_alt_rounded,
  ),
  Achievement(
    'historian',
    'Historien',
    'Consulter git log',
    Icons.history_rounded,
  ),
  Achievement(
    'staging',
    'Gardien du staging',
    'Préparer des fichiers',
    Icons.fact_check_rounded,
  ),
  Achievement(
    'branch',
    'Créateur de branche',
    'Créer une branche',
    Icons.account_tree_rounded,
  ),
  Achievement(
    'merge',
    'Fusion réussie',
    'Fusionner une branche',
    Icons.call_merge_rounded,
  ),
  Achievement(
    'five_lessons',
    'En route',
    'Terminer cinq leçons',
    Icons.rocket_launch_rounded,
  ),
  Achievement(
    'ten_lessons',
    'Cap confirmé',
    'Terminer dix leçons',
    Icons.school_rounded,
  ),
  Achievement(
    'twenty_lessons',
    'Sommet Git',
    'Terminer vingt leçons',
    Icons.landscape_rounded,
  ),
  Achievement(
    'forty_lessons',
    'Grand explorateur',
    'Terminer quarante leçons',
    Icons.workspace_premium_rounded,
  ),
  Achievement(
    'fifty_lessons',
    'Maître du parcours',
    'Terminer cinquante leçons',
    Icons.military_tech_rounded,
  ),
  Achievement(
    'issue_author',
    'Organisateur',
    'Créer une issue pédagogique',
    Icons.adjust_rounded,
  ),
  Achievement(
    'reviewer',
    'Relecteur de code',
    'Effectuer une revue de pull request',
    Icons.rate_review_rounded,
  ),
  Achievement(
    'collaborator',
    'Collaborateur',
    'Ouvrir une pull request',
    Icons.groups_rounded,
  ),
  Achievement(
    'project_complete',
    'Projet terminé',
    'Terminer un projet fil rouge',
    Icons.emoji_events_rounded,
  ),
];
