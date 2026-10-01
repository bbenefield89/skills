# Keyword scopes

The keyword picks what code-brief extracts from. Natural-language requests remain valid.
Square brackets mark an optional argument; angle brackets mark a required value.

| Keyword | Subject |
|---|---|
| *(none)* | Same as `branch main`, using the local `main` ref. |
| `changes` | All uncommitted changes: staged edits, unstaged edits, and untracked files. |
| `staged` | Only changes staged for the next commit. |
| `unstaged` | Edits not staged, plus untracked files. |
| `head` | Changes introduced by the latest commit at `HEAD`. |
| `branch [base]` | This branch's own commits since it left the base branch. |
| `file <path>` | What the code in that file currently exposes. No diff. |
| `system <name>` | What a system currently exposes across its files. No diff. |

## Rules for every scope

- Resolve references to concrete commits locally. Use local refs only: `main`, never
  `origin/main`. No fetch.
- Keep the scope the user picked. If it is empty, say so in one sentence and stop.
- Untracked files exclude ignored files unless the user explicitly includes them.
- In detached HEAD state, name that state in the top strip. Do not invent a branch name.
- Before the first commit, `changes` and `staged` treat staged files as additions;
  `head` and `branch` have nothing to show, so say so and stop.

## `branch [base]`

Baseline:

```
git rev-parse --abbrev-ref HEAD
git rev-parse --verify <base>
git merge-base <base> HEAD
git rev-list --count <base>..HEAD
git log --oneline <base>..HEAD
```

Guards (reply in one plain sentence, no widget):

- the current branch is the base
- the local base ref does not exist
- there is no unique merge base

Use an explicit base exactly as given. With no base, use local `main`.

If `origin/<base>` exists locally and the local base is behind it, append
`· baseline may be stale` to the top strip and add the `git pull` line from the output
contract.

**Isolate the ticket's own commits.** `<base>..HEAD` often includes merged-in base drift
or unrelated work. On one real branch, 7 commits showed but only 3 were the ticket, and
the drift buried the real changes. Do not describe the combined diff. Instead:

1. Find the ticket key in the branch name (for example `FACS-965`).
2. Take the branch's own commits: those whose message carries the key. Where no key
   exists, use `git log --first-parent --no-merges <base>..HEAD`.
3. Exclude every other commit's changes from every card.
4. Extract with `git show <sha>` per commit. Use `git diff <first>^..<last>` only when
   the ticket commits are contiguous and no merge sits between them.

Top strip: `<branch> vs local <base> · merge-base <short-sha> · <k> of <n> commits are
this ticket · <m> files · <primary project or folder>`.

## Uncommitted scopes

- `changes`: inspect the index, the working tree, and untracked files.
  `git diff HEAD` alone misses untracked files. When unstaged edits cancel staged ones,
  extract from both layers and note the difference.
- `staged`: `git diff --cached`. Read index versions when working-tree edits differ.
- `unstaged`: `git diff`, plus untracked files.

Top strip: `<keyword> on <branch> · <m> files · <primary project or folder>`.

## `head`

Compare `HEAD` with its first parent. For a merge commit, say in the top strip that this
is the first-parent difference. For an initial commit, compare against an empty tree.

Top strip: `head <short-sha> on <branch> · <m> files · <primary project or folder>`.

## `file <path>` and `system <name>`

There is no diff and no commit isolation. Use the current working tree unless the user
names another version. For `system`, locate the system's files first and list the
primary folder. The layout drops the Renamed or removed card and retitles the risk and
config sections (see Layout in `SKILL.md`).

Top strip: `<path or system name> · current working tree · <m> files`.
