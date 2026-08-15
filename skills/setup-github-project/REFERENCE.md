# GitHub Project operating model

## Desired state

A GitHub milestone represents a development phase. A **Ticket** is a GitHub issue classified by the BB contract, assigned to exactly one canonical milestone, and included in the Project. A **Task** is classified by the BB contract and attached as a native sub-issue of exactly one Ticket. Tasks omit milestones and Project membership; their native relationship supplies sub-issue progress on Ticket cards.

The only native issue hierarchy is `Ticket -> Task`. A lightweight Ticket is enriched in place by `ticket-to-spec`, retaining its identity, classification, milestone, state, relationships, and Project membership. Standalone specification issues are a legacy structure.

## Ownership

`docs/agents/bb-skills.md` is the source of truth for Ticket, Task, executor, needs-details, release, parent-child, and blocking mappings. Reuse it when complete and compatible. Coordinate `$setup-bb-skills` through its own approval gate when it is missing or incompatible.

`docs/agents/github-project.md` is the source of truth for milestones, Project membership, views, Status behavior, and Project workflows. `setup-github-project` owns this contract and its repository-instruction pointer.

## Canonical milestones

Every configured repository has these exact milestones:

1. `Phase 1: Prototype`
2. `Phase 2: Vertical Slice`
3. `Phase 3: Alpha`
4. `Phase 4: Beta`
5. `Phase 5: Release`

Process them strictly in that order. For each milestone: inspect, create or reuse, read back, and validate its repository, exact title, state, and identity. Proceed only after validation. Stop on the first failure. Never reconcile milestones concurrently.

Reuse exact matches without changing their open or closed state. Create missing matches as open without invented descriptions or due dates. Treat unnumbered and alternate counterparts as ambiguous legacy configuration; pause before creating a duplicate and require an exact approved migration to rename, merge, close, reopen, or delete anything.

## Project

- Visibility: Private.
- Title: repository name.
- Repository linkage: exactly the approved repository.
- Membership: every open and closed Ticket; no Tasks or unrelated issues.
- Custom fields: none.
- Status options: `Todo`, `In Progress`, `Done`.

Reuse a compatible Project. Create a private repository-linked Project only when none exists. Project-item removal changes only membership, never the issue itself, and requires exact approval.

## Tickets view

- Name: `Tickets`.
- Layout: Board.
- Filter: `label:"ticket"`.
- Column by: Status.
- Slice by: Milestone.
- Swimlanes: none.
- Sort: manual.
- Field sum: count.
- Card fields: Title, Assignees, Labels, and Sub-issues progress.

Keep exactly one saved view. Prefer reconciling the default view rather than creating another. Report extra views and propose exact deletion only when supported and approved.

## Workflows

1. Auto-add open issues matching `label:"ticket"`.
2. Item added sets Status to `Todo`.
3. Item closed sets Status to `Done`.
4. Item reopened sets Status to `Todo`.
5. Movement to `In Progress` remains manual.
6. Disable native auto-add-sub-issues so Tasks stay outside the Project.

Workflows do not repair historical membership. Add every existing open and closed Ticket during reconciliation and verify each item.

## Repository bootstrap

Reuse an accessible GitHub repository. When none exists, propose `<sole-active-account>/<local-repository-name>` as private. Ask the executor to select an owner when multiple authenticated accounts are detected. Present repository creation and remote configuration in the approval proposal. Do not commit or push.

## Legacy and conflicts

Detect and report:

- labels `phase`, `epic`, `spec`, and `Feature Ticket`;
- Phase, Epic, Feature Ticket, and standalone specification issue structures;
- unnumbered or alternate milestone schemes;
- custom Phase, Epic, Work Type, hierarchy, estimate, date, WIP, or concurrency fields;
- additional Project views;
- Task or unrelated Project membership; and
- missing or contradictory repository contracts.

Legacy detection is not migration authority. Preserve existing artifacts until the executor approves exact changes.

## Tool boundaries

Use a dedicated `gh` command, then documented GraphQL, then documented REST. Use authenticated browser control only for a setting without a public write operation. Announce the browser-only setting and API gap first. Read back every mutation.

## Verification contract

Verification returns structured `Conforms`, `Errors`, `Warnings`, `LegacyConflicts`, `ProposedMutations`, and `ManualChecks` values. Desired-state errors produce a nonzero exit.

Confirm:

- the private repository and private linked Project match the approved owner and target;
- the BB contract is complete and its confirmed labels exist;
- all five exact canonical milestones exist;
- every Ticket has exactly one canonical milestone and belongs to the Project;
- no Task or unrelated issue belongs to the Project;
- exactly one `Tickets` view has the required board, filter, Status column, Milestone slice, and presentation;
- Status contains only `Todo`, `In Progress`, and `Done`;
- workflows match the Ticket-only contract and auto-add-sub-issues is disabled;
- forbidden custom fields are absent;
- both contracts and instruction pointers exist exactly once; and
- a second discovery run proposes no mutations.
