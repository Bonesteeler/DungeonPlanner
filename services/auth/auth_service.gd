class_name AuthService
extends Node
## AuthService
##
## [i]Stores profile auth data and provides access tokens to other services.[/i][br]
## Call [code]await get_access_token()[/code] before any authenticated API call. If the stored
## access token is missing or expired, the refresh token is used to obtain a new one.[br]
## [b]Signals:[/b][br]
## - [code]signed_in()[/code]: Tokens were stored via [code]set_session()[/code].[br]
## - [code]signed_out()[/code]: Session was cleared (explicitly or after a rejected refresh).[br]

signal signed_in()
signal signed_out()
signal _refresh_finished(success: bool)

# TODO: fill in URL
const REFRESH_URL := ""

const STORAGE_PATH := "user://auth.cfg"
const STORAGE_SECTION := "auth"
# Refresh slightly early to avoid sending a token that expires in flight.
const EXPIRY_SKEW_SECONDS := 30

var profile_id: String = ""
var username: String = ""

var _access_token: String = ""
var _refresh_token: String = ""
## Unix time (seconds) at which the access token expires. 0 means unknown.
var _access_token_expires_at: int = 0
var _is_refreshing := false

func _ready() -> void:
  _load()

## True if there is a refresh token, i.e. a session can be restored.[br]
func has_session() -> bool:
  return not _refresh_token.is_empty()

## Stores a new session and persists it.[br]
## [b]Parameters:[/b][br]
## [code]access_token[/code] : [String] — The new access token.[br]
## [code]refresh_token[/code] : [String] — The new refresh token.[br]
## [code]expires_in[/code] : [int] — Access token lifetime in seconds (0 if unknown).[br]
## [code]profile[/code] : [Dictionary] — Optional keys: [code]profile_id[/code], [code]username[/code].[br]
func set_session(access_token: String, refresh_token: String, expires_in: int = 0, profile: Dictionary = {}) -> void:
  _store_tokens(access_token, refresh_token, expires_in)
  profile_id = profile.get("profile_id", profile_id)
  username = profile.get("username", username)
  _save()
  signed_in.emit()

## Clears the session from memory and disk.[br]
func sign_out() -> void:
  _access_token = ""
  _refresh_token = ""
  _access_token_expires_at = 0
  profile_id = ""
  username = ""
  DirAccess.remove_absolute(ProjectSettings.globalize_path(STORAGE_PATH))
  signed_out.emit()

## Returns a valid access token, refreshing it first if needed.[br]
## Returns an empty string if the user is not signed in or the refresh failed.[br]
func get_access_token() -> String:
  if _is_access_token_valid():
    return _access_token
  if not has_session():
    return ""
  if _is_refreshing:
    await _refresh_finished
  else:
    await _refresh()
  return _access_token if _is_access_token_valid() else ""

## Returns headers for an authenticated request, or an empty array if unauthenticated.[br]
func get_auth_headers() -> PackedStringArray:
  var token := await get_access_token()
  if token.is_empty():
    return PackedStringArray()
  return PackedStringArray(["Authorization: Bearer %s" % token])

func _is_access_token_valid() -> bool:
  if _access_token.is_empty():
    return false
  if _access_token_expires_at == 0:
    return true
  return Time.get_unix_time_from_system() < _access_token_expires_at - EXPIRY_SKEW_SECONDS

func _store_tokens(access_token: String, refresh_token: String, expires_in: int) -> void:
  _access_token = access_token
  if not refresh_token.is_empty():
    _refresh_token = refresh_token
  _access_token_expires_at = int(Time.get_unix_time_from_system()) + expires_in if expires_in > 0 else 0

func _refresh() -> void:
  _is_refreshing = true
  var success := await _request_refresh()
  _is_refreshing = false
  _refresh_finished.emit(success)

func _request_refresh() -> bool:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  var headers: PackedStringArray = ["Content-Type: application/json"]
  var body := JSON.stringify({"refresh_token": _refresh_token})
  var error := http_request.request(REFRESH_URL, headers, HTTPClient.METHOD_POST, body)
  if error != OK:
    http_request.queue_free()
    return false
  var response: Array = await http_request.request_completed
  http_request.queue_free()
  var result: int = response[0]
  var response_code: int = response[1]
  var response_body: PackedByteArray = response[3]
  if result != HTTPRequest.RESULT_SUCCESS:
    # Network failure: keep the session so a later attempt can retry.
    return false
  if response_code == 401 or response_code == 403:
    # Refresh token rejected; the session is no longer recoverable.
    sign_out()
    return false
  if response_code != 200:
    return false
  var json = JSON.parse_string(response_body.get_string_from_utf8())
  if not json is Dictionary or not json.has("access_token"):
    return false
  _store_tokens(json.access_token, json.get("refresh_token", ""), int(json.get("expires_in", 0)))
  _save()
  return true

func _save() -> void:
  var config := ConfigFile.new()
  config.set_value(STORAGE_SECTION, "access_token", _access_token)
  config.set_value(STORAGE_SECTION, "refresh_token", _refresh_token)
  config.set_value(STORAGE_SECTION, "expires_at", _access_token_expires_at)
  config.set_value(STORAGE_SECTION, "profile_id", profile_id)
  config.set_value(STORAGE_SECTION, "username", username)
  config.save_encrypted_pass(STORAGE_PATH, OS.get_unique_id())

func _load() -> void:
  var config := ConfigFile.new()
  if config.load_encrypted_pass(STORAGE_PATH, OS.get_unique_id()) != OK:
    return
  _access_token = config.get_value(STORAGE_SECTION, "access_token", "")
  _refresh_token = config.get_value(STORAGE_SECTION, "refresh_token", "")
  _access_token_expires_at = config.get_value(STORAGE_SECTION, "expires_at", 0)
  profile_id = config.get_value(STORAGE_SECTION, "profile_id", "")
  username = config.get_value(STORAGE_SECTION, "username", "")
