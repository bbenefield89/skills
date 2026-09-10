# Architecture coherence

Help the user understand whether the code fits the surrounding system and why that matters.
Apply these checks to existing code and changes. For changes, distinguish introduced concerns from existing conditions.

## Four checks

| Area | What to inspect |
|---|---|
| Responsibility placement | Whether behavior belongs to its current owner, or introduces an unrelated responsibility or competing owner. |
| Dependency direction | Whether calls and imports respect meaningful boundaries, or create cycles, bypasses, or dependencies on another module's internals. |
| Duplication and competing abstractions | Whether existing services, helpers, state owners, or transformations already serve the same responsibility. |
| File and folder organization | Whether placement follows project conventions and helps someone predict where behavior and tests belong. |

Compare the selected code with relevant callers, nearby implementations, documented decisions, and existing abstractions before identifying a concern.
Search for existing owners of the behavior. Similar names alone do not establish duplication.
Use actual responsibilities and dependencies as evidence, rather than assuming architecture from class names or directory names.
Scale inspection to the code's risk and reach. Keep trivial changes brief; inspect consequential boundaries more closely.
Stay within the selected subject and the surrounding context needed to explain it, rather than auditing the entire repository.

## Decide what matters

Raise a concern when evidence shows a concrete consequence for correctness, maintenance, navigation, or ownership.
Examples include two locations that must change together, unrelated reasons for a module to change, or a bypass of an established boundary.
Ground each concern in verified code and explain the affected behavior or future maintenance task.
When intent or coverage is uncertain, label the uncertainty and describe what evidence would resolve it.

Use project conventions and scale as context, not proof that every existing pattern is sound.
Explain a harmful existing pattern when it matters to the subject, without assigning it to a new change incorrectly.
Recommend additional layers or abstractions only when they address a demonstrated problem.
Treat folder layouts, small helpers, and direct dependencies according to their actual consequences rather than theoretical ideals.
Distinguish concerns with near-term consequences from improvements that can reasonably wait. Explain the reason for that distinction.
Leave the architectural decision with the user. Understanding a tradeoff does not require agreeing with the agent's recommendation.

## Teach concerns in the walkthrough

Introduce a concern when the walkthrough reaches the relevant code, after explaining its current behavior.
Show the code evidence, explain the consequence, and describe a proportionate alternative when useful.
Ask one focused application question, then wait. Use the main skill's clarification loop before continuing with dependent concepts.
Reuse this question as the teaching step's comprehension check rather than adding a separate quiz.

Example: A controller and `PricingService` both calculate the same discount.
Show both implementations and explain how their results can diverge after a rule changes.
Ask: “If the discount policy changes, where would you inspect to keep the behavior consistent?”
Accept an answer that identifies the two owners and the risk, even if the user chooses to retain the duplication.
If the answer misses an owner, trace both call paths and check again with a concrete pricing scenario.

Keep findings inside the interactive lesson. Use the final recap only to summarize meaningful concerns already discussed and unresolved decisions.
Avoid a mandatory architecture report, status grade, or four empty subsections.
If summarizing a clean inspection, say “No meaningful structural concerns found in the inspected scope.”
Disclose material inspection gaps instead of presenting them as a clean result.
The walkthrough remains read-only and does not impose a PR approval gate or authorize refactoring.
