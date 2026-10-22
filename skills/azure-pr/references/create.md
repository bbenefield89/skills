# Create mode

`/azure-pr create <reviewers...> [--optional <name>...] [--draft] [--target <branch>] [--yes]`

Reviewers are required unless the user marks them with `--optional`. The first
required reviewer receives the Jira ticket. The target branch is `main` unless
the user gives `--target`.

## 1. Check the branch

1. Read the current branch with `git rev-parse --abbrev-ref HEAD`.
2. Stop if the branch is the target branch, if HEAD is detached, or if a merge
   or rebase is in progress.
3. Fetch the target branch. Stop if the branch has no commits ahead of
   `origin/<target>`.
4. Report uncommitted changes. Keep them as they are. The PR contains only
   committed work.

## 2. Resolve the inputs

1. Resolve the repository and the Jira key. Use the shared lookups in
   [SKILL.md](../SKILL.md).
2. Read the Jira ticket: summary, description, status, and assignee.
3. Resolve each reviewer name to an alias-file entry.
4. Remove the user from the reviewer list, and tell the user.
5. Read the minimum-reviewer policy on the target branch:

   ```bash
   az repos policy list --org <org> --project <project> \
     --repository-id <repo-id> --branch <target> -o json
   ```

   Find the policy with the type `Minimum number of reviewers`. If the user
   named fewer required reviewers than its `minimumApproverCount`, warn the
   user in the preview.

## 3. Check for an existing PR

```bash
az repos pr list --org <org> --project <project> --repository <repo> \
  --source-branch <branch> --status active -o json
```

If an active PR exists, show it. Ask if the user wants to add the named
reviewers to that PR. Do not create a second PR. For a reused PR, add each
reviewer with `az repos pr reviewer add --id <id> --reviewers <email>
--required true`. Use `--required false` for an optional reviewer.

## 4. Push the branch

Compare the local branch with its remote branch. Stop if the remote branch has
commits that the local branch does not have. Push with
`git push -u origin <branch>` when the remote branch is missing or behind.
Never force push.

## 5. Draft the PR

**Title:** `<KEY>: <Jira summary>`. Keep the title to 80 characters or fewer.
Shorten the summary when necessary, and keep its meaning.

**Description:** Write the description from the full diff against
`origin/<target>`, the commits, and the Jira ticket:

```markdown
## Summary

- <2 to 5 bullets: what changed and why>

## Jira

[<KEY>](https://corrocomplete.atlassian.net/browse/<KEY>)

## Test Plan

- [ ] <How to verify the change: build, tests that cover it, manual steps>
```

State only test results that ran. Write unrun checks as open checkbox items.

## 6. Preview

Show one preview:

- Repository, source branch, and target branch.
- Title and full description.
- Required reviewers and optional reviewers, with emails.
- Draft or published.
- The Jira write: the transition, and the new assignee.
- Each warning from the steps above.

Wait for approval as [SKILL.md](../SKILL.md) describes.

## 7. Create the PR

Write the description to a UTF-8 file in the scratchpad or the OS temporary
directory. Then create the PR:

```bash
az repos pr create --org <org> --project <project> --repository <repo> \
  --source-branch <branch> --target-branch <target> \
  --title "<title>" --description "$(cat <description-file>)" \
  --required-reviewers <email> <email> \
  --optional-reviewers <email> \
  [--draft] -o json
```

Read the PR back with `az repos pr show --id <id> --org <org> -o json`. Check
the branches, the title, and each reviewer's `isRequired` value. If a reviewer
is missing or has the wrong state, add or fix the reviewer with
`az repos pr reviewer add`.

## 8. Update Jira

1. If the ticket is In Development, run `Development Complete`. If the ticket
   is already PR Code Review, skip the transition.
2. Assign the ticket to the first required reviewer.
3. Read the ticket back and check its status and assignee.

If a Jira write fails, keep the PR. Report the failed step for manual action.

Create mode is complete when the PR exists with each approved reviewer, and
when the Jira ticket is in PR Code Review with the first reviewer as assignee.
Each skipped or failed step must have a report.
