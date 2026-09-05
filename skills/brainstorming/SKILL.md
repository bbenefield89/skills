---
name: brainstorming
description: Use before substantial creative or implementation work when material product, behavior, UX, architecture, or scope decisions remain unresolved. Do not use for straightforward capture, transcription, organization, execution of an approved design, or small unambiguous edits.
---

# Brainstorming Ideas Into Designs

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Resolve only the decisions that block safe, faithful implementation. Finish with a shared design and one meaningful approval to proceed.

## Route the request

- **Use brainstorming** when different reasonable interpretations would produce materially different results.
- **Proceed directly** when the user supplied the content or an approved design and the requested action is clear.
- **Proceed directly** for capture, transcription, organization, formatting, and small unambiguous edits.
- **Use grilling** when the user asks to stress-test an idea or explore every unresolved branch.

Do not manufacture a design phase for work whose important decisions are already settled.

## Approval contract

Use one conversational approval gate: present the cohesive design, then ask whether to proceed.

- Treat the user's approval as authorization for the requested implementation within the presented scope.
- Treat an explicit instruction such as “apply it,” “write it,” or “implement it” as approval when the design is already clear in the conversation.
- Preserve approval when translating the design into a plan, task list, or optional document.
- Incorporate non-material refinements without restarting approval.
- Request fresh approval only when new information materially changes scope, risk, user-visible behavior, cost, or external effects.
- Keep separate authorization boundaries required for destructive, privileged, expensive, or out-of-scope actions.
- Do not add a conversational confirmation solely because the execution environment will display its own permission prompt.

## Workflow

1. **Inspect context** — read the relevant files, documentation, and current state.
2. **Find the decision frontier** — distinguish facts the agent can discover from decisions only the user can make.
3. **Ask material questions** — ask a compact round of independent questions; defer questions that depend on unresolved answers.
4. **Compare meaningful approaches** — offer alternatives only when the choice changes the outcome; otherwise recommend the evident approach directly.
5. **Present one cohesive design** — scale detail to the task and make behavior, boundaries, consequences, and validation explicit.
6. **Obtain one approval** — revise the design if needed; after approval, proceed without another design-review gate.
7. **Continue to the requested outcome** — implement, plan, document, or hand off according to the user's request.

## Design quality

Cover only dimensions that matter to the task, such as:

- user-visible behavior and success criteria;
- scope and non-goals;
- components, ownership, and interfaces;
- data or control flow;
- failure handling and safety boundaries;
- validation and testing.

Prefer the smallest design that resolves the material uncertainty. Do not force architecture, error-handling, or testing sections onto content-authoring work where they add no information.

For existing codebases, follow established patterns and include only targeted improvements needed by the requested change. Keep unrelated refactoring out of scope.

## Questions and approaches

Find environmental facts yourself. Ask the user only for choices, preferences, or authority that cannot be inferred safely.

Offer two or three approaches when genuine trade-offs exist. Do not invent alternatives to satisfy a quota. Lead with the recommendation and explain the consequence that makes it preferable.

## Optional design artifacts

A separate design document is optional. Create one only when:

- the user requests it;
- another agent or future session needs a durable handoff;
- the design is too large or consequential to remain reliable only in chat; or
- repository policy requires it.

When a design document is useful:

- write it to the user-requested or repository-defined location;
- otherwise use a uniquely named file in the operating system's temporary directory;
- check it for placeholders, contradictions, ambiguity, and scope drift;
- provide a clickable link;
- do not request another approval when it faithfully records the already-approved design.

## Completion

Brainstorming is complete when the material decisions are settled and the user has approved the cohesive design or already issued a clear instruction to execute it.

Continue directly into the implementation, planning, or documentation workflow that matches the user's request. Do not force an implementation plan when the user asked for the finished change.
