---
name: worktree-enter
description: Creates a git worktree for a ticket branch and moves the current session into it, following the repository's existing worktree path convention. Handles the two mechanics that make a hand-rolled attempt fail — the session moves only through the deferred MCP tool `mcp__ccd_directory__change_directory`, and that move applies only at the end of the turn. Use when asked to "pull FACS-123 into a worktree", "set up a worktree for <ticket>", "move this session into the <ticket> worktree", "work on <ticket> in its own worktree", or when a `cd` failed to move the session.
---

# Enter a ticket worktree

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Put a ticket branch in its own worktree and move this session into it. Do that work and nothing else: create no file, run no build, install nothing.

## The session move

Three mechanics govern the move. Each one was found by failure in a live run.

1. **The session moves only through `mcp__ccd_directory__change_directory`.** A `cd` inside a Bash call applies to that one command. The session stays where it was.
2. **That tool is deferred.** Load the schema first with `ToolSearch`, query `select:mcp__ccd_directory__change_directory`. A direct call without the load fails with `InputValidationError`.
3. **The move applies at the end of the turn.** Every later tool call in the same turn still resolves against the old directory. Use the full absolute worktree path in each of those calls.

## Steps

1. **Resolve the ticket.** Take it from the argument. With no argument, read the current branch name and use the ticket it contains. If neither gives a ticket, ask the user. Never guess in silence.
2. **Confirm the branch exists.** From the repository root:

   ```bash
   git fetch origin --prune
   git branch -a --list "*<TICKET>*"
   ```

3. **Read the path convention.** Run `git worktree list` and follow the convention the existing worktrees show. FSI repositories put worktrees at `<REPO_ROOT>/.claude/worktrees/<TICKET>`. Use that layout only when `git worktree list` confirms it or the repository has no worktree yet.
4. **Create the worktree.** Pick the one case that applies:

   | State | Command |
   |---|---|
   | Remote branch exists, no local branch | `git worktree add .claude/worktrees/<TICKET> -b <TICKET> --track origin/<TICKET>` |
   | Local branch already exists | `git worktree add .claude/worktrees/<TICKET> <TICKET>` |
   | New branch off main | `git worktree add .claude/worktrees/<TICKET> -b <TICKET> origin/main` |

5. **Move the session.** Load the deferred schema, then call `mcp__ccd_directory__change_directory` with `path: <REPO_ROOT>\.claude\worktrees\<TICKET>`.
6. **Report** the worktree path, the branch, and the HEAD commit.

## Keep the shared stash stack safe

All worktrees of one repository share a single stash stack. A bare `git stash pop` can take work that belongs to a different session. To park work in progress, make a temporary WIP commit.

## Related

Use [worktree-exit](../worktree-exit/SKILL.md) to move back out and remove the worktree.
