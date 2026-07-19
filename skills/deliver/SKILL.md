---
name: deliver
description: Delivers an implementation end to end through preflight, test-driven implementation, independent read-only review, and repository-defined validation. Use when the user wants a specification, ticket, plan, or direct request implemented, reviewed, and validated in one workflow.
---

# Deliver

Conduct one self-contained delivery pipeline:

```text
Preflight -> Implementation -> Read-only review -> Validation
                 ^                    |
                 +--------------------+
```

Do not depend on external implementation, cleanup, engineering-principles, or code-review skills. The bundled references are the workflow's authoritative phases and standards.

## Load the contract

1. Read [references/preflight.md](references/preflight.md).
2. Read [references/standards/core.md](references/standards/core.md).
3. Detect applicable technology profiles during preflight and read each matching file under `references/profiles/`. Read [references/profiles/godot.md](references/profiles/godot.md) when Godot evidence is present.
4. Read [references/implementation.md](references/implementation.md), [references/review.md](references/review.md), [references/validation.md](references/validation.md), and [references/report-schema.md](references/report-schema.md).

Implementation and review must use the same core standard, selected profiles, repository guidance, specification, and acceptance criteria.

## Establish authority

Accept a ticket, specification, agreed conversation plan, or direct implementation request. If none exists, ask for a plan. Never invent requirements, acceptance criteria, scope, or conflict resolution.

Record the initial worktree before editing. Exclude unrelated pre-existing changes. If requested work overlaps them and ownership cannot be separated safely, ask.

Never commit or push unless the current user explicitly instructs it. Do not infer authority from repository guidance or earlier automation. An explicit instruction not to commit or push always wins.

## Run the pipeline

1. Complete preflight.
2. Implement in vertical red-green-refactor slices.
3. Run independent Standards and Spec review passes. Review is strictly read-only.
4. Return every actionable finding to Implementation, including formatting, naming, documentation, and straightforward typing findings.
5. Rerun both review passes after fixes. After two unsuccessful correction cycles for the same finding or related finding cluster, stop and ask for conflict resolution.
6. Run repository-defined final validation only after review passes.
7. Return validation failures to Implementation, then rerun review and validation. After two unsuccessful correction attempts for the same validation failure, finish as Failed.

Do not create a separate cleanup phase. Implementation owns fixes; review detects and reports them.

## Finish

Classify the result:

- **Verified:** implementation and both reviews pass, and final validation passes.
- **Unverified:** implementation and both reviews pass, but the repository has no adequate final validation command.
- **Failed:** review or validation remains failing after the allowed correction attempts.
- **Blocked:** unresolved scope, authority, overlap, or conflict prevents implementation.

Use the report schema. Keep both final review outputs complete and unabridged.
