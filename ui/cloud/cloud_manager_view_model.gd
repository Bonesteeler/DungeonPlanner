class_name CloudManagerViewModel
extends RefCounted
## CloudManagerViewModel
##
 ## [i]Mediates between the Network/SceneSaveService autoloads and the cloud manager UI.[/i][br]
## [b]Signals:[/b][br]
## - [code]scene_list_updated(response: SceneListResponse)[/code]: Emitted when a scene list is received from the server.[br]
## - [code]upload_success(scene_name: String)[/code]: Emitted when an upload succeeds.[br]
## - [code]upload_failure(scene_name: String)[/code]: Emitted when an upload fails.[br]

signal scene_list_updated(response: SceneListResponse)
signal upload_success(scene_name: String)
signal upload_failure(scene_name: String)

const SCENE_LIST_URL_TEMPLATE := "v1/scenes/list/%d"
const DEFAULT_PAGE_SIZE := 5

var network: NetworkService

func _init(network_service: NetworkService = Network) -> void:
	network = network_service

## Request a paginated list of scenes from the server.[br]
## [b]Parameters:[/b][br]
## [code]start_idx[/code] : [int] — starting index for pagination (default: 0).[br]
func request_scene_list(start_idx: int = 0) -> void:
	var response := await network.request(SCENE_LIST_URL_TEMPLATE % start_idx, HTTPClient.METHOD_GET, null, true)
	if not response.ok or not (response.json is Dictionary):
		print("Failed to retrieve scene list from server. Response code: %d" % response.status_code)
		var empty := SceneListResponse.new()
		empty.page_size = DEFAULT_PAGE_SIZE
		scene_list_updated.emit(empty)
		return
	var json: Dictionary = response.json
	var result := SceneListResponse.new()
	result.scene_count = json.get("total_count", 0)
	result.page_size = json.get("page_size", DEFAULT_PAGE_SIZE)
	for scene_json in json.get("scenes", []):
		result.scenes.append(SceneSerializer.deserialize_dict(scene_json))
	scene_list_updated.emit(result)

## Upload a local scene to the server by ID.[br]
## [b]Parameters:[/b][br]
## [code]scene_id[/code] : [String] — ID of the local scene to upload.[br]
func upload_scene(scene_id: String) -> void:
	for scene in SceneSaveService.scenes:
		if scene.id == scene_id:
			if await UploadSceneRequest.send(network, scene):
				upload_success.emit(scene.scene_name)
			else:
				upload_failure.emit(scene.scene_name)
			return

## Import a scene from the server into local storage.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the partial scene from the list.[br]
func import_scene(scene: Scene) -> void:
	var response := await network.request(GetSceneRequest.path(scene.id), HTTPClient.METHOD_GET, null, true)
	if not response.ok or not (response.json is Dictionary):
		print("Failed to retrieve scene %s from server. Response code: %d" % [scene.id, response.status_code])
		return
	SceneSaveService.add_scene(GetSceneRequest.deserialize(response.json))

## Get all locally saved scenes.[br]
## [b]Returns:[/b] [Array[Scene]][br]
func get_local_scenes() -> Array[Scene]:
	return SceneSaveService.scenes
