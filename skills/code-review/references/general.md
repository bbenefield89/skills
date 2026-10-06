# General rules

Apply these rules to the requested scope across languages and frameworks.
Evaluate consequences rather than compliance with a checklist alone.
The design checks are practical interpretations of Robert C. Martin's books.
They do not claim complete chapter coverage or require a fixed architecture pattern.

## G1. Correctness and contracts

Trace inputs, state transitions, outputs, and failure paths.
Inspect boundary values, ordering, persistence, and compatibility when the code uses them.
Check available requirements against observable behavior.
Support each defect with a reachable trigger and an incorrect result.

## G2. Responsibility and SOLID

Use the shared [engineering principles](../../engineering-principles/references/principles.md) as the design vocabulary when available.
If unavailable, apply standard SOLID concepts proportionally to the code's responsibilities and contracts.

Inspect mixed responsibilities, broken substitutability, broad interfaces, and dependencies that expose unstable implementation details.
Evaluate each SOLID principle through these review questions:

| Principle | Review question |
|---|---|
| SRP | Do unrelated actors or policies force the same module to change? |
| OCP | Does demonstrated variation require repeated edits across stable policy? |
| LSP | Can each implementation honor the caller's inputs, outputs, invariants, and failure expectations? |
| ISP | Must callers depend on operations or data they do not use? |
| DIP | Does stable policy directly depend on volatile implementations across an intended boundary? |

Explain the concrete change cost, testing difficulty, or contract failure.
Accept simple functions, concrete types, and direct framework use when they fit the responsibility.
Recommend an abstraction only for demonstrated variation, isolation, or a useful testing boundary.
Avoid findings based solely on missing interfaces, class size, method length, or a preferred architecture pattern.

## G3. Clean Code

Check names against the project's domain terms and actual behavior.
Check function cohesion, abstraction levels, and control flow.
Inspect long parameter lists, flag parameters, hidden side effects, and methods that both query and mutate state.
Explain how each candidate obscures behavior, mixes responsibilities, or makes a supported change harder.
Treat these as review prompts. A boolean parameter or long function is not a defect by itself.
Check whether public interfaces expose internal data that callers should not depend on.
Distinguish duplicated policy from code that merely looks similar.
Recommend shared code when the copies represent the same responsibility and should change together.
Keep legitimate adapter or orchestration layers when they hide useful detail.
Use G4 for failure handling, G6 for validation, and G8 for comments and documentation.

## G4. Failure handling and resource ownership

Trace who creates, owns, releases, retries, or replaces each relevant resource.
Check exceptions and error results for lost failures, invalid state, and partial updates.
Inspect cancellation and cleanup paths when operations can stop early.
Tie each finding to a resource lifetime or observable failure.

## G5. Concurrency, security, and performance

Inspect shared state, synchronization, and thread requirements where concurrency exists.
Trace trust boundaries, authorization, and sensitive data where the feature handles them.
Report performance concerns with a demonstrated hot path, growth pattern, measurement, or violated constraint.
Separate measured behavior from estimates. Keep unsupported optimization ideas out of findings.

## G6. Validation and scope

Assess existing checks against the change's failure modes.
For a missing-test finding, identify the unprotected behavior and why existing coverage cannot detect the regression.
Scale validation recommendations to risk. Test absence alone does not establish a High finding.
For change reviews, distinguish required behavior from unintended additions when a specification is available.

Example: Two adapters use similar loops but apply different policies.
Similarity alone does not justify a shared abstraction or a duplication finding.

## G7. Clean Architecture

Identify stable application policy and external details such as UI, persistence, and framework adapters.
Check source dependencies toward policy at intended architectural boundaries.
Inspect imports, inheritance, public signatures, and boundary data for external details that leak into policy.
Check whether application rules can be exercised without starting UI or connecting to storage.
Inspect dependency cycles that force unrelated modules to change or initialize together.
Keep useful adapter and orchestration boundaries. Follow repository responsibilities rather than requiring a fixed layer count.
Framework-specific presentation code can depend on its engine.
Explain the consequence when such dependencies reach independent policy.
Propose a boundary only when it protects an actual responsibility, change, or test.

## G8. Comments and documentation

Read [Comments and documentation](comments-documentation.md) when the scope includes prose or a missing contract affects safe use.
Assess accuracy, useful contract coverage, and STE alignment where applicable.
Tie each finding to the relevant code or documentation and its practical consequence.

## Reference basis

- [Clean Code, first edition](https://www.informit.com/store/clean-code-a-handbook-of-agile-software-craftsmanship-9780132350884): Names, functions, comments, error handling, classes, and design heuristics.
- [Clean Architecture](https://www.informit.com/store/clean-architecture-a-craftsmans-guide-to-software-structure-9780134494166): SOLID, component dependencies, boundaries, and testable policy.
- [The author's Dependency Rule explanation](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html#the-dependency-rule): Source dependencies and data across boundaries.
