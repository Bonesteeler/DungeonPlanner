extends GutTest

const Jwt := preload("res://tests/unit/jwt_helper.gd")


class FakeNetwork:
	extends NetworkService
	var response := NetworkService.Response.new()
	var profile_response := NetworkService.Response.new()
	var calls: Array = []

	func request(
		path: String,
		method: HTTPClient.Method,
		payload: Variant = null,
		authenticated: bool = true,
		sensitive: bool = false
	) -> NetworkService.Response:
		calls.append(
			{
				"path": path,
				"method": method,
				"payload": payload,
				"authenticated": authenticated,
				"sensitive": sensitive
			}
		)
		if path == ProfileViewModel.PROFILE_URL:
			return profile_response
		return response


var net: FakeNetwork
var auth: AuthService
var storage_path: String
var vm: ProfileViewModel


func _token() -> String:
	return Jwt.make(int(Time.get_unix_time_from_system()) + 3600)


func _token_response(status: int = 200, json: Variant = null) -> NetworkService.Response:
	var result := NetworkService.Response.new()
	result.status_code = status
	result.ok = status >= 200 and status < 300
	result.json = json
	return result


func _profile_response(
	status: int = 200, username: String = "user", email: String = "a@b.c"
) -> NetworkService.Response:
	return _token_response(status, {"username": username, "email": email})


func before_each() -> void:
	storage_path = "user://test_profile_vm_%d.cfg" % Time.get_ticks_usec()
	auth = autofree(AuthService.new())
	auth._storage_path = storage_path
	net = FakeNetwork.new()
	add_child_autofree(net)
	vm = ProfileViewModel.new(net, auth)


func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path))


func test_login_posts_credentials_unauthenticated_and_sensitive() -> void:
	await vm.login("a@b.c", "pw")
	assert_eq(net.calls[0].path, ProfileViewModel.LOGIN_URL)
	assert_eq(net.calls[0].method, HTTPClient.METHOD_POST)
	assert_eq(net.calls[0].payload, {"email": "a@b.c", "password": "pw"})
	assert_false(net.calls[0].authenticated)
	assert_true(net.calls[0].sensitive)


func test_signup_posts_username_with_credentials() -> void:
	await vm.signup("user", "a@b.c", "pw")
	assert_eq(net.calls[0].path, ProfileViewModel.SIGNUP_URL)
	assert_eq(net.calls[0].method, HTTPClient.METHOD_POST)
	assert_eq(net.calls[0].payload, {"username": "user", "email": "a@b.c", "password": "pw"})
	assert_false(net.calls[0].authenticated)
	assert_true(net.calls[0].sensitive)


func test_login_stores_session_and_fetches_profile() -> void:
	var access := _token()
	net.response = _token_response(200, {"access_token": access, "refresh_token": "refresh"})
	net.profile_response = _profile_response()
	var ok: bool = await vm.login("a@b.c", "pw")
	assert_true(ok)
	assert_true(vm.is_logged_in())
	assert_eq(auth.get_access_token(), access)
	assert_eq(auth.get_refresh_token(), "refresh")
	assert_eq(net.calls[1].path, ProfileViewModel.PROFILE_URL)
	assert_eq(net.calls[1].method, HTTPClient.METHOD_GET)
	assert_true(net.calls[1].authenticated)
	assert_eq(vm.get_email(), "a@b.c")
	assert_eq(vm.get_username(), "user")


func test_signup_stores_session_and_fetches_profile() -> void:
	net.response = _token_response(200, {"access_token": _token(), "refresh_token": "refresh"})
	net.profile_response = _profile_response()
	var ok: bool = await vm.signup("user", "a@b.c", "pw")
	assert_true(ok)
	assert_true(vm.is_logged_in())
	assert_eq(vm.get_email(), "a@b.c")
	assert_eq(vm.get_username(), "user")


func test_login_keeps_session_when_profile_fetch_fails() -> void:
	net.response = _token_response(200, {"access_token": _token(), "refresh_token": "refresh"})
	net.profile_response = _token_response(500)
	var ok: bool = await vm.login("a@b.c", "pw")
	assert_true(ok)
	assert_true(vm.is_logged_in())
	assert_eq(vm.get_email(), "")
	assert_eq(vm.get_username(), "")


func test_login_fails_on_error_status() -> void:
	net.response = _token_response(401, {"access_token": "access", "refresh_token": "refresh"})
	var ok: bool = await vm.login("a@b.c", "pw")
	assert_false(ok)
	assert_false(vm.is_logged_in())


func test_login_fails_on_missing_tokens() -> void:
	net.response = _token_response(200, {"access_token": "access"})
	var ok: bool = await vm.login("a@b.c", "pw")
	assert_false(ok)
	assert_false(vm.is_logged_in())


func test_login_fails_on_unreadable_access_token() -> void:
	net.response = _token_response(200, {"access_token": "access", "refresh_token": "refresh"})
	var ok: bool = await vm.login("a@b.c", "pw")
	assert_false(ok)
	assert_false(vm.is_logged_in())


func test_login_fails_on_non_dictionary_body() -> void:
	net.response = _token_response(200, "oops")
	var ok: bool = await vm.login("a@b.c", "pw")
	assert_false(ok)


func test_log_out_clears_session_and_emits_signed_out() -> void:
	auth.set_session(_token(), "refresh")
	watch_signals(vm)
	vm.log_out()
	assert_signal_emitted(vm, "signed_out")
	assert_false(vm.is_logged_in())
	assert_eq(vm.get_email(), "")


func test_fetch_profile_populates_username_and_email() -> void:
	auth.set_session(_token(), "refresh")
	net.profile_response = _profile_response(200, "testuser", "test@email.com")
	assert_true(await vm.fetch_profile())
	assert_eq(vm.get_username(), "testuser")
	assert_eq(vm.get_email(), "test@email.com")


func test_fetch_profile_failure_keeps_blank_values() -> void:
	auth.set_session(_token(), "refresh")
	net.profile_response = _token_response(401)
	assert_false(await vm.fetch_profile())
	assert_eq(vm.get_username(), "")
	assert_eq(vm.get_email(), "")


func test_signed_out_clears_profile() -> void:
	auth.set_session(_token(), "refresh")
	net.profile_response = _profile_response()
	await vm.fetch_profile()
	vm.log_out()
	assert_eq(vm.get_username(), "")
	assert_eq(vm.get_email(), "")
