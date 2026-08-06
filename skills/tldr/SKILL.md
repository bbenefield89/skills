---
name: tldr
description: Persistent response mode that replaces the normal prose response with a scannable line-item summary. Use when the user runs /tldr or asks for "tldr mode", "tldr", "tldr list", or "just give me the tldr". Stays on until the user explicitly turns it off ("stop tldr", "tldr off", "normal mode", "full response").
---

# TL;DR Mode

Persistent on/off switch. When ON, the line-item summary **is** the response. There is no prose version before it.

## Toggle behavior

- **Turn ON**: user runs `/tldr` or says "tldr mode", "tldr on", "tldr list", "just the tldr", etc. Once on, every substantive response uses this format.
- **Turn OFF**: only when the user explicitly asks — "stop tldr", "tldr off", "normal mode", "full response", or similar.
- **Never self-disable.** TL;DR does not turn itself off for any topic, warning, or action type. It persists until the user says otherwise.
- Toggling on/off is the one exception where you may briefly confirm (e.g. "TL;DR on." / "TL;DR off."). Otherwise no self-referential announcements.

## Format

- **No prose.** No narrative, no connective tissue, no lead-in, no wrap-up, no closing offer to help.
- **One fact per line.** Each line must stand alone: readable without having read the lines above it, and safe to stop after.
- **Group by kind of thing**, under bold sub-headers. Headers emerge from what the content actually contains rather than from a fixed template. A docs-only change produces different groups than a debugging session.
- Omit a group entirely when it is empty — *unless* its emptiness is itself the fact worth stating (`**Behavior change** — None. Documentation only.`).
- **Front-load anything surprising or needing a decision** from the user. If one group is more important than the rest, it goes first.
- No `## TL;DR` heading. The response is the summary; labelling it is redundant.
- The goal is scannability, not brevity. A line-item response may run as long as the prose version would have and still read faster.

### Stable spine

Let headers be content-driven, but reach for these when they fit, so responses stay recognizable from one to the next:

- **Behavior change** — what is different now, from the user's point of view.
- **Needs your attention** — scope calls, deviations, surprises, open decisions.
- **Validation** — what was run and what it reported.
- **State** — what is and is not committed, pushed, deployed, left running.

## Cut prose, never content

This mode changes how the response is written, not how much the user is told. Compressing the answer itself is a failure of the mode, not the point of it.

- **Answer the question that was asked, completely.** If the user asked a direct question, the answer appears in full. If they asked for an explanation, they get the explanation — as line items rather than paragraphs.
- **Render code, commands, diffs, file contents, and tables in full**, in their normal blocks. These cannot be line-itemed and must not be summarized away or replaced with a description of themselves.
- **Preserve** technical accuracy, exact terminology, numbers, names, file paths, and identifiers verbatim.
- **Preserve** critical safety warnings for destructive or irreversible actions, and place them first.
- **Never** state something the work does not support, or omit a detail whose absence would make a line misleading.

### Reasoning: what to cut and what to keep

- **Cut** reasoning that defends the work. The user gets the conclusion; they will ask if they want the justification.
- **Cut** reassurance, hedging, and restatements of what the user asked for.
- **Keep** reasoning behind a call made on the user's behalf — a scope stretch, a deviation from spec, a surprising discovery that changed the approach. That is not self-justification; it is what the user needs in order to disagree.

## Example

A delivery report that would otherwise run several hundred words of prose, changed-file walkthrough, and review output:

**Behavior change**

- A 401, 404, or 400 from the Config API now reaches the caller as an error.
- Those were previously answered from a cache that could be up to 24 hours stale.
- A 503, 429, 408, transport failure, or client-side timeout still serves the last-good value, unchanged.

**Needs your attention**

- I widened the two new tests from facts to theories because 429 and 408 had no coverage anywhere in the repo.
- `dotnet test Fsi.sln` exits non-zero for a pre-existing reason: `Fsi.Testing` and `Fsi.Testing.Assertions` reference xunit without the test SDK. Unrelated to this change.

**Changed files**

- [ConfigApiRetryHandler.cs](Fsi.Domain/Services/ConfigApi/ConfigApiRetryHandler.cs:57) — `IsTransient` is now `internal static`, the single definition. Status list unchanged.
- [ConfigApiRegistryCache.cs](Fsi.Domain/Services/ConfigApi/ConfigApiRegistryCache.cs:44) — dropped its own status list, defers to that definition. Four log messages stopped claiming "Config API unreachable".

**Validation**

- Build: 0 errors.
- Tests: 1,519 passing, 0 failing, across all six projects — up 6.

**State**

- Nothing committed, nothing pushed.
- All ten acceptance criteria met.
