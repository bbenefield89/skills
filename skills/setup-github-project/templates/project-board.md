# Project board

<!-- setup-github-project:project-board:start;version=1 -->
**Applies to:** The milestone of each ticket, the GitHub Project, and its board. `docs/process/tickets.md` defines tickets, tasks, and their classifications.

> **Editing this file:** The `setup-github-project` skill owns the text between the `setup-github-project:project-board` markers. The skill writes the [Reference](#reference) values from the approved setup, and replaces the block when its template changes, so do not edit it. To change a board setting, run `setup-github-project` again. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies.

Cite a rule by its number, such as "project-board.md rule 2" or "project-board.md rule P1".

## Rules

### 1. Milestones

Give each ticket exactly one milestone from [Milestones](#milestones). The description of each milestone on GitHub defines its phase: what the phase represents, the work that belongs, the work that does not belong, and the exit condition. Read the descriptions before you choose:

```text
gh api "repos/{owner}/{repo}/milestones?state=all" --jq '.[] | .title, .description'
```

Give a task no milestone, because its parent ticket has one.

```text
# Correct
#20 (ticket): Phase 2: Vertical Slice
#21 (task of #20): no milestone

# Incorrect
#20 (ticket): no milestone
#21 (task of #20): Phase 2: Vertical Slice
```

### 2. Project membership

Each ticket, open or closed, is in the Project. Tasks and other issues are not. When a ticket gets its specification, it keeps the same issue, milestone, state, relationships, and Project membership.

```text
# Correct
Add each new ticket to the Project.

# Incorrect
Add a task to the Project so that it shows on the board.
```

### 3. Status

The Status field has the values `Todo`, `In Progress`, and `Done`. The order of the Todo column is the planned work order. A person moves a ticket to In Progress. The Project workflows move the other changes.

```text
# Correct
Put a new ticket in Todo at its place in the work order.

# Incorrect
Put a new ticket in In Progress before anyone works on it.
```

### 4. One board

The Project has one saved view, `Tickets`, and no custom fields. Do not add a view, a field, or a status.

```text
# Correct
Use the Milestone slice of the Tickets view to see one phase.

# Incorrect
Add a Phase field and a second board for one phase.
```

## Checked by

| Rule | Check |
|---|---|
| 2, 3 | The Project workflows in [Workflows](#workflows) |
| 1–4 | `setup-github-project` verification, and review |

## Reference

### Milestones

1. `Phase 1: Prototype`
2. `Phase 2: Vertical Slice`
3. `Phase 3: Alpha`
4. `Phase 4: Beta`
5. `Phase 5: Release`

### Project

| Item | Value |
|---|---|
| Project | <project title>, number <project number>, owner `<owner>` |
| URL | <project URL> |
| Visibility | Private, linked to `<owner>/<repository>` |

### Tickets view

- Board filtered to `label:"<Ticket value>"`.
- Columns use Status: `Todo`, `In Progress`, and `Done`.
- Slice by Milestone.
- No swimlanes.
- Manual sort and Count field sum.
- Cards show Title, Assignees, Labels, and Sub-issues progress.

### Workflows

- Open tickets are added automatically and enter `Todo`.
- Closed tickets move to `Done`.
- Reopened tickets return to `Todo`.
- Movement to `In Progress` is manual.
- Auto-add-sub-issues is off, so tasks stay outside the Project.
<!-- setup-github-project:project-board:end -->

## Project rules

None.
