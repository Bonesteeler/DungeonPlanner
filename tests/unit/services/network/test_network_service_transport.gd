extends GutTest

class TransportNetwork extends NetworkService:
  var next_result: int = HTTPRequest.RESULT_SUCCESS
  var next_status: int = 200
  var next_body: String = "{}"
  var last_http: HTTPRequest
  var last_args: Dictionary = {}

  func _start_request(http: HTTPRequest, url: String, headers: PackedStringArray, method: HTTPClient.Method, body: String) -> Error:
    last_http = http
    last_args = {"url": url, "headers": headers, "method": method, "body": body, "timeout": http.timeout}
    # Completes on the next frame, after _send() has reached its await.
    get_tree().process_frame.connect(
      func(): http.request_completed.emit(next_result, next_status, PackedStringArray(), next_body.to_utf8_buffer()),
      CONNECT_ONE_SHOT)
    return OK

var net: TransportNetwork

func before_each():
  net = TransportNetwork.new()
  add_child_autofree(net)

func _send(payload: Variant = null, token: String = "") -> NetworkService.Response:
  var response := await net._send("http://test/x", HTTPClient.METHOD_POST, payload, token)
  # The test would otherwise finish inside request_completed's emission and free its emitter.
  await wait_process_frames(1)
  return response

# --- Outgoing request ---

func test_dictionary_payload_is_sent_as_json():
  await _send({"a": 1})
  assert_eq(net.last_args.url, "http://test/x")
  assert_eq(net.last_args.method, HTTPClient.METHOD_POST)
  assert_eq(net.last_args.body, JSON.stringify({"a": 1}))
  assert_true((net.last_args.headers as PackedStringArray).has("Content-Type: application/json"))

func test_array_payload_is_sent_as_json():
  await _send([1, 2])
  assert_eq(net.last_args.body, JSON.stringify([1, 2]))
  assert_true((net.last_args.headers as PackedStringArray).has("Content-Type: application/json"))

func test_string_payload_is_sent_as_is_without_content_type():
  await _send("raw body")
  assert_eq(net.last_args.body, "raw body")
  assert_eq((net.last_args.headers as PackedStringArray).size(), 0)

func test_null_payload_sends_empty_body():
  await _send(null)
  assert_eq(net.last_args.body, "")
  assert_eq((net.last_args.headers as PackedStringArray).size(), 0)

func test_token_is_sent_as_bearer_header():
  await _send(null, "tok")
  assert_true((net.last_args.headers as PackedStringArray).has("Authorization: Bearer tok"))

func test_empty_token_sends_no_authorization_header():
  await _send({"a": 1}, "")
  for header in net.last_args.headers as PackedStringArray:
    assert_false(header.begins_with("Authorization"), "Unexpected header: " + header)

func test_timeout_is_set():
  await _send()
  assert_eq(net.last_args.timeout, NetworkService.DEFAULT_TIMEOUT)

# --- Response parsing ---

func test_success_response_is_parsed():
  net.next_status = 201
  net.next_body = '{"id": 5}'
  var response := await _send()
  assert_true(response.ok)
  assert_eq(response.status_code, 201)
  assert_eq(response.body, '{"id": 5}')
  assert_eq(response.json, {"id": 5.0}, "JSON numbers parse as floats")

func test_non_2xx_status_is_not_ok():
  net.next_status = 404
  var response := await _send()
  assert_false(response.ok)
  assert_eq(response.status_code, 404)

func test_non_success_result_is_not_ok_even_with_2xx_status():
  net.next_result = HTTPRequest.RESULT_TIMEOUT
  var response := await _send()
  assert_false(response.ok)

func test_invalid_json_body_leaves_json_null():
  net.next_body = "not json"
  var response := await _send()
  assert_engine_error("Parse JSON failed")
  assert_true(response.ok)
  assert_eq(response.body, "not json")
  assert_null(response.json)

# --- Lifecycle ---

func test_http_request_is_freed_after_completion():
  await _send()
  await wait_process_frames(2)
  assert_false(is_instance_valid(net.last_http))
