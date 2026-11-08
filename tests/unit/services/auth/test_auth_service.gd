extends GutTest

var auth: AuthService
var storage_path: String

func _now() -> int:
  return int(Time.get_unix_time_from_system())

func _new_auth() -> AuthService:
  var service := AuthService.new()
  service._storage_path = storage_path
  return autofree(service)

func before_each():
  storage_path = "user://test_auth_%d.cfg" % Time.get_ticks_usec()
  auth = _new_auth()

func after_each():
  DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path))

func test_has_no_session_initially():
  assert_false(auth.has_session())
  assert_eq(auth.get_access_token(), "")
  assert_eq(auth.get_refresh_token(), "")

func test_set_session_stores_tokens():
  auth.set_session("access", "refresh", _now() + 3600)
  assert_true(auth.has_session())
  assert_eq(auth.get_access_token(), "access")
  assert_eq(auth.get_refresh_token(), "refresh")

func test_access_token_expired_returns_empty():
  auth.set_session("access", "refresh", _now() - 10)
  assert_eq(auth.get_access_token(), "")
  assert_true(auth.has_session(), "Refresh token must survive access token expiry")

func test_access_token_inside_expiry_buffer_returns_empty():
  auth.set_session("access", "refresh", _now() + AuthService.EXPIRY_BUFFER_SECONDS - 5)
  assert_eq(auth.get_access_token(), "")

func test_access_token_outside_expiry_buffer_is_returned():
  auth.set_session("access", "refresh", _now() + AuthService.EXPIRY_BUFFER_SECONDS + 60)
  assert_eq(auth.get_access_token(), "access")

func test_first_set_session_emits_signed_in_only():
  watch_signals(auth)
  auth.set_session("access", "refresh", _now() + 3600)
  assert_signal_emitted(auth, "signed_in")
  assert_signal_not_emitted(auth, "tokens_refreshed")
  assert_signal_not_emitted(auth, "signed_out")

func test_second_set_session_emits_tokens_refreshed_only():
  auth.set_session("access", "refresh", _now() + 3600)
  watch_signals(auth)
  auth.set_session("access2", "refresh2", _now() + 3600)
  assert_signal_emitted(auth, "tokens_refreshed")
  assert_signal_not_emitted(auth, "signed_in")
  assert_signal_not_emitted(auth, "signed_out")
  assert_eq(auth.get_access_token(), "access2")
  assert_eq(auth.get_refresh_token(), "refresh2")

func test_empty_access_token_emits_signed_out_only():
  watch_signals(auth)
  auth.set_session("", "refresh", _now() + 3600)
  assert_signal_emitted(auth, "signed_out")
  assert_signal_not_emitted(auth, "signed_in")
  assert_signal_not_emitted(auth, "tokens_refreshed")
  assert_eq(auth.get_access_token(), "")

func test_empty_refresh_token_overwrites_existing_one():
  auth.set_session("access", "refresh", _now() + 3600)
  watch_signals(auth)
  auth.set_session("access2", "", _now() + 3600)
  assert_signal_emitted(auth, "signed_out")
  assert_signal_not_emitted(auth, "tokens_refreshed")
  assert_eq(auth.get_refresh_token(), "")
  assert_false(auth.has_session())

func test_refresh_token_is_persisted_and_loaded():
  auth.set_session("access", "refresh", _now() + 3600)
  var other := _new_auth()
  other._load()
  assert_eq(other.get_refresh_token(), "refresh")
  assert_true(other.has_session())
  assert_eq(other.get_access_token(), "", "Access token must not be persisted")

func test_empty_refresh_token_is_persisted_as_empty():
  auth.set_session("access", "refresh", _now() + 3600)
  auth.set_session("access2", "", _now() + 3600)
  var other := _new_auth()
  other._load()
  assert_false(other.has_session())

func test_load_without_file_leaves_session_empty():
  var other := _new_auth()
  other._load()
  assert_false(other.has_session())

func test_sign_out_clears_session_and_file():
  auth.set_session("access", "refresh", _now() + 3600)
  watch_signals(auth)
  auth.sign_out()
  assert_signal_emitted(auth, "signed_out")
  assert_false(auth.has_session())
  assert_eq(auth.get_access_token(), "")
  assert_eq(auth.get_refresh_token(), "")
  assert_false(FileAccess.file_exists(storage_path))

func test_set_session_after_sign_out_emits_signed_in():
  auth.set_session("access", "refresh", _now() + 3600)
  auth.sign_out()
  watch_signals(auth)
  auth.set_session("access2", "refresh2", _now() + 3600)
  assert_signal_emitted(auth, "signed_in")

func test_email_is_stored_persisted_and_loaded():
  auth.set_session("access", "refresh", _now() + 3600, "a@b.c")
  assert_eq(auth.get_email(), "a@b.c")
  var other := _new_auth()
  other._load()
  assert_eq(other.get_email(), "a@b.c")

func test_refresh_without_email_keeps_existing_email():
  auth.set_session("access", "refresh", _now() + 3600, "a@b.c")
  auth.set_session("access2", "refresh2", _now() + 3600)
  assert_eq(auth.get_email(), "a@b.c")

func test_sign_out_clears_email():
  auth.set_session("access", "refresh", _now() + 3600, "a@b.c")
  auth.sign_out()
  assert_eq(auth.get_email(), "")

func test_empty_tokens_clear_email():
  auth.set_session("access", "refresh", _now() + 3600, "a@b.c")
  auth.set_session("", "", _now() + 3600)
  assert_eq(auth.get_email(), "")
