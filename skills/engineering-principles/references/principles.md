# Engineering principles

## Clean Code

- Use intention-revealing names in the project's domain vocabulary.
- Keep functions cohesive and at one abstraction level.
- Prefer shallow nesting and clear early exits.
- Remove duplication when it repeats the same responsibility or policy.
- Comments explain why, constraints, or non-obvious contracts; they do not narrate syntax.
- A function over roughly 12 logical lines triggers scrutiny for mixed responsibilities, abstraction levels, or extractable policy. Length alone is not a violation.

## SOLID

- **SRP:** a module has one coherent responsibility and one meaningful reason to change.
- **OCP:** demonstrated variation can extend at a real seam without repeated conditional editing. Do not build speculative plug-in systems.
- **LSP:** every adapter or subtype honors the complete interface contract and remains substitutable.
- **ISP:** callers depend on focused interfaces rather than unrelated capabilities.
- **DIP:** stable policy depends on supplied interfaces; volatile framework and infrastructure details are adapters.

## Clean Architecture

- Point dependencies toward stable policy when doing so creates leverage.
- Expose small interfaces and hide implementation detail.
- Keep external systems and frameworks replaceable behind real seams.
- Organize by responsibilities and reasons to change, not ceremonial layers.
- Introduce an abstraction only for demonstrated variation, test leverage, or locality.

## Implementation questions

1. What responsibility and reason to change does each affected module have?
2. Is the public interface smaller and more stable than its implementation?
3. Are dependencies explicit and supplied at the correct seam?
4. Do tests observe behavior through public interfaces?
5. Is every new abstraction justified by a current need?
