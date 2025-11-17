class_name ImportTileset
extends Control
## ImportTileset
##
## [i]UI control for importing tile sets, manages import dialog and progress display.[/i][br]
## [b]Properties:[/b][br]
## - [b]view_model[/b]: [ImportTilesetViewModel] view model managing import state and logic.[br]
## - [b]action_buttons[/b]: [HBoxContainer] container for action buttons.[br]
## - [b]confirm_button[/b]: [Button] button to confirm and start import.[br]
## - [b]file_dialog[/b]: [FileDialog] dialog for selecting import directory.[br]
## - [b]import_status_label[/b]: [Label] displays import progress.[br]
## - [b]selected_dir_label[/b]: [Label] shows selected directory path.[br]
## - [b]set_name_input[/b]: [LineEdit] input field for tile set name.[br]
## [b]Signals:[/b][br]
## - [code]set_imported()[/code]: Emitted when import completes successfully.[br]

signal set_imported()

var view_model: ImportTilesetViewModel

@onready var action_buttons: HBoxContainer = $%ActionButtons
@onready var confirm_button: Button = $%Confirm
@onready var file_dialog: FileDialog = $%FileDialog
@onready var import_status_label: Label = $%ImportStatus
@onready var selected_dir_label: Label = $%SelectedDirLabel
@onready var set_name_input: LineEdit = $%NameInput

## Display the import dialog and reset to initial state[br]
func show_dialog():
  view_model.set_initial_state()
  selected_dir_label.text = "Not selected"
  set_name_input.text = ""
  visible = true

## Set the view model and connect its signals[br]
## [b]Parameters:[/b][br]
## [code]viewModel[/code] : [ImportTilesetViewModel] — view model to bind to this view.[br]
func set_vm(vm: ImportTilesetViewModel):
  view_model = vm
  view_model.import_complete.connect(on_import_complete)
  view_model.import_path_updated.connect(update_selected_dir_label)
  view_model.import_state_updated.connect(update_import_status_label)
  view_model.validity_updated.connect(update_confirm_button)

## Update the import status label with current progress[br]
func update_import_status_label() -> void:
  import_status_label.text = view_model.get_import_string()
  import_status_label.visible = view_model.show_import_progress

## Enable or disable the confirm button based on view model validity[br]
func update_confirm_button() -> void:
  confirm_button.disabled = not view_model.is_valid

## Update the selected directory label with current import path[br]
func update_selected_dir_label() -> void:
  selected_dir_label.text = view_model.import_path

## Handle browse button press by showing file dialog[br]
func browse_pressed():
  file_dialog.popup_centered()

## Handle directory selection from file dialog[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — selected directory path.[br]
func on_import_directory_selected(path: String):
  view_model.set_import_path(path)

## Handle confirm button press by starting the import[br]
func confirm_pressed():
  view_model.start_import()

## Handle cancel button press by canceling import and closing dialog[br]
func cancel_pressed():
  view_model.cancel_import()
  visible = false

## Handle tile set name input text change[br]
## [b]Parameters:[/b][br]
## [code]new_text[/code] : [String] — new tile set name.[br]
func _on_set_name_text_changed(new_text: String) -> void:
  view_model.update_set_name(new_text)

## Handle import completion by emitting signal and closing dialog[br]
## [b]Emits:[/b][br]
## - [code]set_imported()[/code][br]
func on_import_complete():
  set_imported.emit()
  visible = false
