class_name ImportTileset
extends Control

signal set_imported()

var vm: ImportTilesetViewModel

@onready var action_buttons: HBoxContainer = $%ActionButtons
@onready var confirm_button: Button = $%Confirm
@onready var file_dialog: FileDialog = $%FileDialog
@onready var import_status_label: Label = $%ImportStatus
@onready var selected_dir_label: Label = $%SelectedDirLabel
@onready var set_name_input: LineEdit = $%NameInput

func show_dialog():
  vm.set_initial_state()
  selected_dir_label.text = "Not selected"
  set_name_input.text = ""
  visible = true

func set_vm(viewModel: ImportTilesetViewModel):
  vm = viewModel
  vm.import_complete.connect(on_import_complete)
  vm.import_path_updated.connect(update_selected_dir_label)
  vm.import_state_updated.connect(update_import_status_label)
  vm.validity_updated.connect(update_confirm_button)

func update_import_status_label() -> void:
  import_status_label.text = vm.get_import_string()
  import_status_label.visible = vm.show_import_progress

func update_confirm_button() -> void:
  confirm_button.disabled = not vm.is_valid

func update_selected_dir_label() -> void:
  selected_dir_label.text = vm.import_path

func browse_pressed():
  file_dialog.popup_centered()

func on_import_directory_selected(path: String):
  vm.set_import_path(path)

func confirm_pressed():
  vm.start_import()

func cancel_pressed():
  vm.cancel_import()
  visible = false

func _on_set_name_text_changed(new_text: String) -> void:
  vm.update_set_name(new_text)

func on_import_complete():
  set_imported.emit()
  visible = false
