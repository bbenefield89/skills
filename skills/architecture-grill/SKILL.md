---
name: architecture-grill
description: Grill architectural ownership and subsystem boundaries for established behavior before specification or task generation, and record the decisions as they settle. Use after behavioral discovery when responsibilities, state ownership, authority, dependencies, or public interfaces need decisions. Excludes line-by-line implementation design.
---

# Architecture Grill

Run a `/grilling` session with `/domain-modeling`, as `/grill-with-docs` does.
Those skills own the interview: the design tree, rounds, question format, recommended answers, fact-finding, and the documents written inline.
This skill sets the architectural lens: which decisions go on the tree, where the documents go, and what the session hands to the next step.

The session sits after behavioral discovery and before `ticket-to-tasks`.
Deliver keeps authority over local implementation details inside the agreed boundaries.

## Shared writing standard

Before you write prose, read and apply [asd-ste100](../asd-ste100/SKILL.md) and its writing profile.
Preserve the `/grilling` round format.
If the shared guidance is unavailable, state that limit and continue with clear, precise language.

## Establish context

Use the current conversation as the source of agreed behavior, scope, constraints, and exclusions.
If context is missing, recover it from the ticket, behavioral specification, interview summary, repository documentation, or related issues.
A behavior that is still open is a decision for the user: put it on the tree, and keep it unresolved until the user answers.

Read the repository instructions, architecture documents, decision records, glossary, and the code and tests of the affected systems and their direct collaborators.
Keep the reading proportional to the affected responsibilities.

## Build the design tree

A decision goes on the tree when it passes this test:

> Would this decision change responsibility ownership, authority to mutate important state, subsystem dependencies, or how future features must integrate?

Consider only the dimensions the requested behavior touches:

- Responsibility and mutable-state ownership.
- Systems permitted to change state and systems permitted only to observe it.
- Dependency direction and public subsystem interfaces.
- Lifecycle and persistence boundaries.
- Communication between systems and resolution of competing requests.
- Execution authority, including movement and physics when relevant.

Variable names, loops, casts, helper methods, and internal calculations belong to Deliver.
A specific call goes on the tree only when its ownership sets a boundary, such as authority to call `move_and_slide()`.

An existing pattern that is clear, consistent, and fits the behavior is a settled node.
Record the pattern, its evidence, and the rule it gives, and build on it without a question.
One convenient implementation is not a pattern.
Conflicts between code, documented decisions, and the requested behavior, absent patterns, new boundaries, and transfers of responsibility are questions.

Ask about future integration only for agreed requirements or concrete existing collaborators.
Recommend the smallest design that makes ownership explicit.
Recommend an interface, event bus, manager, or other abstraction only for a concrete requirement.

Show the settled nodes with their evidence before the first round, so the user can challenge a pattern before questions build on it.

If the tree has no open decision, finish without an interview.
State that the work stays within existing boundaries, and name the ownership rules and their evidence.

## Keep each question short

Number questions continuously across rounds, so a later question can cite an earlier one by its number.
Give each question body the behavior and the open boundary in a few sentences.
Cite evidence as `file:line` links.
Give each option its ownership arrangement and the consequence for the boundary.
Tests that must keep passing and other implementation constraints go in the summary for Deliver.

## Record the decisions

`/domain-modeling` writes as each decision settles.
The repository's own locations and formats come first: when its instructions or architecture documents name a decision-record folder, write records there in that folder's format.
Otherwise, use the `/domain-modeling` defaults.
A system map or overview describes the code as it is; Deliver updates it when the change lands.

## Hand off

When the frontier is empty, give a concise summary in the conversation, and ask the user to confirm it as the shared understanding.
The session ends when the user confirms.
The summary contains:

- Agreed owners, permitted mutations, dependencies, interfaces, and coordination rules.
- For each new decision, the user's choice and its trade-off. For each preserved pattern, its evidence.
- Architectural invariants that implementation must preserve.
- The decision records and glossary entries written.
- Local implementation details and constraints for Deliver, including tests that must keep passing.

Separate the user's decisions from preserved patterns, and leave unanswered recommendations out of the agreed rules.
If the session ends early, list the settled decisions apart from the open questions.
`ticket-to-tasks` can take the summary into its Implementation Decisions section.

The session ends at the summary: tasks, specifications, and implementation come later in their own steps.
If later implementation needs a boundary change, put that change to the user before it is implemented.
