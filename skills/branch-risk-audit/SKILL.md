---
name: branch-risk-audit
description: Audits the current branch diff for defects and reports Critical, High, Medium, and Low risk findings with exact changed line numbers. Use when the user asks to audit or review branch changes, scan a diff or PR for regressions, or uses prompts like "perform an audit against the current changes in this branch."
---

# Branch Risk Audit

## Quick start

Audit the current branch diff and return findings at `Critical`, `High`, `Medium`, and `Low`.

If nothing clears that bar, respond exactly:

`No findings.`

## Workflow

1. Establish the review base.
- Prefer the repo default branch from `origin/HEAD`.
- Fallback in this order: `origin/main`, `origin/master`, `main`, `master`.
- Compare the branch with `git merge-base HEAD <base>`.
- If staged or unstaged local changes exist, include them and call that out.

2. Gather the changed hunks.
- Prefer `python scripts/changed_lines.py`.
- Use its output as the source of truth for file paths and changed line ranges.
- If the script cannot run, fall back to `git diff --unified=0`.
- Do not cite lines outside changed hunks unless the user explicitly asks for broader review.

3. Apply a risk-review standard.
- Report only issues that describe a plausible defect, regression, or meaningful maintainability risk in the changed code.
- Ignore pure style preferences, naming-only feedback, and speculative concerns that cannot be tied to a concrete failure mode or future change hazard.

4. Severity bar.
- `Critical`: likely production outage, data loss or corruption, security vulnerability, privilege bypass, or irreversible destructive behavior.
- `High`: strong likelihood of incorrect core behavior, serious user-visible breakage, concurrency or transaction bugs, broken retry or idempotency behavior, or missing validation with major impact.
- `Medium`: bounded functional regressions, correctness issues in non-critical flows, performance problems with noticeable impact, missing edge-case handling, or maintainability hazards likely to cause the next change to break behavior.
- `Low`: localized defects with limited blast radius, weak diagnostics, small correctness risks under uncommon conditions, or code changes that add avoidable complexity and increase future change risk.

5. Required finding format.

```md
Critical|High|Medium|Low - Short title
File: path/to/file
Lines: 42-48
Why this is risky: concrete explanation tied to the changed code
Failure mode: one sentence
Suggested fix: one sentence
```

- For deletions or replacements, use `old` and `new` ranges when needed.
- Order findings by severity, then impact.

6. Evidence rules.
- Tie each finding to a specific changed hunk.
- Explain the exact execution path or state transition that fails.
- If severity depends on an assumption, state it explicitly.
- If a concern does not justify `Critical` or `High`, assign `Medium` or `Low` instead of omitting it.

## Notes

- Default to reviewing the current repository in the current working directory.
- If the repo has no detectable base branch, say so and ask for the comparison target rather than guessing.
- Keep the response limited to findings only unless the user asks for a summary.
