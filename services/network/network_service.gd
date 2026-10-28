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

const DOMAIN := "http://localhost:8080/"
const REFRESH_URL := DOMAIN + "v1/auth/refresh"

## Result of a network call.[br]
## [code]ok[/code] is true when the request completed with a 2xx status.
class Response:
  var ok: bool = false
  var status_code: int = 0
  var body: String = ""
  var json: Variant = null

var _logger := NetworkLogger.new()
var _is_refreshing := false

## Performs a request and returns a [Response].[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — Path relative to the server domain, or an absolute URL.[br]
## [code]method[/code] : [HTTPClient.Method] — HTTP method.[br]
## [code]payload[/code] : [Variant] — Dictionary/Array (sent as JSON), String, or null.[br]
## [code]authenticated[/code] : [bool] — Attach the bearer token and refresh it when needed.[br]
func request(
    path: String,
    method: HTTPClient.Method,
    payload: Variant = null,
    authenticated: bool = true) -> Response:
  var url := path if path.begins_with("http") else DOMAIN + path.trim_prefix("/")
  if not authenticated:
    return await _send(url, method, payload, "")

  var token: String = Auth.get_access_token()
  if token.is_empty():
    if not await _refresh_tokens():
      return Response.new()
    token = Auth.get_access_token()
  var response := await _send(url, method, payload, token)
  if response.status_code == 401:
    if not await _refresh_tokens():
      return response
    response = await _send(url, method, payload, Auth.get_access_token())
  return response

func _send(url: String, method: HTTPClient.Method, payload: Variant, token: String) -> Response:
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
  add_child(http)
  _logger.log_request(method, url, body)
  var response := Response.new()
  if http.request(url, headers, method, body) != OK:
    http.queue_free()
    return response
  var result: Array = await http.request_completed
  http.queue_free()
  response.status_code = result[1]
  response.body = (result[3] as PackedByteArray).get_string_from_utf8()
  response.ok = result[0] == HTTPRequest.RESULT_SUCCESS and response.status_code >= 200 and response.status_code < 300
  response.json = JSON.parse_string(response.body)
  _logger.log_response(url, method, response.status_code, response.body)
  return response

## Refreshes tokens; concurrent callers share a single refresh.
func _refresh_tokens() -> bool:
  if _is_refreshing:
    return await _refresh_finished
  _is_refreshing = true
  var success := await _do_refresh()
  _is_refreshing = false
  if not success:
    Auth.sign_out()
    session_expired.emit()
  _refresh_finished.emit(success)
  return success

func _do_refresh() -> bool:
  var refresh_token: String = Auth.get_refresh_token()
  if refresh_token.is_empty():
    return false
  var response := await _send(REFRESH_URL, HTTPClient.METHOD_POST, {"refresh_token": refresh_token}, "")
  if not response.ok or not (response.json is Dictionary):
    return false
  var data: Dictionary = response.json
  var access_token: String = data.get("access_token", "")
  if access_token.is_empty():
    return false
  var expires_at := int(Time.get_unix_time_from_system()) + int(data.get("expires_in", 0))
  Auth.set_session(access_token, data.get("refresh_token", ""), expires_at)
  return true
