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
