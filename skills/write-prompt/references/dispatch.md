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
2. For the Subagent and Parallel subagents modes, use only the Claude Code model and effort. Ignore the Codex suggestion and the better fit. A subagent always runs in Claude Code.
3. Convert the model: Opus 5.5 is `opus`, Sonnet 5.5 is `sonnet`, and Haiku 5.5 is `haiku`.
4. Use the effort without a change.
5. For the Inline mode, keep the Claude Code pick, the Codex pick, and the better fit for the run section. Get the set commands from the catalog of `suggest-model`. For the conditional Inline dispatch, also use the Claude Code model name and the alias as the rules in "Make Inline conditional" state.

For parallel subagents, invoke `suggest-model` one time for each different task type.
If the `suggest-model` skill is not available in the Subagent or Parallel subagents mode, omit the model and effort. Then the subagent uses the session model.
If the `suggest-model` skill is not available in the Inline mode, omit the run section and use the plain Inline dispatch. Add an `**Assumed:**` line that states this.

## Make Inline conditional

A model change in a session discards the prompt cache, because the cache is per model. The new model reads the whole conversation at the uncached price. A subagent starts with a small, clean context.
So an Inline dispatch depends on the model of the agent that runs the prompt. That agent can be a different session from the one that wrote the prompt.

When the mode is Inline, write the conditional dispatch from [the output format](../SKILL.md#output-format):

- Name the Claude Code pick with its model name, such as "Opus 5.5". The receiving agent compares it with the model name in its system prompt.
- If the receiving agent runs on that model, it does the task in its own session.
- If it runs on another model, it spawns one subagent with the Claude Code pick. Select the agent type with the rules above. Use `run_in_background: false`.
- A different effort with the same model does not start a subagent. An effort change keeps the cache.

Use the plain Inline dispatch, without the condition, in these cases:

- The task needs questions and answers with the user while it runs. A subagent cannot ask the user a question partway through.
- The better fit from `suggest-model` is Codex. The Agent tool and the model aliases exist only in Claude Code, and the user can run the prompt in Codex.

These rules do not change the mode selection. If the task is large or difficult enough for a subagent, select Subagent, whatever the session model is.

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

## Run section

Add this section after the code block of each Inline output, conditional or plain. It goes after the `**Assumed:**` line.

```markdown
**Run with**
- Claude Code: <model>, <effort> — `/model <alias>`, then `/effort <effort>`
- Codex: <model>, <effort label> — `/model`, then select <model> and <effort label>
- Better fit: <Claude Code, Codex, or Either>
```
