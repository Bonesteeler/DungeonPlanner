extends MenuButton

signal save_scene()
signal save_scene_as()

const ID_SAVE = 0
const ID_SAVE_AS = 1

func _ready():
  var menu = get_popup()
  menu.id_pressed.connect(on_menu_button_id_pressed)
  menu.add_item("Save", ID_SAVE)
  menu.add_item("Save As", ID_SAVE_AS)

func on_menu_button_id_pressed(id: int):
  match id:
    ID_SAVE:
      save_scene.emit()
    ID_SAVE_AS:
      save_scene_as.emit()
