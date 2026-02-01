extends ConfirmationDialog
## SaveAsDialog
##
## [i]A dialog for entering a name when saving a scene with a new name.[/i][br]
## [b]Signals:[/b][br]
## - [code]saved_with_name(name: String)[/code]: Emitted when the save is confirmed with the entered name.[br]

signal saved_with_name(name: String)

@onready var name_input: TextEdit = $SaveNameInput

## Initialize the dialog and connect the confirmed signal.[br]
func _ready():
  self.confirmed.connect(self.on_save)

## Handle the save confirmation and emit the saved_with_name signal.[br]
## [b]Emits:[/b][br]
## - [code]saved_with_name(name: String)[/code] with the entered name[br]
func on_save():
  saved_with_name.emit(name_input.text)