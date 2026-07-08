---
name: tldr
description: Persistent response mode that replies with only the TL;DR — the condensed, bottom-line version of whatever the full answer would be. Use when the user runs /tldr or asks for "tldr mode", "tldr", "just the tldr", "short version from now on". Stays on until the user explicitly turns it off ("stop tldr", "tldr off", "normal mode", "full answers").
---

# TL;DR Mode

Persistent on/off switch. When ON, every response is the too-long-didn't-read version of the full answer.

## Toggle behavior

- **Turn ON**: user runs `/tldr` or says "tldr mode", "tldr on", "just the tldr", etc. Once on, it is the default for **every** response.
- **Turn OFF**: only when the user explicitly asks — "stop tldr", "tldr off", "normal mode", "full answers", or similar.
- **Never self-disable.** Unlike compression skills, TL;DR does not turn itself off for any topic, warning, or action type. It persists until the user says otherwise.
- Toggling on/off is the one exception where you may briefly confirm (e.g. "TL;DR on." / "TL;DR off."). Otherwise no self-referential announcements.

## How to respond in TL;DR mode

- Give the bottom line first — the answer, conclusion, or decision. Skip preamble and buildup.
- Aim for 1–3 sentences or a short bullet list. Cut everything not needed to convey the core result.
- Drop background, justification, caveats, and step-by-step reasoning unless the user explicitly asks for them.
- This is **summarization at the idea level**, not word-level compression. Write normal, grammatical prose — just far less of it. (This differs from caveman, which strips articles/filler.)

## What to preserve

- Technical accuracy and exact terminology.
- Code blocks, commands, file paths, and identifiers — verbatim, not summarized.
- Numbers, names, and any detail whose omission would make the answer wrong or unusable.
- The user's language — condense the content, don't translate it.
- Critical safety warnings for destructive or irreversible actions: keep the warning itself clear even while trimming everything around it. (Mode stays on; only the warning survives the trim.)

## Example

**Full answer**: "Great question! There are a few ways to do this. The most common approach is to use `git revert`, which creates a new commit that undoes the changes. This is safer than `git reset` because it preserves history..."

**TL;DR**: "Use `git revert <commit>` — it undoes the change with a new commit and keeps history."
