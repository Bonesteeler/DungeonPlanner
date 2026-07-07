class_name BackendImpl
extends Node
## BackendImpl
##
## [i]Manages HTTP communication with the scene server for listing and uploading scenes.[/i][br]
## [b]Signals:[/b][br]
## - [code]new_scene_list(scenes: SceneListResponse)[/code]: Emitted when a scene list is successfully retrieved from the server.[br]
## - [code]upload_success(scene_name: String)[/code]: Emitted when a scene is successfully uploaded to the server.[br]
## - [code]upload_failure(scene_name: String)[/code]: Emitted when a scene upload fails.[br]

signal new_scene_list(scenes: SceneListResponse)
signal upload_success(scene_name: String)
signal upload_failure(scene_name: String)

const DOMAIN = "http://localhost:8080/"
const SCENES_URL = DOMAIN + "v1/scenes"
const SCENE_ADD_URL = SCENES_URL + "/add"
const SCENE_LIST_URL_TEMPLATE = SCENES_URL + "/list/%d"

var _logger := NetworkLogger.new()

## Request a list of scenes from the server starting at a specific index[br]
## [b]Parameters:[/b][br]
## [code]startIdx[/code] : [int] — The starting index for pagination (default: 0).[br]
## [b]Returns:[/b] [void][br]
func request_scene_list(startIdx: int = 0) -> void:
  var http_request := HTTPRequest.new()
  var uri: String = SCENE_LIST_URL_TEMPLATE % startIdx
  add_child(http_request)
  http_request.request_completed.connect(
    func(_result, response_code, _headers, body: PackedByteArray) -> void:
      if response_code != 200:
        http_request.queue_free()
        return
      var json_string = body.get_string_from_utf8()
      var json: Dictionary = JSON.parse_string(json_string)
      _logger.log_response(uri, "GET", response_code, json_string)
      var response = SceneListResponse.new()
      if json.has("total_count"):
        response.scene_count = json.total_count
      else:
        response.scene_count = 0
      if json.has("page_size"):
        response.page_size = json.page_size
      else:
        response.page_size = 5
      var scenes = []
      if json.has("scenes"):
        scenes = json.scenes
      for scene_json in scenes:
        var new_scene = SceneSerializer.deserialize_dict(scene_json)
        response.scenes.append(new_scene)
      http_request.queue_free()
      new_scene_list.emit(response)
  )
  _logger.log_request("GET", uri)
  http_request.request(uri)

## Upload a scene to the server[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — The scene to upload to the server.[br]
## [b]Returns:[/b] [void][br]
func upload_scene(scene: Scene) -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func(_result, response_code: int, _headers, body) -> void:
      _logger.log_response(SCENE_ADD_URL, "POST", response_code, body.get_string_from_utf8())
      if response_code == 200:
        upload_success.emit(scene.scene_name)
      else:
        upload_failure.emit(scene.scene_name)
      http_request.queue_free()
  )
  var json_string = UploadSceneRequest.serialize(scene)
  var headers: PackedStringArray = ["Content-Type: application/json"]
  _logger.log_request("POST", SCENE_ADD_URL, json_string)
  var error = http_request.request(SCENE_ADD_URL, headers, HTTPClient.METHOD_POST, json_string)
  if error != OK:
    http_request.queue_free()
