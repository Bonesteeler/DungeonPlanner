class_name CloudManagerViewModel
extends RefCounted
## CloudManagerViewModel
##
## [i]Mediates between the Backend/SceneSaveService autoloads and the cloud manager UI.[/i][br]
## [b]Signals:[/b][br]
## - [code]scene_list_updated(response: SceneListResponse)[/code]: Emitted when a scene list is received from the server.[br]
## - [code]upload_success(scene_name: String)[/code]: Emitted when an upload succeeds.[br]
## - [code]upload_failure(scene_name: String)[/code]: Emitted when an upload fails.[br]

signal scene_list_updated(response: SceneListResponse)
signal upload_success(scene_name: String)
signal upload_failure(scene_name: String)

func _init() -> void:
	Backend.new_scene_list.connect(_on_scene_list)
	Backend.upload_success.connect(upload_success.emit)
	Backend.upload_failure.connect(upload_failure.emit)

## Request a paginated list of scenes from the server.[br]
## [b]Parameters:[/b][br]
## [code]start_idx[/code] : [int] — starting index for pagination (default: 0).[br]
func request_scene_list(start_idx: int = 0) -> void:
	Backend.request_scene_list(start_idx)

## Upload a local scene to the server by ID.[br]
## [b]Parameters:[/b][br]
## [code]scene_id[/code] : [String] — ID of the local scene to upload.[br]
func upload_scene(scene_id: String) -> void:
	for scene in SceneSaveService.scenes:
		if scene.id == scene_id:
			Backend.upload_scene(scene)
			return

## Import a scene from the server into local storage.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene received from the server.[br]
func import_scene(scene: Scene) -> void:
	SceneSaveService.add_scene(scene)

## Get all locally saved scenes.[br]
## [b]Returns:[/b] [Array[Scene]][br]
func get_local_scenes() -> Array[Scene]:
	return SceneSaveService.scenes

func _on_scene_list(response: SceneListResponse) -> void:
	scene_list_updated.emit(response)
