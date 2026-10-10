# Dispatch rules

Select one mode for the task. The sources are in [the prompting reference](prompting.md#sources).
The goal is good quality at the lowest cost. Give each part of the task the cheapest model and effort that still does it well.

## Modes

| Mode | Meaning |
|---|---|
| Inline | The agent that receives the prompt does the task in its own session. |
| Plan | The receiving agent runs an ordered list of steps. Each step has one or more agents, and each agent has its own model and effort. The agents of one step run in parallel. |

A plan does not mean many agents. Most plans have one step and one agent.
Add a step or an agent only when the cost rule supports it.

The receiving agent runs in Claude Code or in Codex. Both tools spawn subagents, and both set the model and effort of each subagent.
Write each output so that it runs in both tools. The tool does not change the mode, the steps, or the number of agents.

## Select the mode

First, find the parts of the task with the procedure in "Plan the steps". If more than one part remains, select Plan.

If one part remains, select **Plan** with one step and one agent when one or more of these conditions apply:

- The task reads many files, logs, or documents, and the parent needs only the conclusion.
- The task is self-contained, and its result fits in one report.
- The task needs a different model or effort than the session uses, such as Haiku 5.5 for a bulk scan.
- The task needs restricted tools, such as a read-only search.

Select **Inline** when one or more of these conditions apply:

- The task needs questions and answers with the user while it runs.
- The task depends on much conversation context that is difficult to put in a prompt.
- The task is a small, targeted change, or one search command answers it.
- The result of each step controls the next step, and the steps share most of their context.

If no condition applies, select Inline. A subagent must collect its context again, and that costs time and tokens.
Do not select a subagent only to verify or review the work of the parent.

## Plan the steps

1. Break the task into parts. A part is work that one agent can do with one model and effort.
2. Get a model and effort for each part with the rules in "Select the model and effort".
3. Merge neighboring parts that have the same pick, or that share most of their context.
4. Keep a part separate only when the cost rule supports it. Merge each other part with its neighbor.
5. If one part remains, select the mode as "Select the mode" states.
6. Put the parts in order. Put parts that do not depend on each other in the same step.
7. Write the dispatch in [the Plan format](plan.md).

### Cost rule

A split has three costs:

- Setup: each subagent reads again the context that it needs.
- Handoff loss: each step passes on a summary, not all that it saw.
- Coordination: the parent uses turns on its own model to start the agents and read the reports.

Split out a part only when all of these conditions apply:

- The part is large: many files, records, or tokens.
- Its pick is much cheaper than the pick for the rest of the task, such as Haiku 5.5, or Sonnet 5.5 at low effort, against Opus 5.5. Check the picks of each tool. The condition applies when the picks of one tool or of both tools show it.
- Its input and its output are compact, such as a list, a table, or a file path.

Keep the parts together in these cases:

- The parts share a large context.
- The difficult judgment is spread through the whole task.
- The part is small, and the setup costs more than the savings.

### Parallel agents in one step

Put 2 or more agents in one step only when their parts do not depend on each other.
Each part must have its own clear boundary, or the agents do the same work two times.
Use 2 to 4 agents for a comparison. Use more only for wide research with many independent sources, or for many independent modules.

### Parent steps

The parent can do a step itself when that costs less than a new subagent and the quality is similar.
For example, the step is small, or it needs only the reports of earlier steps, such as a step that combines reports.
Use the parent form of the Plan format for that step. A parent step has one agent.
The parent form uses the same check as the conditional Inline dispatch. The parent does the step only if it runs on the shared model of its tool below. Otherwise it spawns a subagent with the settings in the parent form.
A different effort with the same model does not start a subagent. An effort change keeps the prompt cache, and a spawn costs more. So the session effort decides the effort of a parent step. The run section tells the user which effort to set before the prompt runs.

One session runs all parent steps of an output. So all of them name the same model and the same effort. The parent forms of one plan never differ in model or in effort.
Find the shared model and effort one time from the Claude Code picks and one time from the Codex picks.

- The shared effort is the highest effort among the picks of the parent steps. The order is low, medium, high, xhigh, max. A step that runs above its pick costs a little more on a small step. A step that runs below its pick can give a worse result that nobody notices.
- The shared model is the most capable model among the picks of the steps that stay parent steps. The order in Claude Code is Opus 5.5, Sonnet 5.5, Haiku 5.5. The order in Codex is GPT-6 Astra, GPT-6.1 Sol, GPT-6 Luna. No step runs on a model below its pick.

A step can qualify as a parent step while its pick names a less capable model than the pick of another parent step, in one tool or in both tools. Choose one of these for that step. The choice applies in both tools:

- Raise it. The step stays a parent step and takes the shared model and effort. Choose this when the step is small or needs only the reports of earlier steps, so that the setup and coordination of a new subagent cost more than the run on the more capable model.
- Use the subagent form with the pick of the step. Choose this when the cost rule supports a split: the step is large, its pick is much cheaper, and its input and output are compact.

Make this choice for each such step first. Then find the shared model and effort from the steps that stay parent steps. A raised step counts with its own pick for the effort.
Write the shared model and effort of each tool in the parent form of each parent step: in the model names of the condition, and in the model and effort lines of the fallback settings. Then every parent form in one plan shows identical model and effort lines.
Add the plan run section from "Run section" to the response when the plan has one or more parent steps.

### Gated steps

Add a "Run only if" line to a step that is necessary only for some results of an earlier step.
For example, run the Opus 5.5 step only if a Sonnet 5.5 step reports difficult cases.
Write the condition so that the parent can check it in the earlier reports.
Tell the earlier task prompt to report the fact that the condition checks, such as a list of difficult cases that can be empty.
If the condition is false, the parent skips the step and states this in its final report.

### Continue a subagent

A later step can continue a subagent from an earlier step. The parent sends a follow-up to that subagent. In Claude Code, it uses the SendMessage tool and the agent ID. The subagent keeps what it read.
Use the continue form only when both of these conditions apply:

- The later step needs the same model and effort in both tools. The model of a subagent does not change after the spawn.
- The later step needs the context of that subagent.

A continued subagent carries its earlier context into each turn. So each turn costs more than a turn of a new subagent.
In the other cases, spawn a new subagent. Give it only the earlier reports that it needs in the Input line.

## Select the agent type

Select one agent type for Claude Code:

- Use `Explore` for a read-only search of a codebase. It does not read `CLAUDE.md`.
- Use `Plan` for a read-only implementation plan. It does not read `CLAUDE.md`.
- Use `general-purpose` for a task that edits files, runs commands, or uses connectors.
- If a custom agent in the session matches the task exactly, use that agent.

Select one agent for Codex:

- Use `explorer` for a read-only search of a codebase.
- Use `worker` for a task that edits files or runs commands.
- Use `default` for each other task.

## Select the model and effort

1. Invoke the `suggest-model` skill with a one-sentence description of each part. Invoke it one time for each different task type and difficulty.
2. For each agent in a plan, keep the Claude Code pick and the Codex pick. Ignore the better fit. A subagent runs in the tool that runs the prompt.
3. Convert the model. In Claude Code, Opus 5.5 is `opus`, Sonnet 5.5 is `sonnet`, and Haiku 5.5 is `haiku`. In Codex, use the model id from the catalog of `suggest-model`, such as `gpt-6.1-sol`.
4. Use the effort without a change. In Codex, use the config value of the effort, such as `xhigh`.
5. For the Inline mode, keep the Claude Code pick, the Codex pick, and the better fit for the run section. Get the set commands from the catalog of `suggest-model`. For the conditional Inline dispatch, also use the model name of each pick, the alias, and the model id as the rules in "Make Inline conditional" state.
6. For a Plan with a parent step, keep the set commands of each tool from the catalog of `suggest-model` for the run section. The shared model and effort come from the rules in "Parent steps".

If the `suggest-model` skill is not available in the Plan mode, omit the model and effort of each agent. Then each subagent uses the session model. Do not split parts by cost, because no pick shows a difference in cost. Use no parent form and add no run section, because no pick names a model.
If the `suggest-model` skill is not available in the Inline mode, omit the run section and use the plain Inline dispatch. Add an `**Assumed:**` line that states this.

## Make Inline conditional

A model change in a session discards the prompt cache, because the cache is per model. The new model reads the whole conversation at the uncached price. A subagent starts with a small, clean context.
So an Inline dispatch depends on the model of the agent that runs the prompt. That agent can be a different session from the one that wrote the prompt.

When the mode is Inline, write the conditional dispatch from [the output format](../SKILL.md#output-format):

- Name the Claude Code pick and the Codex pick with their model names, such as "Opus 5.5" and "GPT-6.1 Sol". The receiving agent compares them with the model that it runs on.
- If the receiving agent runs on one of those models, it does the task in its own session.
- If it runs on another model, it spawns one subagent with the pick for its tool. Select the agent type with the rules above. In Claude Code, use `run_in_background: false`.
- A different effort with the same model does not start a subagent. An effort change keeps the cache.

Use the plain Inline dispatch, without the condition, when the task needs questions and answers with the user while it runs. A subagent cannot ask the user a question partway through.

These rules do not change the mode selection. If the task is large or difficult enough for a subagent, select Plan, whatever the session model is.

## Select foreground or background

`run_in_background` is a Claude Code setting. Codex has no such setting. It starts the agents of a step together and waits for their results.

- Use `run_in_background: false` for a step with one agent when the next step or the parent needs its report.
- Use `run_in_background: true` for each agent in a step with 2 or more agents. The parent waits for the notification of each agent before it starts the next step.
- Use `run_in_background: true` for the last step when the parent or the user can do other work while it runs.
- A parent step and the subagent of a conditional Inline dispatch use `run_in_background: false`.

## After each step

State in the dispatch what the parent does with the reports of each step and of the whole plan. For example:

- Give the user a summary of the findings.
- Use the report as input for the next step.
- Combine the reports of the parallel agents into one result.

Tell the parent not to wait in a loop for a background subagent. The parent gets a notification when the subagent finishes.

## Run section

### Inline output

Add this section after the code block of each Inline output, conditional or plain. It goes after the `**Assumed:**` line.

```markdown
**Run with**
- Claude Code: <model>, <effort> — `/model <alias>`, then `/effort <effort>`
- Codex: <model>, <effort label> — `/model`, then select <model> and <effort label>
- Better fit: <Claude Code, Codex, or Either>
```

### Plan output

Add this section after the code block of each Plan output that has one or more parent steps. It goes after the `**Assumed:**` line, in the same position as the Inline run section.
Use the shared model and the shared effort from "Parent steps". The user sets them before the prompt runs, because the effort of the session decides the effort of each parent step.

```markdown
**Run with**
- Claude Code: <model>, <effort> — `/model <alias>`, then `/effort <effort>`
- Codex: <model>, <effort label> — `/model`, then select <model> and <effort label>
- Applies to: <the parent steps>, which run in this session.
```

Name the parent steps by their step numbers.
When a step runs above its pick in model or in effort, the "Applies to" line also states it. For example: "Applies to: steps 1 and 3, which run in this session. In Claude Code, step 1 is picked at low and runs at medium."
The Plan run section has no "Better fit" line. The user runs the prompt in the tool that the user selects.
A Plan output with no parent step has no run section, because each subagent step sets its own model and effort.
