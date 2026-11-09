class_name NetworkService
extends Node
## NetworkService
##
## [i]Makes HTTP calls to the server, optionally authenticated.[/i][br]
## Authenticated calls read the access token from [code]Auth[/code]. If the token is missing/expired
## or the server answers 401, the tokens are refreshed once and the call is retried. If the refresh
## fails, the session is signed out.[br]
## Usage: [code]var response := await Network.request("v1/scenes", HTTPClient.METHOD_GET, null, true)[/code][br]
## [b]Signals:[/b][br]
## - [code]session_expired()[/code]: Refreshing the tokens failed and the user was signed out.[br]

signal session_expired()
signal _refresh_finished(success: bool)

const DEFAULT_TIMEOUT := 30
const REDACTED := "[redacted]"
const DOMAIN := "http://localhost:8080/"
const REFRESH_URL := DOMAIN + "auth/refresh"

## Result of a network call.[br]
## [code]ok[/code] is true when the request completed with a 2xx status.
class Response:
  var ok: bool = false
  var status_code: int = 0
  var body: String = ""
  var json: Variant = null

var auth: AuthService = Auth
var _logger := NetworkLogger.new()
var _is_refreshing := false

func _ready() -> void:
  await _do_refresh()

## Performs a request and returns a [Response].[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — Path relative to the server domain, or an absolute URL.[br]
## [code]method[/code] : [HTTPClient.Method] — HTTP method.[br]
## [code]payload[/code] : [Variant] — Dictionary/Array (sent as JSON), String, or null.[br]
## [code]authenticated[/code] : [bool] — Attach the bearer token and refresh it when needed.[br]
## [code]sensitive[/code] : [bool] — Redact the request and response bodies in the network log.[br]
func request(
    path: String,
    method: HTTPClient.Method,
    payload: Variant = null,
    authenticated: bool = true,
    sensitive: bool = false) -> Response:
  var url := path if path.begins_with("http") else DOMAIN + path.trim_prefix("/")
  if not authenticated:
    return await _send(url, method, payload, "", sensitive)

  var token: String = auth.get_access_token()
  if token.is_empty():
    if not auth.has_session():
      return Response.new()
    if not await _refresh_tokens():
      return Response.new()
    token = auth.get_access_token()
  var response := await _send(url, method, payload, token, sensitive)
  if response.status_code == 401:
    if not await _refresh_tokens():
      return Response.new()
    response = await _send(url, method, payload, auth.get_access_token(), sensitive)
  return response

func _start_request(http: HTTPRequest, url: String, headers: PackedStringArray, method: HTTPClient.Method, body: String) -> Error:
  return http.request(url, headers, method, body)

func _send(url: String, method: HTTPClient.Method, payload: Variant, token: String, sensitive: bool = false) -> Response:
  var headers := PackedStringArray()
  var body := ""
  if payload is String:
    body = payload
  elif payload != null:
    body = JSON.stringify(payload)
    headers.append("Content-Type: application/json")
  if not token.is_empty():
    headers.append("Authorization: Bearer " + token)

  var http := HTTPRequest.new()
  http.timeout = DEFAULT_TIMEOUT
  add_child(http)
  _logger.log_request(method, url, REDACTED if sensitive else body)
  var response := Response.new()
  if _start_request(http, url, headers, method, body) != OK:
    http.queue_free()
    return response
  var result: Array = await http.request_completed
  http.queue_free()
  response.status_code = result[1]
  response.body = (result[3] as PackedByteArray).get_string_from_utf8()
  response.ok = result[0] == HTTPRequest.RESULT_SUCCESS and response.status_code >= 200 and response.status_code < 300
  response.json = JSON.parse_string(response.body)
  _logger.log_response(url, method, response.status_code, REDACTED if sensitive else response.body)
  return response

## Refreshes tokens; concurrent callers share a single refresh.
func _refresh_tokens() -> bool:
  if _is_refreshing:
    return await _refresh_finished
  if not auth.has_session():
    return false
  _is_refreshing = true
  var success := await _do_refresh()
  _is_refreshing = false
  if not success:
    auth.sign_out()
    session_expired.emit()
  _refresh_finished.emit(success)
  return success

func _do_refresh() -> bool:
  var refresh_token: String = auth.get_refresh_token()
  if refresh_token.is_empty():
    return false
  var response := await _send(REFRESH_URL, HTTPClient.METHOD_POST, {"refresh_token": refresh_token}, "", true)
  if not response.ok or not (response.json is Dictionary):
    return false
  var data: Dictionary = response.json
  var access_token: String = data.get("access_token", "")
  if access_token.is_empty():
    return false
  refresh_token = data.get("refresh_token", "")
  if refresh_token.is_empty():
    return false
  return auth.set_session(access_token, refresh_token)
