extends GutTest


const SETTING := NetworkService.SERVER_URL_SETTING


# --- URL validation (static) ---


func test_https_hosts_are_allowed() -> void:
	assert_true(NetworkService._is_domain_allowed("https://example.com/"))
	assert_true(
		NetworkService._is_domain_allowed("https://stg-dungeon-planner-backend.herokuapp.com/")
	)


func test_http_localhost_variants_are_allowed() -> void:
	assert_true(NetworkService._is_domain_allowed("http://localhost:8080/"))
	assert_true(NetworkService._is_domain_allowed("http://127.0.0.1:8080/"))
	assert_true(NetworkService._is_domain_allowed("http://[::1]:8080/"))


func test_http_remote_hosts_are_refused() -> void:
	assert_false(NetworkService._is_domain_allowed("http://example.com/"))
	assert_false(NetworkService._is_domain_allowed("http://192.168.1.10/"))
	assert_false(NetworkService._is_domain_allowed("http://localhost.evil.com/"))


func test_malformed_urls_are_refused() -> void:
	assert_false(NetworkService._is_domain_allowed(""))
	assert_false(NetworkService._is_domain_allowed("example.com"))
	assert_false(NetworkService._is_domain_allowed("ftp://example.com/"))
	assert_false(NetworkService._is_domain_allowed("https://"))


# --- Normalization (static) ---


func test_normalize_domain_appends_trailing_slash() -> void:
	assert_eq(NetworkService._normalize_domain("http://a"), "http://a/")
	assert_eq(NetworkService._normalize_domain("http://a/"), "http://a/")


# --- Fail closed ---


func test_invalid_domain_fails_closed() -> void:
	var net := NetworkService.new()
	net.auth = autofree(AuthService.new())
	add_child_autofree(net)
	net._domain_valid = false
	var response := await net.request("v1/x", HTTPClient.METHOD_GET, null, false)
	assert_false(response.ok)
	assert_eq(response.status_code, 0)
