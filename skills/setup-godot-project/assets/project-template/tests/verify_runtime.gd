extends SceneTree


func _initialize() -> void:
	var main_scene_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
	if main_scene_path.is_empty():
		print("NOT_APPLICABLE: no main scene configured")
		quit(0)
		return

	var packed_scene: PackedScene = load(main_scene_path) as PackedScene
	if packed_scene == null:
		push_error("Unable to load configured main scene: %s" % main_scene_path)
		quit(1)
		return

	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	print("PASS: configured main scene instantiated")
	quit(0)
