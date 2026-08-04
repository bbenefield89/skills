---
name: scoped-grill-me
description: Runs a relentless grilling session with numbered questions and a strict temporary scope ledger. Use when the user wants a plan or design grilled without losing track of question count or drifting outside the agreed scope.
disable-model-invocation: true
---

# Scoped Grill Me

Run a `/grilling` session. The grilling skill owns the interview workflow and question content. Apply only the scope, persistence, numbering, and output rules below.

## Initialize the scope ledger

Before asking Question 1:

1. Resolve the operating system's temporary directory with a platform-native facility. Do not hardcode a platform-specific path or write the ledger into the repository.
2. Create a uniquely named Markdown file for this session.
3. Write exactly these two semantic blocks:

```markdown
## TL;DR

<Concise description of what is being grilled.>

## IN SCOPE

- <Current scope item>
```

Update the ledger when the user's answers explicitly refine or change the goal or scope. Do not broaden `IN SCOPE` merely to permit a proposed question.

If the ledger cannot be created, read, or updated, stop before asking another question and report the failure.

## Control conversational state

Begin the session in **GRILLING**.

Enter **DISCUSSION** when the user does not directly answer the pending question and instead asks for context, asks a follow-up, challenges a premise, expresses uncertainty, wants to reason through the decision, or otherwise starts a conversational detour. When uncertain whether the user answered, prefer DISCUSSION.

While in DISCUSSION:

- Respond normally without displaying `TL;DR`, `IN SCOPE`, `SCOPE EXCEPTION`, or `Question N`.
- Do not generate, restate, or rephrase the pending question.
- Do not generate a new grilling question or increment the question number.
- Silently update the ledger only when the user explicitly changes or refines the goal or scope.
- Remain in DISCUSSION across any number of turns. Do not infer that the user is ready to resume.

Return to GRILLING only when the user explicitly says `resume grilling`, ignoring capitalization. Reread the ledger before continuing. If the discussion resolved the pending question, ask the next appropriate question using the next number. Otherwise, show the pending question again using its original number.

## Gate every question

Only while in GRILLING, immediately before asking each question:

1. Reread the ledger.
2. Let `/grilling` determine the proposed question.
3. Compare the complete proposed question with `IN SCOPE`.
4. Reject it if it is outside scope and let `/grilling` choose an in-scope question instead.

Ask an out-of-scope question only when it is necessary to advance the stated `TL;DR` and no in-scope question can resolve the need. Explain that exceptional reason in a `SCOPE EXCEPTION` block before the question.

## Number and display every question

Start at Question 1. Determine each next number from the highest `## Question N` already shown in this session, then increment by one. Never replace the number with wording such as "next question."

Every question response must reproduce the current ledger content and use this shape:

```markdown
## TL;DR

<Current TL;DR from the ledger>

## IN SCOPE

<Current IN SCOPE from the ledger>

<Optional SCOPE EXCEPTION block and concrete reason>

## Question N

<Question produced by /grilling>
```

Do not prescribe, replace, or rewrite the underlying question content beyond rejecting a proposed out-of-scope question.
