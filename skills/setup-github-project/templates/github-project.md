# GitHub Project workflow

This repository uses a private repository-linked GitHub Project for release-level Ticket tracking. Tracker classifications and Ticket-to-Task publishing mappings are defined separately in `docs/agents/bb-skills.md`.

## Release milestones

Tickets use exactly one of these GitHub milestones:

1. `Phase 1: Prototype`
2. `Phase 2: Vertical Slice`
3. `Phase 3: Alpha`
4. `Phase 4: Beta`
5. `Phase 5: Release`

Tasks omit milestones because their parent Ticket carries release grouping.

## Project membership

- Every open and closed Ticket belongs to the Project.
- Tasks and unrelated issues stay outside the Project.
- Native Ticket-to-Task sub-issues provide progress on Ticket cards.
- Expanding a Ticket into a specification preserves the same issue, milestone, state, relationships, and Project membership.

## Tickets board

The Project has one saved view named `Tickets`:

- Board filtered to `label:"ticket"`.
- Columns use Status: `Todo`, `In Progress`, and `Done`.
- Slice by Milestone.
- No swimlanes.
- Manual sort and Count field sum.
- Cards show Title, Assignees, Labels, and Sub-issues progress.

## Workflows

- Open Tickets are automatically added and enter `Todo`.
- Closed Tickets move to `Done`.
- Reopened Tickets return to `Todo`.
- Movement to `In Progress` is manual.
- Auto-add-sub-issues is disabled so Tasks remain outside the Project.
