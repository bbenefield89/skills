# Spec to Tasks Reference

These decomposition and publication rules are inherited from the source `to-tickets` skill and adapted for child tasks.

## Tracer-bullet rules

- Each task cuts a narrow but COMPLETE path through every relevant layer: schema, API, UI, and tests where applicable.
- A completed task is demoable or verifiable on its own.
- Each task is sized to fit in a single fresh context window.
- Any prefactoring should be done first: make the change easy, then make the easy change.
- Declare only genuine blocking edges.
- Preserve enough ticket context, prior decisions, expected starting state, and downstream purpose for a replacement worker.

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
- The parent ticket's state and authored content remain unchanged.
- Equivalent existing tasks are reused only after the user confirms the match.

## Review format

Before publishing, present:

1. **Title:** short descriptive name
2. **Executor:** configured agent or human classification
3. **Blocked by:** task numbers/titles or none
4. **What it delivers:** the observable behavior or enabling result

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
