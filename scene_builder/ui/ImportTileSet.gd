extends Control
## ImportTileSet
##
## [i]UI control for importing tile sets from directories containing tile files.[/i][br]
## [b]Signals:[/b][br]
## - [code]set_imported[/code]: Emitted when the import process completes successfully.[br]
## [b]Constants:[/b][br]
## - [code]IMPORT_STATUS_LABEL_TEMPLATE[/code]: Template string for displaying import progress.[br]
## [b]Properties:[/b][br]
## - [code]file_loader[/code]: Instance of LoadSavedFiles for handling file operations.[br]
## - [code]first_setup[/code]: Flag indicating if initial setup is needed.[br]
## - [code]import_tile_amount[/code]: Total number of tiles to import.[br]
## - [code]imported_tiles_count[/code]: Current count of imported tiles.[br]
## - [code]import_path[/code]: File system path to the import directory.[br]
## - [code]imported_set_name[/code]: Name assigned to the imported tile set.[br]
## - [code]import_thread[/code]: Thread for performing import operations.[br]
## - [code]set_named[/code]: Flag indicating if a set name has been provided.[br]
## - [code]set_directory_selected[/code]: Flag indicating if an import directory has been selected.[br]

signal set_imported()

const IMPORT_STATUS_LABEL_TEMPLATE = "Importing %d tiles, currently %d/%d"

var file_loader = LoadSavedFiles.new()
var first_setup: bool = true
var import_tile_amount: int = 0
var imported_tiles_count: int = 0
var import_path: String = ""
var imported_set_name: String = ""
var import_thread = Thread.new()
var set_named: bool = false
var set_directory_selected: bool = false

@onready var action_buttons: HBoxContainer = $%ActionButtons
@onready var confirm_button: Button = $%Confirm
@onready var file_dialog: FileDialog = $%FileDialog
@onready var import_status_label: Label = $%ImportStatus
@onready var selected_dir_label: Label = $%SelectedDirLabel
@onready var set_name_input: LineEdit = $%NameInput

## Initialize the import UI and reset all state variables to default values.[br]
## Connects signals on first setup and updates UI elements.[br]
func initialize():
  visible = true
  if first_setup:
    file_loader.import_started.connect(setup_import_status_label)
    file_loader.tile_imported.connect(update_import_status_label)
    first_setup = false
  set_directory_selected = false
  imported_set_name = ""
  set_named = false
  import_path = ""
  selected_dir_label.text = "Not selected"
  set_name_input.text = imported_set_name
  action_buttons.visible = true
  import_status_label.visible = false
  update_confirm_button()

## Process loop to monitor import thread completion.[br]
## [b]Parameters:[/b][br]
## [code]_delta[/code] : [float] — time elapsed since last frame.[br]
## [b]Emits:[/b][br]
## - [code]set_imported[/code] when import thread completes.[br]
func _process(_delta: float) -> void:
  if import_thread.is_started() and not import_thread.is_alive():
    print("Import thread finished")
    import_thread.wait_to_finish()
    set_imported.emit()
    visible = false

## Open the file dialog for directory selection.[br]
func browse_pressed():
  file_dialog.popup_centered()

## Handle directory selection from the file dialog.[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — selected directory path.[br]
func on_import_directory_selected(path: String):
  if path == "":
    return
  selected_dir_label.text = path
  import_path = path
  set_directory_selected = true
  update_confirm_button()

## Update the confirm button's disabled state based on selection and naming status.[br]
func update_confirm_button():
  confirm_button.disabled = not (set_directory_selected and set_named)

## Start the import process on a background thread.[br]
func confirm_pressed():
  if import_path != "":
    action_buttons.visible = false
    import_thread.start(
        file_loader.import_tile_set_from_directory.bind(import_path, imported_set_name)
    )

## Close the import dialog without performing any import.[br]
func cancel_pressed():
  visible = false

## Handle changes to the set name input field.[br]
## [b]Parameters:[/b][br]
## [code]new_text[/code] : [String] — new value of the set name input.[br]
func _on_set_name_text_changed(new_text: String) -> void:
  imported_set_name = new_text
  set_named = new_text != ""
  update_confirm_button()

## Initialize the import status label with total tile count.[br]
## [b]Parameters:[/b][br]
## [code]total_tiles[/code] : [int] — total number of tiles to be imported.[br]
func setup_import_status_label(total_tiles: int):
  import_tile_amount = total_tiles
  imported_tiles_count = 0
  import_status_label.text = IMPORT_STATUS_LABEL_TEMPLATE % [
      import_tile_amount,
      imported_tiles_count,
      import_tile_amount
  ]
  import_status_label.visible = true

## Update the import status label to reflect progress.[br]
func update_import_status_label():
  imported_tiles_count += 1
  import_status_label.text = IMPORT_STATUS_LABEL_TEMPLATE % [
      import_tile_amount,
      imported_tiles_count,
      import_tile_amount
  ]
