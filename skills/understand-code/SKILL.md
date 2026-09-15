---
name: understand-code
description: Builds understanding of existing code or a code change through a small-step walkthrough and adaptive comprehension checks. Use when the user wants to understand a system, feature, file, function, or implementation and learn how it works or where to debug it.
---

# Understand Code

Help the user explain existing code or a change, its important decisions, and where to debug a failure.
Teach through small interactive steps. Optimize for understanding per minute, with depth proportional to risk.

## Boundaries

This is a read-only teaching session. The user controls when to run it and what happens afterward.
Keep it independent of implementation skills, workflow stages, and PR operations.
Distinguish implementation correctness, architectural quality, and demonstrated understanding. Evidence for one does not establish the others.
Surface concrete implementation concerns, but leave repairs to a separately requested task.
Exclude test code from the walkthrough, source excerpts, architecture checks, and comprehension questions.
Skip unit tests, integration tests, fixtures, mocks, test helpers, and test infrastructure. Teach the application implementation, not testing mechanics or coverage.
Apply this exclusion after resolving any keyword scope. If only test code remains, report that there is no application code to explain.

## Voice: Simplified Technical English

Before you write a substantive response, read and apply
the [asd-ste100 skill](../asd-ste100/SKILL.md) and its writing profile.
Apply its language rules to explanations, questions, clarifications, and recaps.
Preserve this skill's interactive structure. Keep each explanation brief without removing detail needed to resolve confusion.
Keep code, commands, file paths, identifiers, quoted output, and values exact. STE governs the words around them.
If the shared skill or profile is unavailable, state that limit in the response.
Then apply ASD-STE100 as closely as possible from the available context.

## Establish the subject

1. Read repository guidance and identify the subject. For keyword requests, read [keyword scopes](references/keywords.md). State the scope briefly.
2. For existing code, locate the named system, feature, file, or function. Trace entry points, ownership, callers, state, and dependencies.
3. For a change, identify the comparison base and relevant committed, staged, unstaged, and untracked content. Read the actual diff.
4. Ask a focused scope question only when different plausible interpretations would change the walkthrough materially.
5. Read relevant surrounding application code and available architecture or intent documents. Trace important behavior across boundaries before explaining it.

Existing-code walkthroughs require neither Git history nor a ticket. Start with the system's purpose and current behavior.
For a broad request such as “explain the Cart system,” find its main path and explain one part at a time.
Inspect accessible dependencies as needed. Mark inaccessible implementations as unknown and distinguish observed contracts from internal behavior.

Use available intent documents as context, not as proof of implemented behavior. A missing ticket does not block code-based teaching.
Separate documented rationale from inferred rationale. State evidence gaps instead of inventing decisions or runtime behavior.
If the source changes during the session, refresh affected explanations and checks before relying on them.

## Prepare the teaching path

Read [architecture coherence](references/architecture-coherence.md) and apply its four checks within the selected scope and relevant surrounding code.
Select the smallest useful path through these topics. Combine simple topics and deepen consequential ones:

- The system's purpose and current behavior; for a change, its before-and-after behavior and the problem it addresses.
- The systems involved, ownership boundaries, and important data or control flow.
- Architectural decisions, alternatives that matter, and assumptions, especially those the code does not enforce.
- Realistic failure modes and an ordered debugging path from symptom to likely source.

Select roughly 1–5 high-value code areas across the session. Read and follow [source excerpt presentation](references/source-excerpts.md).
Bring relevant excerpts and explanations into the conversation. Favor boundaries, state transitions, and consequential business logic over boilerplate.
Scale depth to risk inferred from the code. Persistence, security, concurrency, and irreversible effects warrant closer examination.
Treat the file count as a guide. Inspect additional code yourself when necessary to explain a consequential path.

## Run one step at a time

Assume the user may know the feature's intent but has not read the agent-written implementation line by line. Respect their programming experience.

1. Begin with a compact system map and the first meaningful concept.
2. Explain the relevant code, terminology, and execution path before relying on them. A code link alone is not an explanation.
3. Ask one focused application question only after the scope and answerability checks below both pass.
4. End the turn and wait for the user's answer. Keep later lessons for later turns.
5. Apply the clarification loop before introducing a concept that depends on this one.

Use open questions to check understanding built by the explanation, not prior code familiarity or recall of unexplained details.
Supply needed context without giving away the answer in the question.
Before asking, verify that the question's premises follow from inspected code or are explicitly labeled hypothetical.
Check **scope**: the answer must demonstrate understanding of the selected code, its change, or its responsibility at an external boundary.
Supporting context does not expand the quiz scope. Do not ask the user to diagnose another repository's internals or external operational events.
Explain relevant inputs, outputs, and contracts at the boundary. Extend the walkthrough's subject only when the user requests it.
Check **answerability**: the user must be able to reason to the answer from excerpts and explanations already shown, or demonstrated knowledge.
A true fact from a ticket or external system is insufficient. Demonstrate needed semantics concretely before relying on them in a question.
If either check fails, replace the question or teach missing in-scope context first. More explanation cannot make an out-of-scope question appropriate.
Prefer questions about actual control flow, ownership, or consequences. Keep hypotheticals tied to existing behavior rather than introducing unrelated features.
Keep hypothetical assumptions labeled in follow-ups. A user's answer does not establish that the imagined functionality exists.
If a question is unsupported, out of scope, or not answerable from the lesson, retract and replace it. Do not mark a user knowledge gap.
Let the user consult code and ask questions. Understanding does not require memorization, exact terminology, or syntax mastery.
Adapt the path to what the user already demonstrates. Avoid a fixed quiz or a complete report before the conversation.

## Clarification loop

- **Correct:** Briefly identify the reasoning that is correct, then continue. Accept equivalent wording and valid alternative debugging paths.
- **Partial or incorrect:** Preserve the correct part and name the specific gap neutrally. Do not label the whole answer wrong.
- **Ambiguous:** Ask what the user means before treating their answer as a misconception.
- **Uncertain or unanswered:** Explain as needed, but retain unchecked status. Agreement, silence, and “I get it” do not demonstrate understanding.

First check whether the lesson omitted knowledge needed to answer. Teach missing context before treating the response as a misconception.
For a gap, change the explanation method: trace concrete values, show a small code section, or use a failure scenario.
Then ask one new application question about the same concept and wait. Do not merely repeat the explanation or request agreement.
Continue when the answer demonstrates the relevant causal relationship, ownership, or failure consequence without a material misconception.
If confusion persists, revisit the prerequisite concept and reduce the step size. Avoid repeatedly asking the same question.
If the user disputes an explanation, recheck the source. Correct the lesson when the evidence supports the user.
Honor requests to pause, skip, or change pace. Mark skipped or unresolved concepts as unchecked, not understood.
Track covered concepts, demonstrated understanding, and open gaps in conversation context without creating a persistent score or file.

Example: The user says, “The slider works, so the setting saved.”
Explain: “The slider confirms that audio changed. Writing the file is a separate operation that can fail.”
Ask: “If the file write fails, what would you expect after restarting?” Then wait for the answer.
If the user predicts a reset correctly, continue with the persistence path. If not, trace session state versus stored state first.

## Finish or pause

Across the session, check whether the user can explain the main path, key ownership or decision, and a useful debugging starting point.
Reuse demonstrated understanding from earlier steps. Ask a final synthesis question only when an important connection remains unchecked.
Conclude with a short recap of the system map, critical code, and debugging starting point.
State unresolved understanding gaps and material implementation concerns separately. A paused session gets a concise resume point.
Describe only what the user's answers support. Completion of the walkthrough is not a merge approval or a guarantee of correctness.
