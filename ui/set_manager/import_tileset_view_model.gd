class_name ImportTilesetViewModel
extends RefCounted

const IMPORT_STATUS_LABEL_TEMPLATE = "Importing %d tiles, currently %d/%d"

signal validity_updated()
signal import_complete()
signal import_path_updated()
signal import_state_updated()

var file_loader = LoadSavedFiles.new()
var import_path: String = ""
var import_tile_amount: int = 0
var imported_tiles_count: int = 0
var import_thread = Thread.new()
var is_valid: bool = false
var show_import_progress: bool = false
var tileset_name: String = ""

func _init() -> void:
  file_loader.import_started.connect(initialize_import_label)
  file_loader.tile_imported.connect(update_import_label)
  file_loader.import_complete.connect(on_import_complete)

func set_initial_state() -> void:
  import_path = ""
  import_path_updated.emit()
  show_import_progress = false
  tileset_name = ""
  import_state_updated.emit()
  is_valid = false
  validity_updated.emit()

func get_import_string() -> String:
  return IMPORT_STATUS_LABEL_TEMPLATE % [
      import_tile_amount,
      imported_tiles_count,
      import_tile_amount
  ]

func initialize_import_label(tile_count: int) -> void:
  import_tile_amount = tile_count
  imported_tiles_count = 0
  show_import_progress = true
  import_state_updated.emit()

func update_import_label() -> void:
  imported_tiles_count += 1
  import_state_updated.emit()

func on_import_complete() -> void:
  import_complete.emit()

func update_set_name(new_name: String) -> void:
  tileset_name = new_name
  check_validity()

func check_validity() -> void:
  var prev_validity = is_valid
  is_valid = tileset_name != "" and import_path != ""
  if is_valid != prev_validity:
    validity_updated.emit()

func set_import_path(path: String) -> void:
  import_path = path
  import_path_updated.emit()
  check_validity()

func start_import() -> void:
  if not import_thread.is_alive() and import_thread.is_started():
    import_thread.wait_to_finish()
  import_thread.start(
      file_loader.import_tile_set_from_directory.bind(import_path, tileset_name)
  )

func cancel_import() -> void:
  file_loader.cancel_import()
