# Implementation phase

Implement the accepted specification against the core standard, every selected technology profile, and repository guidance.

## Work test-first

For each smallest meaningful vertical slice:

1. Identify the public behavior and observable outcome.
2. Write a focused failing test when that behavior is testable through a legitimate production contract.
3. Run it and confirm it fails for the expected reason.
4. Write the minimum production code that satisfies the behavior.
5. Run focused parser, type, and test feedback.
6. Refactor while green.
7. Continue with the next slice.

Run the full relevant test suite when implementation ends.

Test only public production contracts and observable behavior. Never test private or protected APIs directly. Never add a public method, signal, property, hook, or visibility change solely for tests.

If an acceptance criterion is genuinely untestable through a legitimate public seam, ask whether production design should change or the behavior should remain untested. If the subject is merely a private implementation detail, do not test it directly; verify it through review or tooling and report material uncertainty.

## Apply the standard proactively

- Keep changed code and directly affected interfaces cohesive, readable, typed, documented, and appropriately tested.
- Directly fix clear in-scope quality problems instead of deferring them to review.
- Run focused validation after each meaningful group of changes.
- Leave unrelated legacy problems untouched unless they prevent delivery or the user expands scope.
- Report significant nearby debt briefly without turning delivery into a whole-file or repository refactor.
- Ask before architectural, behavioral, or scope-expanding changes.

Mock collaborators at legitimate dependency-injection seams unless the repository has an established alternative. Do not mock the subject under test or private internals. Verify collaborator calls only when the interaction is part of the public responsibility; avoid incidental call order and implementation transcripts.

Do not run an independent code-review phase from inside Implementation. Do not commit or push unless the current user explicitly instructs it.
