class_name SceneSaveServiceImpl
extends Node
## SceneSaveServiceImpl
##
## [i]Manages saving, loading and tracking of user-created scenes.[/i][br]
## [b]Properties:[/b][br]
## - [b]scenes[/b]: Array of [code]Scene[/code] objects currently discovered in the save folder and managed in-memory.[br]

signal scene_added()

const LOCAL_SCENES_PATH = "user://SavedScenes/LocalScenes/"
const SAVED_SCENES_PATH = "user://SavedScenes/"
const RECENT_SCENE_IDS_FILE = "recent_scene_ids.json"

var scenes: Array[Scene] = []

## Ensure the save directory exists and populate [code]scenes[/code] from any existing JSON files.[br]
## [b]Emits:[/b][br]
## - [code]scene_added()[/code] when a saved scene is discovered and added to the in-memory list during initialization.[br]
func _init():
  var dir = DirAccess.open("user://")
  if dir.dir_exists(SAVED_SCENES_PATH) == false:
    dir.make_dir(SAVED_SCENES_PATH)
  if dir.dir_exists(LOCAL_SCENES_PATH) == false:
    dir.make_dir(LOCAL_SCENES_PATH)
  var saved_scenes_dir = DirAccess.open(LOCAL_SCENES_PATH)
  saved_scenes_dir.list_dir_begin()
  var save_name = saved_scenes_dir.get_next()
  while save_name != "":
    if save_name.ends_with(".json"):
      var without_suffix = save_name.trim_suffix(".json")
      var scene = load_scene_from_user(without_suffix)
      if scene != null:
        scenes.append(scene)
    save_name = saved_scenes_dir.get_next()
  saved_scenes_dir.list_dir_end()

## Load a TileLayout from a JSON file path.[br]
## [b]Parameters:[/b][br]
## [code]file_path[/code] : [String] — absolute or relative filesystem path to a .json file containing a serialized TileLayout.[br]
## [b]Returns:[/b] [TileLayout] — a deserialized TileLayout. Returns a new empty [code]TileLayout[/code] if the file cannot be opened.[br]
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

## Load a saved Scene from the user save directory.[br]
## [b]Parameters:[/b][br]
## [code]file_name[/code] : [String] — base filename (without .json) of the saved scene under user://SavedScenes/.[br]
## [b]Returns:[/b] [Scene] — the deserialized Scene. If the file cannot be opened, a new [code]Scene[/code] with [code]scene_name[/code] set to [code]file_name[/code] is returned.[br]
func load_scene_from_user(file_name: String) -> Scene:
    var file = FileAccess.open(LOCAL_SCENES_PATH + file_name + ".json", FileAccess.READ)
    if file == null:
      print("Failed to open saved scene:%s with error %s" %
       [file_name, str(FileAccess.get_open_error())])
      var new_scene = Scene.new()
      new_scene.id = UUID.v7()
      return new_scene
    var json_string = file.get_as_text()
    var parsed_scene = SceneSerializer.deserialize(json_string)
    file.close()
    return parsed_scene

## Serialize and write a Scene to the user save directory as JSON.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the Scene instance to serialize and persist. The Scene's [code]scene_name[/code] is used for the filename.[br]
func save_scene_to_user(scene: Scene):
  var json_string = SceneSerializer.serialize(scene)
  var file = FileAccess.open(LOCAL_SCENES_PATH + scene.scene_name + ".json", FileAccess.WRITE)
  file.store_string(json_string)
  file.close()

## Add or replace a Scene in memory and persist it to disk.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to add or update.[br]
## [b]Emits:[/b][br]
## - [code]scene_added()[/code] after the scene is added or updated and saved.[br]
func add_scene(scene: Scene):
  var idx = scenes.find_custom((func(s): return s.scene_name == scene.scene_name))
  if idx == -1:
    scenes.append(scene)
  else:
    scenes[idx] = scene
  save_scene_to_user(scene)
  scene_added.emit()

## Remove a Scene in memory and from disk.[br]
## [code]file_name[/code] : [String] — base filename (without .json) of the scene to delete from user://SavedScenes/.[br]
func delete_scene(file_name: String):
  var local_path = LOCAL_SCENES_PATH + file_name + ".json"
  OS.move_to_trash(ProjectSettings.globalize_path(local_path))
  var idx = scenes.find_custom((func(s): return s.scene_name == file_name))
  while idx != -1:
    scenes.remove_at(idx)
    idx = scenes.find_custom((func(s): return s.scene_name == file_name))

func save_recent_scene_ids(ids: Array[String]):
  var file = FileAccess.open(SAVED_SCENES_PATH + RECENT_SCENE_IDS_FILE, FileAccess.WRITE)
  if file == null:
    print("Failed to save recent scene ids with error %s" % str(FileAccess.get_open_error()))
    return

  file.store_string(JSON.stringify(ids))
  file.close()

func load_recent_scene_ids() -> Array[String]:
  var file = FileAccess.open(SAVED_SCENES_PATH + RECENT_SCENE_IDS_FILE, FileAccess.READ)
  if file == null:
    return []

  var json_string = file.get_as_text()
  file.close()

  var parsed = JSON.parse_string(json_string)
  if typeof(parsed) != TYPE_ARRAY:
    return []

  var ids: Array[String] = []
  for value in parsed:
    if typeof(value) == TYPE_STRING:
      ids.append(value)

  return ids

func send_scene_upload_request(scene_id: String):
    var sceneIdx = scenes.find_custom((func(s): return s.id == scene_id))
    if sceneIdx != -1:
        Backend.upload_scene(scenes[sceneIdx])
