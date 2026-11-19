# Journal des changements

## 1.2.0 — 2026-11-19

### Finitions

- Boîte à outils : 11 nouvelles situations (41 au total), dont `git rm`, `git log --graph`, la HEAD détachée, `git branch -vv`, `remote set-url`, `--force-with-lease`, le regroupement de commits, `git bisect` et `gh auth login`.
- Glossaire : 10 nouvelles définitions (40 au total), dont HEAD détachée, upstream, squash, jeton d’accès, clé SSH, GitHub Pages, Actions et secret.
- Terminal : suggestions rapides pour clone, rm, mv, log en graphe, HEAD détachée, suivi distant et stash list.
- Nouveau projet fil rouge « Site GitHub Pages » (4 projets au total), avec une étape de publication suivie (`git push -u`).
- Mode d’emploi mis à jour : niveau 8, nouvelles commandes, 30 missions et 4 projets.
- Intégration continue GitHub Actions : formatage, analyse et tests à chaque push et pull request.
- Le validateur de projets ne dépend plus d’un nombre magique pour reconnaître une issue créée.

### Niveau 8 « GitHub en pratique »

- 8 guides pas à pas (58 leçons au total) : créer un jeton d’accès personnel, utiliser son jeton avec Git (credential helper, GitHub CLI), configurer une clé SSH, publier un site avec GitHub Pages, créer son site pseudo.github.io, personnaliser son profil GitHub, automatiser avec GitHub Actions, stocker un secret pour la CI.
- 16 exercices supplémentaires (116 au total).

### Parcours enrichi

- 10 nouvelles leçons (50 au total) : supprimer et renommer un fichier suivi, lire l’historique en graphe, HEAD détachée, cloner un projet, contribuer avec un fork, s’authentifier auprès de GitHub, push refusé, avance et retard sur le distant, regrouper ses commits, trouver un bug avec bisect.
- Le niveau « Voyageur distant » passe de 4 à 9 leçons.
- Chaque leçon propose au moins deux exercices (100 au total).
- 5 nouvelles missions (30 au total) : Rejoindre un projet, Grand ménage, Publier et suivre, Essai à sauver, Historique présentable.
- Nouveau badge « Maître du parcours » pour les cinquante leçons ; le badge des quarante leçons devient « Grand explorateur ».
- Moteur : `git clone`, `git rm` (et `--cached`), `git mv`, `git log --graph` et `--all` avec étiquettes HEAD/branches/tags, HEAD détachée (`switch --detach`, `checkout <commit>`) avec alerte de commit orphelin, `git switch -`, `checkout -b`, `push -u` et `branch -vv`, `reset HEAD~n`.
- `git log` n’affiche plus que l’historique atteignable depuis HEAD, comme Git ; `git reset` sans référence retire seulement les fichiers préparés.
- `git status` distingue les fichiers ajoutés (A), modifiés (M) et supprimés (D), et indique la branche suivie.

### Corrections issues de l’audit

- Identifiants de commit uniques : le 16ᵉ commit ne reprend plus l’identifiant du 1er. Les dépôts existants sont réparés au chargement.
- `git revert` annule uniquement le commit visé et refuse proprement s’il a été recouvert par un commit plus récent.
- `git stash` remet la copie de travail au dernier commit, inclut les fichiers préparés. Ajout de `git stash list`. `pop` protège les changements locaux.
- `git commit --amend` n’embarque plus les fichiers non préparés et est refusé pendant une fusion ou un rebase.
- Les fichiers non suivis sont conservés par `switch`, `merge`, `reset --hard` et ne bloquent plus un rebase.
- Un fichier créé par `echo` est « non suivi » ; `git add .` ne prépare que les fichiers changés ; `reset --soft/--mixed` ne marque que les fichiers réellement concernés.
- `git branch -d` signale une branche inexistante et protège une branche non fusionnée (`-D` pour forcer).
- Historique des commandes et reflog bornés pour limiter la taille du stockage.
- Import : la sauvegarde est entièrement validée avant toute modification, la taille de texte est bornée et le rappel est reprogrammé.
- Un profil local corrompu n’empêche plus le démarrage. La série de jours s’affiche rompue après un jour manqué.
- Version unique `gitQuestVersion` vérifiée contre le pubspec. Libellé Android « GitQuest » et signature release via `android/key.properties`.

