# Review mode

`/azure-pr review approve|suggest|wait|reject [PR id or link] [--yes]`

| Argument | Vote value |
|---|---|
| `approve` | 10 |
| `suggest` | 5 |
| `wait` | -5 |
| `reject` | -10 |

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
8. Read the reviewer list with the REST call below. It returns `id`,
   `uniqueName`, `vote`, and `isRequired` for each reviewer.

   ```bash
   az devops invoke --org <org> --area git --resource pullRequestReviewers \
     --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> \
     --api-version 7.1 -o json
   ```

9. Find the user in the reviewer list. Get the user's name with
   `az account show --query user.name -o tsv`. Match it to `uniqueName` without
   case. Record the reviewer `id`, the current vote, and the current rank.
   - `isRequired` true means the rank is **required**.
   - `isRequired` null or absent means the rank is **optional**. It is never
     `false`.
10. If the user is not in the list, use the `adoId` of the entry in the alias
    file whose aliases include `me`. The user has no rank yet. If the alias file
    has no such entry, stop and report.

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
- The user's rank on the PR: the current rank (required or optional), which the
  vote keeps. If the user is not a reviewer yet, show "not a reviewer yet" and
  ask the user which rank to use, required or optional. Recommend optional,
  because a vote from the Azure DevOps web UI adds a new reviewer as optional.
  Use the `AskUserQuestion` tool if it is available. Otherwise ask in plain
  text. Ask this question with `--yes` too, because it has no default. Ask it
  with the preview, before any write.
- Each required reviewer and the reviewer's current vote.
- The Jira write: the transition, if any, and the new assignee. Or the reason
  that the skill skips the Jira write.

Wait for approval as [SKILL.md](../SKILL.md) describes.

## 4. Vote

Do not use `az repos pr set-vote`. It sends the vote without `isRequired`, and
Azure DevOps then changes the voter to an optional reviewer.

1. Set `isRequired` to the rank from the preview. Use `true` for required and
   `false` for optional.
2. Write the body to a UTF-8 file in the scratchpad or the OS temporary
   directory. For example, a required reviewer who votes -5:

   ```json
   {"id": "<reviewer id>", "vote": -5, "isRequired": true}
   ```

3. Cast the vote with one call:

   ```bash
   az devops invoke --org <org> --area git --resource pullRequestReviewers \
     --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> \
     reviewerId=<reviewer id> --http-method PUT --in-file <body-file> \
     --api-version 7.1 -o json
   ```

4. Read the reviewer list again with the call from step 1. Check the user's
   entry against the plan. Treat `isRequired` null or absent as `false`.
   - The `vote` must have the expected value.
   - The rank must be the same as in the preview.
5. If the rank changed, report the mismatch. Show the `PUT` from item 3 with
   the planned `isRequired` value, which restores the rank. Do not run it. Wait
   for fresh approval.

## 5. Update Jira

1. Read the PR reviewers again. If a reviewer voted after the preview and the
   change alters the plan, show the new plan and wait for approval.
2. Do the transition from step 2, if any.
3. Assign the ticket.
4. Read the ticket back and check its status and assignee.

If a Jira write fails, keep the vote. Report the failed step for manual action.

Review mode is complete when the vote has the expected value, the user's rank
is unchanged, and when the Jira
ticket matches the plan or has a reported reason for the skip.
