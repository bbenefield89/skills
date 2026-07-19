# Canonical version-1 legacy signatures

Read this file only when discovery finds legacy setup-godot-project policy artifacts. It exists solely to distinguish unchanged generated version-1 content from user customization.

Normalize CRLF and LF line endings before comparison. Do not normalize spaces, wording, headings, links, table rows, or markers.

## `docs/agents/implementation.md`

```markdown
<!-- setup-godot-project:template=implementation;version=1;section=contract -->
# Implementation contract

Implementation is complete only after the accepted specification is implemented through agreed public test seams, applicable language hygiene is resolved, final Standards and Spec review is complete, and `final_validation` passes.

Use the capabilities in `workflow-adapters.md`. Apply `engineering_quality` during implementation and review. Use vertical red/green TDD slices where practical. Leave verified changes uncommitted unless the current user request explicitly authorizes a commit; an explicit `do not commit` always wins.
```

## `docs/agents/workflow-adapters.md`

```markdown
<!-- setup-godot-project:template=workflow-adapters;version=1;section=bindings -->
# Workflow adapters

| Capability | Adapter | Required | Applies when | Verification |
| --- | --- | --- | --- | --- |
| `implementation_driver` | `$implement` | yes | implementation work | skill is globally available |
| `test_driven_development` | `$tdd` | yes | implementation work | skill is globally available |
| `engineering_quality` | `$engineering-principles` | yes | implementation and review | skill is globally available |
| `gdscript_hygiene` | `$gdscript-cleanup` | yes | touched `.gd` or `.tscn` | skill is globally available |
| `change_review` | `$code-review` | yes | completed change | skill is globally available |
| `final_validation` | `just validate` | yes | every delivery | recipe exists and executes |
| `project_setup` | `$setup-godot-project` | yes | missing Godot guardrails | skill is globally available |
```

## `docs/agents/gdscript.md`

```markdown
<!-- setup-godot-project:template=gdscript;version=1;section=standards -->
# GDScript standards

Use concrete project types, explicit local types, typed enums, typed getters, typed exported node references, direct method calls, and native `##` documentation. Refresh Godot metadata before weakening an unresolved project type.

> If a Godot object is a stable, intentional part of the game world, author it in a scene. Create objects at runtime only when their existence or quantity is genuinely dynamic.

Runtime construction of stable world objects is an actionable review finding unless genuinely dynamic behavior is documented.
```

## `docs/agents/architecture.md`

```markdown
<!-- setup-godot-project:template=architecture;version=1;section=principles -->
# Architecture

Apply `$engineering-principles`: intention-revealing code, cohesive responsibilities, proportional SOLID, dependency direction toward stable policy, focused interfaces, explicit dependencies, and replaceable external adapters. Introduce seams only for demonstrated variation or test leverage. Let real features establish folders and modules.
```

## `docs/agents/testing.md`

```markdown
<!-- setup-godot-project:template=testing;version=1;section=contract -->
# Testing

GUT is the default framework. Record the vendored version here during setup.

Agree public behavior seams before writing tests. Work in vertical red/green slices and avoid tests coupled to private implementation. Use `just test <test-path>` for focused feedback and `just test-all` for the full suite.
```

## `docs/agents/code-review.md`

```markdown
<!-- setup-godot-project:template=code-review;version=1;section=contract -->
# Code review

Review every delivery along separate Standards and Spec axes. Standards include repository guidance, `$engineering-principles`, GDScript typing/documentation, and the stable-object scene-authoring rule. Spec review checks missing requirements, incorrect behavior, and scope creep. Preserve the final review output completely.
```

## Legacy AGENTS blocks

Compare each block independently, including its markers.

```markdown
<!-- setup-godot-project:implementation:start -->
### Implementation

For implementation work, follow `docs/agents/implementation.md`.
<!-- setup-godot-project:implementation:end -->
```

```markdown
<!-- setup-godot-project:workflow-adapters:start -->
### Workflow adapters

Resolve delivery capabilities through `docs/agents/workflow-adapters.md`.
<!-- setup-godot-project:workflow-adapters:end -->
```

```markdown
<!-- setup-godot-project:gdscript:start -->
### GDScript changes

For GDScript or scene changes, follow `docs/agents/gdscript.md`.
<!-- setup-godot-project:gdscript:end -->
```

```markdown
<!-- setup-godot-project:architecture:start -->
### Architecture

For design and architecture, follow `docs/agents/architecture.md`.
<!-- setup-godot-project:architecture:end -->
```

```markdown
<!-- setup-godot-project:testing:start -->
### Testing

For test seams and commands, follow `docs/agents/testing.md`.
<!-- setup-godot-project:testing:end -->
```

```markdown
<!-- setup-godot-project:code-review:start -->
### Code review

For review standards and output, follow `docs/agents/code-review.md`.
<!-- setup-godot-project:code-review:end -->
```
