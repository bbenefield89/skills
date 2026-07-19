# setup-godot-project:template=runtime-verification;version=2
## Verifies that the configured main scene can be loaded and instantiated headlessly.[br]
## [b]Responsibilities[/b][br]
## 1. Report runtime validation as not applicable when no main scene exists.[br]
## 2. Load and instantiate the configured main scene for one process frame.[br]
## [b]Single reason to change[/b][br]
## The project's universal runtime-smoke contract changes.
extends SceneTree


## Runs the runtime-smoke decision and exits with a deterministic process status.
func _initialize() -> void:
	var main_scene_path: String = _main_scene_path()
	if main_scene_path.is_empty():
		_finish_not_applicable()
		return

	var packed_scene: PackedScene = load(main_scene_path) as PackedScene
	if packed_scene == null:
		_fail_to_load(main_scene_path)
		return

	await _instantiate_for_one_frame(packed_scene)


## Returns the configured main-scene resource path, or an empty string when absent.
func _main_scene_path() -> String:
	return str(ProjectSettings.get_setting("application/run/main_scene", ""))


## Reports that runtime validation is not yet applicable and exits successfully.
func _finish_not_applicable() -> void:
	print("NOT_APPLICABLE: no main scene configured")
	quit(0)


## Reports an invalid configured main-scene path and exits unsuccessfully.[br]
## [b]Parameters[/b][br]
## [param main_scene_path] — The configured resource path that failed to load.
func _fail_to_load(main_scene_path: String) -> void:
	push_error("Unable to load configured main scene: %s" % main_scene_path)
	quit(1)


## Instantiates the configured scene, waits one frame, and exits successfully.[br]
## [b]Parameters[/b][br]
## [param packed_scene] — The validated main-scene resource to instantiate.
func _instantiate_for_one_frame(packed_scene: PackedScene) -> void:
	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	print("PASS: configured main scene instantiated")
	quit(0)
