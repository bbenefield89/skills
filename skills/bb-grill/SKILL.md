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

## Make every question self-contained

Each question is **self-contained**: lift it out of the round, give it to someone who has not seen this conversation, and it still makes complete sense. Rewrite each question from the underlying skills until it passes every rule below. Keep the decisions that those skills chose.

- **One decision per question.** Each question settles exactly one decision. When a proposed question bundles several claims, split it into one question per claim.
- **A labeled question line.** Put the question in its own `**Question:**` line, directly under the title. It is one interrogative sentence that ends in `?`, and it is the only sentence in the question that ends in `?`.
- **The question line stands alone.** It states the decision itself, so it makes sense with everything else hidden. Write "Should `SettingsPanel` save each volume change itself?", not "Is that right?". It points at nothing outside itself: no "that", "this", "the above", or "the following".
- **Carry every fact the question relies on.** Put each fact that the answer depends on in the question's `Context:`: earlier decisions, conclusions from a discussion, constraints, and corrections to earlier statements. State each fact in full: "`MenuPanels` requires a bound save session", not "under D4" or "under your decisions". Text outside the question, such as your reply to the user's follow-up, is lost when the question is lifted out, so repeat in the question each part of it that the question needs.
- **Use exact names.** Name each thing by its exact identifier in code format: the file, scene, class, node, method, or resource. Write "`catalog_save_preview.tscn`", not "the Catalog save preview", and "the `Inventory` and `Map` panels in `HUD.tscn`", not "the panels". A plain-English description of a named thing is not its name. If you do not know the name, find it before you ask. Finding facts is your job.
- **Explain each name.** The first time a name appears in a question, follow it with a short parenthetical that says what kind of thing it is and what it does: "**`MenuPanels`** (the node that wraps each menu in the fullscreen frame, safe area, and background)". Do this again in every question, because each question stands alone. For a glossary term, give its definition from `GLOSSARY.md` in a few words.
- **Bold the keywords.** In the question line, bold the named referents and the one word or phrase that carries the decision, so the eye finds them first: "Should **`SettingsPanel`** **save each volume change** itself?". Bold two to four keywords per line; a line in which most words are bold has no keywords. Keep code names in backticks, inside the bold. In `Context:`, bold only a name the first time it appears.
- **Context holds facts only.** Put the facts under `**Context:**` as short bullets. Context never lists an option. Context only explains the question line; it never adds a claim that the user must also accept.
- **Options get their own section.** Put the options under `**Options:**`, directly after `**Context:**` and before `**Serves:**`. Label each option with a letter: **A**, **B**, **C**. Start again at **A** in each question. Write each option as a statement that says what it changes and what it costs. Every question has at least two options. A plain do-it-or-not decision becomes **A** (do it, with its effect and cost) and **B** (do not, with its effect and cost).

Test each question: give only this question to a developer who knows the codebase but not this conversation. Without asking anything, they can say what decision it asks for, what each name refers to, and what a valid answer looks like.

## Show every round

Start each round with the current ledger, then show each question in the shape below. This shape replaces the `grilling` question format; keep its recommended answer, and name the recommended option by its letter. "Yes" or "agree" selects the recommended option. A letter selects that option. Number questions across the whole session: the first question of a round continues from the last number shown.

When the user asks about a question instead of answering it, reply, then ask the question again in full. Write the new version from the start so that it carries what your reply settled; it is never a change note against the earlier version.

```markdown
**TL;DR:** <TL;DR>
**IN SCOPE:** <items, separated by semicolons>
**OUT OF SCOPE:** <items, separated by semicolons>

---

❓ **Q7 - <question title>**

**Question:** <one standalone interrogative sentence>

**Context:**
- <fact the question relies on>

**Options:**
- **A** - <option: what it changes and what it costs>
- **B** - <option: what it changes and what it costs>

**Serves:** <IN SCOPE item>

➡️ **Recommended:** <letter> - <answer>
```
