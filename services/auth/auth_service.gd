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
const EXPIRY_BUFFER_SECONDS := 30

var _access_token: String = ""
var _refresh_token: String = ""
## Unix time at which the access token expires.
var _access_token_expires_at: int = 0

func _ready() -> void:
  _load()

## True if a refresh token is stored.[br]
func has_session() -> bool:
  return not _refresh_token.is_empty()

## Stores an access token in memory and persists the refresh token.[br]
## [b]Parameters:[/b][br]
## [code]access_token[/code] : [String] — The new access token.[br]
## [code]refresh_token[/code] : [String] — The new refresh token.[br]
## [code]expires_at[/code] : [int] — Unix time at which the access token expires.[br]
func set_session(access_token: String, refresh_token: String, expires_at: int) -> void:
  var was_active := not _access_token.is_empty()
  _access_token = access_token
  if not refresh_token.is_empty():
    _refresh_token = refresh_token
  _access_token_expires_at = expires_at
  _save()
  if was_active:
    tokens_refreshed.emit()
  else:
    signed_in.emit()

## Clears the session from memory and disk.[br]
func sign_out() -> void:
  _access_token = ""
  _refresh_token = ""
  _access_token_expires_at = 0
  DirAccess.remove_absolute(ProjectSettings.globalize_path(STORAGE_PATH))
  signed_out.emit()

## Returns the access token if it is valid, or an empty string otherwise.[br]
func get_access_token() -> String:
  if _is_access_token_valid():
    return _access_token
  return ""

## Returns the stored refresh token, or an empty string if there is none.[br]
func get_refresh_token() -> String:
  return _refresh_token

func _is_access_token_valid() -> bool:
  if _access_token.is_empty():
    return false
  return Time.get_unix_time_from_system() < _access_token_expires_at - EXPIRY_BUFFER_SECONDS

func _save() -> void:
  var config := ConfigFile.new()
  config.set_value(STORAGE_SECTION, REFRESH_TOKEN, _refresh_token)
  config.save_encrypted_pass(STORAGE_PATH, OS.get_unique_id())

func _load() -> void:
  var config := ConfigFile.new()
  if config.load_encrypted_pass(STORAGE_PATH, OS.get_unique_id()) != OK:
    return
  _refresh_token = config.get_value(STORAGE_SECTION, REFRESH_TOKEN, "")
