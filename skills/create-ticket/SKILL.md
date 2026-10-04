---
name: create-ticket
description: Creates a lightweight tracker ticket with a plain-language title, a short TL;DR, configured classifications, relevant labels, release grouping, project position, and ticket dependencies. Use when an idea needs an initial ticket before grilling or specification.
disable-model-invocation: true
---

# Create Ticket

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Create the lightweight ticket that starts the workflow. Set its release grouping and project position, and reconcile relevant ticket dependencies.

## Preconditions

Read `docs/agents/bb-skills.md`. If it is absent, incomplete, or contradicts the tracker, stop and direct the user to `$setup-bb-skills`.

Resolve the tracker target from the contract and current repository. If the target is ambiguous, ask before continuing.

For GitHub Issues, also read `docs/agents/github-project.md` for milestone, Project, Status, and ordering rules.

## Draft

Use the conversation and repository vocabulary to write:

- a concrete, easy-to-scan title with no corporate phrasing;
- a TL;DR of one or two sentences describing what needs to be done and why.

The body is exactly:

```markdown
## TL;DR

<One or two sentences.>
```

Search for an existing equivalent ticket before proposing a new one. Ask whether to reuse a plausible duplicate.

## Classifications and release

Apply the configured ticket classification and needs-details state.

Inspect available labels and their descriptions in the target repository.
Select existing labels that match the ticket's purpose and affected area.
Examples include `bug`, `enhancement`, `documentation`, and component labels when those labels exist and fit.
Use exact repository label names and meanings, including relevant user-requested labels.
Retain required classification and needs-details labels. If no additional label fits, use only the required labels.
Report any unavailable user-requested labels in the preview.

For GitHub Issues, release grouping means the milestone that represents the development phase.

If the user supplied a release grouping, use it without a separate selection question. Otherwise inspect available release groupings, infer the best fit from context, and ask the user to confirm it. If no fit is defensible, ask the user to choose. Omit release grouping only when the contract says it is not used.

Do not create missing classifications, labels, or release groupings. Direct configuration problems to `$setup-bb-skills`.

## Ticket dependencies

Read every existing ticket in the selected release grouping whose Project Status is not `Done`, including `In Progress` tickets.
Inspect each ticket's scope, available acceptance criteria, and current blocking relationships.
Identify prerequisites for the new ticket, existing tickets that require the new ticket, and existing relationships affected by its scope.

Use the contract's configured blocking mechanism. For GitHub Issues, use native `blocked by` / `blocking` relationships.
Keep Project Status separate from dependencies. Preserve existing Project Status values.

Propose additions for missing prerequisites and removals or replacements for dependencies that the new context shows are obsolete.
Limit changes to the new ticket and reviewed unfinished tickets in its release grouping.
Preserve valid and unrelated relationships, including dependencies outside that release grouping. Keep the resulting dependency graph acyclic.

Treat a blocker as work that must finish before the dependent ticket can proceed.
An earlier TODO position alone does not establish a dependency. Creating a new ticket does not complete a prerequisite.
A ticket remains blocked while any unfinished prerequisite remains.

## Project position

Inspect the existing tickets in the project's TODO column within the selected release grouping.
If the user specified where the new ticket belongs, use that position.
Otherwise infer its position from the reviewed dependencies and intended work order.

## Approval and creation

Preview:

- tracker target;
- title and complete body;
- ticket classification;
- needs-details state;
- complete label set and the reason for each additional label;
- release grouping;
- intended position in the project's TODO column;
- every proposed blocker addition, removal, or replacement, with affected ticket identifiers, dependency direction, and a reason.

Wait for explicit approval of the ticket and all proposed dependency changes in the same preview.
Then:

1. Create the ticket with the approved classifications, labels, and release grouping.
2. Ensure the ticket belongs to the configured project and its TODO column.
3. Move the ticket to the approved position.
4. Apply the approved blocker additions, removals, and replacements.
5. Read back each affected ticket's native relationships and remaining unfinished blockers, plus the new ticket's neighboring TODO tickets.
6. Read back the ticket's labels and verify every confirmed value. Report each ticket's resulting blocking state.

Create no specification or child tasks. On a partial failure, do not delete the ticket; report what succeeded and what remains.
