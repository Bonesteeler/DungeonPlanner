extends GutTest

class FakeNetwork extends NetworkService:
  var response := NetworkService.Response.new()
  var calls: Array = []

  func request(path: String, method: HTTPClient.Method, payload: Variant = null, authenticated: bool = true, sensitive: bool = false) -> NetworkService.Response:
    calls.append({"path": path, "method": method, "payload": payload, "authenticated": authenticated})
    return response

var net: FakeNetwork
var vm: CloudManagerViewModel

func _response(status: int, json: Variant = null) -> NetworkService.Response:
  var result := NetworkService.Response.new()
  result.status_code = status
  result.ok = status >= 200 and status < 300
  result.json = json
  return result

func before_each():
  net = FakeNetwork.new()
  add_child_autofree(net)
  vm = CloudManagerViewModel.new(net)
  watch_signals(vm)

func test_request_scene_list_gets_page_authenticated():
  net.response = _response(200, {"scenes": []})
  await vm.request_scene_list(10)
  assert_eq(net.calls[0].path, "v1/scenes/list/10")
  assert_eq(net.calls[0].method, HTTPClient.METHOD_GET)
  assert_true(net.calls[0].authenticated)

func test_request_scene_list_emits_parsed_response():
  net.response = _response(200, {"total_count": 12, "page_size": 3, "scenes": []})
  await vm.request_scene_list()
  assert_signal_emitted(vm, "scene_list_updated")
  var result: SceneListResponse = get_signal_parameters(vm, "scene_list_updated")[0]
  assert_eq(result.scene_count, 12)
  assert_eq(result.page_size, 3)
  assert_eq(result.scenes.size(), 0)

func test_request_scene_list_uses_defaults_when_fields_missing():
  net.response = _response(200, {})
  await vm.request_scene_list()
  var result: SceneListResponse = get_signal_parameters(vm, "scene_list_updated")[0]
  assert_eq(result.scene_count, 0)
  assert_eq(result.page_size, CloudManagerViewModel.DEFAULT_PAGE_SIZE)

func test_request_scene_list_emits_empty_result_on_failure():
  net.response = _response(500)
  await vm.request_scene_list()
  assert_signal_emitted(vm, "scene_list_updated")
  var result: SceneListResponse = get_signal_parameters(vm, "scene_list_updated")[0]
  assert_eq(result.scene_count, 0)
  assert_eq(result.scenes.size(), 0)

func _local_scene() -> Scene:
  var tile_data := Tile.new()
  tile_data.id = "tile-1"
  var tile := PlacedTile.new()
  tile.tile_data = tile_data
  tile.position = Vector2(3, 4)
  tile.rotation = Vector3(0, 90, 0)
  var layer := TileLayer.new()
  layer.height = 0.5
  layer.tiles.append(tile)
  var scene := Scene.new()
  scene.id = "scene-1"
  scene.scene_name = "My Scene"
  scene.author = "Tester"
  scene.data.layers.append(layer)
  return scene

func test_upload_scene_posts_authenticated_request_body():
  var scene := _local_scene()
  SceneSaveService.scenes.append(scene)
  net.response = _response(200)
  await vm.upload_scene("scene-1")
  SceneSaveService.scenes.erase(scene)
  assert_eq(net.calls[0].path, "v1/scenes/add")
  assert_eq(net.calls[0].method, HTTPClient.METHOD_POST)
  assert_true(net.calls[0].authenticated)
  assert_eq(net.calls[0].payload, {
    "name": "My Scene",
    "author": "Tester",
    "layers": [ {
      "height": 50,
      "tiles": [ {"tile_id": "tile-1", "rotation": 90, "x_pos": 3, "y_pos": 4}],
    }],
  })

func test_upload_scene_emits_success():
  var scene := _local_scene()
  SceneSaveService.scenes.append(scene)
  net.response = _response(200)
  await vm.upload_scene("scene-1")
  SceneSaveService.scenes.erase(scene)
  assert_signal_emitted_with_parameters(vm, "upload_success", ["My Scene"])
  assert_signal_not_emitted(vm, "upload_failure")

func test_upload_scene_emits_failure():
  var scene := _local_scene()
  SceneSaveService.scenes.append(scene)
  net.response = _response(500)
  await vm.upload_scene("scene-1")
  SceneSaveService.scenes.erase(scene)
  assert_signal_emitted_with_parameters(vm, "upload_failure", ["My Scene"])
  assert_signal_not_emitted(vm, "upload_success")

func test_upload_scene_ignores_unknown_id():
  await vm.upload_scene("missing")
  assert_eq(net.calls.size(), 0)

func _remove_imported(scene_name: String) -> void:
  for scene in SceneSaveService.scenes.filter(func(s): return s.scene_name == scene_name):
    SceneSaveService.scenes.erase(scene)
  DirAccess.remove_absolute(SceneSaveService.LOCAL_SCENES_PATH + scene_name + ".json")

func test_import_scene_fetches_full_scene_by_id():
  var partial := Scene.new()
  partial.id = "scene-42"
  net.response = _response(200, {"id": "scene-42", "name": "Cloud Import Test", "layers": []})
  await vm.import_scene(partial)
  _remove_imported("Cloud Import Test")
  assert_eq(net.calls[0].path, "v1/scenes/scene-42")
  assert_eq(net.calls[0].method, HTTPClient.METHOD_GET)
  assert_true(net.calls[0].authenticated)

func test_import_scene_saves_fetched_scene_locally():
  var partial := Scene.new()
  partial.id = "scene-42"
  partial.scene_name = "Partial"
  net.response = _response(200, {"id": "scene-42", "name": "Cloud Import Test", "layers": []})
  await vm.import_scene(partial)
  var saved := SceneSaveService.scenes.filter(func(s): return s.scene_name == "Cloud Import Test")
  var file_exists := FileAccess.file_exists(SceneSaveService.LOCAL_SCENES_PATH + "Cloud Import Test.json")
  var partial_saved := SceneSaveService.scenes.any(func(s): return s.scene_name == "Partial")
  _remove_imported("Cloud Import Test")
  assert_eq(saved.size(), 1)
  assert_true(file_exists)
  assert_false(partial_saved)

func test_import_scene_does_not_save_on_failure():
  var partial := Scene.new()
  partial.id = "scene-42"
  partial.scene_name = "Cloud Import Failure Test"
  net.response = _response(500)
  await vm.import_scene(partial)
  var saved := SceneSaveService.scenes.any(func(s): return s.scene_name == "Cloud Import Failure Test")
  assert_false(saved)
