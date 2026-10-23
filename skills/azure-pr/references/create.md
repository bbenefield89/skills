# Create mode

`/azure-pr create [reviewers...] [--optional <name>...] [--draft] [--target <branch>] [--yes]`

Reviewers are required unless the user marks them with `--optional`. When the
user names required reviewers, use exactly those people, and the first name
receives the Jira ticket. When the user names no required reviewer, pick them
with [step 3](#3-pick-reviewers). The target branch is `main` unless the user
gives `--target`.

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

## 3. Pick reviewers

Do this step only when the user named no required reviewer. Pick one `US`
reviewer and one `Kosovo` reviewer from the alias file. Only entries with
`autoPick: true` are candidates. This is a best guess, not an exact score.

1. **Out of office.** For each candidate, call `find_meeting_availability` with
   only that person as participant and `isOrganizerOptional: true`. Cover the
   rest of today and the next working day. Remove a candidate who is `oof` for
   most of that time. If the lookup cannot read a calendar, keep the candidate
   and mark the calendar as unknown.
2. **Review load.** For each candidate, count the active, non-draft PRs in all
   repositories of the project where the candidate is a required reviewer with
   vote 0:

   ```bash
   az repos pr list --org <org> --project <project> --status active --top 200 -o json
   ```

3. **Ticket load.** For each candidate, count the Jira tickets of the same
   project key that are assigned to the candidate in `PR Code Review` or
   `In Development`.
4. **Pick.** In each region, pick the candidate with the lowest review load.
   Use the ticket load to break a tie. If a tie remains, pick the candidate who
   least recently reviewed one of the user's PRs.

If a region has no candidate left, tell the user and ask for a name.

**Ticket order.** Decide which of the two reviewers receives the Jira ticket
first. Give it to the reviewer who will probably start the review sooner:

- Kosovo reviewers stop work at about 11:00 Eastern time. In the Eastern
  morning, prefer the US reviewer. Do not give a Kosovo reviewer a PR when only
  two or three working hours remain in that reviewer's day.
- Later in the Eastern day, prefer the Kosovo reviewer more. That reviewer will
  see the PR at the start of the next Kosovo morning.
- Prefer the Kosovo reviewer when the US reviewer has a heavy review load or
  ticket load that will delay this review.

Put the first reviewer first in the required-reviewer list. In the preview, show
each candidate's calendar state, review load, and ticket load. Give the reason
for each pick and for the ticket order in one line each.

## 4. Check for an existing PR

```bash
az repos pr list --org <org> --project <project> --repository <repo> \
  --source-branch <branch> --status active -o json
```

If an active PR exists, show it. Ask if the user wants to add the named
reviewers to that PR. Do not create a second PR. For a reused PR, add each
reviewer with `az repos pr reviewer add --id <id> --reviewers <email>
--required true`. Use `--required false` for an optional reviewer.

## 5. Push the branch

Compare the local branch with its remote branch. Stop if the remote branch has
commits that the local branch does not have. Push with
`git push -u origin <branch>` when the remote branch is missing or behind.
Never force push.

## 6. Draft the PR

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

## 7. Preview

Show one preview:

- Repository, source branch, and target branch.
- Title and full description.
- Required reviewers and optional reviewers, with emails.
- Draft or published.
- The Jira write: the transition, and the new assignee.
- Each warning from the steps above.

Wait for approval as [SKILL.md](../SKILL.md) describes.

## 8. Create the PR

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

## 9. Update Jira

1. If the ticket is In Development, run `Development Complete`. If the ticket
   is already PR Code Review, skip the transition.
2. Assign the ticket to the first required reviewer.
3. Read the ticket back and check its status and assignee.

If a Jira write fails, keep the PR. Report the failed step for manual action.

Create mode is complete when the PR exists with each approved reviewer, and
when the Jira ticket is in PR Code Review with the first reviewer as assignee.
Each skipped or failed step must have a report.
