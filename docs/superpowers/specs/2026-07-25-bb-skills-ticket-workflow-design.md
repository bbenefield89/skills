# BB Skills Ticket Workflow Design

**Date:** 2026-07-25
**Status:** Approved in brainstorming

## Purpose

Create a reusable, tracker-configurable planning workflow built around small outcome tickets and executable child tasks. The workflow replaces the Phase/Epic model and removes the need to repeatedly override generic `to-spec` and `to-tickets` behavior.

The common personal workflow is:

`create-ticket` → `grill-with-docs` → `ticket-to-spec` → `spec-to-tasks`

The skills must also work in repositories that use trackers other than GitHub, including Jira, by reading a repository-local tracker contract instead of hardcoding platform mechanics.

## Design Principles

- Use the tracker's configured native concepts when available.
- Ask rather than assume tracker vocabulary or hierarchy.
- Keep initial tickets quick to create and easy to scan.
- Preserve proven behavior by forking the existing `to-spec` and `to-tickets` skills.
- Make every generated task durable enough for agent replacement or safe parallel work.
- Require explicit approval before repository or tracker setup writes.
- Keep domain modeling owned by `grill-with-docs`; setup does not duplicate it.
- Do not install workflow tutorials or delivery lifecycle policy into target repositories.

## Artifact Model

The repository contract maps these conceptual roles to the selected tracker's labels, issue types, fields, or relationships:

- **Release grouping:** the release or milestone containing an outcome.
- **Ticket:** a deliverable outcome that will later hold its specification.
- **Task:** an implementation step belonging to a ticket.
- **Executor:** the agent or human responsible for a task.
- **Needs details:** the state applied to a newly created ticket before its specification is appended.
- **Parent-child relationship:** the tracker relationship between a ticket and its tasks.
- **Blocking relationship:** the tracker relationship that controls task ordering.

The preferred GitHub defaults are:

| Concept | Default GitHub representation |
| --- | --- |
| Release grouping | Native GitHub Milestone |
| Ticket | Issue labeled `ticket` |
| Task | Native child issue labeled `task` |
| Executor | Exactly one of `agent` or `human` |
| Needs details | Label `needs-details` |
| Ordering constraint | Native issue dependency |

Only the parent ticket receives the Milestone by default. Tasks inherit release context through their parent.

## Skill Architecture

### `setup-bb-skills`

`setup-bb-skills` is the reusable, non-Godot bootstrap for the publishing skills.

It must:

1. Inspect the repository and any existing tracker configuration read-only.
2. Ask the user to confirm:
   - the tracker;
   - ticket and task classifications;
   - agent and human executor classifications;
   - the needs-details state;
   - release grouping;
   - parent-child relationships;
   - blocking relationships.
3. Present every proposed local write and external tracker mutation.
4. Wait for explicit approval before making any change.
5. Repeat the approval gate if a material choice changes.
6. Reconcile the approved tracker configuration using the capabilities and tools available to the agent.
7. Write the confirmed mapping to `docs/agents/bb-skills.md`.
8. Add one concise pointer to that contract in the repository's existing `AGENTS.md` or `CLAUDE.md`.
9. Verify the resulting repository and tracker configuration.

The skill defines desired outcomes and safeguards, not tracker-specific operating manuals. Agents are expected to discover and use the selected tracker's available capabilities.

It must not:

- install domain-document conventions;
- document the publishing-skill pipeline in the target repository;
- install PR, task-ordering, or issue-closure policy;
- silently create, rename, delete, or reinterpret tracker configuration.

### `create-ticket`

`create-ticket` creates the lightweight placeholder that begins the workflow.

It must:

- read the repository tracker contract;
- produce a concrete, plain-language title without corporate phrasing;
- produce a TL;DR of no more than two sentences;
- apply the configured ticket classification;
- apply the configured needs-details state;
- use an explicitly supplied release grouping without asking again;
- otherwise infer the likely release grouping and ask for confirmation;
- preview the complete proposed ticket before creating it;
- create no specification and no tasks.

Its content shape is:

```markdown
# <Plain-language title>

## TL;DR

<One or two sentences describing what needs to be done and why.>
```

The heading represents the tracker title; the issue body begins with `## TL;DR`.

### `ticket-to-spec`

`ticket-to-spec` is a personalized fork of the existing `to-spec` skill.

It retains the existing skill's:

- conversation synthesis;
- repository and domain-context exploration;
- specification content and template;
- testing-seam check.

It changes publication behavior:

- append the specification to the original ticket;
- do not create a separate specification issue;
- preserve the ticket title, TL;DR, discussion, release grouping, and unrelated metadata;
- remove the configured needs-details state only after the specification is successfully appended;
- do not apply an executor, task, or legacy readiness classification to the parent ticket.

Spec rerun and replacement behavior is intentionally unspecified.

### `spec-to-tasks`

`spec-to-tasks` is a personalized fork of the existing `to-tickets` skill.

It retains the existing skill's:

