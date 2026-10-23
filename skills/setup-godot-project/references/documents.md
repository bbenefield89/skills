# Publish the repository documents

Setup publishes eight documents. Each one has a block that this skill owns. The repository owns the rest of the file.

| Template in `assets/project-template/` | Target path | Block key | AGENTS row: Before you… |
|---|---|---|---|
| `docs/standards/gdscript.md` | `docs/standards/gdscript.md` | `gdscript` | write or change a `.gd` file |
| `docs/standards/scenes.md` | `docs/standards/scenes.md` | `scenes` | write or change a `.tscn` file |
| `docs/standards/ui.md` | `docs/standards/ui.md` | `ui` | create or change player UI |
| `docs/standards/testing.md` | `docs/standards/testing.md` | `testing` | write or change a test |
| `docs/architecture/file-layout.md` | `docs/architecture/file-layout.md` | `file-layout` | add, move, or rename a file |
| `docs/architecture/overview.md` | `docs/architecture/overview.md` | `overview` | add a system or change which system owns a rule |
| `docs/architecture/decisions/README.md` | `docs/architecture/decisions/README.md` | `decisions` | make a decision that is hard to reverse |
| `docs/process/done.md` | `docs/process/done.md` | `done` | say that a change is complete |

## Skill-owned blocks

Each block starts with `<!-- setup-godot-project:<key>:start;version=<N> -->` and ends with `<!-- setup-godot-project:<key>:end -->`. Each block holds an editing note. The note tells agents and people not to edit the block, and to add project rules, numbered P1, P2, and so on, under `## Project rules` below the end marker.

Never change text outside a block. Project rules, the System map, the Folder map, and the tables in the UI Reference belong to the repository.

## Classify each document

Compare only the block. Ignore line-ending differences.

- **Missing:** the file does not exist. Propose to copy the whole template file.
- **Current:** the block version and the block text match the template. No-op.
- **Outdated:** the block version is lower than the template version. Show the difference between the two blocks, and propose to replace the block. The user's approval of that difference authorizes the replacement. The version alone does not.
- **Edited block:** the block version matches the template, but the text does not. Show the difference. Ask whether to move each edit to `## Project rules` as a P rule, or to discard it. Then replace the block.
- **No block:** the file exists without markers, or with duplicate or malformed markers. Show the file, and ask how to proceed. One choice is to put the template block at the top and keep the current text below it as project content.
- **Legacy:** see "Legacy documents" in [reconciliation.md](reconciliation.md).

When an Outdated block changes the number of a rule, report the change. Project rules and other documents can cite the old number.

## AGENTS.md index

Add one row to the `## Before you…` table in `AGENTS.md` for each document, with the target path in backticks in the Read column. Add a row only when no row names that path. Keep each row that the repository added.

When `AGENTS.md` does not exist or has no such table, run `$setup-agents-md` first. It creates `AGENTS.md` as an index, and `CLAUDE.md`. Include its proposal in the setup proposal.

Also add each of these lines that is missing. Replace `None.` in a section when you add its first line. Preserve all other `AGENTS.md` content.

Under `## Commands`:

```markdown
- `just import`: import the project and build the `.godot/` cache.
- `just test <path>`: run the tests in one file or folder.
- `just test-all`: run all tests.
- `just validate`: run all checks.

A change is complete only after the checks in `docs/process/done.md` pass.
```

Under `## Hard rules`:

```markdown
- Do not edit files in `.godot/`. Godot generates them.
- Do not edit the vendored add-ons in `addons/`.
```

## Boundaries

Publishing a document does not authorize code changes, scene changes, or file moves. Those need a separate request. Do not write project rules, map rows, or Reference rows. The repository adds them.

## Verify

After the writes, check that each document has exactly one well-formed block that matches its template, and that `AGENTS.md` has exactly one row for each target path. A second run proposes no document edits.

## Change a rule

Edit only the template, and raise the version in its start marker by one in the same change. A rule change without a version change makes each published copy an Edited block.
