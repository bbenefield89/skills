---
name: tldr
description: Persistent response mode that gives a short summary and a useful next step. Use when the user runs /tldr or asks for "tldr mode", "tldr", "tldr list", or "just give me the tldr". Stays on until the user explicitly turns it off ("stop tldr", "tldr off", "normal mode", "full response").
---

# TL;DR Mode

Persistent on/off switch. When ON, prefix every substantive chat response with
`# TL;DR`. Use the short summary where a stronger contract permits it.

## Toggle behavior

- **Turn ON**: user runs `/tldr` or says "tldr mode", "tldr on", "tldr list", "just the tldr", etc. Once on, TLDR remains active for every response. Prefix each substantive chat response with the TLDR heading. Apply the summary format only where a stronger contract permits it.
- **Turn OFF**: only when the user explicitly asks — "stop tldr", "tldr off", "normal mode", "full response", or similar.
- **Never self-disable.** TLDR does not turn itself off for any topic, warning, action type, or other skill. Yielding to a stronger contract does not turn TLDR off.
- Toggling on/off is the one exception where you may briefly confirm (e.g. "TL;DR on." / "TL;DR off."). Otherwise no self-referential announcements.

## Interaction with other skills

TLDR does not control another skill's workflow. Separate the chat response from an artifact.

- The chat response is the text shown in the conversation.
- An artifact is content a skill writes or posts elsewhere: a file, a Jira ticket or comment, a PR body, a commit message, or a note.

- Always prefix each substantive chat response with `# TL;DR`. This heading is the chat-response envelope, not part of the summary format.
- A stronger contract can override the summary format. It cannot remove the chat heading.
- Omit the chat heading only in these cases:
  - The response is a bare toggle confirmation.
  - The response contains only exact copy-ready output (see the Summary section).
- Write all prose in ASD-STE100. This covers both the chat response and the prose inside an artifact.
- Never put the `# TL;DR` heading or the TLDR summary format inside an artifact. An artifact keeps its own skill's structure. Only its prose follows ASD-STE100.
- The STE voice takes priority over another skill's own wording or plain-language preference. It does not override that skill's structure, required detail, or exact tokens.

Apply the TLDR summary format only where it does not malform a stronger contract:

- The user's explicit output requirements and the active task skill's required workflow and output contract take priority over the summary format.
- A stronger contract includes required structure, detail, artifacts, questions, approval gates, progress updates, and report schemas.
- When a stronger contract conflicts with the summary format, keep `# TL;DR` as the first line. Follow the stronger contract after the heading.
  - Do not apply the summary limit.
  - Do not force the bullet or short-paragraph form.
  - Do not omit required detail.
  - Do not reorder required content.
  - Do not add a separate Next step.
- If a stronger contract requires a response with no additional text, treat the response as exact copy-ready output and omit the heading.
- Apply the summary format only to incidental chat prose that the stronger contract does not control.
- Treat a required question or action from the active task skill as the user's next step. Do not duplicate it.
- Keep TLDR active. Do not use a per-skill exception list or require the user to toggle TLDR.

## Summary

- When the user or active task skill requires only exact output or a copy-ready artifact, return only that output. Omit the `# TL;DR` heading, summary wrapper, and `**Next step**` section.
- Summarize instead of reproducing the full answer.
- Use either a natural short paragraph of no more than 100 words or no more than five bullets. Choose the form that best fits the answer.
- Include only the core answer and any material warning.
- Omit background, examples, diagrams, comparisons, implementation details, and references unless they are essential to the core answer.
- Put a material warning, required decision, blocker, or surprising result before less important information.
- When the user or active task skill requires code, commands, a table, a diff, file contents, or another artifact, provide that artifact in full. The summary limit does not shorten the artifact.
- When the user asks to "explain fully," "expand," "give me the details," or makes an equivalent request, suspend the summary limit for that response only. Resume TL;DR mode on the next response.

## Chat response audit

Append one compact audit block as the final content of each substantive chat
response. Put each audit field on its own line. The audit is outside the summary
word and bullet limits.

Use exactly one applicable form:

Paragraph summary:

```markdown
**Response audit**

- **Format:** Paragraph
- **Words:** <count>/100
- **STE review:** <status>
- **Exceptions:** <exceptions>
```

