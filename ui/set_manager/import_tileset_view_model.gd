class_name ImportTilesetViewModel
extends RefCounted
## ImportTilesetViewModel
##
## [i]Manages the state and logic for dialog which imports tile sets from directories of STL files.[/i][br]
## [b]Properties:[/b][br]
## - [b]file_loader[/b]: [LoadSavedFiles] instance for handling file import operations.[br]
## - [b]import_path[/b]: [String] filesystem path to the directory being imported.[br]
## - [b]import_tile_amount[/b]: [int] total number of tiles to import.[br]
## - [b]imported_tiles_count[/b]: [int] current count of imported tiles.[br]
## - [b]import_thread[/b]: [Thread] for running import operations asynchronously.[br]
## - [b]is_valid[/b]: [bool] whether the current state is valid for import.[br]
## - [b]show_import_progress[/b]: [bool] whether to display import progress.[br]
## - [b]tileset_name[/b]: [String] name for the imported tile set.[br]
## [b]Signals:[/b][br]
## - [code]validity_updated()[/code]: Emitted when import validity state changes.[br]
## - [code]import_complete()[/code]: Emitted when import process finishes.[br]
## - [code]import_path_updated()[/code]: Emitted when import path changes.[br]
## - [code]import_state_updated()[/code]: Emitted when import progress state changes.[br]

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

## Initialize the view model and connect file loader signals[br]
func _init() -> void:
  file_loader.import_started.connect(initialize_import_label)
  file_loader.tile_imported.connect(update_import_label)
  file_loader.import_complete.connect(on_import_complete)

## Reset the view model to its initial state[br]
## [b]Emits:[/b][br]
## - [code]import_path_updated()[/code][br]
## - [code]import_state_updated()[/code][br]
## - [code]validity_updated()[/code][br]
func set_initial_state() -> void:
  import_path = ""
  import_path_updated.emit()
  show_import_progress = false
  tileset_name = ""
  import_state_updated.emit()
  is_valid = false
  validity_updated.emit()

## Generate formatted import progress string[br]
## [b]Returns:[/b] [String] — formatted progress message showing current import status[br]
func get_import_string() -> String:
  return IMPORT_STATUS_LABEL_TEMPLATE % [
      import_tile_amount,
      imported_tiles_count,
      import_tile_amount
  ]

## Initialize import progress tracking with total tile count[br]
## [b]Parameters:[/b][br]
## [code]tile_count[/code] : [int] — total number of tiles to import.[br]
## [b]Emits:[/b][br]
## - [code]import_state_updated()[/code][br]
func initialize_import_label(tile_count: int) -> void:
  import_tile_amount = tile_count
  imported_tiles_count = 0
  show_import_progress = true
  import_state_updated.emit()

## Increment imported tile count and update state[br]
## [b]Emits:[/b][br]
## - [code]import_state_updated()[/code][br]
func update_import_label() -> void:
  imported_tiles_count += 1
  import_state_updated.emit()

## Forward import_complete signal[br]
## [b]Emits:[/b][br]
## - [code]import_complete()[/code][br]
func on_import_complete() -> void:
  import_complete.emit()

## Update the tile set name and check validity[br]
## [b]Parameters:[/b][br]
## [code]new_name[/code] : [String] — name for the tile set.[br]
func update_set_name(new_name: String) -> void:
  tileset_name = new_name
  check_validity()

## Validate import configuration and emit signal if validity changed[br]
## [b]Emits:[/b][br]
## - [code]validity_updated()[/code] when validity state changes[br]
func check_validity() -> void:
  var prev_validity = is_valid
  is_valid = tileset_name != "" and import_path != ""
  if is_valid != prev_validity:
    validity_updated.emit()

## Set the directory path for import and validate[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — filesystem path to the directory containing tile files.[br]
## [b]Emits:[/b][br]
## - [code]import_path_updated()[/code][br]
func set_import_path(path: String) -> void:
  import_path = path
  import_path_updated.emit()
  check_validity()

## Start the tile set import process on a background thread[br]
func start_import() -> void:
  if not import_thread.is_alive() and import_thread.is_started():
    import_thread.wait_to_finish()
  import_thread.start(
      file_loader.import_tile_set_from_directory.bind(import_path, tileset_name)
  )

## Cancel the current import operation[br]
func cancel_import() -> void:
  file_loader.cancel_import()
