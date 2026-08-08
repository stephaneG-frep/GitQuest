enum CommandRisk { safe, caution, danger }

class CommandReference {
  const CommandReference({
    required this.situation,
    required this.command,
    required this.explanation,
    required this.result,
    required this.category,
    required this.level,
    required this.risk,
    required this.example,
    this.variants = const <String>[],
    this.warning,
  });

  final String situation;
  final String command;
  final String explanation;
  final String result;
  final String category;
  final String level;
  final CommandRisk risk;
  final String example;
  final List<String> variants;
  final String? warning;

  String get searchableText => <String>[
    situation,
    command,
    explanation,
    result,
    category,
    ...variants,
  ].join(' ').toLowerCase();
}

class GlossaryEntry {
  const GlossaryEntry(this.term, this.definition, this.example);

  final String term;
  final String definition;
  final String example;

  String get searchableText => '$term $definition $example'.toLowerCase();
}

const commandReferences = <CommandReference>[
  CommandReference(
    situation: 'Créer un nouveau dépôt',
    command: 'git init',
    explanation: 'Active le suivi Git dans le dossier actuel.',
    result: 'Un dépôt local vide est prêt à enregistrer des commits.',
    category: 'Dépôt',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git init',
  ),
  CommandReference(
    situation: 'Voir les fichiers modifiés',
    command: 'git status',
    explanation: 'Compare le dossier de travail, l’index et le dernier commit.',
    result: 'Git liste les fichiers non suivis, modifiés et préparés.',
    category: 'Inspection',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git status',
  ),
  CommandReference(
    situation: 'Préparer un fichier',
    command: 'git add <fichier>',
    explanation: 'Place la version actuelle du fichier dans l’index.',
    result: 'Le fichier sera inclus dans le prochain commit.',
    category: 'Staging',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git add README.md',
    variants: <String>['git add .', 'git add -p'],
  ),
  CommandReference(
    situation: 'Retirer un fichier du staging',
    command: 'git restore --staged <fichier>',
    explanation: 'Retire le fichier de l’index sans effacer son contenu.',
    result: 'Les modifications restent présentes mais ne seront pas commitées.',
    category: 'Staging',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git restore --staged README.md',
  ),
  CommandReference(
    situation: 'Enregistrer les changements',
    command: 'git commit -m "Message"',
    explanation:
        'Crée un point cohérent dans l’historique avec les fichiers préparés.',
    result: 'Un nouveau commit est ajouté sur la branche actuelle.',
    category: 'Commits',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git commit -m "Ajoute la page d’accueil"',
  ),
  CommandReference(
    situation: 'Afficher l’historique compact',
    command: 'git log --oneline',
    explanation: 'Affiche un commit par ligne avec son identifiant court.',
    result: 'L’historique devient facile à parcourir.',
    category: 'Historique',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git log --oneline --graph --all',
  ),
  CommandReference(
    situation: 'Voir les changements non préparés',
    command: 'git diff',
    explanation: 'Montre les lignes modifiées depuis la dernière préparation.',
    result: 'Aucun fichier n’est modifié par la commande.',
    category: 'Inspection',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git diff',
    variants: <String>['git diff --staged'],
  ),
  CommandReference(
    situation: 'Créer une branche',
    command: 'git switch -c <branche>',
    explanation: 'Crée une ligne de travail indépendante et s’y place.',
    result: 'Les prochains commits appartiendront à la nouvelle branche.',
    category: 'Branches',
    level: 'Intermédiaire',
    risk: CommandRisk.safe,
    example: 'git switch -c feature/profil',
    variants: <String>['git branch <branche>'],
  ),
  CommandReference(
    situation: 'Changer de branche',
    command: 'git switch <branche>',
    explanation: 'Déplace HEAD vers une branche existante.',
    result: 'Le dossier de travail reflète la branche choisie.',
    category: 'Branches',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git switch main',
  ),
  CommandReference(
    situation: 'Lister les branches',
    command: 'git branch',
    explanation: 'Affiche les branches locales et indique la branche active.',
    result: 'Aucune donnée n’est modifiée.',
    category: 'Branches',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git branch',
    variants: <String>['git branch -a'],
  ),
  CommandReference(
    situation: 'Supprimer une branche fusionnée',
    command: 'git branch -d <branche>',
    explanation: 'Supprime le pointeur local d’une branche déjà intégrée.',
    result:
        'La branche disparaît, mais ses commits intégrés restent accessibles.',
    category: 'Branches',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git branch -d feature/profil',
    warning:
        'Évite -D tant que tu n’as pas vérifié que le travail est récupérable.',
  ),
  CommandReference(
    situation: 'Fusionner une branche',
    command: 'git merge <branche>',
    explanation: 'Intègre l’historique indiqué dans la branche actuelle.',
    result: 'Git avance la branche ou crée un commit de fusion.',
    category: 'Fusion',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git switch main puis git merge feature/profil',
  ),
  CommandReference(
    situation: 'Abandonner une fusion conflictuelle',
    command: 'git merge --abort',
    explanation: 'Revient à l’état qui précédait la tentative de fusion.',
    result: 'La fusion en cours est annulée.',
    category: 'Fusion',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git merge --abort',
  ),
  CommandReference(
    situation: 'Garder ma version pendant un conflit',
    command: 'git checkout --ours <fichier>',
    explanation: 'Choisit la version de la branche actuelle pour ce fichier.',
    result:
        'Le contenu entrant est remplacé, puis le fichier doit être ajouté.',
    category: 'Conflits',
    level: 'Avancé',
    risk: CommandRisk.caution,
    example: 'git checkout --ours README.md puis git add README.md',
    variants: <String>['git checkout --theirs <fichier>'],
  ),
  CommandReference(
    situation: 'Enregistrer temporairement mes modifications',
    command: 'git stash',
    explanation:
        'Range les changements suivis pour retrouver un dossier propre.',
    result: 'Le travail est conservé dans une pile temporaire.',
    category: 'Stash',
    level: 'Intermédiaire',
    risk: CommandRisk.safe,
    example: 'git stash',
    variants: <String>['git stash pop', 'git stash list'],
  ),
  CommandReference(
    situation: 'Restaurer le dernier travail mis de côté',
    command: 'git stash pop',
    explanation: 'Réapplique le stash le plus récent et le retire de la pile.',
    result: 'Les modifications reviennent dans le dossier de travail.',
    category: 'Stash',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git stash pop',
  ),
  CommandReference(
    situation: 'Modifier le message du dernier commit',
    command: 'git commit --amend -m "Message"',
    explanation: 'Remplace le dernier commit par une version corrigée.',
    result: 'Le commit reçoit un nouvel identifiant.',
    category: 'Annulation',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git commit --amend -m "Corrige la documentation"',
    warning: 'Évite de réécrire un commit déjà partagé.',
  ),
  CommandReference(
    situation: 'Annuler le dernier commit sans perdre les fichiers',
    command: 'git reset --soft HEAD~1',
    explanation:
        'Recule la branche tout en gardant les changements dans l’index.',
    result: 'Le commit disparaît localement, les fichiers restent préparés.',
    category: 'Annulation',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git reset --soft HEAD~1',
  ),
  CommandReference(
    situation: 'Annuler proprement un commit partagé',
    command: 'git revert <commit>',
    explanation: 'Crée un nouveau commit qui inverse le commit ciblé.',
    result: 'L’historique reste partagé et traçable.',
    category: 'Annulation',
    level: 'Intermédiaire',
    risk: CommandRisk.safe,
    example: 'git revert HEAD',
  ),
  CommandReference(
    situation: 'Effacer toutes les modifications locales',
    command: 'git reset --hard HEAD',
    explanation: 'Aligne l’index et les fichiers sur le dernier commit.',
    result: 'Les modifications locales suivies sont perdues.',
    category: 'Annulation',
    level: 'Avancé',
    risk: CommandRisk.danger,
    example: 'git reset --hard HEAD',
    warning: 'Action destructive : vérifie git status et crée un stash avant.',
  ),
  CommandReference(
    situation: 'Ajouter un dépôt distant',
    command: 'git remote add origin <url>',
    explanation: 'Associe le nom origin à l’adresse d’un dépôt distant.',
    result: 'Le dépôt local sait où publier et récupérer les données.',
    category: 'Distant',
    level: 'Intermédiaire',
    risk: CommandRisk.safe,
    example: 'git remote add origin https://example.com/projet.git',
  ),
  CommandReference(
    situation: 'Publier une branche',
    command: 'git push -u origin <branche>',
    explanation:
        'Envoie les commits et configure le suivi de la branche distante.',
    result: 'La branche est disponible sur le dépôt distant.',
    category: 'Distant',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git push -u origin main',
  ),
  CommandReference(
    situation: 'Récupérer les changements du serveur',
    command: 'git pull',
    explanation: 'Télécharge puis intègre la branche distante suivie.',
    result: 'La branche locale reçoit les nouveaux commits.',
    category: 'Distant',
    level: 'Intermédiaire',
    risk: CommandRisk.caution,
    example: 'git pull origin main',
    variants: <String>['git fetch', 'git pull --rebase'],
  ),
  CommandReference(
    situation: 'Télécharger sans modifier ma branche',
    command: 'git fetch',
    explanation: 'Met à jour les références distantes sans fusion automatique.',
    result: 'Tu peux inspecter les changements avant de les intégrer.',
    category: 'Distant',
    level: 'Intermédiaire',
    risk: CommandRisk.safe,
    example: 'git fetch origin',
  ),
  CommandReference(
    situation: 'Marquer une version',
    command: 'git tag <version>',
    explanation: 'Ajoute un nom stable au commit actuel.',
    result: 'La version devient facile à retrouver et à publier.',
    category: 'Tags',
    level: 'Intermédiaire',
    risk: CommandRisk.safe,
    example: 'git tag v1.0.0',
  ),
  CommandReference(
    situation: 'Retrouver un commit après une erreur',
    command: 'git reflog',
    explanation:
        'Affiche les déplacements récents de HEAD dans le dépôt local.',
    result: 'Les identifiants perdus peuvent être retrouvés.',
    category: 'Historique',
    level: 'Avancé',
    risk: CommandRisk.safe,
    example: 'git reflog',
  ),
  CommandReference(
    situation: 'Rejouer un commit précis',
    command: 'git cherry-pick <commit>',
    explanation:
        'Applique les changements d’un commit sur la branche actuelle.',
    result: 'Un nouveau commit équivalent est créé.',
    category: 'Avancé',
    level: 'Avancé',
    risk: CommandRisk.caution,
    example: 'git cherry-pick a1b2c3d',
  ),
  CommandReference(
    situation: 'Replacer ma branche au-dessus de main',
    command: 'git rebase main',
    explanation:
        'Rejoue les commits de la branche après le dernier commit de main.',
    result: 'L’historique devient linéaire avec de nouveaux identifiants.',
    category: 'Avancé',
    level: 'Avancé',
    risk: CommandRisk.caution,
    example: 'git switch feature/profil puis git rebase main',
    warning: 'Ne rebase pas une branche partagée sans accord de l’équipe.',
  ),
  CommandReference(
    situation: 'Copier un dépôt existant',
    command: 'git clone <url>',
    explanation: 'Télécharge le dépôt, son historique et configure origin.',
    result: 'Un nouveau dossier de travail local est créé.',
    category: 'Dépôt',
    level: 'Débutant',
    risk: CommandRisk.safe,
    example: 'git clone https://example.com/projet.git',
  ),
  CommandReference(
    situation: 'Déplacer ou renommer un fichier suivi',
    command: 'git mv <source> <destination>',
    explanation: 'Déplace le fichier et prépare l’opération dans l’index.',
    result: 'Le renommage sera inclus dans le prochain commit.',
    category: 'Fichiers',
    level: 'Intermédiaire',
    risk: CommandRisk.safe,
    example: 'git mv ancien.md guide.md',
  ),
];

