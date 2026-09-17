---
name: architecture-grill
description: Resolve architectural ownership and subsystem boundaries for established behavior before specification or task generation. Use after behavioral discovery when responsibilities, state ownership, authority, dependencies, or public interfaces need decisions. Excludes line-by-line implementation design.
---

# Architecture Grill

Resolve architectural decisions after behavioral discovery and before Ticket to Spec and Spec to Tasks.
Deliver retains authority over local implementation details within the agreed boundaries.

## Shared writing standard

Before writing prose, read and apply [asd-ste100](../asd-ste100/SKILL.md) and its writing profile.
Preserve this skill's question format and required detail.
If the shared guidance is unavailable, state that limit and continue with clear, precise language.

## Establish context

Use the current conversation as the preferred source of agreed behavior, scope, constraints, and exclusions.
A separate handoff document is unnecessary when that context is available.

If context is missing, recover it from the ticket, behavioral specification, interview summary, repository documentation, or related issues.
Ask only for missing behavioral decisions that prevent architectural analysis. Treat unresolved behavior as unresolved, rather than inventing requirements.

Inspect relevant repository instructions, code, architecture documents, ADRs, nearby implementations, tests, and conventions.
Keep inspection proportional to the affected responsibilities and their direct collaborators.
Resolve environmental facts through inspection before asking the user for a decision.

## Identify architectural decisions

Apply this test to each uncertainty:

> Would this decision change responsibility ownership, authority to mutate important state, subsystem dependencies, or how future features must integrate?

Consider only dimensions relevant to the requested behavior:

- Responsibility and mutable-state ownership.
- Systems permitted to change state and systems permitted only to observe it.
- Dependency direction and public subsystem interfaces.
- Lifecycle and persistence boundaries.
- Communication between systems and resolution of competing requests.
- Execution authority, including movement and physics when relevant.

Leave variable names, loops, casts, helper methods, internal calculations, and other local details to Deliver.
Discuss a specific call only when its ownership establishes an architectural boundary, such as authority to call `move_and_slide()`.

Preserve clear, consistent existing patterns that fit the requested behavior and applicable architectural decisions.
Record each relevant pattern, its supporting evidence, and the resulting rule without asking the user to approve it again.
A single convenient implementation does not establish a consistent pattern.
Surface conflicts between code, documented decisions, and the requested behavior.

Ask about conflicting patterns, absent patterns, new boundaries, or changes that expand or transfer responsibility.
Limit questions about future integration to agreed requirements or concrete existing collaborators.
Choose the smallest design that makes ownership explicit.
Introduce interfaces, event buses, managers, or other abstractions only when a concrete requirement justifies them.

If no architectural decision is necessary, finish without an interview.
State that the work stays within existing boundaries and briefly identify the relevant ownership rules and evidence.

## Ask one question at a time

Explain the concrete behavior and unresolved boundary before each question.
Offer meaningful alternatives. Do not invent alternatives merely to fill the format.
Use this structure:

```markdown
<Brief context grounded in the requested behavior and repository evidence.>

**<Architectural question>?**

1. **<Option one>.** <Ownership arrangement and consequence.>
2. **<Option two>.** <Ownership arrangement and consequence.>

**My recommendation:** <Recommended arrangement and why it fits.>

**Trade-off:** <Specific benefit and cost of the recommendation.>

<Direct invitation for the user to choose or refine the arrangement.>
```

Wait for the answer before asking dependent questions.
When the user asks for clarification, explain the current decision before continuing the interview.
Treat discussion, uncertainty, and requests for examples as unresolved answers.
Use each resolved answer to identify the next relevant architectural question.
Preserve settled behavioral decisions unless an architectural conflict requires the user to reconsider one.

## Summarize the agreed boundaries

Finish when all architectural uncertainties relevant to the requested behavior are resolved.
Distinguish user decisions from preserved repository patterns. Exclude unanswered recommendations from agreed rules.

Provide a concise summary in the conversation containing:

- Agreed owners, permitted mutations, dependencies, interfaces, and coordination rules, where relevant.
- The rationale and material trade-offs for new decisions, plus evidence for preserved patterns.
- Architectural invariants that implementation must preserve.
- Local implementation details left to Deliver.

Ticket to Spec can incorporate this summary into its Implementation Decisions section.
The summary documents the rules without requiring another artifact in the same session.
If the interview ends early, clearly separate settled decisions from unresolved questions.

Create a persistent summary or architecture document only when the user requests it or repository instructions require it.
Do not generate tasks, publish a specification, or implement the feature as part of this interview.
If later implementation requires a boundary change, surface that change for a decision before implementing it.
