---
name: write-prompt
description: Writes an agent-ready prompt for any task from current Anthropic prompting guidance. Adds a dispatch block that tells the receiving agent to do the task inline or to run a plan of steps with subagents, each part on the cheapest model and effort from suggest-model that still does it well. Use when the user asks to write, create, or generate a prompt for an agent, or wants a task packaged for a subagent or another session. Outputs the prompt only and does not run it.
argument-hint: "Optional: the task, or emphasis for the prompt"
---

# Write Prompt

Write one prompt that another agent can execute. The prompt has a dispatch block and one or more task prompts.
This skill only writes the prompt. Do not do the task, and do not spawn a subagent.

Agents read the output, not humans. Do not apply ASD-STE100 to the output.

## Steps

1. Find the task. Use the arguments, the user's request, the conversation, and the referenced material.
2. Collect the context that the executing agent needs. Read the referenced files, issues, and documents.
   Record the exact paths, commands, names, and decisions. The executing agent does not see this conversation.
3. Read [the prompting reference](references/prompting.md) and [the dispatch rules](references/dispatch.md).
4. Ask the clarifying questions. Do this before you write any part of the output.
5. Break the task into parts, and get the model and effort for each part as the dispatch rules state. Do this in every mode.
6. Select the mode with the dispatch rules. For the Plan mode, plan the steps, the agent types, and foreground or background.
7. Write the output in the format below. [The examples](references/example.md) show a plan with one step and a plan with three steps.
8. Check each task prompt against the checklist in the prompting reference. Correct each failure.

## Clarifying questions

List each gap that the material does not answer and that would change the prompt:

- The objective, or the done condition.
- The scope: what is in scope, what is out of scope, and where to stop.
- A constraint, such as a file, behavior, or system that must not change.
- A required input, such as a path, a command, an identifier, or a source.
- The output format that the user wants back.
- A dispatch choice that depends on the user, such as whether the task needs the user while it runs.

Ask about each gap. Ask independent questions together, and give a recommended answer for each question.
If the `AskUserQuestion` tool is available, use it. It accepts up to four questions in each call.
If an answer opens a new gap, ask again.

Do not invent a requirement, a path, or a command to fill a gap.
If the user tells you to continue without an answer, use your recommended answer and state it in the `**Assumed:**` line.
This step is complete when each gap has an answer from the user or an assumption that the user accepted.
If the material has no gap, continue to the next step without a question.

## Output format

Put the complete output in one code block with four backticks and the `text` language. Four backticks keep inner code blocks intact.
Add no other text, except the `**Assumed:**` line and the run section below.

For the Inline mode:

````text
<dispatch>
Do the task in <task_prompt> in this session. Do not spawn a subagent.
Reason: <one sentence from the dispatch rules>
</dispatch>

<task_prompt>
<the task prompt, in the structure from the prompting reference>
</task_prompt>
````

For the Plan mode, use [the Plan format](references/plan.md). It covers one agent, parallel agents, parent steps, gated steps, and continued subagents.

For the conditional Inline mode, use the Inline format with these changes. The dispatch rules state when to use it:

- Replace the first dispatch line with: "If you run on <Claude Code model name>, do the task in <task_prompt> in this session. Do not spawn a subagent. Otherwise, spawn one subagent with the Agent tool. Give it the complete text inside <task_prompt> as its prompt. Do not do the task in this session. Use these settings exactly:"
- Add a settings list after it: `- subagent_type: <agent type>`, `- model: <opus | sonnet | haiku>`, `- effort: <low | medium | high | xhigh | max>`, and `- run_in_background: false`.
- Keep the Reason line. Add a `Task type: <task type from suggest-model>` line and a `When the subagent returns: <what the parent does with the report>` line.

If you assumed a fact, add one line after the code block: `**Assumed:** <assumption>`.

For each Inline output, end the response with the run section. Use [the template in the dispatch rules](references/dispatch.md#run-section). Put it after the `**Assumed:**` line. The user reads it to set the session.
