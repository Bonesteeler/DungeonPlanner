class_name BackendImpl
extends Node
## BackendImpl
##
## [i]Manages HTTP communication with the scene server for uploading scenes.[/i][br]
## [b]Signals:[/b][br]
## - [code]upload_success(scene_name: String)[/code]: Emitted when a scene is successfully uploaded to the server.[br]
## - [code]upload_failure(scene_name: String)[/code]: Emitted when a scene upload fails.[br]

signal upload_success(scene_name: String)
signal upload_failure(scene_name: String)

const DOMAIN = "http://localhost:8080/"
const SCENES_URL = DOMAIN + "v1/scenes"
const SCENE_ADD_URL = SCENES_URL + "/add"

var _logger := NetworkLogger.new()

## Upload a scene to the server[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — The scene to upload to the server.[br]
## [b]Returns:[/b] [void][br]
func upload_scene(scene: Scene) -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func(_result, response_code: int, _headers, body) -> void:
      _logger.log_response(SCENE_ADD_URL, HTTPClient.METHOD_POST, response_code, body.get_string_from_utf8())
      if response_code == 200:
        upload_success.emit(scene.scene_name)
      else:
        upload_failure.emit(scene.scene_name)
      http_request.queue_free()
  )
  var json_string = UploadSceneRequest.serialize(scene)
  var headers: PackedStringArray = ["Content-Type: application/json"]
  _logger.log_request(HTTPClient.METHOD_POST, SCENE_ADD_URL, json_string)
  var error = http_request.request(SCENE_ADD_URL, headers, HTTPClient.METHOD_POST, json_string)
  if error != OK:
    http_request.queue_free()
