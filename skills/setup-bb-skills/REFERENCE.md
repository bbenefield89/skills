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

## Repository contract

Write only confirmed repository configuration:

```markdown
# BB Skills Tracker Contract

## Tracker

- **System:** <tracker>
- **Target:** <repository, project, space, or board>

## Artifact mappings

| Concept | Representation | Confirmed value |
| --- | --- | --- |
| Ticket | <label/type/field/status> | <value> |
| Task | <label/type/field/status> | <value> |
| Agent executor | <label/type/field/assignment> | <value> |
| Human executor | <label/type/field/assignment> | <value> |
| Needs details | <label/type/field/status> | <value> |

## Relationships

| Concept | Confirmed mechanism |
| --- | --- |
| Release grouping | <mechanism or Not used> |
| Task release behavior | <inherit, duplicate, omit, or Not used> |
| Parent-child | <mechanism or textual fallback> |
| Blocking | <mechanism or textual fallback> |
```

Do not add instructions for running skills, domain-document rules, PR lifecycle, task closure, or implementation order.

## Instruction pointer

Add one concise pointer under an appropriate existing section:

```markdown
Tracker conventions for ticket publishing are defined in `docs/agents/bb-skills.md`.
```

Do not create duplicate sections or pointers. Preserve surrounding content.

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

- the contract contains every confirmed mapping exactly once;
- the selected instruction file points to it exactly once;
- classifications have the confirmed meanings;
- configured relationships are available;
- no unapproved tracker objects changed;
- a second discovery run proposes no changes.
