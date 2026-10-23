# BB Skills Setup Reference

## Required conceptual mappings

Resolve and confirm each concept independently:

| Concept | Question the contract must answer |
| --- | --- |
| Tracker | Where do tickets and tasks live? |
| Target | Which repository, project, space, or board owns them? |
| Ticket | How does the tracker classify a deliverable outcome? |
| Task | How does it classify an implementation step? |
| Agent executor | How is an agent-executed task represented? |
| Human executor | How is a human-executed task represented? |
| Needs details | How is a lightweight ticket marked before specification? |
| Release grouping | How is a ticket assigned to a release, if at all? |
| Task release behavior | Do tasks inherit, duplicate, or omit release grouping? |
| Parent-child | How are tasks attached to their ticket? |
| Blocking | How are task dependencies represented? |

A concept may be represented by a label, issue type, field, status, relationship, or another tracker-native mechanism. Record `Not used` explicitly when the user declines a concept.

## Resolution rules

- Reuse compatible existing configuration.
- Treat contradictory meanings, duplicate classifications, and ambiguous targets as conflicts.
- Ask before changing an existing name or meaning.
- Prefer native relationships when the user confirms them.
- A textual fallback is a distinct configuration choice, not an automatic downgrade.
- Never place credentials, tokens, or private connection material in the contract.
- Discover tracker operations from available tools and current capabilities; do not require a hardcoded platform recipe.

## Repository document

Write the tracker contract and the ticket rules to `docs/process/tickets.md` from [templates/tickets.md](templates/tickets.md). Replace each placeholder in the Tracker contract with a confirmed value. Write only confirmed repository configuration. Keep the table shape exactly, because other skills and scripts read the rows.

The block starts with `<!-- setup-bb-skills:tickets:start;version=<N> -->` and ends with `<!-- setup-bb-skills:tickets:end -->`. The repository owns all text outside the block, including its project rules. Never change that text.

Compare only the block with the template filled with the confirmed values. Ignore line-ending differences.

- **Missing:** the file does not exist. Propose to write the whole template file with the values.
- **Current:** the block version and the filled block match. No-op.
- **Outdated:** the block version is lower than the template version, or a confirmed value changed. Show the difference, and propose to replace the block.
- **Edited block:** the version matches, but the text does not. Show the difference. Ask whether to move each edit to `## Project rules` as a P rule, or to discard it. Then replace the block.
- **No block:** the file exists without markers, or with duplicate or malformed markers. Show the file, and ask how to proceed.

To change a rule, edit only the template, and raise the version in its start marker by one in the same change.

Do not add instructions for running skills, domain-document rules, PR lifecycle, task closure, or implementation order.

## Legacy contract

Earlier releases wrote the contract to `docs/agents/bb-skills.md`, with this pointer in `AGENTS.md` or `CLAUDE.md`:

```markdown
Tracker conventions for ticket publishing are defined in `docs/agents/bb-skills.md`.
```

Read its values as existing configuration. Propose to write them to `docs/process/tickets.md`, and to remove the legacy file and its pointer in the same change. Text in the legacy file outside the contract shape is project guidance: ask whether to add it as a P rule or to discard it. Remove `docs/agents/` only when it becomes empty.

## AGENTS.md index row

Add this row to the `## Before you…` table in `AGENTS.md` when no row names `docs/process/tickets.md`:

```markdown
| create or change a ticket | `docs/process/tickets.md` |
```

When another skill already added a row for the same action, add the path to that row. When `AGENTS.md` does not exist or has no such table, run `$setup-agents-md` first. It creates `AGENTS.md` as an index, and `CLAUDE.md`.

Do not create duplicate sections or rows. Preserve surrounding content.

## External reconciliation

For every confirmed tracker object:

1. Inspect for an exact or semantically compatible match.
2. Reuse a match.
3. Create an absent object only when approved.
4. Change a conflicting object only when the proposal named that exact change.
5. Verify its resulting name, meaning, and availability.

If a platform cannot configure a confirmed mechanism through available tools, report the gap and ask whether the user will configure it manually or approve a fallback. Do not claim completion while the contract and tracker disagree.

## Verification

Confirm:

- the skill-owned block of `docs/process/tickets.md` contains every confirmed mapping exactly once;
- `AGENTS.md` names `docs/process/tickets.md` in exactly one row;
- no legacy contract or pointer remains, unless the user chose to keep it;
- classifications have the confirmed meanings;
- configured relationships are available;
- no unapproved tracker objects changed;
- a second discovery run proposes no changes.
