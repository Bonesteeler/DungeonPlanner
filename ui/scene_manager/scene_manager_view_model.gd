class_name SceneManagerViewModel
extends RefCounted
## SceneManagerViewModel
##
## [i]View model wrapping SceneSaveService to provide sorted scene lists and recent scene tracking.[/i][br]
## [b]Signals:[/b][br]
## - [code]scenes_updated()[/code]: Emitted when the scene list changes.[br]
## - [code]recent_scenes_updated()[/code]: Emitted when recent scenes are modified.[br]

signal scenes_updated()
signal recent_scenes_updated()

const MAX_RECENT_SCENES = 10

var save_manager: SceneSaveService
var _recent_scene_ids: Array[String] = []

## Initialize with a SceneSaveService instance and connect to its signals.[br]
## [b]Parameters:[/b][br]
## [code]manager[/code] : [SceneSaveService] — the save service to wrap.[br]
func _init(manager: SceneSaveService):
    save_manager = manager
    save_manager.scene_added.connect(_on_scene_added)
    _load_recent_scenes()

## Get all scenes sorted alphabetically by scene name.[br]
## [b]Returns:[/b] [Array[Scene]] — sorted array of scenes.[br]
func get_scenes_alphabetically() -> Array[Scene]:
    var sorted_scenes = save_manager.scenes.duplicate()
    sorted_scenes.sort_custom(func(a: Scene, b: Scene): return a.scene_name.naturalnocasecmp_to(b.scene_name) < 0)
    return sorted_scenes

## Get recently edited scenes, ordered by most recent first.[br]
## [b]Returns:[/b] [Array[Scene]] — array of recently accessed scenes.[br]
func get_recent_scenes() -> Array[Scene]:
    var recent_scenes: Array[Scene] = []
    for scene_id in _recent_scene_ids:
        var scene = find_scene_by_id(scene_id)
        if scene != null:
            recent_scenes.append(scene)
    return recent_scenes

## Mark a scene as recently accessed, moving it to the top of the recent list.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to mark as recently accessed.[br]
## [b]Emits:[/b][br]
## - [code]recent_scenes_updated()[/code][br]
func mark_scene_as_recent(scene: Scene) -> void:
    if scene.id == "":
        return
    
    # Remove if already in list
    var idx = _recent_scene_ids.find(scene.id)
    if idx != -1:
        _recent_scene_ids.remove_at(idx)
    
    # Add to front
    _recent_scene_ids.insert(0, scene.id)
    
    # Trim to max size
    if _recent_scene_ids.size() > MAX_RECENT_SCENES:
        _recent_scene_ids.resize(MAX_RECENT_SCENES)
    
    _save_recent_scenes()
    recent_scenes_updated.emit()

## Load a scene by name from the save manager.[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene to load.[br]
## [b]Returns:[/b] [Scene] — the loaded scene.[br]
func load_scene(scene_name: String) -> Scene:
    var scene = save_manager.load_scene_from_user(scene_name)
    mark_scene_as_recent(scene)
    return scene

## Save a scene and mark it as recently accessed.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to save.[br]
func save_scene(scene: Scene) -> void:
    save_manager.save_scene_to_user(scene)
    mark_scene_as_recent(scene)

## Add a new scene to the save manager.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to add.[br]
func add_scene(scene: Scene) -> void:
    save_manager.add_scene(scene)
    mark_scene_as_recent(scene)

## Delete a scene by name.[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene to delete.[br]
## [b]Emits:[/b][br]
## - [code]scenes_updated()[/code][br]
## - [code]recent_scenes_updated()[/code][br]
func delete_scene(scene_name: String) -> void:
    # Find and remove from recent list
    var scene = _find_scene_by_name(scene_name)
    if scene != null and scene.id != "":
        var idx = _recent_scene_ids.find(scene.id)
        if idx != -1:
            _recent_scene_ids.remove_at(idx)
            _save_recent_scenes()
            recent_scenes_updated.emit()
    
    save_manager.delete_scene(scene_name)
    scenes_updated.emit()

## Get the total number of scenes.[br]
## [b]Returns:[/b] [int] — count of scenes.[br]
func get_scene_count() -> int:
    return save_manager.scenes.size()

## Internal callback when SceneSaveService adds a scene.[br]
func _on_scene_added() -> void:
    scenes_updated.emit()

## Find a scene by its ID.[br]
## [b]Parameters:[/b][br]
## [code]scene_id[/code] : [String] — the scene ID to search for.[br]
## [b]Returns:[/b] [Scene] or [null].[br]
func find_scene_by_id(scene_id: String) -> Scene:
    for scene in save_manager.scenes:
        if scene.id == scene_id:
            return scene
    return null

## Find a scene by its name.[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — the scene name to search for.[br]
## [b]Returns:[/b] [Scene] or [null].[br]
func _find_scene_by_name(scene_name: String) -> Scene:
    for scene in save_manager.scenes:
        if scene.scene_name == scene_name:
            return scene
    return null

## Load recent scene IDs from persistent storage (stub).[br]
func _load_recent_scenes() -> void:
  var loaded_ids: Array[String] = SceneSaveService.load_recent_scene_ids()

  var sanitized: Array[String] = []
  for id in loaded_ids:
    if sanitized.size() >= MAX_RECENT_SCENES:
      break
    if not find_scene_by_id(id):
      continue
    if sanitized.has(id):
      continue
    sanitized.append(id)

  _recent_scene_ids = sanitized
  recent_scenes_updated.emit()

## Save recent scene IDs to persistent storage (stub).[br]
func _save_recent_scenes() -> void:
  SceneSaveService.save_recent_scene_ids(_recent_scene_ids)

## Send upload scene request to the save manager[br]
## [b]Parameters:[/b][br]## [code]scene_id[/code] : [String] — ID of the scene to upload.[br]
func upload_scene(scene_id: String) -> void:
    save_manager.send_scene_upload_request(scene_id)
