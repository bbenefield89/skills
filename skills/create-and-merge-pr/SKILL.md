---
name: create-and-merge-pr
description: Creates a GitHub PR from the current branch, closes its ticket, squash merges into the specified base (default main), and syncs local main. Use when the user requests this complete PR and merge workflow.
---

# Create and Merge PR

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
the [asd-ste100 skill](../asd-ste100/SKILL.md) and its writing profile.
Apply its language rules to the PR title, PR body, and result report.
Keep this skill's required workflow and output detail.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

## Scope and authority

A request to run this workflow authorizes publishing the current branch, creating the PR, squash merging, and closing its confirmed issue.
It also authorizes switching to `main` and synchronizing it with the repository remote.
Continue through these actions without another approval when the user's request covers the complete workflow.
Honor narrower requests, such as creating a PR without merging.
Creating or editing this skill does not authorize running it.

Use committed changes from the current branch. Leave uncommitted work intact and report it before publishing.
Do not automatically commit, stash, discard changes, force push, delete branches, or bypass repository protections.

## Resolve the branch and issue

1. Read repository instructions and any applicable tracker contract.
2. Inspect the current branch, worktree, remotes, and GitHub repository identity.
   Resolve the base repository and publishing remote explicitly, including fork ownership when applicable.
3. Use the requested base branch. If none is provided, use `main`, regardless of GitHub's default branch.
   Keep `main` as the final checkout even when the requested base differs.
4. Fetch the relevant remote refs. Confirm that the base exists and differs from the current branch.
   Stop for detached HEAD, an unfinished merge or rebase, or ambiguous repository identity.
   If the requested base or `main` is missing, ask for the intended branch instead of substituting another.
5. Resolve the issue from an explicit user reference, then the branch name, then clear conversation and repository evidence.
   For example, `SP-101` in StuffiePop identifies candidate issue `#101` in that repository.
   Names such as `feature/SP-101-claw-movement` can supply the same candidate.
6. Read the candidate issue from GitHub. Confirm its repository, title, body, and relationship to the branch changes.
   Check the branch diff and commits against the fetched base.
   A branch number alone is not proof that an issue is the correct ticket.
   If references conflict or multiple issues fit, ask which issue to close before creating or editing a PR.
7. Check required validation and available results for the current commit.
   Run missing repository-required checks when feasible. Report actual results without claiming unperformed tests passed.

Proceed when the source branch, base, issue, and committed scope are unambiguous.

## Create the PR

1. Inspect remote branch history before publishing. Stop if a normal push would overwrite divergent remote work.
2. Push the current branch to the confirmed publishing remote when needed, with upstream tracking.
   Verify that the remote head equals the local commit intended for the PR.
3. Find an existing PR for this exact source repository, source branch, base repository, and base branch.
   Reuse a matching open PR instead of creating a duplicate.
   Inspect matching merged PRs before a retry. Resume remaining steps if the intended changes are already merged.
   Stop for a conflicting base, ambiguous match, or a closed unmerged PR that requires a user decision.
4. Prepare a concise title and body from the complete diff and ticket requirements.
   Use a Conventional Commit title suitable for the squash commit.
   Follow the repository PR template when present. Explain the resulting behavior, validation, and material limitations.
5. Include a standalone `Closes #101` line for issue `#101` in the same repository.
   Use `Closes owner/repo#101` for a confirmed issue in another repository.
   Preserve unrelated content when adding the closing line to an existing PR.
6. Create a ready PR with explicit base and head values.
   With GitHub CLI, use `gh pr create --repo <base-repository> --base <base> --head <head> --title <title> --body-file <file>`.
   Write multiline bodies to a temporary file. Pass text through structured arguments or safe shell quoting.
7. Read the PR from GitHub. Verify its URL, source repository, head SHA, base, body, and intended closing reference.

## Squash merge and close the issue

1. Read current mergeability, required checks, review requirements, and draft state.
   If mergeability is unknown, refresh it before deciding. Report an unresolved state if GitHub does not resolve it.
2. If conflicts exist, leave the PR open and report its URL and conflict status.
   Stop before merging, closing the issue, or switching branches. Conflict resolution requires a separate request.
3. Wait for pending required checks within the available execution time.
   If checks fail, approvals are missing, or another protection blocks merging, leave the PR open and report the blocker.
   If squash merging is disabled, report that limitation instead of selecting another merge method.
4. Refresh the PR head SHA and base immediately before merging. Reassess any changes since the verified revision.
5. Squash merge the verified head into the verified base.
   With GitHub CLI, use `gh pr merge <url> --squash --match-head-commit <verified-head-sha>`.
   Use the Conventional Commit PR title as the squash commit title.
   Respect a required merge queue. A queued merge is pending until GitHub reports `MERGED`.
6. Read the PR again. Require `MERGED`, the expected base, and a merge commit before continuing.
7. Read the confirmed issue state.
   GitHub closing keywords apply automatically when a PR merges into the repository's default branch.
   A different target branch does not provide that automatic closure.
   If the issue remains open after the verified merge, close it as completed to satisfy this workflow.
   With GitHub CLI, use `gh issue close <number> --repo <issue-repository> --reason completed`.
   Read the issue again and verify closure. Preserve an already closed issue's reason.

## Switch to main and sync

1. After the verified merge, inspect the worktree again.
   If local changes prevent a safe checkout, preserve them and report the remaining synchronization step.
2. Fetch `main` from the confirmed base repository remote.
3. Switch to local `main`. If absent, create it to track that remote's `main`.
   If another worktree owns `main`, report its location and the checkout limitation.
4. Fast-forward local `main` to the fetched remote `main`.
   If local commits prevent an exact match, preserve them and report the divergence or local-only commits.
   Never reset local `main` to remove commits automatically.
5. Verify the current branch is `main` and local HEAD equals the fetched remote `main` SHA.
   When the PR base differs from `main`, report that its merge remains on that base.

## Report and recovery

Report the PR link, merge result and base, issue link and closure state, and local synchronization result.
Include any blocker or incomplete step. Claim completion only for states verified through readback.

After an uncertain write result, read the remote state before retrying.
Resume only confirmed missing steps. Stop if the same failure repeats.
Continue independent post-merge synchronization if issue closure fails, and report the incomplete closure.

## GitHub references

- [Issue closing behavior](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue)
- [GitHub CLI PR creation](https://cli.github.com/manual/gh_pr_create)
- [GitHub CLI merge options and queues](https://cli.github.com/manual/gh_pr_merge)
