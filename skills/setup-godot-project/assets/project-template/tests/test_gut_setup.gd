# setup-godot-project:template=gut-smoke;version=2
## Verifies that the vendored GUT framework can execute project tests.[br]
## [b]Responsibilities[/b][br]
## 1. Load through the project's configured GUT runner.[br]
## 2. Produce one deterministic passing assertion.[br]
## [b]Single reason to change[/b][br]
## The project's GUT setup-smoke contract changes.
extends GutTest


## Confirms that GUT discovers and executes this project-owned smoke test.
func test_gut_is_available() -> void:
	assert_true(true, "GUT executes project tests")
