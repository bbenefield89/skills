---
name: azure-pr
description: Create an Azure DevOps PR for the current branch with required reviewers, or vote on a PR as a reviewer, and move and assign its Jira ticket to match. Use when the user says "create a PR", "open a PR with Ray and Diellza", "approve this PR", "approve with suggestions", "wait for author", or "reject the PR".
argument-hint: "create <reviewers...> [--optional <name>] [--draft] [--target <branch>] [--yes] | review approve|suggest|wait|reject [PR id or link] [--yes]"
---

# Azure PR

## Shared writing standard

Before you write user-facing prose, PR titles, or PR descriptions, read and
apply [the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this
skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.

## What this skill does

This skill has two modes. Each mode writes to Azure DevOps and to Jira:

- `create`: Create a PR for the current branch, add the reviewers, and move the
  Jira ticket into review. Follow [create.md](references/create.md).
- `review`: Cast the user's vote on a PR, and then move or hand off the Jira
  ticket. Follow [review.md](references/review.md).

If the user gives no mode, select the mode from the request. If the request
does not identify one mode, ask.

The skill never completes, merges, or abandons a PR. It never posts PR comments
and never changes branch policies.

## Confirmation

Each mode shows one preview of every Azure DevOps write and every Jira write.
Wait for the user's explicit approval, and then do the writes. With `--yes`,
skip the wait and do the writes after the preview.

Request fresh approval when new information changes a write after the preview.

## Shared lookups

**Repository.** Read `git remote get-url origin`. Parse the organization,
project, and repository from the URL. For example,
`https://RevCycleDevOps@dev.azure.com/RevCycleDevOps/CorroComplete/_git/Fsi`
gives `https://dev.azure.com/RevCycleDevOps`, `CorroComplete`, and `Fsi`.
Pass `--org`, `--project`, and `--repository` explicitly on every `az` call.
The machine has no `az devops configure` default.

**Jira key.** Extract the first match of `[A-Z][A-Z0-9]+-\d+` from the branch
name. Branches usually are the bare key, such as `FACS-895`. If the branch has
no key, use the PR title. If neither has a key, ask the user.

**Jira site.** Use cloudId `f1dfcd28-8b1b-4aa4-a12e-b0e253cc07aa`
(`corrocomplete.atlassian.net`).

**People.** Resolve each reviewer name against the user-scoped alias file
`~/.claude/azure-pr/reviewers.json`. Match the name, or any alias, without
case. Each entry has `name`, `aliases`, `email`, `adoId`, and `role`.

- If a name matches two or more entries, ask which person.
- If a name matches no entry, ask for the email. Offer to add the person to the
  alias file.
- Do not use `az devops user show`. The user does not have the permission to
  read the user directory. Pass emails directly to `az`.

To find a person's Jira account, call `lookupJiraAccountId` with the email.
Assign a ticket with `editJiraIssue` and the `assignee` field set to that
`accountId`.

**Jira workflow.** Read [jira-workflow.md](references/jira-workflow.md) before
you plan any Jira write.

## Report

After the writes, read back each changed item and report:

- The PR link and the PR state that Azure DevOps returned.
- Each reviewer and the reviewer's required or optional state, or the vote.
- The Jira ticket link, its new status, and its new assignee.
- Each skipped or failed step and the manual action that the user must do.

Report a write as done only after the readback confirms it.
