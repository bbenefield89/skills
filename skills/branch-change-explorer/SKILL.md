---
name: branch-change-explorer
description: Generates a self-contained interactive HTML artifact with a branch-level goal and implemented-result overview plus a collapsible tree of changed files, where each file has a plain-language summary, rationale, and pseudocode. Use when the user asks to visualize, explore, or explain branch/PR changes as an HTML tree view, or requests a clickable file-tree walkthrough of a diff.
---

# Branch Change Explorer

Turn the current branch's diff into one self-contained HTML page: a branch-level
**goal / implemented** overview in the header, a file tree on the left, and a per-file
**summary / why / pseudocode** panel on the right.

## Workflow

1. **Establish the base.**
   - Prefer the repo default from `origin/HEAD`; fall back in order: `origin/main`,
     `origin/master`, `main`, `master`.
   - Diff range is `git merge-base HEAD <base>`..working tree. Include staged **and**
     unstaged changes so a mid-review working tree is covered. If the interesting work
     is staged-but-uncommitted (e.g. a commit was just soft-reset), diff against `HEAD`.

2. **Gather the changed files.**
   - `git diff --name-status <base>...HEAD` (plus staged/unstaged) for paths + status.
   - Map status to a single letter: `A` added, `M` modified, `D` deleted. Treat renames
     (`R`) as `M` unless a pure move; copies (`C`) as `A`.
   - Read each file's actual hunks (`git diff` / read the file) so every summary is
     grounded in the real change — never guess from the filename.

3. **Explain the overall change.** Write two concise header fields:
   - **goal** — the user, ticket, or specification outcome the change is meant to
     achieve. Describe the behavioral objective, not the implementation plan.
   - **implemented** — a plain-language summary of what the complete diff now does.
     Mention the main behavior and important scope decisions without listing files.

   Keep each field to one short paragraph. Ground both in the request, ticket, commit
   context, and actual diff; never invent intent that the available evidence does not support.

4. **Explain each file.** For every changed file write three fields:
   - **summary** — a bullet list of what changed, concretely (structs/functions/routes
     added, removed, reshaped). One terse fragment per bullet, not a paragraph.
   - **why** — a bullet list of the rationale. Infer from the diff, commit messages,
     ticket/ADR context, and surrounding code. Say *why this change exists*, not just
     what it does — one point per bullet.
   - **pseudo** — a language-agnostic sketch of the change, not a copy of the diff.
     Show the shape of the new/removed logic; mark removed lines and asides with
     comment spans (see markup below).

   Keep it scannable: prefer several short bullets over one dense sentence.

5. **Assemble the data** as a JSON object matching the schema below.

6. **Render.** Copy `assets/template.html` to a temp location, then replace the six
   placeholders: `__TITLE__` (a short branch/change title), `__HEAD__` (branch name),
   `__BASE__` (base ref, short sha ok), `__GOAL__` (HTML-escaped overall objective),
   `__IMPLEMENTED__` (HTML-escaped overall result), and `__DATA__` (the JSON object
   literal). Save to the OS temp/scratch dir — **not** the repo — and return a clickable
   `file://` link.

## Data schema

```js
{
  files: [
    { path: "internal/foo.go", status: "M",
      summary: ["…bullet…", "…bullet…"],   // array → bullet list
      why:     ["…bullet…", "…bullet…"],   // array → bullet list
      pseudo:  "…HTML string…" }
  ]
}
```

- `files` order controls keyboard (<kbd>↑</kbd>/<kbd>↓</kbd>) navigation;
  the tree itself is built from the `path`s (directories first, then alphabetical).
- `summary` / `why` are **arrays of bullet strings** and render as a `<ul>`. Each item
  is HTML — use `<code>…</code>` for identifiers. (A plain string is still accepted and
  renders as a paragraph, but prefer the array form.)
- `pseudo` renders inside `<pre><code>` and is auto-highlighted (heuristic: keywords,
  strings, numbers, `//`/`#` comments, `fn(` calls). You don't need to tag tokens.
  You may still wrap a note in `<span class="c">…</span>` to force it to render as a
  comment — pre-tagged spans are left untouched by the highlighter. Escape literal
  `<`, `>`, `&` that are not markup.
- Keep the JSON valid (escape quotes/newlines). Every path in `files` must be unique.

## Quality bar

- **One artifact, zero dependencies** — all CSS/JS is inline in the template; it must
  open offline from a `file://` link.
- **Immediate context** — the header explains the overall goal and implemented result
  without requiring the reader to inspect individual files first.
- **Grounded** — each summary/why reflects the actual hunks, not assumptions.
- **Pseudocode, not diff** — convey intent at the idea level; don't paste raw lines.
- When many files are removed for one reason (e.g. a deleted stack), give each its own
  entry but reuse the shared rationale text so the story stays consistent.

## Notes

- Default to the repo in the current working directory. If no base branch is
  detectable, say so and ask for the comparison target rather than guessing.
- For very large diffs, offer to scope to a subtree or a subset of paths before
  writing every file's explanation.
