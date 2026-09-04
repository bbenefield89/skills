---
name: tldr
description: Persistent response mode that gives a short summary and a useful next step. Use when the user runs /tldr or asks for "tldr mode", "tldr", "tldr list", or "just give me the tldr". Stays on until the user explicitly turns it off ("stop tldr", "tldr off", "normal mode", "full response").
---

# TL;DR Mode

Persistent on/off switch. When ON, give the short summary as the response.

## Toggle behavior

- **Turn ON**: user runs `/tldr` or says "tldr mode", "tldr on", "tldr list", "just the tldr", etc. Once on, every substantive response uses this format.
- **Turn OFF**: only when the user explicitly asks — "stop tldr", "tldr off", "normal mode", "full response", or similar.
- **Never self-disable.** TL;DR does not turn itself off for any topic, warning, or action type. It persists until the user says otherwise.
- Toggling on/off is the one exception where you may briefly confirm (e.g. "TL;DR on." / "TL;DR off."). Otherwise no self-referential announcements.

## Summary

- When the user requests only exact output or a copy-ready artifact, return only that output. Omit the `# TL;DR` heading, summary wrapper, and `**Next step**` section.
- Summarize instead of reproducing the full answer.
- Open each substantive response with `# TL;DR` on its own line. A bare toggle confirmation (`TL;DR on.` or `TL;DR off.`) needs no heading.
- Use either a natural short paragraph of no more than 100 words or no more than five bullets. Choose the form that best fits the answer.
- Include only the core answer and any material warning.
- Omit background, examples, diagrams, comparisons, implementation details, and references unless they are essential to the core answer.
- Put a material warning, required decision, blocker, or surprising result before less important information.
- When the user explicitly requests code, commands, a table, a diff, file contents, or another artifact, provide that artifact in full. The summary limit does not shorten the requested artifact.
- When the user asks to "explain fully," "expand," "give me the details," or makes an equivalent request, suspend the summary limit for that response only. Resume TL;DR mode on the next response.

## Voice: Simplified Technical English

Write the summary and next step in ASD-STE100 Simplified Technical English, applied in
spirit — not as a claim of full dictionary compliance:

- Short sentences. One instruction or one statement each.
- Active voice. Present tense where the fact allows.
- Simple, common words. Avoid jargon, idioms, and a long word where a short one
  carries the meaning.
- One term for one thing. Do not vary the word for the same concept.

Use the project's ubiquitous language for domain terms:

- If the repo has a `CONTEXT.md`, take domain terms from it.
- If the repo has more than one, read `CONTEXT-MAP.md` first to find the right
  `CONTEXT.md`, then use that one.
- If neither file exists, use plain words.

This voice does not change exact code, commands, identifiers, file paths, or required domain terms.

## Next step

After the summary, add a separate `**Next step**` section. This section does not count toward the summary's bullet or word limit.

- Move the user from the current request toward the likely goal.
- Use the conversation context to identify the immediate prerequisite, decision, or action.
- For learning, guide the user to the next concept they need before a later topic.
- For a workflow, give the next concrete action.
- If the correct direction depends on unknown information, ask one focused question.
- Do not suggest a topic only because it is related.
