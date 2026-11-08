extends GutTest

const Jwt := preload("res://tests/unit/jwt_helper.gd")

class FakeNetwork extends NetworkService:
  signal release_refresh()
  var queue: Array = []
  var calls: Array = []
  var hold_refresh := false

  func _send(url: String, method: HTTPClient.Method, payload: Variant, token: String, sensitive: bool = false) -> NetworkService.Response:
    calls.append({"url": url, "method": method, "payload": payload, "token": token, "sensitive": sensitive})
    if hold_refresh and url == NetworkService.REFRESH_URL:
      await release_refresh
    if queue.is_empty():
      return NetworkService.Response.new()
    return queue.pop_front()

var net: FakeNetwork
var auth: AuthService
var storage_path: String
var _results: Array = []
var _valid_token: String
var _new_token: String

func _now() -> int:
  return int(Time.get_unix_time_from_system())

func _resp(status: int, json: Variant = null) -> NetworkService.Response:
  var response := NetworkService.Response.new()
  response.status_code = status
  response.ok = status >= 200 and status < 300
  response.json = json
  return response

## Refresh response whose new access token expires [param seconds_from_now] seconds from now.
func _refresh_ok(seconds_from_now: int = 3600) -> NetworkService.Response:
  _new_token = Jwt.make(_now() + seconds_from_now)
  return _resp(200, {"access_token": _new_token, "refresh_token": "new_refresh"})

func _sign_in_expired() -> void:
  auth.set_session(Jwt.make(_now() - 10), "old_refresh")

func _sign_in_valid() -> void:
  _valid_token = Jwt.make(_now() + 3600)
  auth.set_session(_valid_token, "refresh")

func _run_request(path: String) -> void:
  var response := await net.request(path, HTTPClient.METHOD_GET)
  _results.append(response)

func before_each():
  storage_path = "user://test_network_auth_%d.cfg" % Time.get_ticks_usec()
  auth = autofree(AuthService.new())
  auth._storage_path = storage_path
  net = FakeNetwork.new()
  net.auth = auth
  add_child_autofree(net)
  _results = []

func after_each():
  DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path))

# --- URL building and unauthenticated calls ---

func test_relative_path_is_prefixed_with_domain():
  await net.request("v1/scenes", HTTPClient.METHOD_GET, null, false)
  assert_eq(net.calls[0].url, NetworkService.DOMAIN + "v1/scenes")

func test_leading_slash_is_trimmed():
  await net.request("/v1/scenes", HTTPClient.METHOD_GET, null, false)
  assert_eq(net.calls[0].url, NetworkService.DOMAIN + "v1/scenes")

func test_absolute_url_is_not_prefixed():
  await net.request("https://example.com/x", HTTPClient.METHOD_GET, null, false)
  assert_eq(net.calls[0].url, "https://example.com/x")

func test_unauthenticated_call_sends_no_token_and_passes_arguments():
  _sign_in_valid()
  await net.request("v1/x", HTTPClient.METHOD_POST, {"a": 1}, false)
  assert_eq(net.calls.size(), 1)
  assert_eq(net.calls[0].token, "")
  assert_eq(net.calls[0].method, HTTPClient.METHOD_POST)
  assert_eq(net.calls[0].payload, {"a": 1})

func test_unauthenticated_call_returns_queued_response():
  net.queue.append(_resp(200))
  var response := await net.request("v1/x", HTTPClient.METHOD_GET, null, false)
  assert_true(response.ok)
  assert_eq(response.status_code, 200)

# --- Authenticated calls ---

func test_authenticated_call_sends_valid_token():
  _sign_in_valid()
  net.queue.append(_resp(200))
  var response := await net.request("v1/x", HTTPClient.METHOD_GET)
  assert_true(response.ok)
  assert_eq(net.calls.size(), 1)
  assert_eq(net.calls[0].token, _valid_token)

func test_authenticated_call_without_session_returns_empty_response():
  var response := await net.request("v1/x", HTTPClient.METHOD_GET)
  assert_false(response.ok)
  assert_eq(response.status_code, 0)
  assert_eq(net.calls.size(), 0)

func test_expired_token_refreshes_before_sending():
  _sign_in_expired()
  net.queue.append(_refresh_ok())
  net.queue.append(_resp(200))
  var response := await net.request("v1/x", HTTPClient.METHOD_GET)
  assert_true(response.ok)
  assert_eq(net.calls.size(), 2)
  assert_eq(net.calls[0].url, NetworkService.REFRESH_URL)
  assert_eq(net.calls[0].method, HTTPClient.METHOD_POST)
  assert_eq(net.calls[0].payload, {"refresh_token": "old_refresh"})
  assert_eq(net.calls[0].token, "")
  assert_true(net.calls[0].sensitive, "Refresh traffic must be redacted in logs")
  assert_eq(net.calls[1].token, _new_token)
  assert_eq(auth.get_refresh_token(), "new_refresh")

