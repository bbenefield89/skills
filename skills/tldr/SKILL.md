---
name: tldr
description: Persistent response mode that preserves the complete normal response and appends a concise TL;DR block at the end. Use when the user runs /tldr or asks for "tldr mode", "tldr", "add a tldr", or "summarize responses at the end". Stays on until the user explicitly turns it off ("stop tldr", "tldr off", "normal mode", or "no summary").
---

# TL;DR Mode

Persistent on/off switch. When ON, write the response normally, then append its too-long-didn't-read version.

## Toggle behavior

- **Turn ON**: user runs `/tldr` or says "tldr mode", "tldr on", "add a tldr", etc. Once on, append a TL;DR to **every substantive response**.
- **Turn OFF**: only when the user explicitly asks — "stop tldr", "tldr off", "normal mode", "no summary", or similar.
- **Never self-disable.** Unlike compression skills, TL;DR does not turn itself off for any topic, warning, or action type. It persists until the user says otherwise.
- Toggling on/off is the one exception where you may briefly confirm (e.g. "TL;DR on." / "TL;DR off."). Otherwise no self-referential announcements.

## How to respond in TL;DR mode

- Write the complete response exactly as you normally would without this skill. Preserve its explanation, context, caveats, examples, formatting, and requested level of detail.
- Do not shorten, restructure, simplify, or omit content from the normal response merely because TL;DR mode is active.
- After the complete response, add a `## TL;DR` heading and summarize the bottom line beneath it.
- Keep the appended summary to 1–3 sentences or a short bullet list unless additional detail is required to remain accurate or actionable.
- Summarize at the idea level rather than compressing individual sentences. Use normal grammatical prose.
- Do not introduce information in the TL;DR that is absent from or inconsistent with the complete response.
- Keep the TL;DR last. Do not add commentary after it.

## What to preserve

- Preserve technical accuracy, exact terminology, numbers, names, and details whose omission would make the summary misleading or unusable.
- Preserve commands, file paths, and identifiers verbatim when they are essential to the bottom line.
- Preserve critical safety warnings for destructive or irreversible actions in both the complete response and, when material to the requested action, the TL;DR.
- Use the same language as the complete response.

## Example

Use `git revert <commit>` when you need to undo a published commit safely. It creates a new commit that reverses the selected change, so the existing history remains intact. This is generally safer for a shared branch than rewriting history with `git reset`.

## TL;DR

Use `git revert <commit>` to undo the change while preserving shared history.
