---
name: setup-github-project
description: Creates or reconciles a lightweight GitHub Projects V2 planning system linked to a repository, with epic, specification, and implementation-ticket conventions. Use when the user asks to set up, configure, connect, or standardize a GitHub Project for a repository or planning document.
---

# Set Up a GitHub Project

Create a repository-linked GitHub Project using the operating model in [REFERENCE.md](REFERENCE.md).

## Non-negotiable approval gate

Before any local or GitHub write:

1. Read repository instructions, planning documents, issue-tracker conventions, and label documentation.
2. Inspect the repository, authentication, labels, existing issues, and existing Projects read-only.
3. Present every resolved default and exact write target to the user.
4. Identify inferred, absent, or conflicting values.
5. Wait for explicit approval or requested changes.

Approval applies only to the presented configuration. Repeat the gate if a material choice changes. Do not create a Project, link a repository, create issues, or write repository files before approval.

## Discovery

Resolve, without inventing:

- Repository from the current workspace's Git remote.
- Project owner from the repository owner; ask if ownership is ambiguous.
- Project title from the repository name.
- Phases and epics from the GDD, product plan, roadmap, or equivalent.
- Canonical readiness labels from repository documentation.
- Existing specs, epics, tickets, Projects, fields, and duplicates.

Default to a private GitHub Projects V2 Project linked to one repository. Reuse an existing matching Project only after approval.

Run `scripts/inspect.ps1 -Repository OWNER/REPO` for a read-only inventory when PowerShell and `gh` are available.

## Approved execution

After approval:

1. Create or reuse and link the Project.
2. Keep Status options `Todo`, `In Progress`, and `Done`.
3. Create single-select `Phase` from source material and `Work Type` with `Epic` and `Ticket`.
4. Create only source-supported epic issues; search for duplicates first.
5. Add epics and implementation tickets to the Project; exclude specification issues.
6. Set Phase, Work Type, Status, and exactly one native parent epic for every ticket.
7. Link each specification from its epic's `Specification` section, not as a sub-issue.
8. Configure the views and workflows in [REFERENCE.md](REFERENCE.md).
9. Add the operating contract using [templates/project-readme.md](templates/project-readme.md).
10. Verify the finished system and report inconsistencies.

Prefer `gh` for data and bulk changes. Use authenticated browser control only for view and workflow settings unavailable through `gh`. Announce browser use and avoid the tab the user is actively operating.

## Safety and reconciliation

- Never expose tokens or credentials.
- Never invent phases, epics, dates, estimates, or parent relationships.
- Never silently close, reopen, split, reparent, or rewrite issues for tidiness.
- Prefer splitting cross-epic tickets; dominant-parent assignment requires user direction.
- Report closed-parent/open-child inconsistencies without resolving them automatically.
- Make every operation idempotent by inspecting before creating or updating.

## Verification

Run `scripts/verify.ps1 -Repository OWNER/REPO -Owner OWNER -ProjectNumber N` for a read-only structural report, then complete the UI checks in [REFERENCE.md](REFERENCE.md). Summarize created, reused, changed, skipped, and unresolved items.

