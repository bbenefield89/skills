---
name: deliver
description: Delivers an implementation through test-driven development, implementation, language cleanup, final review, and deterministic validation. Use when the user wants a specification, ticket, plan, or direct request completed end to end in one workflow.
---

# Deliver

Deliver through abstract capabilities bound by the repository. Read [references/preflight.md](references/preflight.md) and [references/adapter-contract.md](references/adapter-contract.md) before implementation.

## 1. Establish authority

Accept a ticket, spec, agreed conversation plan, or direct instructions. If none exists, ask for a plan. Ask rather than infer ambiguous scope, authority, acceptance criteria, or precedence.

Run preflight. Missing proof infrastructure blocks full delivery. Offer the configured setup adapter, an explicitly enumerated reduced-assurance run, or stop.

## 2. Deliver

1. Resolve scope and acceptance criteria; record the task starting point.
2. Read repository guidance and capability bindings.
3. Propose meaningful public test seams and obtain agreement before writing tests.
4. Apply `engineering_quality` throughout design and implementation.
5. Use `test_driven_development` in vertical red/green slices where practical.
6. Run focused parser/type checks and tests regularly.
7. Invoke `implementation_driver` and allow its built-in review as the initial review.
8. Suppress its commit step unless the current user request explicitly authorizes a commit. An explicit `do not commit` always wins.
9. Invoke applicable language hygiene; Godot uses `gdscript_hygiene`.
10. Invoke `change_review` after cleanup with the fixed point, authoritative spec, repository standards, and engineering principles.
11. Fix actionable findings. After material fixes, repeat cleanup and final review.
12. Invoke `final_validation` and finish only when it passes or the user approves a specific exception.

Three complete fix/review cycles trigger escalation only for ambiguity, contradiction, or churn. Continue normal diagnosis for routine failures.

## 3. Report

Use [references/report-schema.md](references/report-schema.md). Preserve the final review adapter output completely and unabridged.
