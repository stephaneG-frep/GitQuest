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
