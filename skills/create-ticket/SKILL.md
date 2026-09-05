---
name: create-ticket
description: Creates a lightweight tracker ticket with a plain-language title, a one- or two-sentence TL;DR, and configured classifications and release grouping. Use when an idea needs an initial ticket before grilling or specification.
disable-model-invocation: true
---

# Create Ticket

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Create only the lightweight ticket that starts the workflow.

## Preconditions

Read `docs/agents/bb-skills.md`. If it is absent, incomplete, or contradicts the tracker, stop and direct the user to `$setup-bb-skills`.

Resolve the tracker target from the contract and current repository. If the target is ambiguous, ask before continuing.

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

If the user supplied a release grouping, use it without a separate selection question. Otherwise inspect available release groupings, infer the best fit from context, and ask the user to confirm it. If no fit is defensible, ask the user to choose. Omit release grouping only when the contract says it is not used.

Do not create missing classifications or release groupings. Direct configuration problems to `$setup-bb-skills`.

## Project position

Inspect the existing tickets in the project's TODO column. If the user specified where the new ticket belongs, use that position. Otherwise infer when it should be worked relative to the other TODO tickets and choose the best position.

## Approval and creation

Preview:

- tracker target;
- title and complete body;
- ticket classification;
- needs-details state;
- release grouping;
- intended position in the project's TODO column.

Wait for explicit approval before creating the ticket. Then create it using available tracker capabilities. After it is present in the project and its TODO column, move it to the approved position. Read back its neighboring TODO tickets and verify every confirmed value.

Create no specification or child tasks. On a partial failure, do not delete the ticket; report what succeeded and what remains.
