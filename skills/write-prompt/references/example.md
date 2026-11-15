# Example

A user asks for a prompt to find every caller of a deprecated API in a large repository.
The material names the API but not the directories to skip, so the skill asks one question. The user says to skip `vendor/` and `generated/`.
`suggest-model` returns Research · Light with Haiku 5.5, medium, for Claude Code and GPT-6 Luna, high, for Codex, and the better fit is Either.
The task prompt names the API, the directories to search, and the directories to ignore, with the reason for each.
Its output format asks for a table of file path, line, and call form. It tells the agent to run one real search check, because the model is Haiku 5.5.

The response:

`````markdown
````text
<summary>
For the user. The task is in <task_prompt>.
Finds every caller of the deprecated `LegacyClient.fetch` API and lists them in one table.
</summary>

<task_prompt>
<context>…</context>
<objective>…</objective>
<scope>…</scope>
<done_when>…</done_when>
<output_format>…</output_format>
</task_prompt>
````

**Run with**
- Claude Code: Haiku 5.5, medium — `/model haiku`, then `/effort medium`
- Codex: GPT-6 Luna, High — `/model`, then select GPT-6 Luna and High
- Better fit: Either
`````
