---
name: setup-github-project
description: Creates or reconciles a private GitHub repository and repository-linked GitHub Projects V2 Ticket board, including canonical milestones, Ticket-only membership, Status workflows, BB tracker-contract coordination, and repository guidance. Use when a repository needs its GitHub planning infrastructure created, connected, repaired, or standardized.
---

# Set Up a GitHub Project

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Create or reconcile the approved GitHub planning infrastructure using [REFERENCE.md](REFERENCE.md). Read the reference completely before discovery.

## Non-negotiable approval gate

Before every local or GitHub write:

1. Read repository instructions, planning documents, and existing `docs/agents/` contracts.
2. Run `scripts/preflight.ps1`, then inspect the repository and GitHub read-only.
3. Present the exact repository, remote, BB coordination, labels, milestones, Project, membership, views, workflows, and local files to create, reuse, change, or leave unresolved.
4. Identify every inferred, missing, conflicting, legacy, and browser-only value.
5. Wait for explicit approval from the human executor.

Approval covers only the proposal shown. Repeat discovery and approval when a material target, setting, or recovery action changes. Never create a repository, remote, milestone, Project, Project item, workflow, or local file before approval.

## Preflight and repository bootstrap

Run `scripts/preflight.ps1` before inspection or mutation. Treat a failed prerequisite as a gate, except that a missing GitHub remote or remote repository is a proposed bootstrap action:

- Require a local Git worktree, GitHub CLI 2.94.0 or newer, and authenticated GitHub access.
- Reuse an accessible GitHub repository resolved from the remote or explicit `OWNER/REPO`.
- When no GitHub repository exists, propose a private repository named after the local repository under the sole active GitHub account.
- When multiple authenticated accounts are detected, ask the executor to select the owner.
- After approval, create and read back the private repository, then add the approved remote if missing.
- Repository bootstrap does not authorize a commit or push.

If preflight reports any other missing prerequisite, report every entry in `Missing` with its matching `Guidance`, stop, and rerun preflight after correction.

## BB contract gate

Inspect `docs/agents/bb-skills.md` and its repository-instruction pointer. Reuse a complete compatible contract.

When the contract is absent, incomplete, contradictory, or inconsistent with GitHub, coordinate `$setup-bb-skills` through its independent discovery and approval gate. Resume Project setup only after BB verification succeeds. The BB contract owns Ticket, Task, executor, needs-details, release grouping, Task release behavior, parent-child, and blocking mappings; never duplicate those mappings in the Project contract.

## Discovery

Run `scripts/inspect.ps1 -Repository OWNER/REPO` only after preflight permits GitHub inspection. Inspect, without mutation:

- repository ownership, visibility, remotes, and linked Projects;
- BB-owned labels and conflicting or legacy labels;
- canonical and ambiguous milestones;
- every Ticket, its milestone, state, and Project membership;
- Task and unrelated Project membership;
- Project visibility, repository linkage, fields, Status options, saved views, and workflows;
- both repository contracts and their instruction pointers.

Reuse an existing compatible private Project. Create one only when none exists. Never create Tickets or Tasks.

## Approved execution

After exact approval, execute in this order:

1. Create and validate the private GitHub repository and remote when missing.
2. Run `scripts/reconcile-milestones.ps1 -Repository OWNER/REPO`; it must validate each canonical milestone before proceeding to the next.
3. Create or reuse the private Project named after the repository and link it.
4. Reconcile Status to `Todo`, `In Progress`, and `Done`.
5. Reconcile the single `Tickets` board defined in [REFERENCE.md](REFERENCE.md).
6. Add every open and closed Ticket to the Project and verify each membership.
7. Remove approved non-Ticket Project memberships without changing the underlying issues.
8. Configure Ticket-only workflows and keep auto-add-sub-issues disabled.
9. Reconcile `docs/agents/github-project.md` from [templates/github-project.md](templates/github-project.md).
10. Add its pointer to the repository instruction file exactly once.
11. Run verification, then rerun discovery and require zero proposed mutations.

Apply this operation ladder separately to each GitHub setting:

1. Dedicated `gh` command.
2. Documented public GraphQL mutation.
3. Documented public REST endpoint.
4. Authenticated browser control only when the exact setting has no public write interface.

Before browser use, name the remaining setting and the absent CLI/API capability. Prefer converting the default Project view into `Tickets` instead of creating a second view.

## Safety and recovery

- Inspect immediately before every write.
- Stop after the first failed mutation or read-back validation.
- Report completed work, the failed operation, and the untouched remainder.
- Preserve successful objects for an idempotent retry; never perform destructive rollback.
- Require renewed approval when recovery changes the proposal.
- Report legacy configuration without silently renaming, deleting, closing, reopening, reparenting, or reinterpreting it.
- Never expose tokens or credentials.

## Verification

Run `scripts/verify.ps1 -Repository OWNER/REPO -Owner OWNER -ProjectNumber N`. A conforming result has `Conforms: true`, no `Errors`, and no `ProposedMutations`. Complete any reported `ManualChecks`, then run a second dry-run. Summarize created, reused, changed, skipped, legacy, and unresolved items.
