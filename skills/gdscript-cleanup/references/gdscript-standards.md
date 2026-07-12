# GDScript standards

- Prefer concrete project script types over `Node`, `Object`, or unnecessarily broad engine types.
- Prefer explicit local types over avoidable Variant inference and loose `:=` in touched code.
- Use typed enums for closed state sets.
- Prefer typed getters and stable interfaces over mixed dictionary bags.
- Cast unavoidable node lookups and dictionary extraction to concrete types.
- Prefer typed exported node references such as `@export var player: PlayerController` over exported `NodePath` plus runtime lookup.
- Call known typed methods directly; reflective `.call()` is a finding.
- Use native `##` documentation and supported BBCode: `[param]`, `[member]`, `[constant]`, `[signal]`, and `[code]`.
- Substantial scripts document purpose, responsibility, and reason to change. Document non-obvious method contracts.
- Run focused validation after each meaningful fix group.

This skill requires no formatter, linter, Python, `uv`, or `uvx` dependency.
