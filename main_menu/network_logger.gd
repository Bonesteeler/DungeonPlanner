class_name NetworkLogger
extends RefCounted
## NetworkLogger
##
## [i]Logs HTTP network events to the Godot console and [code]user://logs/network.log[/code].[/i][br]
## [b]Configuration:[/b][br]
## Read [code]user://logs/network_logger.cfg[/code] on construction. Missing file or key defaults to [code]NONE[/code] (silent).[br]

enum LogLevel {
  INFO = 0,
  WARNING = 1,
  ERROR = 2,
  NONE = 0x7FFFFFFF,
}

func _get_level_string(level: LogLevel) -> String:
  match level:
    LogLevel.INFO: return "INFO"
    LogLevel.WARNING: return "WARNING"
    LogLevel.ERROR: return "ERROR"
    LogLevel.NONE: return "NONE"
    _: return "UNKNOWN"

const _CONFIG_PATH := _LOG_DIR + "/network_logger.cfg"
const _LOG_PATH := _LOG_DIR + "/network.log"
const _LOG_DIR := "user://logs"
const _MIN_LEVEL_KEY := "min_level"
const _SECTION_KEY := "logger"

var _min_level: LogLevel = LogLevel.NONE
var _log_file: FileAccess


func _init() -> void:
  _load_config()
  DirAccess.make_dir_recursive_absolute(_LOG_DIR)
  _log_file = FileAccess.open(_LOG_PATH, FileAccess.READ_WRITE)
  if _log_file:
    _log_file.seek_end(0)
  else:
    _log_file = FileAccess.open(_LOG_PATH, FileAccess.WRITE)


func _load_config() -> void:
  var cfg := ConfigFile.new()
  if cfg.load(_CONFIG_PATH) != OK:
    return
  if not cfg.has_section_key(_SECTION_KEY, _MIN_LEVEL_KEY):
    return
  var raw: int = cfg.get_value(_SECTION_KEY, _MIN_LEVEL_KEY)
  if raw == LogLevel.INFO or raw == LogLevel.WARNING or raw == LogLevel.ERROR or raw == LogLevel.NONE:
    _min_level = raw as LogLevel


func _format_entry(level: LogLevel, tag: String, message: String) -> String:
  var timestamp := Time.get_datetime_string_from_system(true)
  return "[%s] %s [%s] %s" % [timestamp, _get_level_string(level), tag, message]

func _write(level: LogLevel, tag: String, message: String) -> void:
  if level < _min_level:
    return
  var entry := _format_entry(level, tag, message)
  print(entry)
  if _log_file:
    _log_file.store_line(entry)
    _log_file.flush()


## Log an outgoing HTTP request.[br]
func log_request(method: String, url: String, body: String = "") -> void:
  var msg: String
  if body.length() > 0:
    msg = "%s %s body: %s" % [method, url, body]
  else:
    msg = "%s %s" % [method, url]
  _write(LogLevel.INFO, "REQUEST ", msg)


## Log a completed HTTP response.[br]
## Level is determined by [code]response_code[/code]: INFO for 2xx, WARNING for 4xx, ERROR for 5xx or 0.
func log_response(url: String, method: String, response_code: int, body: String = "") -> void:
  var response_class = response_code / 100
  var msg := "%d %s %s" % [response_code, method, url]
  if body.length() > 0:
    msg += " body: %s" % [body]
  var level: LogLevel
  if response_class == 2:
    level = LogLevel.INFO
  elif response_class == 4:
    level = LogLevel.WARNING
  elif response_class == 5:
    level = LogLevel.ERROR
  else:
    level = LogLevel.INFO
  _write(level, "RESPONSE", msg)
