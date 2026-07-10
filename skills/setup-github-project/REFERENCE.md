# GitHub Project operating model

## Artifact model

An **Epic** is a real issue representing a major outcome. It belongs to the Project with `Work Type = Epic`, an appropriate Phase, roadmap status, and aggregate sub-issue progress. It does not receive a readiness label merely because it is an epic.

A **Specification / PRD** is a separate issue containing detailed behavior, scope, requirements, and acceptance criteria. Link it from the Epic's `Specification` section. Do not make it a sub-issue or add it to the Project.

An **Implementation ticket** is executable work. It belongs to the Project with `Work Type = Ticket`, an appropriate Phase, exactly one native parent Epic, and exactly one canonical readiness label such as `ready-for-agent` or `ready-for-human`.

## Default fields

- Status: retain `Todo`, `In Progress`, `Done`.
- Phase: required single-select; derive every option from source material or ask.
- Work Type: required single-select with `Epic` and `Ticket`.

Do not add ownership, worker, estimate, date, schedule, WIP, or concurrency fields unless explicitly requested.

## Current Work

- Name: `Current Work`
- Layout: Board
- Columns: Status (`Todo`, `In Progress`, `Done`)
- No swimlanes and no grouping
- Filter: `work-type:"Ticket" label:"READY_AGENT","READY_HUMAN"`, replacing placeholders with exact repository labels
- Visible card fields: Title, Parent issue, Labels
- Hide Assignees, Status, Linked pull requests, and Sub-issues progress unless requested

Verify visible results after applying the filter. A syntactically accepted filter is not proof that it matches correctly.

## Epic Overview

- Name: `Epic Overview`
- Layout: Table
- Filter: `work-type:"Epic"`
- Group by Phase
- Show Title, Status, and Sub-issues progress

GitHub displays only non-empty groups. Do not create placeholder epics. Do not call this a Roadmap or add dates unless the user explicitly requests timeline planning.

## Workflows

1. Auto-add open issues matching either canonical readiness label. Example: `is:issue is:open label:"ready-for-agent","ready-for-human"`.
2. Item added sets Status to `Todo`.
3. Item closed sets Status to `Done`.
4. Item reopened sets Status to `Todo`.
5. Movement to `In Progress` is manual.

Native workflows do not populate Phase, Work Type, or Parent issue in this model. Populate them explicitly during creation and reconciliation.

## Tool boundaries

Use `gh project create|link|view|field-create|field-list|item-add|item-list|item-edit|edit`, `gh issue create|view|list|edit|close`, and `gh api` for supported operations.

Creating a native sub-issue requires the child's numeric database ID:

```powershell
$childId = [int64](gh api "repos/OWNER/REPO/issues/CHILD" --jq '.id')
gh api --method POST "repos/OWNER/REPO/issues/PARENT/sub_issues" -F sub_issue_id=$childId
```

Use authenticated browser control for view layouts, filters, grouping, visible card fields, and workflow definitions when the installed `gh` lacks those operations. Save views explicitly and confirm that any unsaved indicator disappears.

## Final verification checklist

- Project is linked to the approved repository and owner.
- Required fields/options exist exactly once.
- Current Work has three status columns, no grouping, and no swimlanes.
- Current Work contains only readiness-labelled tickets and zero epics.
- Every ticket visibly has one parent Epic and one readiness label.
- Epic Overview contains only epics and groups by Phase.
- Specifications are excluded from the Project.
- Closed and reopened workflows use the intended statuses.
- No duplicate or unexpected artifacts were created.
- Closed-parent/open-child and ambiguous-parent cases are reported.

