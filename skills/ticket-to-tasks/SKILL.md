---
name: ticket-to-tasks
description: Turn a clarified ticket into task drafts for approval. Create and post its specification behind the scenes, then publish child tasks after approval. With `jira`, post the approved tasks as one comment on the Jira ticket of the current branch.
argument-hint: "Optional: jira [ticket-key], or instructions that replace the tracker contract"
---

# Ticket to Tasks

Create the specification on the existing ticket, then present task drafts for approval.
Keep the specification in the tracker. Show it in chat only when the user asks.

A user request for this combined workflow authorizes specification publication and removal of the configured needs-details state.
Publish child tasks and their relationships only after the user approves the task drafts.

## Shared references

Before you write prose, read and apply [the shared ASD-STE100 skill](../asd-ste100/SKILL.md) and its writing profile.
Keep this skill's output contract. If the writing guidance is unavailable, state that limit and use the available guidance.

Read both references completely before drafting:

- [Specification template and synthesis rules](references/specification.md).
- [Task decomposition, content, relationships, and publication rules](references/tasks.md).

These references supply the artifact rules. This skill controls the combined sequence and approval boundary.
If a reference is missing, report the missing dependency before publishing.

## Invocation instructions

Instructions that the user gives with the invocation replace the matching parts of the tracker contract and of this workflow.
Follow them without a tracker contract. Use the contract only for the parts that the instructions leave open.

If the invocation includes `jira`, read and follow [the Jira comment mode](references/jira.md).
That mode replaces the tracker contract, specification publication, and task publication.

## Gather context

Read `docs/agents/bb-skills.md` to resolve the tracker, target, classifications, release behavior, and relationships.
If the contract is missing or inconsistent for a part that the invocation instructions leave open, direct the user to `$setup-bb-skills` before publishing.

Resolve the existing ticket from the user's reference or current conversation.
Read its full body, comments, and existing child tasks.
Read the current conversation and relevant repository instructions, domain docs, ADRs, code, and prior tests.

Synthesize the clarified scope from these sources. Make routine technical decisions using existing project conventions.
Ask a focused question only when an unresolved choice materially changes scope, behavior, or acceptance criteria.
Resolve that choice before publishing dependent content.

## Create and post the specification

Use the specification reference's template and synthesis rules.
Choose the highest existing behavioral testing seam and the fewest seams possible.
Record the seam in the specification and each relevant task's validation.
Include testing decisions in the task review instead of requesting separate testing-seam or specification approval.

If a specification already exists, reuse it when it matches the clarified scope.
If it conflicts with the requested work, resolve only the conflicting decision with the user.
Preserve unrelated decisions when updating an existing specification to match the user's explicit changes.
Keep one specification section on the original ticket.

Before writing, reread the ticket to preserve intervening changes.
Append a new specification after a thematic break, or update the existing specification as authorized above.
Preserve the title, TL;DR, comments, release grouping, ticket classification, and unrelated body content and metadata.
Read the ticket back to verify the specification and preserved content.

After the specification is verified, remove the configured needs-details state if present.
Verify the resulting classifications. Keep task and executor classifications off the parent ticket.
If either operation fails, report the exact partial result and stop publication.

This stage is complete when the tracker contains the verified specification and the configured needs-details state is absent.
Continue directly to task drafting. Keep the specification out of the chat response.

## Draft tasks for review

Use the verified specification and task reference to draft complete, bounded tasks.
Apply the tracer-bullet rules, or expand-contract rules for a wide refactor.
Size each task for a fresh context window and make its result independently verifiable.

Include sufficient parent context, relevant decisions, expected starting state, and downstream purpose in each draft.
Make each draft understandable without the originating conversation or a separate specification review.
Expose all material scope, behavior, and testing choices through the task drafts.

Assign exactly one configured executor to each task.
Apply the verification and executor rules in the task reference.
Suggest a model for each task with the model suggestion rules in the task reference.
Declare only genuine blocking edges.

Present the drafts as a numbered list in the proposed work order. Include these fields for each task:

- **Title:** The task title.
- **Executor:** The configured agent or human classification.
- **Suggested model:** The model suggestion line, or `—`.
- **Blocked by:** Draft task numbers and titles, or `None`.
- **What it delivers:** The observable result and bounded work.
- **Context:** The decisions, starting state, and later work needed to execute this task independently.
- **Acceptance criteria:** The observable conditions that prove completion.
- **Validation:** The behavioral seam and checks performed as part of this task.

Identify equivalent existing tasks and propose reuse in the numbered review.
Reuse a task only after the user confirms that match.
Keep the proposed drafts concrete enough to publish without adding material decisions after approval.

Briefly confirm that the specification is posted, using the parent ticket link or local file link.
Ask whether to publish the drafts or change their granularity, executors, blockers, or scope.
Wait for explicit approval before publishing child tasks.

Revise the drafts from the user's feedback. Update the specification behind the scenes when that feedback changes agreed decisions.
Verify specification updates and present the affected drafts again for approval.

## Publish approved tasks

Reread the tracker contract, parent specification, and existing children before publication.
If a material change affects an approved draft, revise that draft and obtain approval for the changed work.
If a new equivalent task appears, propose its reuse in the task review before creating any duplicate.

Follow the task reference's publication invariants and relationship rules:

1. Recheck equivalent child tasks to prevent duplicates. Use only approved matches.
2. Publish new tasks in dependency order using the approved content.
3. Apply the configured task classification and exactly one executor classification.
4. Attach each task to the parent using the configured relationship.
5. Apply release grouping according to the tracker contract.
6. Create the approved blocking relationships and retain readable blocker references.
7. Verify every task, classification, parent edge, and blocker edge.
8. Prepend or refresh the parent's generated task sequence table in the approved work order.
9. Verify the table and preserve the verified parent body byte-for-byte below its thematic break.

Stop on partial failure. Report what was created, changed, and left incomplete before attempting recovery.
On a rerun, inspect verified artifacts and remaining work before making further writes.
Preserve existing ticket and task status. Leave implementation and unrelated tracker changes outside this workflow.

After publication, provide the parent link and task links in the approved order.
Report any incomplete operations. Keep the specification out of the final response unless the user requests it.
