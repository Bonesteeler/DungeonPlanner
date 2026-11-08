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

func test_request_scene_list_gets_page_unauthenticated():
  net.response = _response(200, {"scenes": []})
  await vm.request_scene_list(10)
  assert_eq(net.calls[0].path, "v1/scenes/list/10")
  assert_eq(net.calls[0].method, HTTPClient.METHOD_GET)
  assert_false(net.calls[0].authenticated)

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

func test_request_scene_list_does_not_emit_on_failure():
  net.response = _response(500)
  await vm.request_scene_list()
  assert_signal_not_emitted(vm, "scene_list_updated")
