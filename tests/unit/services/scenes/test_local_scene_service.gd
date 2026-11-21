extends GutTest

const TEST_ID := "018eb2a4-5e1f-7c3d-9a2b-4c6d8e0f1a2b"
const MISSING_ID := "00000000-0000-0000-0000-000000000000"

var service: LocalSceneServiceImpl


func before_each() -> void:
	service = LocalSceneServiceImpl.new()
	autofree(service)


func after_each() -> void:
	for stem in [TEST_ID, MISSING_ID]:
		var path := ProjectSettings.globalize_path(
			LocalSceneServiceImpl.LOCAL_SCENES_PATH + stem + ".json"
		)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _write(content: String) -> void:
	_write_named(TEST_ID, content)


func _write_named(stem: String, content: String) -> void:
	var file := FileAccess.open(
		LocalSceneServiceImpl.LOCAL_SCENES_PATH + stem + ".json", FileAccess.WRITE
	)
	file.store_string(content)
	file.close()


func _file_exists(stem: String = TEST_ID) -> bool:
	return FileAccess.file_exists(LocalSceneServiceImpl.LOCAL_SCENES_PATH + stem + ".json")


func _test_scene() -> Scene:
	var scene := Scene.new()
	scene.id = TEST_ID
	scene.scene_name = "Test Scene"
	scene.author = "Tester"
	return scene


func test_load_scene_from_user_discards_invalid_json() -> void:
	_write("not json")
	assert_null(service.load_scene_from_user(TEST_ID))
	assert_engine_error("Discarding corrupt saved scene")
	assert_false(_file_exists())


func test_load_scene_from_user_discards_scene_with_fallback_values() -> void:
	_write("{}")
	assert_null(service.load_scene_from_user(TEST_ID))
	assert_engine_error("Discarding corrupt saved scene")
	assert_false(_file_exists())


func test_load_scene_from_user_keeps_valid_scene() -> void:
	_write(SceneSerializer.serialize(_test_scene()))
	var loaded := service.load_scene_from_user(TEST_ID)
	assert_not_null(loaded)
	assert_eq(loaded.scene_name, "Test Scene")
	assert_true(_file_exists())


func test_load_scene_from_user_rejects_non_uuid_file_name() -> void:
	assert_null(service.load_scene_from_user("../../evil"))
	assert_push_error("Invalid scene id")


func test_load_scene_from_user_returns_nul_for_missing_file() -> void:
	var scene := service.load_scene_from_user(MISSING_ID)
	assert_null(scene)
	assert_push_error("Failed to open saved scene")


func test_find_scene_by_id_returns_matching_scene() -> void:
	var scene := Scene.new()
	scene.id = "find-me"
	service.scenes.append(scene)
	assert_eq(service.find_scene_by_id("find-me"), scene)


func test_find_scene_by_id_returns_null_when_not_found() -> void:
	assert_null(service.find_scene_by_id("missing"))


func test_delete_scene_removes_scene_and_emits_scene_deleted() -> void:
	_write("{}")
	var scene := _test_scene()
	service.scenes.append(scene)
	watch_signals(service)

	service.delete_scene(TEST_ID)

	assert_null(service.find_scene_by_id(TEST_ID), "Should remove the scene from memory")
	assert_signal_emitted_with_parameters(service, "scene_deleted", [TEST_ID])


func test_delete_scene_emits_for_each_duplicate_removed() -> void:
	_write("{}")
	var scene_a := _test_scene()
	var scene_b := _test_scene()
	service.scenes.append(scene_a)
	service.scenes.append(scene_b)
	watch_signals(service)

	service.delete_scene(TEST_ID)

	assert_null(service.find_scene_by_id(TEST_ID), "Should remove every matching scene")
	assert_eq(
		get_signal_emit_count(service, "scene_deleted"),
		2,
		"Should emit scene_deleted once per removed scene"
	)


func test_delete_scene_without_match_does_not_emit() -> void:
	_write_named(MISSING_ID, "{}")
	watch_signals(service)

	service.delete_scene(MISSING_ID)

	assert_signal_not_emitted(service, "scene_deleted")


func test_delete_scene_with_non_uuid_id_touches_nothing() -> void:
	_write("{}")
	var scene := _test_scene()
	service.scenes.append(scene)
	watch_signals(service)

	service.delete_scene("../../" + TEST_ID)

	assert_push_error("Refusing to delete scene with invalid id")
	assert_not_null(service.find_scene_by_id(TEST_ID), "Should keep the scene in memory")
	assert_true(_file_exists(), "Should keep the file on disk")
	assert_signal_not_emitted(service, "scene_deleted")


func test_save_scene_to_user_uses_id_for_filename() -> void:
	var scene := _test_scene()
	scene.scene_name = "../../evil"

	service.save_scene_to_user(scene)
	service.scenes.append(scene)

	assert_true(_file_exists(), "Should save to <id>.json inside the local scenes directory")
	assert_eq(scene.scene_name, "../../evil", "Should keep the display name untouched")
	assert_false(
		FileAccess.file_exists("user://evil.json"), "Should not write outside the save directory"
	)
	var loaded := service.load_scene_from_user(TEST_ID)
	assert_eq(loaded.scene_name, "../../evil", "Should preserve the display name in the JSON")


func test_save_scene_to_user_regenerates_invalid_id() -> void:
	var scene := _test_scene()
	scene.id = "../../x"

	service.save_scene_to_user(scene)

	assert_true(
		LocalSceneServiceImpl._is_uuid(scene.id), "Should assign a fresh UUID before saving"
	)
	assert_true(_file_exists(scene.id), "Should save under the new id")
	DirAccess.remove_absolute(LocalSceneServiceImpl.LOCAL_SCENES_PATH + scene.id + ".json")