func test_expired_token_with_failed_refresh_returns_empty_and_signs_out():
  _sign_in_expired()
  net.queue.append(_resp(500))
  watch_signals(net)
  watch_signals(auth)
  var response := await net.request("v1/x", HTTPClient.METHOD_GET)
  assert_false(response.ok)
  assert_eq(response.status_code, 0)
  assert_eq(net.calls.size(), 1, "The original request must not be sent")
  assert_signal_emitted(net, "session_expired")
  assert_signal_emitted(auth, "signed_out")
  assert_false(auth.has_session())

func test_401_refreshes_and_retries_once_with_new_token():
  _sign_in_valid()
  net.queue.append(_resp(401))
  net.queue.append(_refresh_ok())
  net.queue.append(_resp(200))
  var response := await net.request("v1/x", HTTPClient.METHOD_GET)
  assert_true(response.ok)
  assert_eq(net.calls.size(), 3)
  assert_eq(net.calls[0].token, _valid_token)
  assert_eq(net.calls[1].url, NetworkService.REFRESH_URL)
  assert_eq(net.calls[2].url, NetworkService.DOMAIN + "v1/x")
  assert_eq(net.calls[2].token, _new_token)

func test_401_after_retry_is_returned_without_further_refresh():
  _sign_in_valid()
  net.queue.append(_resp(401))
  net.queue.append(_refresh_ok())
  net.queue.append(_resp(401))
  var response := await net.request("v1/x", HTTPClient.METHOD_GET)
  assert_eq(response.status_code, 401)
  assert_eq(net.calls.size(), 3)

func test_401_with_failed_refresh_returns_empty_and_signs_out():
  _sign_in_valid()
  net.queue.append(_resp(401))
  net.queue.append(_resp(500))
  watch_signals(net)
  watch_signals(auth)
  var response := await net.request("v1/x", HTTPClient.METHOD_GET)
  assert_false(response.ok)
  assert_eq(response.status_code, 0)
  assert_eq(net.calls.size(), 2)
  assert_signal_emitted(net, "session_expired")
  assert_signal_emitted(auth, "signed_out")
  assert_false(auth.has_session())

# --- Refresh response validation ---

func test_refresh_fails_on_non_ok_status():
  _sign_in_expired()
  net.queue.append(_resp(500, {"access_token": "a", "refresh_token": "r"}))
  assert_false(await net._do_refresh())

func test_refresh_fails_when_json_is_not_a_dictionary():
  _sign_in_expired()
  net.queue.append(_resp(200, ["a"]))
  assert_false(await net._do_refresh())

func test_refresh_fails_without_access_token():
  _sign_in_expired()
  net.queue.append(_resp(200, {"refresh_token": "r"}))
  assert_false(await net._do_refresh())

func test_refresh_fails_without_refresh_token():
  _sign_in_expired()
  net.queue.append(_resp(200, {"access_token": Jwt.make(_now() + 3600)}))
  assert_false(await net._do_refresh())

func test_refresh_fails_without_stored_refresh_token():
  assert_false(await net._do_refresh())
  assert_eq(net.calls.size(), 0)

func test_refresh_stores_expiry_from_access_token():
  _sign_in_expired()
  net.queue.append(_refresh_ok(AuthService.EXPIRY_BUFFER_SECONDS + 60))
  assert_true(await net._do_refresh())
  assert_eq(auth.get_access_token(), _new_token)

func test_refresh_with_short_lived_token_yields_no_valid_token():
  _sign_in_expired()
  net.queue.append(_refresh_ok(AuthService.EXPIRY_BUFFER_SECONDS - 10))
  assert_true(await net._do_refresh())
  assert_eq(auth.get_access_token(), "")

# --- Concurrency ---

func test_concurrent_requests_share_a_single_refresh():
  _sign_in_expired()
  net.hold_refresh = true
  net.queue.append(_refresh_ok())
  net.queue.append(_resp(200))
  net.queue.append(_resp(200))
  _run_request("v1/a")
  _run_request("v1/b")
  net.release_refresh.emit()
  await wait_until(func(): return _results.size() == 2, 2.0)
  var refresh_calls := net.calls.filter(func(entry): return entry.url == NetworkService.REFRESH_URL)
  assert_eq(refresh_calls.size(), 1, "Only one refresh call expected")
  assert_eq(_results.size(), 2)
  for response in _results:
    assert_true(response.ok)

func test_concurrent_requests_all_fail_when_shared_refresh_fails():
  _sign_in_expired()
  net.hold_refresh = true
  net.queue.append(_resp(500))
  watch_signals(net)
  _run_request("v1/a")
  _run_request("v1/b")
  net.release_refresh.emit()
  await wait_until(func(): return _results.size() == 2, 2.0)
  assert_signal_emit_count(net, "session_expired", 1)
  for response in _results:
    assert_false(response.ok)
