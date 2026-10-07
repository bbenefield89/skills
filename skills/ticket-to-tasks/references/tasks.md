# Task reference

These decomposition and publication rules are inherited from the source `to-tickets` skill and adapted for child tasks.

## Tracer-bullet rules

- Each task cuts a narrow but COMPLETE path through every relevant layer: schema, API, UI, and tests where applicable.
- A completed task is demoable or verifiable on its own.
- Each task is sized to fit in a single fresh context window.
- Any prefactoring should be done first: make the change easy, then make the easy change.
- Declare only genuine blocking edges.
- Preserve enough ticket context, prior decisions, expected starting state, and downstream purpose for a replacement worker.

## Verification and executors

The user verifies the work as each implementation task proceeds.
Keep automated tests and manual checks in the acceptance criteria and validation of the owning implementation task.
Do not create tasks whose only outcome is human verification, including QA, playtesting, or acceptance sign-off.
Apply this rule throughout the breakdown, including its final task.
Before presenting drafts, fold any task devoted only to human verification into the relevant implementation tasks.
Keep ongoing user verification outside the task dependency graph.

Use the configured agent executor for work possible with available tools and access.
Use the human executor only for implementation work that requires human-only judgment, access, or physical action.
If an agent cannot perform a manual check, state the check and limitation in the owning task's validation.

## Model suggestions

Suggest a model for each task that has the agent executor.
Read and apply [the shared suggest-model skill](../../suggest-model/SKILL.md) one time for each of these tasks.
Match the task type to the work of that task, not to the parent ticket. Select the nearest task type instead of asking the user.

Keep that skill's picks and winner. Replace its reply format with this one line:

```markdown
Claude Code: <model>, <effort> · Codex: <model>, <effort> · Winner: <Claude Code, Codex, or Tie>
```

Use `—` as the suggestion for a task that has the human executor.
If the suggest-model skill is unavailable, state that limit one time in the review and use `—` for every task.
If that skill requires a note about the age of its picks, state the note one time in the review.

## Wide refactors

A wide refactor is one mechanical change whose blast radius fans across the codebase so one edit breaks many callers and no vertical task can land green. Do not force it into a tracer bullet. Use expand-contract:

1. Expand by adding the new form beside the old.
2. Migrate callers in batches sized to remain understandable and verifiable.
3. Contract by removing the old form after all migrations.

The expand task blocks every migration. The contract task is blocked by every migration. Keep CI green from batch to batch because the old form still exists. If even the batches cannot stay green alone, keep the sequence but let them share an integration branch and block a final integrate-and-verify task.

## Task content

Retain the source skill's task-writing behavior. Each published task must communicate:

- the parent ticket and outcome;
- the bounded behavior or enabling change;
- relevant specification and architectural context;
- acceptance criteria and validation;
- blocking tasks or `None`;
- later tasks or outcomes it enables.

Avoid brittle line numbers, unnecessary file paths, and ordinary code snippets. A decision-rich prototype excerpt is allowed when prose would be less precise.

## Readable relationship fallback

Even when native relationships exist, keep a readable `Blocked by` section in task content. When a configured native relationship is unavailable:

1. Stop before substituting a fallback.
2. Explain the missing capability.
3. Ask the user to approve a textual relationship or manual configuration.
4. Record and verify the approved fallback.

## Publication invariants

- One parent ticket owns every task in the breakdown.
- Every task has the configured task classification.
- Every task has exactly one configured executor classification.
- Release grouping follows the contract; never assume tasks duplicate the parent's release.
- Published blockers match the approved graph.
- The parent ticket's state and authored content below the generated task sequence table remain unchanged.
- Equivalent existing tasks are reused only after the user confirms the match.

## Parent task sequence

After every child task and relationship is verified, prepend this generated section to the parent ticket body:

```markdown
# Tasks

| Task | What it delivers | Ready for | Suggested model |
|---|---|---|---|
| [#<number> - <title>](<task URL>) | <Plain-English result.> | `<ready-for-* label>` | <Approved model suggestion, or `—`.> |

---
```

Write one row per child task in the approved work order, from first to last. The row order is the prescribed sequence even when the native blocker graph permits parallel work.

For each row:

- Link the task number and full title to the task issue.
- Describe the delivered result in one short sentence of plain, non-technical English. Keep it to one or two rendered lines when practical.
- Display the task's attached `ready-for-*` label exactly.
- Display the model suggestion from the approved draft exactly.

Keep native blocker relationships in the task issues and omit them from this table. If the body already starts with the generated `# Tasks` section, replace that section through its thematic break. Otherwise, place the section before the existing body. Preserve the rest of the body byte-for-byte.

Read back the parent body and verify that:

- the generated section is the first content;
- every child task appears exactly once in the approved order;
- every task link, result, and `ready-for-*` label matches the published task;
- every model suggestion matches the approved draft; and
- the previous parent body remains unchanged below the thematic break.

## Review format

Before publishing, present:

1. **Title:** short descriptive name
2. **Executor:** configured agent or human classification
3. **Blocked by:** task numbers/titles or none
4. **What it delivers:** the observable behavior or enabling result
5. **Suggested model:** the model suggestion line, or `—`

Ask:

- Is the granularity too coarse or too fine?
- Are executor choices correct?
- Does every blocker genuinely gate the task?
- Should anything be merged or split?

## Local task template

When the configured tracker is local files, write one file per task in dependency order:

```markdown
# <NN> — <Task title>

**What to build:** <The end-to-end behavior or enabling result.>

**Blocked by:** <Task numbers/titles, or “None — can start immediately”.>

**Executor:** <Configured agent or human value>

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2
```

## Tracker task template

Use the tracker's configured fields and classifications plus this content:

```markdown
## Parent

<Reference to the parent ticket.>

## What to build

<The end-to-end behavior or enabling result, not a layer-by-layer implementation list.>

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- <Reference to each blocking task, or “None — can start immediately”.>
```
