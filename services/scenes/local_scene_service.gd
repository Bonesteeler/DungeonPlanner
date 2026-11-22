class_name LocalSceneServiceImpl
extends Node
## LocalSceneServiceImpl
##
## [i]Manages saving, loading and tracking of user-created scenes.[/i][br]
## [b]Properties:[/b][br]
## - [b]scenes[/b]: Array of [code]Scene[/code] objects currently discovered in the save folder and managed in-memory.[br]

signal scene_added
signal scene_deleted(scene_id: String)

const LOCAL_SCENES_PATH = "user://SavedScenes/LocalScenes/"
const SAVED_SCENES_PATH = "user://SavedScenes/"
const RECENT_SCENE_IDS_FILE = "recent_scene_ids.json"

static var _uuid_regex := RegEx.create_from_string(
	"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)

var scenes: Array[Scene] = []


## Check whether [code]value[/code] is a canonical UUID (8-4-4-4-12 lowercase hex).[br]
## Only UUIDs are used as on-disk filenames, so path separators and dot segments can never reach the filesystem.[br]
static func _is_uuid(value: String) -> bool:
	return _uuid_regex.search(value) != null


## Ensure the save directory exists and populate [code]scenes[/code] from any existing JSON files.[br]
## Saved files are named [code]<scene id>.json[/code].[br]
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


## Load a saved Scene from the user save directory.[br]
## [b]Parameters:[/b][br]
## [code]file_name[/code] : [String] — base filename (without .json) of the saved scene under user://SavedScenes/.[br]
## [b]Returns:[/b] [Scene] — the deserialized Scene. If the file is invalid, it is deleted and [code]null[/code] is returned.[br]
func load_scene_from_user(file_name: String) -> Scene:
	if not _is_uuid(file_name):
		push_error("Invalid scene id: %s" % file_name)
		return null
	var file = FileAccess.open(LOCAL_SCENES_PATH + file_name + ".json", FileAccess.READ)
	if file == null:
		push_error("Failed to open saved scene: %s" % file_name)
		return null
	var json_string = file.get_as_text()
	var parsed_scene = SceneSerializer.deserialize(json_string)
	file.close()
	## Assume a scene with author 'Unknown' and scene_name 'Untitled Scene' as error, and delete the json.
	if (
		parsed_scene == null
		or (parsed_scene.author == "Unknown" and parsed_scene.scene_name == "Untitled Scene")
	):
		push_warning("Discarding corrupt saved scene: %s" % file_name)
		delete_scene(file_name)
		return null
	return parsed_scene


## Serialize and write a Scene to the user save directory as JSON.[br]
## If the scene's id is missing or invalid, a fresh UUID is assigned before saving.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the Scene instance to serialize and persist.[br]
func save_scene_to_user(scene: Scene) -> void:
	if not _is_uuid(scene.id):
		scene.id = UUID.v7()
	var json_string = SceneSerializer.serialize(scene)
	var file = FileAccess.open(LOCAL_SCENES_PATH + scene.id + ".json", FileAccess.WRITE)
	if file == null:
		push_error(
			(
				"Failed to save scene %s with error %s"
				% [scene.id, str(FileAccess.get_open_error())]
			)
		)
		return
	file.store_string(json_string)
	file.close()


## Add or replace a Scene in memory and persist it to disk.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to add or update.[br]
## [b]Emits:[/b][br]
## - [code]scene_added()[/code] after the scene is added or updated and saved.[br]
func add_scene(scene: Scene) -> void:
	var idx = scenes.find_custom(func(s): return s.id == scene.id)
	if idx == -1:
		scenes.append(scene)
	else:
		scenes[idx] = scene
	save_scene_to_user(scene)
	scene_added.emit()


## Remove a Scene in memory and from disk.[br]
## [code]scene_id[/code] : [String] — id of the scene to delete.[br]
## [b]Emits:[/b][br]
## - [code]scene_deleted(scene_id)[/code] for each removed scene.[br]
func delete_scene(scene_id: String) -> void:
	if not _is_uuid(scene_id):
		push_error("Refusing to delete scene with invalid id: %s" % scene_id)
		return
	var local_path = LOCAL_SCENES_PATH + scene_id + ".json"
	OS.move_to_trash(ProjectSettings.globalize_path(local_path))
	var idx = scenes.find_custom(func(s): return s.id == scene_id)
	while idx != -1:
		scene_deleted.emit(scenes[idx].id)
		scenes.remove_at(idx)
		idx = scenes.find_custom(func(s): return s.id == scene_id)


## Find a scene by its ID.[br]
## [b]Parameters:[/b][br]
## [code]scene_id[/code] : [String] — the scene ID to search for.[br]
## [b]Returns:[/b] [Scene] or [null].[br]
func find_scene_by_id(scene_id: String) -> Scene:
	for scene in scenes:
		if scene.id == scene_id:
			return scene
	return null


func save_recent_scene_ids(ids: Array[String]) -> void:
	var file = FileAccess.open(SAVED_SCENES_PATH + RECENT_SCENE_IDS_FILE, FileAccess.WRITE)
	if file == null:
		push_error(
			"Failed to save recent scene ids with error %s" % str(FileAccess.get_open_error())
		)
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
