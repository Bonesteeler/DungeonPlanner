class_name AuthService
extends Node
## AuthService
##
## [i]Stores authentication tokens and provides access tokens to other services.[/i][br]
## Call [code]get_access_token()[/code] before any authenticated API call. Access tokens
## stay in memory; the refresh token is persisted for use by the authentication flow.[br]
## [b]Signals:[/b][br]
## - [code]signed_in()[/code]: [code]set_session()[/code] was called while no access token was held[br]
## - [code]tokens_refreshed()[/code]: [code]set_session()[/code] replaced an access token that was already held.[br]
## - [code]signed_out()[/code]: The session was cleared, for any reason.[br]

signal signed_in()
signal tokens_refreshed()
signal signed_out()

const STORAGE_PATH := "user://auth.cfg"
const STORAGE_SECTION := "auth"
const REFRESH_TOKEN := "refresh_token"
const EMAIL := "email"
const EXPIRY_BUFFER_SECONDS := 30
## Matches unpadded standard base64.
static var _BASE64_PATTERN := RegEx.create_from_string("^[A-Za-z0-9+/]+$")

var _storage_path := STORAGE_PATH
var _access_token: String = ""
var _refresh_token: String = ""
var _email: String = ""
## Unix time at which the access token expires.
var _access_token_expires_at: int = 0

func _ready() -> void:
  _load()

## True if a refresh token is stored.[br]
func has_session() -> bool:
  return not _refresh_token.is_empty()

## Stores an access token in memory and persists the refresh token and email.[br]
## [b]Parameters:[/b][br]
## [code]access_token[/code] : [String] — The new access token.[br]
## [code]refresh_token[/code] : [String] — The new refresh token.[br]
## [code]email[/code] : [String] — The signed in user's email.[br]
## [b]Returns:[/b] [bool] — false if a token was empty or the access token's expiry could not be read; the session is cleared.[br]
func set_session(access_token: String, refresh_token: String, email: String = "") -> bool:
  var expires_at := _read_expiry(access_token)
  if refresh_token.is_empty() or expires_at < 0:
    sign_out()
    return false
  var was_active := not _access_token.is_empty()
  _access_token = access_token
  _refresh_token = refresh_token
  _access_token_expires_at = expires_at
  if not email.is_empty():
    _email = email
  _save()
  if was_active:
    tokens_refreshed.emit()
  else:
    signed_in.emit()
  return true

## Clears the session from memory and disk.[br]
func sign_out() -> void:
  _access_token = ""
  _refresh_token = ""
  _email = ""
  _access_token_expires_at = 0
  DirAccess.remove_absolute(ProjectSettings.globalize_path(_storage_path))
  signed_out.emit()

## Returns the access token if it is valid, or an empty string otherwise.[br]
func get_access_token() -> String:
  if _is_access_token_valid():
    return _access_token
  return ""

## Returns the stored refresh token, or an empty string if there is none.[br]
func get_refresh_token() -> String:
  return _refresh_token

## Returns the stored email, or an empty string if there is none.[br]
func get_email() -> String:
  return _email

## Returns the JWT's [code]exp[/code] claim, or -1 if it cannot be read.[br]
func _read_expiry(token: String) -> int:
  var parts := token.split(".")
  if parts.size() != 3:
    return -1
  var payload := parts[1].replace("-", "+").replace("_", "/")
  if payload.length() % 4 == 1 or not _BASE64_PATTERN.search(payload):
    return -1
  while payload.length() % 4 != 0:
    payload += "="
  var bytes := Marshalls.base64_to_raw(payload)
  if bytes.is_empty():
    return -1
  var json := JSON.new()
  if json.parse(bytes.get_string_from_utf8()) != OK or not (json.data is Dictionary):
    return -1
  var expiry: Variant = json.data.get("exp")
  if not (expiry is float or expiry is int) or expiry < 0:
    return -1
  return int(expiry)

func _is_access_token_valid() -> bool:
  if _access_token.is_empty():
    return false
  var current_time := Time.get_unix_time_from_system()
  return current_time < _access_token_expires_at - EXPIRY_BUFFER_SECONDS

func _save() -> void:
  var config := ConfigFile.new()
  config.set_value(STORAGE_SECTION, REFRESH_TOKEN, _refresh_token)
  config.set_value(STORAGE_SECTION, EMAIL, _email)
  config.save_encrypted_pass(_storage_path, OS.get_unique_id())

func _load() -> void:
  var config := ConfigFile.new()
  if config.load_encrypted_pass(_storage_path, OS.get_unique_id()) != OK:
    return
  _refresh_token = config.get_value(STORAGE_SECTION, REFRESH_TOKEN, "")
  _email = config.get_value(STORAGE_SECTION, EMAIL, "")
