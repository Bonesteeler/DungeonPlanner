extends MenuButton
## FileButton
##
## [i]A menu button that provides file operations for saving scenes.[/i][br]
## [b]Signals:[/b][br]
## - [code]save_scene[/code]: Emitted when the user selects the Save option.[br]
## - [code]save_scene_as[/code]: Emitted when the user selects the Save As option.[br]

signal save_scene()
signal save_scene_as()

const ID_SAVE = 0
const ID_SAVE_AS = 1

## Initialize the menu button and populate it with file operation options.[br]
## [b]Emits:[/b][br]
## - [code]save_scene[/code] when the Save menu item is selected[br]
## - [code]save_scene_as[/code] when the Save As menu item is selected[br]
func _ready():
  var menu = get_popup()
  menu.id_pressed.connect(on_menu_button_id_pressed)
  menu.add_item("Save", ID_SAVE)
  menu.add_item("Save As", ID_SAVE_AS)

## Handle menu item selection events and emit the appropriate signal.[br]
## [b]Parameters:[/b][br]
## [code]id[/code] : [int] — the ID of the selected menu item.[br]
## [b]Emits:[/b][br]
## - [code]save_scene[/code] when ID_SAVE is pressed[br]
## - [code]save_scene_as[/code] when ID_SAVE_AS is pressed[br]
func on_menu_button_id_pressed(id: int):
  match id:
    ID_SAVE:
      save_scene.emit()
    ID_SAVE_AS:
      save_scene_as.emit()
