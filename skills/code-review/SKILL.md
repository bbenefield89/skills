---
name: code-review
description: Reviews diffs, modules, or codebases against general engineering principles, applicable language and framework practices, and repository rules. Use when the user requests a code review of a PR, branch, working changes, files, or a codebase. Reports evidence-based findings in tables ranked High, Med, and Low without editing the reviewed code.
---

# Code Review

Review the requested scope without editing source files, creating commits, or changing tracker state.
Use repository evidence to select rules and prove findings.

## 1. Establish the scope

- Honor the user's requested PR, revisions, working changes, files, module, or codebase.
- If context does not establish the scope, ask one scope question. Continue independent rule discovery while awaiting the answer.
- Resolve comparison refs to commit IDs. Use endpoint comparisons for explicit revisions and merge-base comparisons for branch or PR changes.
- Include staged, unstaged, and relevant untracked files when the request covers working changes.
- Read surrounding implementations, callers, tests, and resources needed to understand the requested code.
- Read comments and documentation relevant to the reviewed code.
- For change reviews, report defects introduced or exposed by the change. Identify relevant existing defects separately as context.
- Record reviewed commit IDs or working-file hashes. Recheck them before reporting if concurrent changes are possible.

The scope is ready when its boundaries and comparison method are explicit.

## 2. Select applicable rules

- Read applicable `AGENTS.md` instructions and their referenced standards.
- Inspect coding standards, architecture decisions, contribution guidance, and an available issue or specification.
- Detect languages, frameworks, and versions from project files and dependency configuration.
- Read [General rules](references/general.md) for every review.
- Evaluate SOLID, Clean Code, Clean Architecture, and comments/documentation as explicit general review areas.
- For Godot code or scenes, read [Godot rules](references/godot.md).
- For C# or .NET code, read [C# and .NET rules](references/csharp-dotnet.md).
- Combine applicable profiles. A Godot project using C# requires both profiles.
- For other stacks, use repository guidance and official documentation for the detected version.
- Apply each rule only to code where its condition is relevant. UI rules do not apply to unrelated gameplay code.

Explicit user instructions and repository conventions override generic design preferences.
An accepted convention does not suppress evidence of a correctness or security defect.
Label unwritten conventions as observations rather than mandatory rules.
Distinguish documented requirements, language or framework contracts, and design recommendations.

Rule selection is ready when the applicable sources, profiles, versions, and exceptions are known.

## 3. Inspect and verify

- Trace behavior and ownership across relevant boundaries. Evaluate applicable general, stack, and repository rules.
- If a specification exists, check its required behavior and scope. Continue general review when no specification exists.
- For each candidate, identify the location, trigger, consequence, supporting rule, and smallest useful correction.
- Check surrounding code for an existing safeguard, accepted tradeoff, or valid framework exception.
- Use focused existing checks when they can resolve a material uncertainty. Report exactly what each check establishes.
- Keep verification within review authorization. Avoid commands that rewrite source, install dependencies, or affect external systems.
- Put unresolved material questions in verification limits. Reserve findings for supported defects or concrete improvement opportunities.
- Consolidate repeated symptoms of one root cause. Avoid duplicating analyzer output or repeating a finding across rule layers.

A finding is ready when evidence supports its impact and suggested correction.
Passing tests support the behavior they exercise. They do not establish design quality or visual acceptance.

## 4. Report

Read [Report format](references/report-format.md) before writing the result.
Use its severity definitions, finding types, and separate tables.

When available, apply the sibling [ASD-STE100 skill](../asd-ste100/SKILL.md) and its writing profile.
If unavailable, use plain technical language and state the writing-guidance limit.
Keep the required tables and evidence when the user requests concise output.

The review is complete when all requested scope has coverage or an explicit limitation.
An empty findings table is a valid outcome. Report coverage, verification, and limits without inventing findings.
