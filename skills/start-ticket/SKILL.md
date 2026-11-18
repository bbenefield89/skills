---
name: start-ticket
description: Syncs the local repository with origin, switches to or creates the branch for a Jira or GitHub ticket, and gives a short summary of the ticket. Use when the user starts a new chat on a ticket, types "/start-ticket FACS-899" or a ticket URL, or says "sync with remote, switch to <ticket>, and explain it".
---

# Start a ticket

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Sync with origin, put the session on the ticket branch, and explain the ticket. Do that work and nothing else: make no code edits, run no build, create no worktree, and write nothing to the tracker. Do not offer or start a code review. The user decides the next step.

## Input

A ticket reference and an optional branch name, for example `/start-ticket FACS-899` or `/start-ticket https://github.com/<owner>/<repo>/issues/123 my-branch`.

Find the tracker from the form of the reference:

| Reference | Tracker | Fetch |
|---|---|---|
| Jira URL, or a key that matches `[A-Z][A-Z0-9]+-\d+` | Jira | The Jira/Atlassian MCP tools or connector. Take the site from the URL when one is given. Otherwise get the cloudId from the accessible-resources lookup. Never hard-code a site. |
| GitHub issue URL, or `#123` | GitHub | The `gh` CLI: `gh issue view <number> [--repo <owner>/<repo>]` |
| Bare number, or unclear form | From `docs/process/tickets.md` | Read the tracker contract there. If the file does not exist, ask the user. |

## Steps

1. **Check the working tree.** Run `git status --porcelain`. If it shows changes, stop before any checkout. List the changed files and ask the user how to proceed. Never move, stash, or discard uncommitted work without the user's choice.
2. **Sync the default branch.**

   ```bash
   git fetch origin --prune
   git symbolic-ref --short refs/remotes/origin/HEAD   # e.g. origin/main
   git checkout <default>
   git merge --ff-only origin/<default>
   ```

   If `origin/HEAD` is not set, use `main`, and say so. If the fast-forward fails, stop and report.
3. **Resolve the branch name.** Use the name the user gives. If they give none, follow the repo's pattern: read `docs/process/git.md` if it exists, and look at existing names with `git branch -a`. Jira repos usually use the bare key, such as `FACS-899`. Find matches with `git branch -a --list "*<TICKET>*"`. If no pattern is clear, ask the user once.
4. **Switch or create.** Use the one case that applies:

   | State | Command | Usual next step |
   |---|---|---|
   | Local branch exists | `git checkout <branch>`, then `git merge --ff-only origin/<branch>` if the remote branch exists | PR review |
   | Remote branch only | `git checkout -b <branch> --track origin/<branch>` | PR review or continued work |
   | Neither exists | `git checkout -b <branch> origin/<default>` | New work from the latest default branch |

   If a local branch and its remote branch have diverged, stop and report. Do not reset or rebase.
5. **Fetch the ticket** with the tool from the input table. If the tool or `gh` is not available or not authenticated, keep the git result and say that the ticket could not be fetched, and why.
6. **Explain the ticket.** Write a short summary only. Do not invoke or turn on the `tldr` skill: it is a persistent mode, and this skill needs one short summary.

## Output

```markdown
**Branch:** `<branch>` (<case from step 4>) · default branch `<default>` at `<short sha>`

**[<KEY or #N>: <title>](<url>)**
- <what is asked>
- <why>
- <done or acceptance criteria>
```

Use no more than five bullets. Give the same output for a new branch and for an existing branch. Stop after the summary.
