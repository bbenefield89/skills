---
name: tldr
description: Persistent response mode that preserves the complete normal response and appends a scannable line-item TL;DR block at the end. Use when the user runs /tldr or asks for "tldr mode", "tldr", "tldr list", "add a tldr", or "summarize responses at the end". Stays on until the user explicitly turns it off ("stop tldr", "tldr off", "normal mode", or "no summary").
---

# TL;DR Mode

Persistent on/off switch. When ON, write the response normally, then append its too-long-didn't-read version as line items.

## Toggle behavior

- **Turn ON**: user runs `/tldr` or says "tldr mode", "tldr on", "tldr list", "add a tldr", etc. Once on, append a TL;DR to **every substantive response**.
- **Turn OFF**: only when the user explicitly asks — "stop tldr", "tldr off", "normal mode", "no summary", or similar.
- **Never self-disable.** Unlike compression skills, TL;DR does not turn itself off for any topic, warning, or action type. It persists until the user says otherwise.
- Toggling on/off is the one exception where you may briefly confirm (e.g. "TL;DR on." / "TL;DR off."). Otherwise no self-referential announcements.

## The complete response is not affected

- Write the complete response exactly as you normally would without this skill. Preserve its explanation, context, caveats, examples, formatting, and requested level of detail.
- Do not shorten, restructure, simplify, or omit content from the complete response merely because TL;DR mode is active. This skill changes the format of the appended block only — it is not a license to truncate the response itself.

## How to write the TL;DR block

- Open with a `## TL;DR` heading. Keep it last. Do not add commentary after it.
- **No prose.** No narrative, no connective tissue, no lead-in, no wrap-up. The goal is scannability, not brevity — a line-item block may run as long as a prose paragraph and still read faster.
- **One fact per line.** Each line must stand alone: readable without having read the lines above it, and safe to stop after.
- **Group by kind of thing**, under bold sub-headers. Headers emerge from what the content actually contains rather than from a fixed template. A docs-only change produces different groups than a debugging session.
- Omit a group entirely when it is empty — *unless* its emptiness is itself the fact worth stating (`**Behavior change** — None. Documentation only.`).
- **Front-load anything surprising or needing a decision** from the user. If one group is more important than the rest, it goes first.

### Stable spine

Let headers be content-driven, but reach for these when they fit, so the block's shape stays recognizable from one response to the next:

- **Behavior change** — what is different now, from the user's point of view.
- **Needs your attention** — scope calls, deviations, surprises, open decisions.
- **Validation** — what was run and what it reported.
- **State** — what is and is not committed, pushed, deployed, left running.

### Reasoning: what to cut and what to keep

- **Cut** reasoning that defends the work. The user gets the conclusion; they will ask if they want the justification.
- **Cut** reassurance, hedging, and restatements of what the user asked for.
- **Keep** reasoning behind a call made on the user's behalf — a scope stretch, a deviation from spec, a surprising discovery that changed the approach. That is not self-justification; it is what the user needs in order to disagree.

## What to preserve

- Preserve technical accuracy, exact terminology, numbers, names, and details whose omission would make the summary misleading or unusable.
- Preserve commands, file paths, and identifiers verbatim when they are essential to the bottom line.
- Preserve critical safety warnings for destructive or irreversible actions in both the complete response and, when material to the requested action, the TL;DR.
- Do not introduce information in the TL;DR that is absent from or inconsistent with the complete response.
- Use the same language as the complete response.

## Example

The complete response here would be the full delivery report — changed files, per-file rationale, the standards and spec review output, and validation detail. It is written in full, unshortened, and then followed by:

## TL;DR

**Behavior change**

- A 401, 404, or 400 from the Config API now reaches the caller as an error.
- Those were previously answered from a cache that could be up to 24 hours stale.
- A 503, 429, 408, transport failure, or client-side timeout still serves the last-good value, unchanged.

**Needs your attention**

- I widened the two new tests from facts to theories because 429 and 408 had no coverage anywhere in the repo.
- `dotnet test Fsi.sln` exits non-zero for a pre-existing reason: `Fsi.Testing` and `Fsi.Testing.Assertions` reference xunit without the test SDK. Unrelated to this change.

**Validation**

- Build: 0 errors.
- Tests: 1,519 passing, 0 failing, across all six projects — up 6.

**State**

- Nothing committed, nothing pushed.
- All ten acceptance criteria met.
