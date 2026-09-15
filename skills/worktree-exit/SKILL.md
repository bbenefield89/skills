---
name: worktree-exit
description: Moves the current session out of a ticket worktree and removes the worktree completely — the directory gone, not only deregistered — after confirming no work would be lost. Handles the locked-directory failure on Windows, where `git worktree remove` deletes the contents but leaves the empty folder because the session still holds a handle on it. Use when asked to "clean up the worktree", "remove the <ticket> worktree", "move this session back to the repo root", or when `git worktree remove` reported "Permission denied", "Device or resource busy", or "being used by another process".
---

# Exit and remove a ticket worktree

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Move this session back to the repository root and remove the ticket worktree in full. The directory itself must be gone at the end. Leave the local branch in place, and touch no other worktree.

**Completion criterion:** step 6 prints `GONE`. Until then the cleanup is unfinished. Report no success before that.

## Steps

1. **Confirm no work would be lost.** From inside the worktree:

   ```bash
   git status --porcelain
   git log --oneline origin/<TICKET>..HEAD
   ```

   Both must print nothing. If either prints output, stop, report it, and remove nothing.

2. **Move the session back.** The session moves only through the deferred MCP tool. Load the schema with `ToolSearch`, query `select:mcp__ccd_directory__change_directory`. Then call `mcp__ccd_directory__change_directory` with `path: <REPO_ROOT>`. A `cd` cannot do this, and the move applies at the end of the turn, so use absolute paths for the rest of the turn.
3. **Remove the worktree** from outside the worktree:

   ```bash
   cd <REPO_ROOT> && git worktree remove .claude/worktrees/<TICKET>
   ```

   Let this command fail if it fails. Adding `--force` to defeat the lock corrupts the admin state; the retry loop in step 5 handles the lock instead.

4. **Check whether the folder survived:**

   ```bash
   test -d <REPO_ROOT>/.claude/worktrees/<TICKET> && echo PRESENT || echo GONE
   ```

5. **On `PRESENT`, start a detached retry loop.** Use the PowerShell tool with `run_in_background: true`, so the loop outlives this turn:

   ```powershell
   $p = '<REPO_ROOT>\.claude\worktrees\<TICKET>'
   for ($i = 0; $i -lt 60; $i++) {
     if (-not (Test-Path $p)) { "GONE after $i tries"; break }
     try { Remove-Item $p -Recurse -Force -ErrorAction Stop; 'GONE'; break }
     catch { Start-Sleep -Seconds 5 }
   }
   if (Test-Path $p) { "STILL PRESENT after 5 minutes" }
   ```

6. **Confirm the end state** when the loop reports back:

   ```bash
   test -d <REPO_ROOT>/.claude/worktrees/<TICKET> && echo PRESENT || echo GONE
   git -C <REPO_ROOT> worktree prune
   git -C <REPO_ROOT> worktree list
   ls <REPO_ROOT>/.git/worktrees/
   ```

   `git worktree list` and `.git/worktrees/` must show no `<TICKET>` entry.

7. **Report the end state plainly.** If the loop still reports `STILL PRESENT`, say so and give the user this line to run:

   ```
   rmdir "<REPO_ROOT>\.claude\worktrees\<TICKET>"
   ```

## Why the folder stays locked

In a live run, `git worktree remove` printed `Permission denied` and still deregistered the worktree and deleted every file. Only the empty folder remained. `rmdir` then gave `Device or resource busy`, and `Remove-Item` gave `being used by another process`. The cause is this session's own directory grant on that path, not a stray editor or build process. The handle drops a short time after step 2, which is why step 5 waits in a detached loop.

The git admin state and the folder can also disagree: `git worktree list` and `.git/worktrees/` were both clean while the folder still existed. Verify the folder on its own. `git worktree prune` tidies any leftover admin entry.

## The branch

Leave the local branch `<TICKET>` in place. The pull request usually stays open, so the branch must survive the cleanup. Delete it only when the user asks.

## Related

Use [worktree-enter](../worktree-enter/SKILL.md) to create a worktree and move into it.
