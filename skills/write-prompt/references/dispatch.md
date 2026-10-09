# Dispatch rules

Select one mode for the task. The sources are in [the prompting reference](prompting.md#sources).

## Modes

| Mode | Meaning |
|---|---|
| Inline | The agent that receives the prompt does the task in its own session. |
| Subagent | The receiving agent spawns one subagent and gives it the task prompt. |
| Parallel subagents | The receiving agent spawns 2 or more subagents in one message. Each subagent gets its own task prompt. |

## Select the mode

Select **Subagent** when one or more of these conditions apply:

- The task reads many files, logs, or documents, and the parent needs only the conclusion.
- The task is self-contained, and its result fits in one report.
- The task needs a different model or effort than the session uses, such as Haiku 5.5 for a bulk scan.
- The task needs restricted tools, such as a read-only search.

Select **Parallel subagents** only when the task divides into parts that do not depend on each other.
Each part must have its own clear boundary, or the subagents do the same work two times.
Use 2 to 4 subagents for a comparison. Use more only for wide research with many independent sources.

Select **Inline** when one or more of these conditions apply:

- The task needs questions and answers with the user while it runs.
- The task depends on much conversation context that is difficult to put in a prompt.
- The task is a small, targeted change, or one search command answers it.
- The result of each step controls the next step, and the steps share most of their context.

If no condition applies, select Inline. A subagent must collect its context again, and that costs time and tokens.
Do not select a subagent only to verify or review the work of the parent.

## Select the agent type

- Use `Explore` for a read-only search of a codebase. It does not read `CLAUDE.md`.
- Use `Plan` for a read-only implementation plan. It does not read `CLAUDE.md`.
- Use `general-purpose` for a task that edits files, runs commands, or uses connectors.
- If a custom agent in the session matches the task exactly, use that agent.

## Select the model and effort

1. Invoke the `suggest-model` skill with a one-sentence description of the task.
2. Use only the Claude Code model and effort. Ignore the Codex suggestion and the better fit. A subagent always runs in Claude Code.
3. Convert the model: Opus 5.5 is `opus`, Sonnet 5.5 is `sonnet`, and Haiku 5.5 is `haiku`.
4. Use the effort without a change.

For parallel subagents, invoke `suggest-model` one time for each different task type.
If the `suggest-model` skill is not available, omit the model and effort. Then the subagent uses the session model.

## Select foreground or background

- Use `run_in_background: false` when the next step of the parent needs the result.
- Use `run_in_background: true` when the parent or the user can do other work while the subagent runs.
- Use `run_in_background: true` for parallel subagents.

## After the subagent returns

State in the dispatch block what the parent does with the report. For example:

- Give the user a summary of the findings.
- Use the report as input for the next step.
- Combine the reports of the parallel subagents into one result.

Tell the parent not to wait in a loop for a background subagent. The parent gets a notification when the subagent finishes.
