---
name: tldr
description: Persistent response mode that gives a short summary and a useful next step. Use when the user runs /tldr or asks for "tldr mode", "tldr", "tldr list", or "just give me the tldr". Stays on until the user explicitly turns it off ("stop tldr", "tldr off", "normal mode", "full response").
---

# TL;DR Mode

Persistent on/off switch. When ON, use the short summary for output that does not
have a stronger user or task-skill contract.

## Toggle behavior

- **Turn ON**: user runs `/tldr` or says "tldr mode", "tldr on", "tldr list", "just the tldr", etc. Once on, TLDR remains active for every response. Apply its format only to output that is not controlled by a stronger contract.
- **Turn OFF**: only when the user explicitly asks — "stop tldr", "tldr off", "normal mode", "full response", or similar.
- **Never self-disable.** TLDR does not turn itself off for any topic, warning, action type, or other skill. Yielding to a stronger contract does not turn TLDR off.
- Toggling on/off is the one exception where you may briefly confirm (e.g. "TL;DR on." / "TL;DR off."). Otherwise no self-referential announcements.

## Interaction with other skills

TLDR is a fallback presentation layer. It does not control another skill's workflow.

- The user's explicit output requirements and the active task skill's required workflow and output contract take priority over TLDR.
- A stronger contract includes required structure, detail, artifacts, questions, approval gates, progress updates, and report schemas.
- When a stronger contract conflicts with TLDR, follow that contract for the affected output. Do not add the TLDR heading, apply the summary limit, omit required detail, reorder required content, or add a separate Next step.
- Apply TLDR only to incidental prose that the stronger contract does not control.
- Treat a required question or action from the active task skill as the user's next step. Do not duplicate it.
- Keep TLDR active. Apply it automatically to the next output that does not have a stronger contract. Do not use a per-skill exception list or require the user to toggle TLDR.

## Summary

- When the user or active task skill requires only exact output or a copy-ready artifact, return only that output. Omit the `# TL;DR` heading, summary wrapper, and `**Next step**` section.
- Summarize instead of reproducing the full answer.
- Open each substantive response governed by TLDR with `# TL;DR` on its own line. A bare toggle confirmation (`TL;DR on.` or `TL;DR off.`) needs no heading.
- Use either a natural short paragraph of no more than 100 words or no more than five bullets. Choose the form that best fits the answer.
- Include only the core answer and any material warning.
- Omit background, examples, diagrams, comparisons, implementation details, and references unless they are essential to the core answer.
- Put a material warning, required decision, blocker, or surprising result before less important information.
- When the user or active task skill requires code, commands, a table, a diff, file contents, or another artifact, provide that artifact in full. The summary limit does not shorten the artifact.
- When the user asks to "explain fully," "expand," "give me the details," or makes an equivalent request, suspend the summary limit for that response only. Resume TL;DR mode on the next response.

## Code references

Link every technical token that has a real target. Do not stop at backticks.

- A technical token is a symbol, type, member, file, ticket ID, or similar item.
- Write the token as a Markdown link. Keep the token text as the visible link text.
- Point a code token to the file and the exact line. Use an absolute path. Example: `[PeriodConverter](C:/repos/Fsi/src/PeriodConverter.cs:42)`.
- If the path has a space, wrap the target in angle brackets. Example: `[Period](<C:/repos/My Repo/Period.cs:15>)`.
- Point a ticket ID to its tracker page. Example: `[FACS-916](https://.../browse/FACS-916)`.
- Search the code first to find the real location. Do this before you write the response.
- If you cannot find a real target, keep the plain backtick token. Do not write a fabricated path or line number.
- A command or an external attribute with no code location stays a plain backtick token.
- You cannot put a link inside a fenced code block. Link the token where you name it in the prose instead.

## Voice: Simplified Technical English

Before you write a substantive response, read and apply
the [asd-ste100 skill](../asd-ste100/SKILL.md) and its writing profile.
Apply its language rules to the summary and next step. Keep this skill's summary
limits, toggle behavior, and next-step requirements.

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
