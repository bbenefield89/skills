---
name: goal-prompt
description: Turn an agreed feature, refactor, migration, or bug-fix discussion into an implementation-ready Goal Prompt for another agent. Use when the team has converged on what should be built and needs a durable objective with clear done conditions, constraints, validation steps, checkpoints, and starting context.
argument-hint: "Optional: implementation emphasis, recipient, or extra constraints to include"
---

# Goal Prompt

Turn the agreed conversation into a single Goal Prompt that another agent can execute.

Output only the prompt unless the user explicitly asks for analysis.

## What to capture

Build the prompt around the same contract used by Codex goals:

- one objective
- one verifiable stopping condition
- what must not change
- what files, docs, plans, issues, logs, or screenshots to read first
- the commands, tests, or artifacts that prove progress
- checkpoint guidance for long-running work
- explicit non-goals and escalation points when needed

## Workflow

1. Read the current conversation and any referenced repository artifacts before drafting.
2. Use the project's established language from `CONTEXT.md`, ADRs, issues, and existing code when those sources exist.
3. Separate settled decisions from open questions.
4. If key parts are unresolved, do not fake certainty. Ask targeted follow-up questions or return a short "Missing to draft a Goal Prompt" list.
5. Compress the settled scope into one durable objective. Do not turn it into a backlog.
6. Name the exact files, directories, docs, issues, commands, tests, screenshots, or URLs when known. If unknown, say to use the project's standard command instead of inventing one.
7. Preserve important constraints: compatibility, visual parity, migrations, rollback expectations, performance, security, naming, and files or areas that are out of bounds.
8. State how the implementation agent should work: in checkpoints, with concise progress notes, and with validation after each meaningful change.
9. End with a concrete stopping condition and any conditions that should cause the agent to stop and report instead of guessing.

## Output rules

- Do not start with `/goal`.
- Do not mention this skill.
- Do not include preamble, commentary, or Markdown fences unless the user asks.
- Write as a direct instruction to an implementation agent.
- Prefer precise repo paths, command names, and acceptance criteria over generic advice.
- Keep the prompt compact but complete.

## Suggested shape

Complete [objective] without stopping until [verifiable end state].

Start by reading: [files/docs/issues/plans/logs]

Constraints:
- ...

Non-goals:
- ...

Validation:
- ...

Execution:
- Work in checkpoints.
- Keep a short progress log.
- Re-validate after each checkpoint.
- Stop and report if [blocking condition].

## Quality bar

A good Goal Prompt gives the implementation agent enough context to start immediately, enough validation to prove progress, and a crisp definition of done.

If the user passed arguments, treat them as emphasis for what to prioritize in the prompt.
