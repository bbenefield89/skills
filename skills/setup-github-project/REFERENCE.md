# GitHub Project operating model

## Desired state

A GitHub milestone represents a development phase. A **Ticket** is a GitHub issue classified by the BB contract, assigned to exactly one canonical milestone, and included in the Project. A **Task** is classified by the BB contract and attached as a native sub-issue of exactly one Ticket. Tasks omit milestones and Project membership; their native relationship supplies sub-issue progress on Ticket cards.

The only native issue hierarchy is `Ticket -> Task`. A lightweight Ticket is enriched in place by `ticket-to-tasks`, retaining its identity, classification, milestone, state, relationships, and Project membership. Standalone specification issues are a legacy structure.

## Ownership

The Tracker contract in `docs/process/tickets.md` is the source of truth for Ticket, Task, executor, needs-details, release, parent-child, and blocking mappings. `$setup-bb-skills` owns it. Reuse it when complete and compatible. Coordinate `$setup-bb-skills` through its own approval gate when it is missing or incompatible.

`docs/process/project-board.md` is the source of truth for milestones, Project membership, views, Status behavior, and Project workflows. `docs/process/git.md` holds the branch, commit, pull request, and merge rules. `setup-github-project` owns the skill-owned block of each document and its `AGENTS.md` index row.

## Canonical milestones

Every configured repository has these exact milestones:

1. `Phase 1: Prototype`
2. `Phase 2: Vertical Slice`
3. `Phase 3: Alpha`
4. `Phase 4: Beta`
5. `Phase 5: Release`

Process them strictly in that order. For each milestone: inspect, create or reuse, read back, and validate its repository, exact title, state, and identity. Proceed only after validation. Stop on the first failure. Never reconcile milestones concurrently.

Reuse exact matches without changing their open or closed state. Create missing matches as open with their approved phase description and without due dates. Treat unnumbered and alternate counterparts as ambiguous legacy configuration; pause before creating a duplicate and require an exact approved migration to rename, merge, close, reopen, or delete anything.

## Phase descriptions

The description of each canonical milestone is the definition of its phase. Other skills read these descriptions from GitHub to select the milestone for a Ticket. [templates/milestones/](templates/milestones/) holds one base description for each phase in game-development terms.

A conforming description has these four parts in this order:

1. `**What this phase represents:**` gives the definition of the phase.
2. `**Work that belongs here**` lists examples of work in the phase.
3. `**Work that does not belong here**` lists examples of work for a different phase.
4. `**Exit condition:**` gives the condition that ends the phase.

Studios put the Alpha and Beta lines in different places. The base descriptions end Alpha at feature complete and end Beta at content complete.

Prepare the descriptions before the approval proposal:

1. Copy `templates/milestones/` to a temporary directory. The files `phase-1.md` to `phase-5.md` map to the canonical milestones in order.
2. Skip each milestone that has a conforming description on GitHub. The script reuses that description.
3. For each other milestone, tailor the two work lists in its file:
   - Replace a base example with a project example only when repository evidence supports the example. Evidence is a domain term from `GLOSSARY.md`, a planning document, or a Ticket in that milestone.
   - Keep the base example when the repository has no evidence.
   - Keep the definition, the exit condition, and each line about code structure work.
4. If a milestone has description text without the four parts, add that text unchanged after the exit condition. Put the text under `**Scope for <project name>:**`.
5. In the approval proposal, show the full text of each description that the script will set. State that the examples show the type of work and are not commitments.

`scripts/reconcile-milestones.ps1 -DescriptionsPath DIRECTORY` applies the approved directory. For each milestone, the script does one of these operations:

- `Create`: The milestone is missing. The script creates the milestone with its description.
- `Describe`: The milestone has no conforming description. The script sets the description and keeps the open or closed state.
- `Reuse`: The milestone has a conforming description. The script writes nothing.

The script stops before a write when an approved description does not contain the existing description text. A change to a conforming description requires an exact approved edit.

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

## Repository documents

Write each document from its template. The repository owns all text outside the block, including its project rules. Never change that text.

| Template | Target path | Block key | Values to fill | AGENTS row: Before you… |
|---|---|---|---|---|
| [templates/project-board.md](templates/project-board.md) | `docs/process/project-board.md` | `project-board` | Project title, number, owner, URL, repository, and the Ticket value | create or change a ticket |
| [templates/git.md](templates/git.md) | `docs/process/git.md` | `git` | The branch prefix | create a branch, commit, or pull request |

Ask the executor for the branch prefix, such as `SP` for branches named `SP-147`. Propose a prefix from existing branch names when they show one.

Each block starts with `<!-- setup-github-project:<key>:start;version=<N> -->` and ends with `<!-- setup-github-project:<key>:end -->`. Compare only the block with the template filled with the approved values. Ignore line-ending differences.

- **Missing:** the file does not exist. Propose to write the whole template file with the values.
- **Current:** the block version and the filled block match. No-op.
- **Outdated:** the block version is lower than the template version, or an approved value changed. Show the difference, and propose to replace the block.
- **Edited block:** the version matches, but the text does not. Show the difference. Ask whether to move each edit to `## Project rules` as a P rule, or to discard it. Then replace the block.
- **No block:** the file exists without markers, or with duplicate or malformed markers. Show the file, and ask how to proceed.

To change a rule, edit only the template, and raise the version in its start marker by one in the same change.

### AGENTS.md index rows

Add a row to the `## Before you…` table in `AGENTS.md` for each document, with the target path in backticks in the Read column, when no row names that path. When a row for the same action exists, such as the `docs/process/tickets.md` row for tickets, add the path to that row. When `AGENTS.md` does not exist or has no such table, run `$setup-agents-md` first. It creates `AGENTS.md` as an index, and `CLAUDE.md`.

Preserve all other `AGENTS.md` content.

### Legacy contract

Earlier releases wrote `docs/agents/github-project.md` from [templates/legacy/github-project.md](templates/legacy/github-project.md), with a pointer in `AGENTS.md` or `CLAUDE.md`. When the file matches that template, propose to delete it and its pointer in the same change that writes `docs/process/project-board.md`. Other text in the file is project guidance: ask whether to add it as a P rule or to discard it. Remove `docs/agents/` only when it becomes empty.

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
- all five exact canonical milestones exist and each has a conforming phase description;
- every Ticket has exactly one canonical milestone and belongs to the Project;
- no Task or unrelated issue belongs to the Project;
- exactly one `Tickets` view has the required board, filter, Status column, Milestone slice, and presentation;
- Status contains only `Todo`, `In Progress`, and `Done`;
- workflows match the Ticket-only contract and auto-add-sub-issues is disabled;
- forbidden custom fields are absent;
- the tracker contract, `docs/process/project-board.md`, and `docs/process/git.md` exist, and `AGENTS.md` names each one in exactly one row; and
- a second discovery run proposes no mutations.