const glossaryEntries = <GlossaryEntry>[
  GlossaryEntry(
    'Git',
    'Outil distribué qui mémorise les versions d’un projet.',
    'Chaque développeur possède l’historique complet.',
  ),
  GlossaryEntry(
    'GitHub',
    'Plateforme qui héberge des dépôts Git et facilite la collaboration.',
    'Une équipe y révise une pull request.',
  ),
  GlossaryEntry(
    'Dépôt',
    'Dossier de projet suivi par Git avec son historique.',
    'git init transforme un dossier en dépôt.',
  ),
  GlossaryEntry(
    'Repository',
    'Mot anglais pour dépôt.',
    'Un repository peut être local ou distant.',
  ),
  GlossaryEntry(
    'Working directory',
    'Fichiers visibles que tu modifies actuellement.',
    'README.md modifié se trouve dans le working directory.',
  ),
  GlossaryEntry(
    'Staging area',
    'Zone de préparation du prochain commit.',
    'git add place une version dans la staging area.',
  ),
  GlossaryEntry(
    'Index',
    'Autre nom technique de la zone de préparation.',
    'L’index permet de choisir précisément le prochain commit.',
  ),
  GlossaryEntry(
    'Commit',
    'Instantané cohérent accompagné d’un message.',
    'Un commit peut ajouter une page et ses tests.',
  ),
  GlossaryEntry(
    'Hash',
    'Identifiant unique calculé pour un commit.',
    'a1b2c3d est un hash court.',
  ),
  GlossaryEntry(
    'HEAD',
    'Pointeur vers le commit actuellement utilisé.',
    'HEAD suit généralement la branche active.',
  ),
  GlossaryEntry(
    'Branche',
    'Pointeur mobile permettant une ligne de travail indépendante.',
    'feature/profil isole le développement du profil.',
  ),
  GlossaryEntry(
    'Merge',
    'Opération qui intègre une branche dans une autre.',
    'git merge feature/profil depuis main.',
  ),
  GlossaryEntry(
    'Conflit',
    'Désaccord que Git ne peut pas résoudre seul.',
    'Deux branches ont modifié les mêmes lignes.',
  ),
  GlossaryEntry(
    'Remote',
    'Nom local donné à un dépôt accessible par réseau.',
    'origin est le remote principal habituel.',
  ),
  GlossaryEntry(
    'Origin',
    'Nom conventionnel du dépôt distant principal.',
    'git push origin main publie main.',
  ),
  GlossaryEntry(
    'Clone',
    'Copie locale complète d’un dépôt distant.',
    'git clone récupère aussi l’historique.',
  ),
  GlossaryEntry(
    'Fork',
    'Copie personnelle d’un dépôt hébergé.',
    'Un fork permet de contribuer sans droit d’écriture direct.',
  ),
  GlossaryEntry(
    'Pull request',
    'Proposition de fusion soumise à discussion et revue.',
    'Une PR relie une branche source à main.',
  ),
  GlossaryEntry(
    'Issue',
    'Ticket décrivant un problème ou une tâche.',
    'Une issue peut être liée à une pull request.',
  ),
  GlossaryEntry(
    'Tag',
    'Nom fixe posé sur un commit important.',
    'v1.0.0 marque une version.',
  ),
  GlossaryEntry(
    'Release',
    'Version publiée avec notes et fichiers associés.',
    'Une release GitHub peut utiliser le tag v1.0.0.',
  ),
  GlossaryEntry(
    'Stash',
    'Pile locale pour ranger temporairement du travail.',
    'git stash permet de changer de tâche rapidement.',
  ),
  GlossaryEntry(
    'Reset',
    'Déplace une branche et peut modifier l’index ou les fichiers.',
    'reset --soft conserve les changements préparés.',
  ),
  GlossaryEntry(
    'Revert',
    'Nouveau commit qui annule un ancien commit.',
    'git revert convient à un historique partagé.',
  ),
  GlossaryEntry(
    'Rebase',
    'Rejoue des commits sur une nouvelle base.',
    'Une branche peut être replacée au-dessus de main.',
  ),
  GlossaryEntry(
    'Cherry-pick',
    'Rejoue un commit choisi sur la branche actuelle.',
    'On récupère un correctif sans fusionner toute la branche.',
  ),
  GlossaryEntry(
    'Hook',
    'Script exécuté lors d’un événement Git.',
    'pre-commit peut vérifier le formatage.',
  ),
  GlossaryEntry(
    'Workflow',
    'Organisation partagée des branches, revues et livraisons.',
    'GitHub Flow utilise des branches courtes et des PR.',
  ),
  GlossaryEntry(
    'CI/CD',
    'Automatisation des tests, constructions et déploiements.',
    'La CI teste chaque pull request.',
  ),
  GlossaryEntry(
    'Conventional Commit',
    'Convention de messages structurés par type.',
    'feat: ajoute la recherche décrit une fonctionnalité.',
  ),
];
