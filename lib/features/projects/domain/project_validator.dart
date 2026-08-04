import '../../collaboration/data/collaboration_store.dart';
import '../../collaboration/domain/collaboration_models.dart';
import '../../terminal/domain/virtual_repository.dart';
import 'project_models.dart';

abstract final class ProjectValidator {
  static bool isSatisfied(
    ProjectStepDefinition step,
    VirtualRepository repository,
    CollaborationStore collaboration,
  ) => switch (step.requirement) {
    ProjectRequirement.repositoryInitialized => repository.initialized,
    ProjectRequirement.fileCommitted => repository.commits.any(
      (commit) => commit.snapshot.containsKey(step.target),
    ),
    ProjectRequirement.minimumCommits =>
      repository.commits.length >= step.minimum,
    ProjectRequirement.branchExists =>
      step.target!.endsWith('/')
          ? repository.branches.keys.any(
              (branch) => branch.startsWith(step.target!),
            )
          : repository.branches.containsKey(step.target),
    ProjectRequirement.branchMerged => repository.mergedBranches.contains(
      step.target,
    ),
    ProjectRequirement.tagExists => repository.tags.containsKey(step.target),
    ProjectRequirement.remoteExists => repository.remotes.containsKey(
      step.target,
    ),
    ProjectRequirement.issueCreated => collaboration.issues.any(
      (issue) => issue.id >= 3,
    ),
    ProjectRequirement.pullRequestCreated =>
      collaboration.pullRequests.isNotEmpty,
    ProjectRequirement.pullRequestApproved => collaboration.pullRequests.any(
      (pullRequest) =>
          pullRequest.status == PullRequestStatus.approved ||
          pullRequest.status == PullRequestStatus.merged,
    ),
    ProjectRequirement.pullRequestMerged => collaboration.pullRequests.any(
      (pullRequest) => pullRequest.status == PullRequestStatus.merged,
    ),
    ProjectRequirement.conventionalCommit => repository.commits.any(
      (commit) => RegExp(r'^(feat|fix)(\(.+\))?:').hasMatch(commit.message),
    ),
    ProjectRequirement.pullRequestCommented => collaboration.pullRequests.any(
      (pullRequest) => pullRequest.comments.isNotEmpty,
    ),
  };
}
