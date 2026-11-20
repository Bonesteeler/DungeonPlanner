class_name ProfileViewModel
extends RefCounted
## ProfileViewModel
##
## [i]Mediates between the Network/Auth autoloads and the profile UI.[/i][br]
## [b]Signals:[/b][br]
## - [code]signed_out()[/code]: The session ended, either by logging out or because it expired.[br]

signal signed_out

const LOGIN_URL := "auth/login"
const SIGNUP_URL := "auth/signup"
const PROFILE_URL := "auth/profile"

var network: NetworkService
var auth: AuthService
var _username: String = ""
var _email: String = ""


func _init(network_service: NetworkService = Network, auth_service: AuthService = Auth) -> void:
	network = network_service
	auth = auth_service
	auth.signed_out.connect(_on_signed_out)


## True if a session is stored.[br]
func is_logged_in() -> bool:
	return auth.has_session()


## The email of the logged in user, or an empty string.[br]
func get_email() -> String:
	return _email


## The username of the logged in user, or an empty string.[br]
func get_username() -> String:
	return _username


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
	return await _authenticate(
		SIGNUP_URL, {"username": username, "email": email, "password": password}
	)


## Ends the session.[br]
func log_out() -> void:
	auth.sign_out()


## Fetches the profile from the server and caches the username and email.[br]
## [b]Returns:[/b] [bool] — true if the profile was fetched; the cached values stay blank otherwise.[br]
func fetch_profile() -> bool:
	var response := await network.request(PROFILE_URL, HTTPClient.METHOD_GET)
	if not response.ok or not (response.json is Dictionary):
		return false
	_username = response.json.get("username", "")
	_email = response.json.get("email", "")
	return true


func _authenticate(path: String, payload: Dictionary) -> bool:
	var response := await network.request(path, HTTPClient.METHOD_POST, payload, false, true)
	if not response.ok or not (response.json is Dictionary):
		return false
	var data: Dictionary = response.json
	var access_token: String = data.get("access_token", "")
	var refresh_token: String = data.get("refresh_token", "")
	if access_token.is_empty() or refresh_token.is_empty():
		return false
	if not auth.set_session(access_token, refresh_token):
		return false
	await fetch_profile()
	return true


func _on_signed_out() -> void:
	_username = ""
	_email = ""
	signed_out.emit()
