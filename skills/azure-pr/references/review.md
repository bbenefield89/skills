# Review mode

`/azure-pr review approve|suggest|wait|reject [PR id or link] [--yes]`

| Argument | `az` vote | Vote value |
|---|---|---|
| `approve` | `approve` | 10 |
| `suggest` | `approve-with-suggestions` | 5 |
| `wait` | `wait-for-author` | -5 |
| `reject` | `reject` | -10 |

## 1. Find the PR

1. Use the PR ID or link that the user gave. Read the organization from the
   link, or from the git remote.
2. If the user gave no PR, find the active PR for the current branch:

   ```bash
   az repos pr list --org <org> --project <project> --repository <repo> \
     --source-branch <branch> --status active -o json
   ```

3. If the lookup finds zero PRs, or two or more PRs, ask the user for the PR.
4. Read the PR with `az repos pr show --id <id> --org <org> -o json`. Record
   the title, the source branch, the author (`createdBy.uniqueName`), and the
   `reviewers` list.
5. Stop if the user is the PR author. A PR author cannot review the PR.
6. Take the Jira key from the source branch, then the title. Use the shared
   lookups in [SKILL.md](../SKILL.md).
7. Read the Jira ticket: status and assignee.

## 2. Plan the Jira write

Use the `reviewers` list from step 1. A **pending reviewer** has all of these
properties:

- `isRequired` is true.
- `isContainer` is not true.
- The reviewer is not the user and not the PR author.
- `vote` is 0.

Apply the same rule for every vote:

1. If one or more pending reviewers exist, assign the ticket to the first
   pending reviewer in the `reviewers` list. Do not transition the ticket. The
   other required reviewers get their turn before the ticket moves.
2. If no pending reviewer exists, the user is the last required reviewer.
   Examine every required reviewer's vote, and include the user's new vote:
   - If every vote is `approve` (10), run `Code review completed`. Assign the
     ticket to the PR author.
   - If any vote is not 10, run `Code review unsuccessful`. Assign the ticket
     to the PR author. `suggest` (5) counts here, because the author must
     address the suggestions.

| User's vote | Pending reviewers | Every required vote is 10 | Jira write |
|---|---|---|---|
| Any | One or more | Not examined | Assign to the next pending reviewer |
| Any | None | Yes | `Code review completed`, assign to the author |
| Any | None | No | `Code review unsuccessful`, assign to the author |

Apply the status guard in [jira-workflow.md](jira-workflow.md). If the ticket is
not in PR Code Review, plan the vote only.

## 3. Preview

Show one preview:

- The PR number, title, and author.
- The vote.
- Each required reviewer and the reviewer's current vote.
- The Jira write: the transition, if any, and the new assignee. Or the reason
  that the skill skips the Jira write.

Wait for approval as [SKILL.md](../SKILL.md) describes.

## 4. Vote

```bash
az repos pr set-vote --id <id> --vote <az vote> --org <org> -o json
```

Read the PR again. Check that the user's vote has the expected value.

## 5. Update Jira

1. Read the PR reviewers again. If a reviewer voted after the preview and the
   change alters the plan, show the new plan and wait for approval.
2. Do the transition from step 2, if any.
3. Assign the ticket.
4. Read the ticket back and check its status and assignee.

If a Jira write fails, keep the vote. Report the failed step for manual action.

Review mode is complete when the vote has the expected value, and when the Jira
ticket matches the plan or has a reported reason for the skip.
