# Core engineering standard

Apply this standard during both Implementation and Standards review.

## Precedence

Resolve rules in this order:

1. Current specification and acceptance criteria.
2. Explicit repository architecture and coding standards.
3. Applicable language and framework profiles.
4. This core standard.
5. Personal preference.

Repository conventions win when healthy and compatible with the specification. Correctness, security, and framework lifecycle constraints may justify exceptions.

## Readable, focused changes

- Choose the simplest design that fully satisfies current behavior.
- Reject speculative features, layers, extension points, and abstractions justified only by imagined future needs.
- Keep work scoped to changed code and directly affected interfaces.
- Use intention-revealing names and make control flow read top-to-bottom like a story.
- Prefer guard clauses for disqualifying paths and named helpers for genuinely complex concepts.
- Replace dense or unusual conditions with meaningful names when doing so improves the narrative.
- Do not create meaningless helpers merely to reduce line counts.
- Comments and documentation explain intent, contracts, rationale, and non-obvious behavior rather than restating syntax.

Treat these as serious design prompts, not automatic failures:

- A created or modified method has 12 or more logical lines.
- A method has three or more parameters.
- A boolean parameter selects between distinct operations.
- Control flow is deeply nested or mixes abstraction levels.
- A class has many injected dependencies.

For a 12-plus-line method, decide whether decomposition would make the story clearer. Keep it intact when one cohesive narrative is clearer than fragmented helpers. Prefer a cohesive parameter object when several parameters form one recurring concept; do not wrap unrelated values merely to lower a count. Replace behavior-selecting boolean flags with intention-revealing operations, while permitting booleans that are genuine domain data.

Prefer queries that return information without changing observable state and commands that change state without masquerading as queries. Permit explicit conventional combined operations such as `pop()`.

## Cohesion, SOLID, and boundaries

- Group code that changes for the same reason and separate code that changes for different reasons.
- Keep responsibilities cohesive; SRP does not mean one method per class.
- Extend stable policy around current, demonstrated variation. Do not prebuild strategies, factories, plugins, or interfaces for hypothetical variation.
- Preserve substitutable contracts: implementations must not strengthen preconditions, weaken promised outcomes, introduce surprising failures, or force callers to branch on concrete type.
- Split broad interfaces when real clients need disjoint capabilities or implementations would require meaningless operations. Do not create one-method interfaces by rote.
- Keep business policy independent of UI, persistence, transport, frameworks, clocks, randomness, and platform services when those form meaningful boundaries.
- Pass simple boundary data instead of leaking external framework types into core policy.
- Preserve a repository's coherent architecture. Add a boundary only when the current work otherwise couples policy to a volatile detail, mixes reasons to change, or violates an explicit constraint.

Inject external, expensive, nondeterministic, or volatile collaborators through legitimate production seams. Do not wrap every stable concrete class, value object, data holder, or pure helper in an interface.

## Tests and collaborators

- Test public production contracts and observable behavior.
- Never test private or protected APIs directly.
- Never expose pseudo-public production APIs solely for tests.
- Keep tests simple, deterministic, and readable as examples of supported behavior.
- Mock collaborators at real dependency-injection seams when isolation is useful and no repository convention prefers a real collaborator, fake, or integration test.
- Never mock the subject under test or its private internals.
- Verify collaborator interactions only when the interaction itself is part of the subject's public responsibility. Avoid incidental call ordering and implementation transcripts.

## Duplication and patterns

Consolidate duplicated knowledge that represents the same rule and must change together. Leave similar syntax separate when it represents independent domain rules. Introduce a policy or strategy only for actual interchangeable behavior, explicit runtime selection, or an established repository seam.

Review for demonstrable code-health improvement rather than doctrinal perfection. Findings must describe the concrete consequence and a proportional remedy.

## Primary references

- [Google Engineering Practices: What to look for](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
- [Google Engineering Practices: The standard of code review](https://google.github.io/eng-practices/review/reviewer/standard.html)
- [Google Testing Blog: Test behavior, not implementation](https://testing.googleblog.com/2013/08/testing-on-toilet-test-behavior-not.html)
- [Google Testing Blog: Do not overuse mocks](https://testing.googleblog.com/2013/05/testing-on-toilet-dont-overuse-mocks.html)
- [Martin Fowler: YAGNI](https://martinfowler.com/bliki/Yagni.html)
- [Martin Fowler: Command-query separation](https://martinfowler.com/bliki/CommandQuerySeparation.html)
- [Robert C. Martin: Single Responsibility Principle](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html)
- [Robert C. Martin: Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Barbara Liskov: Data Abstraction and Hierarchy](https://www.cs.tufts.edu/~nr/cs257/archive/barbara-liskov/data-abstraction-and-hierarchy.pdf)
- [Microsoft: Dependency injection guidelines](https://learn.microsoft.com/en-us/dotnet/core/extensions/dependency-injection/guidelines)