## 1.1.0 — 2026-08-10

- Persistance complète du dépôt virtuel entre les lancements.
- Ajout de `git commit --amend`, `git reset`, `git revert`, `git tag` et `git reflog`.
- Ajout des missions « Mauvais message », « Commit indésirable » et « Préparer une version ».
- Affichage des tags dans le visualiseur de dépôt.
- Corrections responsive pour le Honor MTN NX1M.
- Détection des conflits de fusion à partir de l’ancêtre commun.
- Résolution avec `git checkout --ours` ou `--theirs`, commit de merge et `merge --abort`.
- Ajout de `git cherry-pick` et du rebase pédagogique des branches propres.
- Ajout de trois missions avancées sur les conflits, cherry-pick et rebase.
- Ajout du GitHub Lab local : dépôt distant, issues, pull requests, commentaires et revues.
- Fusion d’une pull request via le moteur Git et fermeture automatique de l’issue liée.
- Releases locales connectées aux tags du dépôt virtuel.
- Ajout des badges Organisateur, Relecteur de code et Collaborateur.
- Ajout de trois projets fil rouge avec étapes séquentielles, validation réelle, récompenses XP et badge dédié.
- Ajout de la reprise du projet actif au tableau de bord et des statistiques de projets au profil.
- Correction du terminal en paysage lorsque le clavier du Honor est affiché.
- Ajout d’une boîte à outils hors connexion avec 30 situations Git, filtres, risques, copie et favoris.
- Ajout d’un glossaire pédagogique de 30 notions Git et GitHub.
- Ajout des statistiques détaillées : activité hebdomadaire, séries, progression par thème et commandes fréquentes.
- Suivi persistant des commandes réussies, erreurs corrigées, activité quotidienne et XP journalier.
- Ajout de la recherche globale avec résultats groupés et destinations directes.
- Ajout d’un historique local des huit dernières recherches, effaçable depuis l’écran.
- Export complet vers un fichier `.gitquest` partageable et import via le sélecteur natif.
- Aperçu avant import, fusion de progression, remplacement complet et sauvegarde automatique de sécurité.
- Compatibilité maintenue avec les anciennes sauvegardes JSON de format 1.
- Ajout du rebase conflictuel persistant avec `--continue` et `--abort`.
- Ajout d’un résolveur visuel multi-fichiers avec choix des versions et édition libre.
- Ajout de la protection persistante de `main` avec approbation et contrôles obligatoires.
- Ajout d’une CI simulée par pull request : analyse statique, tests et compilation Android.
- Invalidation automatique de la CI lorsqu’un nouveau commit est détecté.
- Correction du bouton « Voir le dépôt » qui recouvrait « Exécuter » dans le terminal mobile.
- Ajout d’un accès au dépôt dans la barre supérieure et d’un bouton explicite pour fermer son panneau.
- Ajout de six leçons pour compléter les niveaux Collaboration GitHub et Maîtrise avancée.
- Le parcours propose maintenant 16 leçons et 27 exercices, avec le badge « Cap confirmé » à dix leçons.
- Ajout de quatre leçons professionnelles sur les workflows, les commits conventionnels, SemVer et la sécurité.
- Les sept niveaux proposent désormais 20 leçons et 35 exercices, avec le badge « Sommet Git » à vingt leçons.
- Ajout de quatre missions professionnelles sur stash, la synchronisation distante, les commits conventionnels et la livraison versionnée.
- Extension du catalogue à 40 leçons et 55 exercices répartis sur les sept niveaux.
- Ajout du badge « Maître du parcours » pour l’achèvement des quarante leçons.
- Extension du catalogue à 25 missions avec dix nouveaux scénarios pratiques.
- Correction des commits sélectifs : seuls les fichiers préparés entrent désormais dans le snapshot.
- Ajout d’un rappel quotidien facultatif avec choix de l’heure et persistance locale.
- Reprogrammation automatique du rappel après redémarrage du téléphone ou mise à jour de l’application.
- Ajout d’un mode d’emploi complet accessible depuis l’accueil et les paramètres.

## 1.0.0 — 2026-08-03

- Première version MVP de GitQuest.
- Ajout du parcours, du terminal Git simulé, des missions, de la progression et des sauvegardes locales.
