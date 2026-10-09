---
name: write-prompt
description: Writes an agent-ready prompt for any task from current Anthropic prompting guidance. Adds a dispatch block that tells the receiving agent to do the task inline or in subagents, with the agent type, model, and effort from suggest-model. Use when the user asks to write, create, or generate a prompt for an agent, or wants a task packaged for a subagent or another session. Outputs the prompt only and does not run it.
argument-hint: "Optional: the task, or emphasis for the prompt"
---

# Write Prompt

Write one prompt that another agent can execute. The prompt has a dispatch block and one or more task prompts.
This skill only writes the prompt. Do not do the task, and do not spawn a subagent.

Agents read the output, not humans. Do not apply ASD-STE100 to the output.

## Steps

1. Find the task. Use the arguments, the user's request, the conversation, and the referenced material.
2. If the objective or the done condition is not clear, ask the user one question at a time.
   Do not invent a requirement, a path, or a command.
3. Collect the context that the executing agent needs. Read the referenced files, issues, and documents.
   Record the exact paths, commands, names, and decisions. The executing agent does not see this conversation.
4. Read [the prompting reference](references/prompting.md).
5. Read [the dispatch rules](references/dispatch.md). Select the mode, the agent type, and foreground or background.
6. If the mode is Subagent or Parallel subagents, get the model and effort as the dispatch rules state.
7. Write the output in the format below.
8. Check each task prompt against the checklist in the prompting reference. Correct each failure.

## Output format

Put the complete output in one code block with four backticks and the `text` language.
The four backticks keep code blocks inside the task prompt intact.
Add no other text, except the `**Assumed:**` line below.

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

For the Subagent mode:

````text
<dispatch>
Spawn one subagent with the Agent tool. Give it the complete text inside <task_prompt> as its prompt.
Do not do the task in this session. Use these settings exactly:
- subagent_type: <agent type>
- model: <opus | sonnet | haiku>
- effort: <low | medium | high | xhigh | max>
- run_in_background: <true | false>
Reason: <one sentence from the dispatch rules>
Task type: <task type from suggest-model>
When the subagent returns: <what the parent does with the report>
</dispatch>

<task_prompt>
<the task prompt>
</task_prompt>
````

For the Parallel subagents mode, use the Subagent format with these changes:

- Start the dispatch with "Spawn <N> subagents with the Agent tool in one message."
- Give one settings list for each subagent. Start each list with `task_prompt id="<n>"`.
- Write one `<task_prompt id="<n>">` block for each subagent.
- In "When the subagents return", tell the parent how to combine the reports.

If you assumed a fact, add one line after the code block: `**Assumed:** <assumption>`.

## Example

A user asks for a prompt to find every caller of a deprecated API in a large repository.
The dispatch selects Subagent with `Explore`, because the search reads many files and the parent needs only the list.
`suggest-model` returns Bulk scan with Haiku 5.5, medium. The dispatch uses `model: haiku` and `effort: medium`.
The task prompt names the API, the directories to search, and the directories to ignore.
Its output format asks for a table of file path, line, and call form. It tells the agent to run one real search check, because the model is Haiku 5.5.
