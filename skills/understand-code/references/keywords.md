# Keyword scopes

Use these shortcuts to select the subject, then continue the normal interactive walkthrough.
Natural-language requests remain valid. With no target, use session context or ask when the subject is unclear.
Square brackets indicate an optional argument; angle brackets indicate a required value. Users do not type the brackets.

| Keyword | Subject |
|---|---|
| `changes` | All uncommitted changes: staged edits, unstaged edits, and untracked files. |
| `staged` | Only changes staged for the next commit. |
| `unstaged` | Edits not staged, plus untracked files. |
| `head` | Changes introduced by the latest commit at `HEAD`. |
| `branch [base]` | Combined committed changes from the common ancestor with the base branch to `HEAD`. |
| `file <path>` | Existing code in the specified file, with surrounding code as needed. |
| `system <name>` | A system's current behavior and interactions across relevant files. |

## Resolve Git scopes

Inspect Git status before choosing source versions. Resolve commit references to concrete commits and state the selected scope.

- `changes`: Inspect both the index and working tree, plus untracked files. `git diff HEAD` alone omits untracked files.
  Preserve staged changes even when unstaged edits cancel their effect in the working tree. Explain the two layers when they differ.
- `staged`: Compare `HEAD` with the index using `git diff --cached`. Read index versions when working-tree edits differ.
- `unstaged`: Compare the index with the working tree using `git diff`, and inspect untracked files separately.
- `head`: Compare `HEAD` with its first parent. For a merge commit, state that this shows the first-parent difference.
  For an initial commit, explain its additions relative to an empty tree.
- `branch [base]`: Resolve an explicit base locally. Otherwise infer it from repository guidance, session context, or the configured default branch.
  A same-named remote tracking branch is not evidence of the branch's original base. Ask if the base remains ambiguous.
  Find the merge base between the resolved base and `HEAD`, then compare that ancestor with `HEAD`.
  Explain the combined result, not each commit separately. Exclude staged, unstaged, and untracked changes.
  If the base is unavailable or the history has no unique merge base, explain the limitation and ask for a comparison target.

For committed scopes, read code at the selected commit instead of treating working-tree edits as part of the lesson.
In detached HEAD state, `head` still uses the checked-out commit. Name that state instead of inventing a current branch.
Before the first commit, `changes` and `staged` treat staged files as additions; `head` and `branch` have no commit to explain.
Report an empty selected scope briefly. Do not silently substitute another scope.
Untracked files exclude ignored files unless the user explicitly includes them.
For `file` and `system`, use the current working tree unless the user specifies another version.

## Examples

- `understand-code changes`: Explain all uncommitted work.
- `understand-code branch main`: Explain the branch's combined committed difference from its common ancestor with `main`.
- `understand-code system Cart`: Locate the Cart system and start with its main execution path.
