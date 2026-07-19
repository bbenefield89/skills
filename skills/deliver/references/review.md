# Read-only review phase

Review only after Implementation completes. Do not edit files during review.

Review the current task's staged, unstaged, and untracked non-ignored changes relative to the recorded initial worktree. Exclude unrelated pre-existing changes. Ask when overlapping ownership cannot be separated safely.

Run two independent passes. Prefer parallel reviewers when available; otherwise use separate passes without carrying findings from one axis into the other.

## Standards review

Compare the changes with:

- repository guidance;
- the core engineering standard;
- every selected technology profile;
- the accepted testing and documentation contracts.

Report concrete harm, not acronym-only criticism. Apply principles proportionally and do not demand an interface, layer, pattern, or refactor without a present responsibility, variation, boundary, or maintainability benefit.

## Spec review

Compare the changes with the authoritative request and acceptance criteria. Look for missing requirements, incorrect behavior, regressions, and scope creep.

## Findings and loops

Classify findings:

- **Required:** correctness, specification, public-contract, unsafe dependency direction, materially mixed responsibility, unreadable or fragile control flow, untestable required behavior, or a clear maintainability regression.
- **Required within changed scope:** a clear violation in changed lines or directly affected interfaces that can be corrected without expanding architecture, behavior, or scope.
- **Advisory:** nearby legacy debt, a reasonable alternative without material advantage, or a speculative improvement not justified by the current request.

Every actionable Required finding returns to Implementation. This includes formatting, naming, documentation, typing, and other straightforward hygiene findings; Review never fixes them directly.

After fixes, rerun both complete passes because fixes may materially change either axis. Allow at most two unsuccessful correction cycles for the same finding or related cluster. Then stop and request conflict resolution instead of looping indefinitely.

Preserve the final Standards and Spec outputs independently and unabridged for the completion report.
