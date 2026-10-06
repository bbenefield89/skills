# Comments and documentation

Review relevant code comments, native API documentation, and maintained documents associated with the requested scope.
Apply repository requirements for documentation format and coverage.

## CD1. Accuracy and useful coverage

Compare each documented claim with the implementation and its callers.
Check purpose, ownership, inputs, outputs, side effects, failure behavior, and lifecycle constraints where they matter.
Identify obsolete explanations, contradictory examples, and incorrect contracts.
For missing documentation, identify the non-obvious information needed to use or change the code safely.
Accept clear code without comments when no important contract or rationale is missing.
Prefer explanations of reasons, constraints, and contracts over comments that repeat visible syntax.
Keep required legal notices and supported rationale.

## CD2. STE alignment

Read the shared [ASD-STE100 skill](../../asd-ste100/SKILL.md) and its writing profile before assessing English prose.
Use the shared profile as the language standard. Keep its detailed rules in that source.
Honor required documentation languages and repository terminology.
Preserve identifiers, API names, commands, code examples, exact quotations, and necessary domain terms.
Preserve native documentation syntax, including GDScript `##` and XML tags such as `<summary>` and `<param>`.
Evaluate natural-language text inside those structures.

Apply STE where it fits the documentation's purpose and requirements.
If the shared guidance is unavailable, report the limit and assess basic clarity and accuracy from available evidence.
Describe alignment with the shared profile without claiming formal ASD-STE100 certification.

## CD3. Findings and severity

Separate an incorrect contract from a prose improvement.
Rank incorrect or missing information by its supported effect on behavior, operation, or maintenance.
Treat language polish as Low unless the ambiguity has greater practical consequences or breaks an applicable requirement.
Consolidate repeated writing problems by their common cause and representative locations.
Classify a preference as a Recommendation unless a user or repository requirement makes it mandatory.
Suggest a concrete wording correction while keeping the review read-only.
Avoid adding comments to every obvious method or proposing a general documentation rewrite outside the requested scope.

Example of a useful contract:

```csharp
/// <summary>Writes the profile to the caller-owned stream. Leaves the stream open.</summary>
```

Check that the implementation leaves the stream open before accepting this documentation.
A concise sentence with an incorrect ownership claim still requires a finding.
