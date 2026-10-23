# Tickets

<!-- setup-bb-skills:tickets:start;version=1 -->
**Applies to:** Each ticket and task in the tracker.

> **Editing this file:** The `setup-bb-skills` skill owns the text between the `setup-bb-skills:tickets` markers. The skill writes the [Tracker contract](#tracker-contract) from the values that the user confirms, and replaces the block when its template changes, so do not edit it. To change a tracker value, run `setup-bb-skills` again. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies.

Cite a rule by its number, such as "tickets.md rule 3" or "tickets.md rule P1". The [Tracker contract](#tracker-contract) gives the tracker, the classifications, and the relationships that the rules use.

## Rules

### 1. Tracker

Create each ticket and task in the tracker and target that the [Tracker contract](#tracker-contract) names.

```text
# Correct
A ticket in the tracker target for the work.

# Incorrect
A TODO comment in the code, or a list in a Markdown file, in place of a ticket.
```

### 2. Tickets and tasks

A ticket is one deliverable result. A task is one implementation step of a ticket. Classify each one with the Ticket or the Task value, and attach each task to its ticket with the Parent-child mechanism.

```text
# Correct
#20 Add a reward popup        (Ticket)
  └ #21 Build the popup scene   (Task, child of #20)

# Incorrect
#21 is a Task, and it has no parent ticket.
```

### 3. New tickets

A new ticket is short. It has the Ticket and the Needs details values, and its body is only a TL;DR of one or two sentences: what to do and why. Remove the Needs details value when the ticket gets its full specification.

```markdown
<!-- Correct -->
## TL;DR

Add a popup that shows the reward after each win, so that the player sees what they got.

<!-- Incorrect: a full plan in a ticket that still needs details. -->
## Plan
1. ...
2. ...
```

### 4. Task executor

Give each task exactly one executor value: Agent executor or Human executor.

```text
# Correct
#21: Task, Agent executor

# Incorrect
#21: Task, with no executor
```

### 5. Release grouping

When the contract uses a release grouping, give each ticket exactly one. Choose it from the written meaning of the grouping and from the work of the ticket. The grouping that is active now is not a reason. Apply the Task release behavior to each task.

```text
# Correct
A ticket for final production art goes in the late phase that holds final art,
even while the team works in an earlier phase.

# Incorrect
The ticket goes in a phase only because that phase is active.
```

### 6. Other classifications

Add each existing label or classification that fits the purpose or the area of the ticket, such as a bug or a documentation label. Do not create a new one for one ticket.

```text
# Correct
Ticket, Needs details, and the existing documentation label.

# Incorrect
Ticket, Needs details, and a new docs-cleanup-2026 label.
```

### 7. Blocking

Use the Blocking mechanism only when one ticket must finish before another can start. An earlier place in a list or on a board is not a dependency. Keep the dependency graph free of cycles.

```text
# Correct
#20 (build the test driver) blocks #21 (move the tests to the driver).

# Incorrect
#20 blocks #22 only because #20 is above #22 in the list.
```

### 8. Titles

Write a ticket title as a short, plain statement of the result.

```text
# Correct
Show the reward after each win

# Incorrect
Reward stuff
Improve synergy of the reward subsystem architecture
```

## Checked by

| Rule | Check |
|---|---|
| 1–8 | Review |

## Tracker contract

### Tracker

- **System:** <tracker>
- **Target:** <repository, project, space, or board>

### Artifact mappings

| Concept | Representation | Confirmed value |
| --- | --- | --- |
| Ticket | <label/type/field/status> | <value> |
| Task | <label/type/field/status> | <value> |
| Agent executor | <label/type/field/assignment> | <value> |
| Human executor | <label/type/field/assignment> | <value> |
| Needs details | <label/type/field/status> | <value> |

### Relationships

| Concept | Confirmed mechanism |
| --- | --- |
| Release grouping | <mechanism or Not used> |
| Task release behavior | <inherit, duplicate, omit, or Not used> |
| Parent-child | <mechanism or textual fallback> |
| Blocking | <mechanism or textual fallback> |
<!-- setup-bb-skills:tickets:end -->

## Project rules

None.
