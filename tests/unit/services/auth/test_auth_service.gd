extends GutTest

const Jwt := preload("res://tests/unit/jwt_helper.gd")

var auth: AuthService
var storage_path: String

func _now() -> int:
  return int(Time.get_unix_time_from_system())

## Access token expiring [param seconds_from_now] seconds from now.
func _token(seconds_from_now: int = 3600) -> String:
  return Jwt.make(_now() + seconds_from_now)

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
  var token := _token()
  assert_true(auth.set_session(token, "refresh"))
  assert_true(auth.has_session())
  assert_eq(auth.get_access_token(), token)
  assert_eq(auth.get_refresh_token(), "refresh")

func test_access_token_expired_returns_empty():
  auth.set_session(_token(-10), "refresh")
  assert_eq(auth.get_access_token(), "")
  assert_true(auth.has_session(), "Refresh token must survive access token expiry")

func test_access_token_inside_expiry_buffer_returns_empty():
  auth.set_session(_token(AuthService.EXPIRY_BUFFER_SECONDS - 5), "refresh")
  assert_eq(auth.get_access_token(), "")

func test_access_token_outside_expiry_buffer_is_returned():
  var token := _token(AuthService.EXPIRY_BUFFER_SECONDS + 60)
  auth.set_session(token, "refresh")
  assert_eq(auth.get_access_token(), token)

func test_expiry_is_read_from_exp_claim():
  auth.set_session(Jwt.make(1794777297, {"user_id": "x", "role": "user", "iat": 1794172497}), "refresh")
  assert_eq(auth._access_token_expires_at, 1794777297)

func test_exp_claim_as_float_is_accepted():
  auth.set_session(Jwt.make_from_payload('{"exp":1794777297.0}'), "refresh")
  assert_eq(auth._access_token_expires_at, 1794777297)

func test_payload_needing_base64_padding_is_decoded():
  for padding_length in range(4):
    var payload := '{"exp":1794777297,"p":"%s"}' % "a".repeat(padding_length)
    assert_true(auth.set_session(Jwt.make_from_payload(payload), "refresh"), "padding %d" % padding_length)
    assert_eq(auth._access_token_expires_at, 1794777297)

func test_payload_with_base64url_characters_is_decoded():
  var token := Jwt.make_from_payload('{"exp":1794777297,"p":"%s"}' % "\u00ff".repeat(6))
  assert_true(token.contains("_") or token.contains("-"), "Test payload must exercise base64url characters")
  assert_true(auth.set_session(token, "refresh"))
  assert_eq(auth._access_token_expires_at, 1794777297)

func test_first_set_session_emits_signed_in_only():
  watch_signals(auth)
  auth.set_session(_token(), "refresh")
  assert_signal_emitted(auth, "signed_in")
  assert_signal_not_emitted(auth, "tokens_refreshed")
  assert_signal_not_emitted(auth, "signed_out")

func test_second_set_session_emits_tokens_refreshed_only():
  auth.set_session(_token(), "refresh")
  watch_signals(auth)
  var token2 := _token(7200)
  auth.set_session(token2, "refresh2")
  assert_signal_emitted(auth, "tokens_refreshed")
  assert_signal_not_emitted(auth, "signed_in")
  assert_signal_not_emitted(auth, "signed_out")
  assert_eq(auth.get_access_token(), token2)
  assert_eq(auth.get_refresh_token(), "refresh2")

func test_empty_access_token_emits_signed_out_only():
  watch_signals(auth)
  assert_false(auth.set_session("", "refresh"))
  assert_signal_emitted(auth, "signed_out")
  assert_signal_not_emitted(auth, "signed_in")
  assert_signal_not_emitted(auth, "tokens_refreshed")
  assert_eq(auth.get_access_token(), "")

func test_unreadable_access_token_clears_session():
  var bad_tokens := [
    "access",
    "a.b",
    "a.b.c.d",
    "header.!!!!.sig",
    Jwt.make_from_payload("not json"),
    Jwt.make_from_payload("[1]"),
    Jwt.make_from_payload('{"user_id":"x"}'),
    Jwt.make_from_payload('{"exp":"soon"}'),
    Jwt.make_from_payload('{"exp":-5}'),
  ]
  for bad_token in bad_tokens:
    auth.set_session(_token(), "refresh")
    watch_signals(auth)
    assert_false(auth.set_session(bad_token, "refresh2"), bad_token)
    assert_signal_emitted(auth, "signed_out", bad_token)
    assert_signal_not_emitted(auth, "tokens_refreshed", bad_token)
    assert_false(auth.has_session(), bad_token)
    assert_eq(auth.get_access_token(), "", bad_token)

func test_empty_refresh_token_overwrites_existing_one():
  auth.set_session(_token(), "refresh")
  watch_signals(auth)
  assert_false(auth.set_session(_token(7200), ""))
  assert_signal_emitted(auth, "signed_out")
  assert_signal_not_emitted(auth, "tokens_refreshed")
  assert_eq(auth.get_refresh_token(), "")
  assert_false(auth.has_session())

func test_refresh_token_is_persisted_and_loaded():
  auth.set_session(_token(), "refresh")
  var other := _new_auth()
  other._load()
  assert_eq(other.get_refresh_token(), "refresh")
  assert_true(other.has_session())
  assert_eq(other.get_access_token(), "", "Access token must not be persisted")

func test_empty_refresh_token_is_persisted_as_empty():
  auth.set_session(_token(), "refresh")
  auth.set_session(_token(7200), "")
  var other := _new_auth()
  other._load()
  assert_false(other.has_session())

func test_load_without_file_leaves_session_empty():
  var other := _new_auth()
  other._load()
  assert_false(other.has_session())

func test_sign_out_clears_session_and_file():
  auth.set_session(_token(), "refresh")
  watch_signals(auth)
  auth.sign_out()
  assert_signal_emitted(auth, "signed_out")
  assert_false(auth.has_session())
  assert_eq(auth.get_access_token(), "")
  assert_eq(auth.get_refresh_token(), "")
  assert_false(FileAccess.file_exists(storage_path))

func test_set_session_after_sign_out_emits_signed_in():
  auth.set_session(_token(), "refresh")
  auth.sign_out()
  watch_signals(auth)
  auth.set_session(_token(7200), "refresh2")
  assert_signal_emitted(auth, "signed_in")

func test_email_is_stored_persisted_and_loaded():
  auth.set_session(_token(), "refresh", "a@b.c")
  assert_eq(auth.get_email(), "a@b.c")
  var other := _new_auth()
  other._load()
  assert_eq(other.get_email(), "a@b.c")

func test_refresh_without_email_keeps_existing_email():
  auth.set_session(_token(), "refresh", "a@b.c")
  auth.set_session(_token(7200), "refresh2")
  assert_eq(auth.get_email(), "a@b.c")

func test_sign_out_clears_email():
  auth.set_session(_token(), "refresh", "a@b.c")
  auth.sign_out()
  assert_eq(auth.get_email(), "")

func test_empty_tokens_clear_email():
  auth.set_session(_token(), "refresh", "a@b.c")
  auth.set_session("", "")
  assert_eq(auth.get_email(), "")
