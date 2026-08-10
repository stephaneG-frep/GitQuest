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
    'Maître du parcours',
    'Terminer les quarante leçons',
    Icons.workspace_premium_rounded,
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
