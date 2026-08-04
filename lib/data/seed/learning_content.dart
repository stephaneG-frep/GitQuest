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
];
