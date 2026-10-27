---
name: bb-grill
description: Runs /grill-with-docs with a strict scope ledger and concrete, real questions.
disable-model-invocation: true
---

# BB Grill

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

## Run grill-with-docs

Call the Skill tool twice, for `grilling` and `domain-modeling`. This is all that `/grill-with-docs` does, and it is user-invoked, so call its two skills directly. They own the interview, the rounds, the recommended answers, and the glossary and ADR updates. Add only the rules below.

## Keep a scope ledger

Before the first round, resolve the operating system's temporary directory with a platform-native facility and create a uniquely named Markdown file in it. Keep the ledger out of the repository.

```markdown
## TL;DR

<What is being grilled, in one or two sentences.>

## IN SCOPE

- <Scope item>

## OUT OF SCOPE

- <Excluded or parked item, or "None yet">
```

- Fill `TL;DR` and `IN SCOPE` from the user's request. If the request does not make the scope clear, make the scope the first question.
- Change `TL;DR` or `IN SCOPE` only when the user's answers explicitly refine the goal or scope. Do not broaden `IN SCOPE` merely to permit a proposed question.
- Add to `OUT OF SCOPE` each topic the user excludes and each question the gate rejects, when it happens. Move an item back to `IN SCOPE` only when the user explicitly brings it back.

If the ledger cannot be created, read, or updated, stop before the next round and report the failure.

## Gate every question

Before each round, reread the ledger. For each question that the underlying skills propose:

1. Name the one `IN SCOPE` item that the question serves. A question serves an item only when its answer settles part of that item. A question that is merely related to an item, or that only becomes useful after an out-of-scope decision, does not serve it.
2. If no `IN SCOPE` item fits, or the question touches an `OUT OF SCOPE` item, reject it and add it to `OUT OF SCOPE`.

Ask an out-of-scope question only when it is necessary to advance the `TL;DR` and no in-scope question can resolve the need. Put a `SCOPE EXCEPTION:` line with the concrete reason before that question.

## Word every question

Rewrite each question from the underlying skills until it passes every rule below. Keep the decisions that those skills chose.

- **One decision per question.** Each question settles exactly one decision. When a proposed question bundles several claims, split it into one question per claim.
- **A labeled question line.** Put the question in its own `**Question:**` line, directly under the title. It is one interrogative sentence that ends in `?`, and it is the only sentence in the question that ends in `?`.
- **The question line stands alone.** It states the decision itself, so it makes sense with everything else hidden. Write "Should the Settings panel save each volume change itself?", not "Is that right?". It points at nothing outside itself: no "that", "this", "the above", or "the following".
- **Name every referent.** Name the specific thing: the component, file, screen, state, rule, or glossary term. Write "the Inventory and Map panels in `HUD.tscn`", not "the panels". If you do not know the name, find it before you ask. Finding facts is your job.
- **Bold the keywords.** In the question line, bold the named referents and the one word or phrase that carries the decision, so the eye finds them first: "Should the **Settings panel** **save each volume change** itself?". Bold two to four keywords per line; a line in which most words are bold has no keywords. Keep file and code names in backticks, inside the bold: "**`HUD.tscn`**". In `Context:`, bold only a name the first time it appears.
- **Context supports the question line.** Put the background and options under `**Context:**` as short bullets. Context only explains the question line; it never adds a claim that the user must also accept.

Test each question: a reader who sees only the `**Question:**` line knows exactly what decision it asks for and what a valid answer looks like.

## Show every round

Start each round with the current ledger, then show each question in the shape below. This shape replaces the `grilling` question format; keep its recommended answer, worded so that "yes" accepts it. Number questions across the whole session: the first question of a round continues from the last number shown.

```markdown
**TL;DR:** <TL;DR>
**IN SCOPE:** <items, separated by semicolons>
**OUT OF SCOPE:** <items, separated by semicolons>

---

❓ **Q7 - <question title>**

**Question:** <one standalone interrogative sentence>

**Context:**
- <background or option>

**Serves:** <IN SCOPE item>

➡️ **Recommended:** <recommended answer>
```
