extends RefCounted

## Builds an unsigned JWT whose payload holds the given claims.
static func make(expires_at: int, extra_claims: Dictionary = {}) -> String:
  var claims := {"exp": expires_at}
  claims.merge(extra_claims)
  return make_from_payload(JSON.stringify(claims))

## Builds an unsigned JWT with a raw payload string, base64url encoded without padding.
static func make_from_payload(payload_json: String) -> String:
  var header := _encode('{"alg":"HS256","typ":"JWT"}')
  return "%s.%s.sig" % [header, _encode(payload_json)]

static func _encode(text: String) -> String:
  return Marshalls.raw_to_base64(text.to_utf8_buffer()).replace("+", "-").replace("/", "_").replace("=", "")
