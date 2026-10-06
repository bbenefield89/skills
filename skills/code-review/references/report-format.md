# Report format

Start with the review scope and the most consequential supported result.
Name the reviewed revisions or working changes and the applicable profiles.

## Severity

Rank by consequence and reach rather than by the rule's prestige or the reviewer's confidence.

| Severity | Meaning |
|---|---|
| High | Serious supported consequences, such as data loss, a security breach, a crash in a normal path, or failure of a core requirement. |
| Med | A meaningful defect, requirement violation, or maintenance problem with a concrete effect on likely use or change. |
| Low | A limited improvement with a clear benefit and small consequences. |

A repository rule violation does not automatically receive High severity.
Use confidence separately: **Confirmed** for direct or reproduced evidence, and **Supported** for a grounded analysis with stated assumptions.
Put speculative concerns in verification limits rather than severity tables.

## Finding types

- **Defect:** The implementation breaks a behavior, language contract, or framework contract.
- **Rule violation:** The implementation conflicts with an applicable documented requirement or explicit user instruction.
- **Recommendation:** A concrete design improvement has a supported benefit but no mandatory rule.

## Tables

Use separate **General**, **Language/framework**, and **Repository** tables.
Sort each table by **High**, then **Med**, then **Low**.
Within each severity, put the greatest supported impact first.
Use consistent columns:

| Severity | Type / confidence | Location | Finding and impact | Rule / source | Suggested fix |
|---|---|---|---|---|---|

Assign each finding once, to its most specific applicable source.
A repository UI rule belongs in Repository even when a Godot preference also supports it.
Include secondary sources in that row rather than repeating the finding.
For an empty category, state **No supported findings** instead of manufacturing rows.
If no language or framework profile applies, state that fact beside the category.

Use tight, verified line locations and clickable absolute file links for local files.
Use verified diff links for PR locations when the environment supports them.
Link repository rules to their exact source and section or line.
Identify bundled rules by file and rule ID, such as `general.md G2` or `godot.md GO1`.
For design findings, name the specific SOLID principle or Clean Code/Architecture rule and its consequence.
For prose findings, cite the shared writing rule and show a concrete correction when useful.
Link official documentation when an API or framework fact supports the finding.
Describe the trigger and consequence in the finding cell. Keep the fix proportional to the problem.

Example finding content:

| Severity | Type / confidence | Location | Finding and impact | Rule / source | Suggested fix |
|---|---|---|---|---|---|
| Med | Rule violation / Confirmed | Verified menu script location | `_ready()` overwrites scene-authored spacing. Designers must change code to tune the static menu. | Verified repository UI policy | Move the spacing values into the scene or Theme resource. |

The example uses placeholder locations only to show the format. Actual reviews require verified links.

## Coverage and verification

After the tables, state:

- The inspected scope and any portions that remain unreviewed.
- Coverage of SOLID, Clean Code, Clean Architecture, and comments/documentation. Identify areas that do not apply.
- The checks performed and their outcomes. Say when no runtime checks ran.
- Material assumptions, unavailable rules, and unresolved verification questions.

Use **Partial review** when required scope or evidence is unavailable.
Use **No supported findings in the reviewed scope** when appropriate.
Avoid declaring the entire codebase correct from an empty report or passing checks.
