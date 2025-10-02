class_name SaveManager
extends Node

signal scene_added()

const SAVED_SCENES_PATH = "user://SavedScenes/"

var scenes: Array[Scene] = []

func _init():
  var dir = DirAccess.open("user://")
  if dir.dir_exists(SAVED_SCENES_PATH) == false:
    dir.make_dir(SAVED_SCENES_PATH)
  var saved_scenes_dir = DirAccess.open(SAVED_SCENES_PATH)
  saved_scenes_dir.list_dir_begin()
  var save_name = saved_scenes_dir.get_next()
  while save_name != "":
    if save_name.ends_with(".json"):
      var scene = Scene.new()
      var without_suffix = save_name.trim_suffix(".json")
      scene = load_scene_from_user(without_suffix)
      if scene != null:
        scenes.append(scene)
    save_name = saved_scenes_dir.get_next()
  saved_scenes_dir.list_dir_end()

func load_scene_from_json(file_path: String) -> TileLayout:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
      return TileLayout.new()
    var json_string = file.get_as_text()
    var parsed_scene = TileLayoutSerializer.deserialize(json_string)
    file.close()
    var file_name = file_path.get_file().trim_suffix(".json")
    parsed_scene.scene_name = file_name
    return parsed_scene

func load_scene_from_user(file_name: String) -> Scene:
    var file = FileAccess.open(SAVED_SCENES_PATH + file_name + ".json", FileAccess.READ)
    if file == null:
      print("Failed to open saved scene:%s with error %s" %
       [file_name, str(FileAccess.get_open_error())])
      var new_scene = Scene.new()
      new_scene.scene_name = file_name
      return new_scene
    var json_string = file.get_as_text()
    var parsed_scene = SceneSerializer.deserialize(json_string)
    file.close()
    return parsed_scene

func save_scene_to_user(scene: Scene):
  var json_string = SceneSerializer.serialize(scene)
  var file = FileAccess.open(SAVED_SCENES_PATH + scene.scene_name + ".json", FileAccess.WRITE)
  file.store_string(json_string)
  file.close()

func add_scene(scene: Scene):
  var idx = scenes.find_custom((func(s): return s.scene_name == scene.scene_name))
  if idx == -1:
    scenes.append(scene)
  else:
    scenes[idx] = scene
  save_scene_to_user(scene)
  scene_added.emit()

func delete_scene(file_name: String):
  var local_path = SAVED_SCENES_PATH + file_name + ".json"
  OS.move_to_trash(ProjectSettings.globalize_path(local_path))
  var idx = scenes.find_custom((func(s): return s.scene_name == file_name))
  while idx != -1:
    scenes.remove_at(idx)
    idx = scenes.find_custom((func(s): return s.scene_name == file_name))

func get_scene_path(file_name: String) -> String:
  return SAVED_SCENES_PATH + file_name + ".json"
