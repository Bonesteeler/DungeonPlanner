class_name ProfileViewModel
extends RefCounted
## ProfileViewModel
##
## [i]Mediates between the Network/Auth autoloads and the profile UI.[/i][br]
## [b]Signals:[/b][br]
## - [code]signed_out()[/code]: The session ended, either by logging out or because it expired.[br]

signal signed_out()

const LOGIN_URL := "auth/login"
const SIGNUP_URL := "auth/signup"

var network: NetworkService
var auth: AuthService

func _init(network_service: NetworkService = Network, auth_service: AuthService = Auth) -> void:
  network = network_service
  auth = auth_service
  auth.signed_out.connect(signed_out.emit)

## True if a session is stored.[br]
func is_logged_in() -> bool:
  return auth.has_session()

## The email of the logged in user, or an empty string.[br]
func get_email() -> String:
  return auth.get_email()

## Logs in and stores the returned session.[br]
## [b]Parameters:[/b][br]
## [code]email[/code] : [String] — The account email.[br]
## [code]password[/code] : [String] — The account password.[br]
## [b]Returns:[/b] [bool] — true if a session was stored.[br]
func login(email: String, password: String) -> bool:
  return await _authenticate(LOGIN_URL, {"email": email, "password": password})

## Creates an account and stores the returned session.[br]
## [b]Parameters:[/b][br]
## [code]username[/code] : [String] — The new account's username.[br]
## [code]email[/code] : [String] — The account email.[br]
## [code]password[/code] : [String] — The account password.[br]
## [b]Returns:[/b] [bool] — true if a session was stored.[br]
func signup(username: String, email: String, password: String) -> bool:
  return await _authenticate(SIGNUP_URL, {"username": username, "email": email, "password": password})

## Ends the session.[br]
func log_out() -> void:
  auth.sign_out()

func _authenticate(path: String, payload: Dictionary) -> bool:
  var response := await network.request(path, HTTPClient.METHOD_POST, payload, false, true)
  if not response.ok or not (response.json is Dictionary):
    return false
  var data: Dictionary = response.json
  var access_token: String = data.get("access_token", "")
  var refresh_token: String = data.get("refresh_token", "")
  if access_token.is_empty() or refresh_token.is_empty():
    return false
  return auth.set_session(access_token, refresh_token, payload.get("email", ""))
