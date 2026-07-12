---
name: engineering-principles
description: Applies concrete Clean Code, SOLID, and Clean Architecture standards during implementation, review, or scoped refactoring. Use when engineering work needs shared quality constraints or another skill requires an engineering-quality adapter.
---

# Engineering Principles

Use [references/principles.md](references/principles.md) as one shared vocabulary. Apply it proportionally: prefer the smallest design that gives clear responsibility, testability, and change leverage.

## Select the branch

- **Implementation:** treat every applicable principle as a design and acceptance constraint while coding.
- **Review:** inspect the requested scope and report material violations using [references/review-checklist.md](references/review-checklist.md). Do not edit.
- **Explicit refactor:** fix violations inside the approved scope and validate affected behavior.
- **No context or scope:** ask what work or code to evaluate. Do not mutate files.

Repository-specific standards override generic guidance when they deliberately choose another convention. A proportional exception requires a concrete reason and tradeoff.

## Completion criteria

- Every applicable principle was considered in the supplied scope.
- Every finding names a location, principle, impact, and smallest useful fix.
- Every mutation stays within the approved scope and is validated.
- No speculative abstraction or architecture ceremony was introduced.
