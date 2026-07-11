# GitHub Project operating model

## Artifact model

A **Phase** is a real issue representing a top-level development phase. It receives the repository label `phase`, belongs to the Project, and is the native parent of the Epics in that phase.

An **Epic** is a real issue representing a major outcome. It receives the repository label `epic`, belongs to the Project, and must be attached as a native sub-issue of exactly one Phase. It does not receive a readiness label merely because it is an Epic.

A **Specification / PRD** is a separate issue containing detailed behavior, scope, requirements, and acceptance criteria. It receives `spec`, receives no readiness label, and is linked from the Epic's `Specification` section. It stays outside the Project and has no native parent or children. Implementation tickets are created from the specification but attach natively to the Epic, never to the specification.

An **Implementation ticket** is executable work. It belongs to the Project, must be attached as a native sub-issue of exactly one Epic, and must receive exactly one readiness label: `ready-for-agent` or `ready-for-human`.

The repository's issues and their native parent/sub-issue relationships are the source of truth. Labels classify the issue type, but labels alone do not establish hierarchy.

## Labels and fields

- Required repository labels: `phase`, `epic`, `spec`, `ready-for-agent`, `ready-for-human`.
- Status: retain `Todo`, `In Progress`, `Done`.

Do not require or create manual hierarchy fields such as `Work Type`, `Phase`, `Epic`, or equivalent custom fields. Do not add ownership, worker, estimate, date, schedule, WIP, or concurrency fields unless explicitly requested.

## Current Work

- Name: `Current Work`
- Layout: Board
- Columns: Status (`Todo`, `In Progress`, `Done`)
- No swimlanes and no grouping by Epic or Parent issue
- Filter: `label:"ready-for-agent","ready-for-human"`
- Visible card fields: Title, Parent issue, Labels
- Hide Assignees, Status, Linked pull requests, and Sub-issues progress unless requested

Verify visible results after applying the filter. A syntactically accepted filter is not proof that it matches correctly.

Do not display Phase or Epic issues in this view.

## Epic Roadmap

- Name: `Epic Roadmap`
- Layout: Table
- Filter: `label:"epic"`
- Group by Parent issue
- Show Title, Status, and Sub-issues progress

This displays each Phase as the group heading and its Epics beneath it. Empty Phases will not appear until they have at least one Epic. This is an accepted GitHub limitation.

Do not add `phase` to this filter. That duplicates Phase issues into the view and creates a `No Parent issue` group.

Do not create a separate `Phase Overview` view by default. It is redundant with `Epic Roadmap`.

## Workflows

1. Auto-add open issues matching any of the hierarchy labels. Example: `is:issue is:open label:"phase","epic","ready-for-agent","ready-for-human"`.
2. Item added sets Status to `Todo`.
3. Item closed sets Status to `Done`.
4. Item reopened sets Status to `Todo`.
5. Movement to `In Progress` is manual.
6. Keep native `Auto-add sub-issues to project` enabled.

Native workflows do not establish hierarchy. Apply the correct label, attach the issue to its native parent, and confirm that it was added to the Project. Exclude `spec` from auto-add.

## Repository agent contract

Reconcile `docs/agents/github-project.md` from the bundled template and add one concise pointer in the root `AGENTS.md`. Preserve unrelated repository instructions.

The repository document overrides generic skill defaults for this repository:

- `to-spec` publishes a separate issue with `spec`, no readiness label, no native parent, and no Project membership; it links the issue from the Epic's `Specification` section.
- `to-tickets` publishes implementation issues from the specification, references that specification, attaches each issue natively to the Epic, applies exactly one readiness label, and confirms Project membership.
- Publishing tickets preserves the Epic's state and authored content except for narrowly adding necessary links.

## Tool boundaries

Apply this escalation ladder separately to every operation:

1. Direct `gh` command.
2. `gh api graphql` using a documented public mutation.
3. `gh api` using a documented REST endpoint.
4. Authenticated browser control only for a setting with no documented public write interface.

Use `gh project create|link|view|field-create|field-list|item-add|item-list|item-edit|edit`, `gh issue create|view|list|edit|close`, and `gh api` for supported operations. The lack of a dedicated CLI subcommand is not evidence that no API exists.

### Browser-free coverage

- Create and link the Project with `gh project create` and `gh project link`.
- Set title, description, README, and visibility with `gh project edit`.
- Create fields with `gh project field-create`; use GraphQL `updateProjectV2Field` when the existing Status options must be reconciled.
- Add issues with `gh project item-add` and set Status with `gh project item-edit`.
- Create or change native hierarchy with `gh issue create --parent`, `gh issue edit` hierarchy flags, or the REST sub-issues endpoints supported by the installed CLI/API version.
- Create saved views through `gh api` and the documented Project views REST endpoint. Supply `X-GitHub-Api-Version: 2026-03-10`. At creation, set the view name, layout, filter, and supported visible field IDs through the API.

### Browser-only remainder

Use browser control only for documented gaps such as:

- configuring or enabling built-in workflows, including repository-specific auto-add;
- view grouping, vertical grouping, sorting, slice-by, hierarchy display, board-card controls, or other presentation settings absent from the public view-creation request schema;
- changing a saved view setting when the public API exposes creation/read but no corresponding update operation.

Before browser use, state the exact remaining setting and the missing CLI/API operation. Do not repeat browser work for settings already completed through CLI or API.

Creating a native sub-issue requires the child's numeric database ID:

```powershell
$childId = [int64](gh api "repos/OWNER/REPO/issues/CHILD" --jq '.id')
gh api --method POST "repos/OWNER/REPO/issues/PARENT/sub_issues" -F sub_issue_id=$childId
```

When browser control remains necessary, save views explicitly and confirm that any unsaved indicator disappears.

## Final verification checklist

- Project is linked to the approved repository and owner.
- Required labels `phase`, `epic`, `spec`, `ready-for-agent`, and `ready-for-human` exist exactly once.
- Current Work has three status columns, no grouping by Epic or Parent issue, and no swimlanes.
- Current Work contains only readiness-labelled tickets and zero epics.
- Current Work excludes Phase issues.
- Every ticket visibly has one parent Epic and one readiness label.
- Every Epic visibly has label `epic` and one parent Phase issue.
- Epic Roadmap contains only epics and groups by Parent issue.
- Epic Roadmap does not include `phase` in the filter and therefore does not create duplicate Phase rows or a `No Parent issue` bucket from Phase issues.
- Every specification has `spec`, has no readiness label or native parent, and is excluded from the Project.
- Auto-add includes `phase`, `epic`, `ready-for-agent`, and `ready-for-human`.
- Auto-add sub-issues to project is enabled.
- Closed and reopened workflows use the intended statuses.
- No duplicate or unexpected artifacts were created.
- Closed-parent/open-child and ambiguous-parent cases are reported.
- `docs/agents/github-project.md` exists and the root `AGENTS.md` points to it once.
