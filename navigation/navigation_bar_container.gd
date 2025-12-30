class_name NavigationBarContainer
extends VBoxContainer
## NavigationBarContainer
##
## [i]Handles loading top level scenes for each navigation tab.[/i][br]
## [b]Properties:[/b][br]
## - [b]vm[/b]: The [NavigationBarViewModel] managing navigation state.[br]

var MAIN_MENU = load("res://main_menu/MainMenu.tscn")
var PLANNING_SCENE = load("res://scene_builder/PlannerScene.tscn")
var SETS_SCENE = load("res://ui/set_manager/set_manager.tscn")

var vm: NavigationBarViewModel

@onready var navigation_bar: NavigationBar = $%NavigationBar
@onready var content_container: Viewport = $%SubViewport

## Initializes the navigation bar and loads the home scene.
func _ready() -> void:
  vm = NavigationBarViewModel.new()
  navigation_bar.set_vm(vm)
  home_selected()

## Loads the main menu scene and connects signal.[br]
## [b]Returns:[/b] [void][br]
func home_selected() -> void:
  var home_scene = change_scene(MAIN_MENU)
  home_scene.scene_selected.connect(vm.add_scene_builder)

## Loads the planner scene for the specified scene ID.[br]
## [b]Parameters:[/b][br]
## [code]selected_id[/code] : [String] — the unique identifier of the scene to load.[br]
## [b]Returns:[/b] [void][br]
func planner_selected(selected_id: String) -> void:
  var new_scene_vm = vm.get_scene_by_id(selected_id)
  var planning_scene = change_scene(PLANNING_SCENE)
  planning_scene.set_scene_view_model(new_scene_vm)

## Loads the sets manager scene.[br]
## [b]Returns:[/b] [void][br]
func sets_selected() -> void:
  change_scene(SETS_SCENE)

## Unloads the current scene and instantiates a new scene.[br]
## [b]Parameters:[/b][br]
## [code]new_scene[/code] : [PackedScene] — the scene to instantiate and render.[br]
## [b]Returns:[/b] [Node][br]
func change_scene(new_scene: PackedScene) -> Node:
  for i in range(content_container.get_child_count()):
    content_container.get_child(i).queue_free()
  var scene_instance = new_scene.instantiate()
  content_container.add_child(scene_instance)
  return scene_instance