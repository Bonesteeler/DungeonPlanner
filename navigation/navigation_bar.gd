class_name NavigationBar
extends Container

## NavigationBar
##
## Custom tab bar that sends signals when a tab is selected.[br]
## [b]Signals:[/b][br]
## - home_selected() - Emitted when the home tab is selected.
## - planner_selected(String) - Emitted when the planner tab is selected.
## - set_selected() - Emitted when the sets tab is selected.

signal home_selected()
signal planner_selected(String)
signal sets_selected()

const STATIC_BUTTON_COUNT = 2

var PLANNER_BUTTON_SCENE = preload("res://navigation/scene_button.tscn")

var view_model: NavigationBarViewModel

@onready var button_container: HBoxContainer = $%HBoxContainer

func set_vm(vm: NavigationBarViewModel) -> void:
  view_model = vm
  view_model.scene_builders_updated.connect(update_scene_buttons)
  update_scene_buttons()

func update_scene_buttons() -> void:
  for i in range(STATIC_BUTTON_COUNT, button_container.get_child_count()):
    button_container.get_child(i).queue_free()
  for vm in view_model.scene_builders:
    var button = PLANNER_BUTTON_SCENE.instantiate() as SceneButton
    button.set_scene_name(vm.scene.scene_name)
    button.scene_selected.connect(forward_planner_selected)
    button_container.add_child(button)

func forward_home_selected():
    home_selected.emit()

func forward_planner_selected(tab_name: String):
    planner_selected.emit(tab_name)

func forward_sets_selected():
    sets_selected.emit()
