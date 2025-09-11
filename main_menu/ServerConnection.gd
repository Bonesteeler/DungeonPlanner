class_name ServerConnection
extends Node

signal new_scene_list(scenes: SceneListResponse)
signal scene_imported(sceneJson: Dictionary)
signal upload_success(scene_name: String)
signal upload_failure(scene_name: String)

const SCENE_ADD_URL = DOMAIN + "/scenes/add"
const SCENE_LIST_URL_TEMPLATE = DOMAIN + "/scenes/list/%d"
const SCENE_REQUEST_DATA_URL_TEMPLATE = DOMAIN + "/scenes/%s"
const DOMAIN = "https://dungeon-planner-backend-7f50910efa9c.herokuapp.com"

func request_scene_list(startIdx: int = 0) -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func(_result, response_code, _headers, body: PackedByteArray) -> void:
      if response_code != 200:
        print("Failed to get scene list from server, response code: %d" % response_code)
        http_request.queue_free()
        return
      var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
      var response = SceneListResponse.new()
      if json.has("sceneCount"):
        response.scene_count = json.sceneCount
      else:
        response.scene_count = 0
      if json.has("pageSize"):
        response.page_size = json.pageSize
      else:
        response.page_size = 5
      var scenes = []
      if json.has("scenes"):
        scenes = json.scenes
      for scene_json in scenes:
        var new_scene = Scene.new()
        if scene_json.has("id"):
          new_scene.id = scene_json.id
        else:
          # No id, can't process scene 
          continue
        if scene_json.has("name"):
          new_scene.scene_name = scene_json.name
        else:
          new_scene.scene_name = "Untitled"
        if scene_json.has("author"):
          new_scene.author = scene_json.author
        else:
          new_scene.author = "Unknown author"
        if scene_json.has("uniqueTileIds"):
          new_scene.unique_tile_ids = scene_json.uniqueTileIds
        else:
          new_scene.unique_tile_ids = {}
        response.scenes.append(new_scene)
      http_request.queue_free()
      new_scene_list.emit(response))
  var uri = SCENE_LIST_URL_TEMPLATE % startIdx
  http_request.request(uri)

func request_scene_import(scene_id: String) -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func(_result, response_code, _headers, body: PackedByteArray) -> void:
      if response_code != 200:
        print("Failed to get scene data from server, response code: %d" % response_code)
        http_request.queue_free()
        return
      var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
      scene_imported.emit(json)
      http_request.queue_free()
  )
  http_request.request(SCENE_REQUEST_DATA_URL_TEMPLATE % scene_id)

func upload_scene(scene: TileLayout) -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func(_result, response_code: int, _headers, _body) -> void:
      if response_code == 200:
        upload_success.emit(scene.scene_name)
      else:
        upload_failure.emit(scene.scene_name)
      http_request.queue_free()
  )
  var json_string = scene.to_server_json()
  var headers = ["Content-Type: application/json"]
  var error = http_request.request(SCENE_ADD_URL, headers, HTTPClient.METHOD_PUT, json_string)
  if error != OK:
    print("Failed to upload scene: %s with error: %s" % [scene.scene_name, error])
    http_request.queue_free()
