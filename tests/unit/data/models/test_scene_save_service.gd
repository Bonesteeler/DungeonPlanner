extends GutTest

const TEST_NAME := "gut_scene_save_service_test"

var service: SceneSaveServiceImpl

func before_each():
  service = SceneSaveServiceImpl.new()
  autofree(service)

func after_each():
  var path := ProjectSettings.globalize_path(SceneSaveServiceImpl.LOCAL_SCENES_PATH + TEST_NAME + ".json")
  if FileAccess.file_exists(path):
    DirAccess.remove_absolute(path)

func _write(content: String) -> void:
  var file := FileAccess.open(SceneSaveServiceImpl.LOCAL_SCENES_PATH + TEST_NAME + ".json", FileAccess.WRITE)
  file.store_string(content)
  file.close()

func _file_exists() -> bool:
  return FileAccess.file_exists(SceneSaveServiceImpl.LOCAL_SCENES_PATH + TEST_NAME + ".json")

func test_load_scene_from_user_discards_invalid_json():
  _write("not json")
  assert_null(service.load_scene_from_user(TEST_NAME))
  assert_false(_file_exists())

func test_load_scene_from_user_discards_scene_with_fallback_values():
  _write("{}")
  assert_null(service.load_scene_from_user(TEST_NAME))
  assert_false(_file_exists())

func test_load_scene_from_user_keeps_valid_scene():
  var scene := Scene.new()
  scene.id = "test-id"
  scene.scene_name = "Valid Scene"
  _write(SceneSerializer.serialize(scene))
  var loaded := service.load_scene_from_user(TEST_NAME)
  assert_not_null(loaded)
  assert_eq(loaded.scene_name, "Valid Scene")
  assert_true(_file_exists())
