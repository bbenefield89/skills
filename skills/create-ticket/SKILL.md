---
name: create-ticket
description: Creates a lightweight tracker ticket with a plain-language title, a one- or two-sentence TL;DR, and configured classifications and release grouping. Use when an idea needs an initial ticket before grilling or specification.
disable-model-invocation: true
---

# Create Ticket

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

## Approval and creation

Preview:

- tracker target;
- title and complete body;
- ticket classification;
- needs-details state;
- release grouping.

Wait for explicit approval before creating the ticket. Then create it using available tracker capabilities and verify every confirmed value.

Create no specification or child tasks. On a partial failure, do not delete the ticket; report what succeeded and what remains.
