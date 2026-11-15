extends GutTest

const TEST_NAME := "gut_scene_save_service_test"

var service: LocalSceneServiceImpl


func before_each() -> void:
	service = LocalSceneServiceImpl.new()
	autofree(service)


func after_each() -> void:
	for file_name in [TEST_NAME, "missing_scene"]:
		var path := ProjectSettings.globalize_path(
			LocalSceneServiceImpl.LOCAL_SCENES_PATH + file_name + ".json"
		)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _write(content: String) -> void:
	_write_named(TEST_NAME, content)


func _write_named(file_name: String, content: String) -> void:
	var file := FileAccess.open(
		LocalSceneServiceImpl.LOCAL_SCENES_PATH + file_name + ".json", FileAccess.WRITE
	)
	file.store_string(content)
	file.close()


func _file_exists() -> bool:
	return FileAccess.file_exists(LocalSceneServiceImpl.LOCAL_SCENES_PATH + TEST_NAME + ".json")


func test_load_scene_from_user_discards_invalid_json() -> void:
	_write("not json")
	assert_null(service.load_scene_from_user(TEST_NAME))
	assert_engine_error("Discarding corrupt saved scene")
	assert_false(_file_exists())


func test_load_scene_from_user_discards_scene_with_fallback_values() -> void:
	_write("{}")
	assert_null(service.load_scene_from_user(TEST_NAME))
	assert_engine_error("Discarding corrupt saved scene")
	assert_false(_file_exists())


func test_load_scene_from_user_keeps_valid_scene() -> void:
	var scene := Scene.new()
	scene.id = "test-id"
	scene.scene_name = "Valid Scene"
	_write(SceneSerializer.serialize(scene))
	var loaded := service.load_scene_from_user(TEST_NAME)
	assert_not_null(loaded)
	assert_eq(loaded.scene_name, "Valid Scene")
	assert_true(_file_exists())


func test_find_scene_by_id_returns_matching_scene() -> void:
	var scene := Scene.new()
	scene.id = "find-me"
	service.scenes.append(scene)
	assert_eq(service.find_scene_by_id("find-me"), scene)


func test_find_scene_by_id_returns_null_when_not_found() -> void:
	assert_null(service.find_scene_by_id("missing"))


func test_delete_scene_removes_scene_and_emits_scene_deleted() -> void:
	_write("{}")
	var scene := Scene.new()
	scene.id = "delete-me"
	scene.scene_name = TEST_NAME
	service.scenes.append(scene)
	watch_signals(service)

	service.delete_scene(TEST_NAME)

	assert_null(service.find_scene_by_id("delete-me"), "Should remove the scene from memory")
	assert_signal_emitted_with_parameters(service, "scene_deleted", ["delete-me"])


func test_delete_scene_emits_for_each_duplicate_removed() -> void:
	_write("{}")
	var scene_a := Scene.new()
	scene_a.id = "dup-a"
	scene_a.scene_name = TEST_NAME
	var scene_b := Scene.new()
	scene_b.id = "dup-b"
	scene_b.scene_name = TEST_NAME
	service.scenes.append(scene_a)
	service.scenes.append(scene_b)
	watch_signals(service)

	service.delete_scene(TEST_NAME)

	assert_null(service.find_scene_by_id("dup-a"), "Should remove the first duplicate")
	assert_null(service.find_scene_by_id("dup-b"), "Should remove the second duplicate")
	assert_eq(
		get_signal_emit_count(service, "scene_deleted"),
		2,
		"Should emit scene_deleted once per removed scene"
	)


func test_delete_scene_without_match_does_not_emit() -> void:
	_write_named("missing_scene", "{}")
	watch_signals(service)

	service.delete_scene("missing_scene")

	assert_signal_not_emitted(service, "scene_deleted")
