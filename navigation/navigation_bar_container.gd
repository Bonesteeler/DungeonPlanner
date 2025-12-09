class_name NavigationBarContainer
extends VBoxContainer
## NavigationBarContainer
##
## Handles loading top level scenes for each navigation tab.[br]

var MAIN_MENU = load("res://main_menu/MainMenu.tscn")
var PLANNING_SCENE = load("res://scene_builder/PlannerScene.tscn")
var SETS_SCENE = load("res://ui/set_manager/set_manager.tscn")

var vm: NavigationBarViewModel

@onready var navigation_bar: NavigationBar = $%NavigationBar
@onready var content_container: Viewport = $%SubViewport

func _ready() -> void:
  vm = NavigationBarViewModel.new()
  navigation_bar.set_vm(vm)
  home_selected()

func home_selected() -> void:
  var home_scene = change_scene(MAIN_MENU)
  home_scene.scene_selected.connect(vm.add_scene_builder)

func planner_selected(selected_name: String) -> void:
  var new_scene_vm = vm.get_scene_by_name(selected_name)
  var planning_scene = change_scene(PLANNING_SCENE)
  planning_scene.set_scene_view_model(new_scene_vm)

func sets_selected() -> void:
  change_scene(SETS_SCENE)

func change_scene(new_scene: PackedScene) -> Node:
  for i in range(content_container.get_child_count()):
    content_container.get_child(i).queue_free()
  var scene_instance = new_scene.instantiate()
  content_container.add_child(scene_instance)
  return scene_instance