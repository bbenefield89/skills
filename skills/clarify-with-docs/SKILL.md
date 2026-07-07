---
name: clarify-with-docs
description: Clarifying session that sharpens a plan against the existing domain model, codebase, and documentation by asking only the highest-value HITL questions. Use when the user wants to resolve important ambiguity before implementation without a relentless or exhaustive grilling pass.
disable-model-invocation: true
---

<what-to-do>

Interview me about the important unresolved aspects of this idea, plan, ticket, epic, or draft until we reach enough shared understanding for a strong handoff into PRD creation and implementation.

Do not grill relentlessly. Do not optimize for exhausting every open question. Optimize for asking the minimum worthwhile HITL questions needed to clarify product shape, UX, architecture, contracts, major technical choices, scope, risk, and project direction.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase or documentation, explore first instead of asking.

Before asking, identify the ambiguity yourself. Do not ask me meta-questions about what needs clarification, what docs should be written, or how work should be sequenced.

Every question must include:

1. A short explanation of why the question matters
2. A recommended answer
3. A short 1-2 sentence rationale for that recommendation grounded in the ticket, docs, codebase, or stated goals

Ask only questions that are worthwhile for the HITL to answer. Prefer questions about:

- user-visible behavior and flow
- interface shape and major screen/state decisions
- architecture and system boundaries
- external contracts and compatibility expectations
- security, auth, permissions, vendors, integrations, and third-party lock-in
- major technical choices that materially shape the project
- migration, rollout, or refactor tradeoffs when they affect risk, delivery, or direction

Avoid questions that are mostly implementation detail, including:

- internal code organization
- local abstractions and file/module structure
- testing strategy and execution sequencing
- routine cleanup or housekeeping
- documentation mechanics or ticket slicing mechanics

If the remaining ambiguity is mostly implementation-level, stop asking questions and produce a concise handoff summary that can feed directly into `to-prd`.

</what-to-do>

<supporting-info>

## Domain awareness

During codebase exploration, also look for existing documentation:

### File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## During the session

### Clarify only high-value ambiguities

Ask only when the answer materially affects behavior, UX, architecture, contracts, security, integrations, compatibility, risk, or project direction. If the answer is likely a local implementation choice, do not ask.

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When user-visible behavior, workflows, or boundaries are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases only when those edge cases materially change product shape or architecture.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface the concrete decision that needs clarification instead of asking a meta-question about sources of truth.

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details. Do not treat `CONTEXT.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

### Stop early once the HITL work is done

If the remaining open questions are mostly about implementation technique, internal code structure, or routine execution details, stop the clarification pass and summarize what is now clear enough for `to-prd`.

</supporting-info>
