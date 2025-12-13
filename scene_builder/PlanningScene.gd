class_name PlanningScene
extends Node
## PlanningScene
##
## [i]Controller for the planning scene. Initializes the board, wires the UI to scene and save logic, and forwards viewport resize events to the UI.[/i][br]
## [b]Properties:[/b][br]
## - [b]save_manager[/b]: Instance of [code]SaveManager[/code] used to persist and expose recent scenes.[br]
## - [b]viewport[/b]: The current [code]Viewport[/code] used to observe size changes.[br]
## - [b]board[/b]: Onready reference to the [code]Board[/code] node.[br]
## - [b]planner_ui[/b]: Onready reference to the planner UI node that provides tile selection and scene controls.[br]
## - [b]input_listener[/b]: Onready reference to the [code]InputListener[/code] node.[br]
## [b]Constants:[/b][br]
## - [code]MAIN_MENU_SCENE_PATH[/code]: Path to the main menu scene resource.[br]

signal new_scene()

const MAIN_MENU_SCENE_PATH = "res://main_menu/MainMenu.tscn"

var save_manager: SaveManager = SaveManager.new()
var viewport: Viewport
var vm: SceneBuilderViewModel

@onready var board = $Board
@onready var planner_ui = $%PlannerUI
@onready var input_listener = $InputListener

## Initialize the planning scene, create the board, load the current scene data, wire UI signals, and track viewport size.[br]
## [b]Returns:[/b] [void][br]
func _ready():
  board.create_board()
  planner_ui.new_scene.connect(forward_new_scene)
  planner_ui.save_current_scene.connect(save_scene)
  planner_ui.load_scene.connect(load_scene)
  planner_ui.set_recent_scenes(save_manager.scenes)
  planner_ui.quit_scene.connect(quit_scene)
  viewport = get_viewport()
  viewport.size_changed.connect(on_viewport_resized)

func set_scene_view_model(scene_vm: SceneBuilderViewModel):
  vm = scene_vm
  planner_ui.set_vm(vm)
  board.set_layout(vm.scene.data)

## Create a new, empty tile layout and load it into the board.[br]
## [b]Returns:[/b] [void][br]
func forward_new_scene():
  new_scene.emit()

## Save the provided scene with the save manager and update the current scene context.[br]
## [b]Returns:[/b] [void][br]
func save_scene():
  save_manager.save_scene_to_user(vm.scene)

## Set the provided scene as current and load its tile data into the board.[br]
## [b]Returns:[/b] [void][br]
func load_scene(scene: Scene):
  board.load_scene(scene.data)

## Switch back to the main menu scene using a packed scene change. Logs an error if the change fails.[br]
## [b]Returns:[/b] [void][br]
func quit_scene():
  # Can't preload main menu scene because it causes circular dependencies
  var main_menu_scene = load(MAIN_MENU_SCENE_PATH)
  var error = get_tree().change_scene_to_packed(main_menu_scene)
  if error != OK:
    push_error("Failed to change scene: " + str(error))

## Forward viewport resize notifications to the planner UI.[br]
## [b]Returns:[/b] [void][br]
func on_viewport_resized():
  planner_ui.on_viewport_resized(viewport.size)
