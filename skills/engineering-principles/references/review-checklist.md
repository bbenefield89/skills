# Review checklist

Inspect names, function cohesion, abstraction levels, nesting, duplication, comments, module responsibilities, substitutability, interface focus, dependency direction, seams, framework coupling, and speculative generality.

Report each material finding as:

```text
Severity: blocking | actionable | advisory
Location: <file and tight line or hunk>
Principle: <Clean Code, SOLID member, or Clean Architecture rule>
Impact: <correctness, maintainability, testability, or change-cost consequence>
Smallest useful fix: <concrete proportional correction>
Exception: <optional accepted reason>
```

Do not fail a function solely because it exceeds 12 logical lines. Explain the mixed responsibility or abstraction problem, or omit the finding.
