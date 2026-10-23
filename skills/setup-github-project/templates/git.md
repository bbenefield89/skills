# Git

<!-- setup-github-project:git:start;version=1 -->
**Applies to:** Each branch, commit, and pull request.

> **Editing this file:** The `setup-github-project` skill owns the text between the `setup-github-project:git` markers. The skill writes the branch prefix from the approved setup, and replaces the block when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies.

Cite a rule by its number, such as "git.md rule 2" or "git.md rule P1".

## Rules

### 1. Commit and push only on request

Commit, push, or open a pull request only when the user asks. The user reviews the diff first.

```text
# Correct
The change is complete. The agent reports it and waits.

# Incorrect
The change is complete. The agent commits and pushes it without a request.
```

### 2. Branch names

Make one branch for each ticket, from an up-to-date `main`. Name it `<prefix>-<issue number>`.

```text
# Correct
git switch main
git pull --ff-only
git switch -c <prefix>-20

# Incorrect
git switch -c feature/reward-popup
git switch -c <prefix>-20   (from another ticket branch)
```

### 3. Worktrees

To work on more than one ticket at the same time, put each worktree in `.claude/worktrees/<branch>`. Run the setup commands from `AGENTS.md` in it before the first test. A branch can be checked out in only one worktree.

```text
# Correct
git worktree add .claude/worktrees/<prefix>-20 -b <prefix>-20 main

# Incorrect
git worktree add ../repository-copy main   (main is already checked out)
```

### 4. Commit messages

Write each commit message in the Conventional Commits form `type(scope): summary`. Use `feat`, `fix`, `refactor`, `test`, `docs`, or `chore`. The scope is the area of the change. Write the summary in the imperative. Start it with a lowercase letter, and do not end it with a period.

```text
# Correct
feat(rewards): show the reward after each win
docs: add the ticket rules

# Incorrect
Updated the reward stuff.
Feat(Rewards): Showed the reward.
```

### 5. Pull requests

Give the pull request the same Conventional Commits title that its squash commit will have. Its body has these parts:

1. **Summary:** what changes for the player and what changes for the developer.
2. `Closes #<ticket>`.
3. **Validation:** each command that you ran, with its result, and each check that you did not do.

```markdown
<!-- Correct -->
## Summary
- The player sees the reward after each win.

Closes #20

## Validation
- `just validate`: pass.
- Not checked: mobile browsers.

<!-- Incorrect -->
Fixed the rewards.
```

### 6. Merges

Merge a pull request into `main` with a squash merge. The squash commit uses the title of the pull request and the pull request number, such as `feat(rewards): show the reward after each win (#21)`.

```text
# Correct
gh pr merge 21 --squash

# Incorrect
gh pr merge 21 --merge
```

### 7. No generated output

Do not commit generated output, such as build results, reports, and editor caches. `.gitignore` lists them.

```text
# Correct
git add docs/standards/gdscript.md

# Incorrect
git add -A   (adds generated reports)
```

## Checked by

| Rule | Check |
|---|---|
| 7 | `.gitignore` excludes the generated folders. |
| 1–6 | Review |
<!-- setup-github-project:git:end -->

## Project rules

None.
