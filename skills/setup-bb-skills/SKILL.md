---
name: setup-bb-skills
description: Configures a repository and its issue tracker for the BB ticket publishing skills by reconciling tracker concepts and writing a local contract. Use when a repository needs setup for create-ticket, ticket-to-spec, or spec-to-tasks, or when its tracker conventions change.
---

# Set Up BB Skills

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Configure the repository for the BB publishing skills. Read [REFERENCE.md](REFERENCE.md) completely before discovery.

## Non-negotiable approval gate

Before any local or external write:

1. Inspect the repository and tracker read-only.
2. Resolve every proposed value without inventing it.
3. Present the complete proposed configuration, every local write, and every external mutation.
4. Identify missing, inferred, conflicting, and unsupported values.
5. Wait for explicit approval.

Approval covers only the exact proposal shown. Repeat the gate when a material choice changes.

## Discovery

Inspect:

- repository instructions and existing `docs/agents/` contracts;
- Git remotes and evidence of the tracker in use;
- available authenticated tracker tools or connectors, without exposing credentials;
- existing ticket, task, executor, and needs-details classifications;
- existing release grouping, parent-child, and blocking mechanisms;
- compatible existing labels, issue types, fields, statuses, relationships, and duplicates.

Ask the user to confirm the tracker and every conceptual mapping in the reference. Ask rather than assuming that a platform's common convention is wanted.

## Proposal

Present:

- the exact repository and tracker target;
- the complete contract that will be written;
- the repository instruction file and pointer to add;
- tracker objects to create, reuse, or change;
- unsupported native concepts and any proposed fallback;
- conflicts or legacy configuration that will be preserved.

Do not include unchanged tracker objects as proposed mutations.

## Approved execution

After approval:

1. Reconcile the confirmed tracker configuration using available capabilities.
2. Write `docs/agents/bb-skills.md`.
3. Add one concise pointer in the existing `AGENTS.md` or `CLAUDE.md`; if neither exists, ask which to create before the approval gate.
4. Preserve unrelated instructions and repository configuration.
5. Verify the contract and tracker match.

Operations must be idempotent. Inspect before creating or updating. Stop on a partial failure and report exactly what changed and what remains.

## Boundaries

Do not install domain-document conventions, workflow tutorials, PR policy, task-ordering policy, or closure policy. Do not silently create, rename, delete, or reinterpret tracker configuration.
