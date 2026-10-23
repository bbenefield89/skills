---
name: setup-agents-md
description: Creates or reconciles a repository's AGENTS.md as a short index that points agents to the rule documents in docs/, and CLAUDE.md as a single import of AGENTS.md. Use when a repository needs agent instructions set up, when AGENTS.md holds rules that belong in documents, or when another setup skill needs the "Before you…" table.
---

# Set Up AGENTS.md

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

`AGENTS.md` is an index. It holds no rules. Its "Before you…" table names the document to read before each action. `CLAUDE.md` contains only `@AGENTS.md`, so Claude Code reads the same file as other agents.

This skill owns the two files and the two blocks in [templates/AGENTS.md](templates/AGENTS.md). It does not write rule documents or table rows. The skill that owns each document adds its row, such as `$setup-godot-project`, `$setup-bb-skills`, and `$setup-github-project`.

## Approval gate

Before any write:

1. Inspect the repository read-only.
2. Present each file to create or change, with its full new text or its difference.
3. Identify each inferred value, conflict, and rule to move.
4. Wait for explicit approval.

Approval covers only the proposal shown. When another setup skill runs this skill, include this proposal in that skill's proposal.

## Discovery

Read:

- `AGENTS.md` and `CLAUDE.md`, and the instruction files that they import;
- the README, project manifests such as `project.godot` or `package.json`, and task runners such as a `Justfile`;
- the folders `docs/standards/`, `docs/architecture/`, and `docs/process/`.

## AGENTS.md

Write the file from [templates/AGENTS.md](templates/AGENTS.md). Fill the sections between the blocks:

| Section | Content |
|---|---|
| Project | One or two sentences: what the project is, its main technology, and where it runs. Draft it from the README and the manifests, and ask the user to confirm it. |
| Commands | One line for each public command that agents run, such as setup, focused tests, all tests, and full validation. Take each command from the task runner. Write `None.` when there is no command. |
| Before you… | One row for each existing rule document. Keep the header row. |
| Hard rules | Only a short prohibition that has no topic document, such as "Do not edit files in `.godot/`." Write `None.` when there is no such rule. |

Each block starts with `<!-- setup-agents-md:<key>:start;version=<N> -->` and ends with `<!-- setup-agents-md:<key>:end -->`. The keys are `guide` and `adding-rules`. The repository owns all text outside the blocks. After the first write, never change that text, except to add a missing section heading that another setup skill needs.

Classify the file. Compare only the blocks, and ignore line-ending differences.

- **Missing:** the file does not exist. Propose the whole filled template.
- **Current:** both blocks match the template. No-op.
- **Outdated:** a block version is lower than the template version. Show the difference, and propose to replace the block.
- **Edited block:** a block version matches, but its text does not. Show the difference. Ask whether to keep each edit as project text outside the block, or to discard it. Then replace the block.
- **No blocks:** the file exists without markers, or with duplicate or malformed markers. See [Existing instructions](#existing-instructions).

## CLAUDE.md

`CLAUDE.md` contains exactly `@AGENTS.md`.

- **Missing:** propose to create it from [templates/CLAUDE.md](templates/CLAUDE.md).
- **Current:** it contains only `@AGENTS.md`. No-op.
- **Other content:** treat each other line as an existing instruction. See [Existing instructions](#existing-instructions). Then propose to make the file `@AGENTS.md` only.

## Existing instructions

Do not delete an instruction. For each section or line of an existing `AGENTS.md` or `CLAUDE.md` that the template does not hold, propose one destination and ask the user to confirm it:

- A project description, a command, or a pointer to a document: the matching section of the new `AGENTS.md`.
- A rule with a topic: a project rule, numbered P1, P2, and so on, under `## Project rules` in the document for that topic. When no document fits, a new document in `docs/standards/`, `docs/architecture/`, or `docs/process/`, with a row in the table.
- A short prohibition with no topic: Hard rules.
- A pointer block from an earlier setup skill, such as `<!-- setup-godot-project:godot-standards:start -->`: leave it for the skill that owns it to migrate. Report it.
- Text that is out of date: remove it only when the user approves.

## Other setup skills

A setup skill that adds a row runs this skill first when `AGENTS.md` has no `## Before you…` table. It then adds its rows and its commands. This skill does not duplicate their questions.

## Verify

After the writes, check that:

- `AGENTS.md` has exactly one well-formed `guide` block and one `adding-rules` block, and each matches the template;
- each row in the table names a file that exists;
- `CLAUDE.md` contains only `@AGENTS.md`;
- each moved instruction is in its approved destination;
- a second run proposes no changes.

Never commit or push unless the user explicitly instructs it.