Bullet summary:

```markdown
**Response audit**

- **Format:** Bullets
- **Bullets:** <count>/5
- **STE review:** <status>
- **Exceptions:** <exceptions>
```

Stronger contract:

```markdown
**Response audit**

- **Summary limit:** Not applied
- **Reason:** <reason>
- **STE review:** <status>
- **Exceptions:** <exceptions>
```

User expansion:

```markdown
**Response audit**

- **Summary limit:** Suspended
- **Reason:** User requested expansion
- **STE review:** <status>
- **Exceptions:** <exceptions>
```

Use these status values:

- Use `PASS` only after the mandatory second pass completes with no unresolved failures.
- Use `PASS WITH EXCEPTIONS` when required content prevents full profile alignment. Name each exception.
- Use `UNAVAILABLE` when the review cannot load or complete. State why.
- Do not report a percentage of ASD-STE100 conformance. The local profile cannot support that precision.

Apply these counting boundaries:

- Count words or bullets only in the TLDR summary body.
- Exclude the `# TL;DR` heading, code blocks, artifacts, the Next step, required sections, and the audit block.
- Count bullets only when the summary uses the bullet format.
- Apply the STE review status to all natural-language chat prose above the audit block.
- Do not include artifact content in the audit counts or STE review status.

The audit applies only to chat output. Never put it in a file, ticket, PR body,
commit message, note, code block, or other artifact. If a response contains chat
prose and an artifact, audit only the chat prose. If the response contains only
exact copy-ready output, omit the audit. The response is incomplete until the
applicable audit block is last, unless this exact-output exception applies.

## Code references

Make each code reference clickable in the host you run in.

- Use a path relative to the working directory. Do not use an absolute path or a drive letter. The terminal cannot resolve a `C:/...` target.
- Add the exact line as a `:line` suffix.
- In Claude Code (terminal), write a bare `path:line` token as plain text. Do not wrap it in a Markdown link. Do not put it in backticks. The terminal makes the plain token clickable. It cannot resolve a Markdown link to a local file. Example: Orchestration/Orchestrators/Conductor.cs:118
- In the desktop or web Code app, write a Markdown link with the same relative path and `:line` suffix. Example: `[Conductor.cs:118](Orchestration/Orchestrators/Conductor.cs:118)`.
- If you do not know the host, write the bare `path:line` token. It is readable everywhere and clickable in the terminal.
- Reference only a file that exists in the current checkout. If the file is on another branch, name the branch. State that the path will not open until the user switches to that branch.
- Point a ticket ID to its tracker page. A web URL is a valid link target. Example: `[FACS-916](https://.../browse/FACS-916)`.
- Search the code first. Do this before you write the response.
- If you cannot find a real location, keep the plain backtick token. Do not write a fabricated path or line.
- A command or an external attribute with no code location stays a plain backtick token.
- You cannot put a link inside a fenced code block. Put the reference in the prose instead.

## Voice: Simplified Technical English

Before you write a substantive response, read and apply
the [asd-ste100 skill](../asd-ste100/SKILL.md) and its writing profile.
Apply its language rules to all prose output while TLDR is on. This includes
artifact prose that a stronger contract controls: tickets, PR descriptions,
commit messages, notes, and similar text. Keep this skill's summary limits,
toggle behavior, and next-step requirements.

After you draft the complete prose, return to the ASD-STE100
[Final STE review](../asd-ste100/references/asd-ste100-profile.md#final-ste-review).
Run its mandatory second pass against every sentence and list item. Rewrite each
failure, and repeat the review. Do not send or save the output until the gate
passes.

Keep technical tokens exact. Do not change code, commands, file paths,
identifiers, quoted output, or values. STE governs the words around them. When a
skill requires exact, copy-ready output with no prose, STE does not apply to that
output.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to the exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

## Next step

After a summary governed by TLDR, add a separate `**Next step**` section unless a stronger contract controls the continuation. This section does not count toward the summary's bullet or word limit.

- Move the user from the current request toward the likely goal.
- Use the conversation context to identify the immediate prerequisite, decision, or action.
- For learning, guide the user to the next concept they need before a later topic.
- For a workflow, give the next concrete action.
- If the correct direction depends on unknown information, ask one focused question.
- Do not suggest a topic only because it is related.
