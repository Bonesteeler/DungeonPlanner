class_name NavigationBarContainer
extends VBoxContainer
## NavigationBarContainer
##
## Handles loading top level scenes for each navigation tab.[br]

var MAIN_MENU = load("res://main_menu/MainMenu.tscn")
var PLANNING_SCENE = preload("res://scene_builder/PlannerScene.tscn")

@onready var navigation_bar: NavigationBar = $%NavigationBar
@onready var content_container: Viewport = $%SubViewport

func _ready() -> void:
  change_scene(MAIN_MENU)

func home_selected() -> void:
    change_scene(MAIN_MENU)

func planner_selected() -> void:
    change_scene(PLANNING_SCENE)

func change_scene(new_scene: PackedScene) -> void:
    for i in range(content_container.get_child_count()):
        content_container.get_child(i).queue_free()
    var scene_instance = new_scene.instantiate()
    content_container.add_child(scene_instance)
