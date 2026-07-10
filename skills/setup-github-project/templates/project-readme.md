# Operating contract

This Project separates planning artifacts by purpose:

- **Epics** describe major outcomes and appear in **Epic Overview**.
- **Specifications / PRDs** describe detailed behavior and are linked from epics, but remain outside this Project.
- **Implementation tickets** describe executable work and appear in **Current Work**.

Every implementation ticket must have:

- `Work Type = Ticket`
- an appropriate `Phase`
- exactly one native parent Epic
- exactly one canonical readiness label

## Views

**Current Work** is a flat board grouped only by Status: Todo, In Progress, and Done. It shows readiness-labelled tickets, not epics or specifications.

**Epic Overview** is a table of epics grouped by Phase. It shows Status and Sub-issues progress. Empty phases are not represented by placeholder issues.

## Automation

- Readiness-labelled open issues are automatically added to the Project.
- Added items enter Todo.
- Closed items move to Done.
- Reopened items return to Todo.
- Moving work to In Progress is deliberate and manual.

Phase, Work Type, and Parent issue are not populated by native Project automation and must be assigned explicitly when issues are created or reconciled.

