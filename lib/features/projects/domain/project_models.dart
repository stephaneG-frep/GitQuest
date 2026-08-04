enum ProjectRequirement {
  repositoryInitialized,
  fileCommitted,
  minimumCommits,
  branchExists,
  branchMerged,
  tagExists,
  remoteExists,
  issueCreated,
  pullRequestCreated,
  pullRequestApproved,
  pullRequestMerged,
  conventionalCommit,
  pullRequestCommented,
}

class ProjectStepDefinition {
  const ProjectStepDefinition({
    required this.id,
    required this.title,
    required this.instruction,
    required this.requirement,
    required this.xp,
    this.target,
    this.minimum = 1,
    this.commandHint,
    this.opensCollaboration = false,
  });

  final String id;
  final String title;
  final String instruction;
  final ProjectRequirement requirement;
  final String? target;
  final int minimum;
  final int xp;
  final String? commandHint;
  final bool opensCollaboration;
}

class ProjectDefinition {
  const ProjectDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.story,
    required this.rewardXp,
    required this.steps,
  });

  final String id;
  final String title;
  final String subtitle;
  final String story;
  final int rewardXp;
  final List<ProjectStepDefinition> steps;
}