- tracer-bullet decomposition;
- prefactoring and expand-contract guidance;
- task-breakdown approval loop;
- dependency-graph reasoning;
- publication in dependency order;
- task content and acceptance-criteria behavior.

It changes and strengthens publication behavior:

- publish implementation work as tasks under the source ticket;
- make every task self-contained enough for a replacement agent or safe parallel execution;
- include sufficient parent context, current-plan position, dependencies, and downstream relevance;
- apply the configured task classification;
- apply exactly one configured executor classification;
- replace the source skill's legacy readiness-label default with the configured executor classification;
- create native parent-child relationships when supported;
- create native blocking relationships when supported;
- retain readable blocker references in task content as a fallback;
- verify classifications and relationships after publication;
- stop and report partial publication rather than continuing through an inconsistent graph.

### `setup-godot-project`

`setup-godot-project` remains focused on Godot infrastructure.

It must:

- stop invoking `setup-matt-pocock-skills`;
- remove its separate optional planning-label setup;
- offer `setup-bb-skills` as the optional tracker integration;
- allow core Godot setup to continue when tracker setup is declined or unavailable.

### Superseded Setup Skills

The new workflow supersedes `setup-matt-pocock-skills` and the Phase/Epic-oriented `setup-github-project`.

The new skills must not reference either setup skill. `setup-godot-project` must remove its existing `setup-matt-pocock-skills` integration. The superseded skill directories may remain as legacy artifacts unless their removal is separately approved during implementation.

## Data Flow

1. `setup-bb-skills` records the confirmed tracker mapping.
2. `create-ticket` creates the ticket title and TL;DR, applies ticket and needs-details classifications, and assigns the confirmed release grouping.
3. `grill-with-docs` sharpens the idea and manages domain documentation independently.
4. `ticket-to-spec` appends the synthesized specification to the same ticket and removes needs-details.
5. `spec-to-tasks` drafts a dependency graph and asks for approval.
6. After approval, `spec-to-tasks` publishes self-contained tasks in dependency order, classifies them, attaches them to the ticket, and creates blocking relationships.
7. Downstream implementation normally uses one branch and one pull request for the parent ticket. A single agent usually works through tasks serially, but task content and dependencies must permit agent replacement or safe parallel work.
8. Tasks are closed only when the user directs the implementing agent. Merging the delivery pull request closes the parent ticket.

The setup contract does not install the downstream delivery and closure behavior as repository policy.

## Safety and Failure Handling

- All skills identify the repository, tracker, and target artifact before mutation.
- `setup-bb-skills` performs read-only discovery before requesting approval.
- Setup approval covers only the exact configuration presented.
- Missing or ambiguous configuration stops publishing and directs the user to `setup-bb-skills`.
- Unsupported native relationships are reported. A text fallback requires confirmation.
- Existing tracker configuration is preserved unless its change is explicitly approved.
- Partial publication reports exactly what was created, classified, linked, or left incomplete.
- Setup and task-publication reruns inspect existing artifacts and avoid duplicates. Specification rerun behavior remains intentionally unspecified.
- Publishing skills do not close tasks, tickets, or pull requests.
- `ticket-to-spec` and `spec-to-tasks` retain the approval gates inherited from their source skills.

## Verification Strategy

Verify observable workflow behavior rather than internal instruction wording.

### `setup-bb-skills`

- A new repository produces a complete proposal without writing before approval.
- Existing compatible configuration is reused.
- Conflicts are surfaced instead of overwritten.
- Tracker concepts are configurable rather than hardcoded.
- The written contract matches the approved configuration.
- A second run is idempotent.

### `create-ticket`

- The title is plain and legible.
- The TL;DR is no more than two sentences.
- Explicit release input is honored.
- Inferred release input is confirmed.
- Ticket and needs-details classifications are applied.
- No specification or tasks are created.

### `ticket-to-spec`

- Existing `to-spec` behavior is retained.
- The original ticket is updated instead of creating another issue.
- Existing ticket metadata and the TL;DR are preserved.
- Needs-details is removed only after a successful append.

### `spec-to-tasks`

- Existing `to-tickets` drafting and approval behavior is retained.
- Tasks are self-contained.
- Tasks are attached to the correct parent.
- Task and executor classifications are correct.
- Native blocking relationships match the approved dependency graph.
- Partial-failure recovery does not duplicate tasks.

### `setup-godot-project`

- No `setup-matt-pocock-skills` integration remains.
- No competing planning-label setup remains.
- `setup-bb-skills` is offered as an optional independent step.
- Core Godot setup still works when tracker setup is skipped.

Static skill-structure checks should be combined with dry-run scenarios and read-only tracker inspection. External mutation tests require an explicitly approved test repository or sandbox tracker project.

## Out of Scope

- Creating an implementation or delivery skill.
- Automatically closing tasks.
- Automatically merging or closing pull requests.
- Defining tracker-specific command recipes.
- Installing domain-document conventions.
- Writing a workflow tutorial into target repositories.
- Defining spec rerun replacement behavior.
- Removing superseded skill directories without separate approval.
