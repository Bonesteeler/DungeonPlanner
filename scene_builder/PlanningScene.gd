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

var save_manager: SaveManager = SaveManager.new()
var viewport: Viewport
var vm: SceneBuilderViewModel

@onready var board = $Board
@onready var planner_ui = $%PlannerUI
@onready var input_listener = $InputListener

## Initialize the planning scene, create the board, load the current scene data, wire UI signals, and track viewport size.[br]
## [b]Returns:[/b] [void][br]
func _ready():
  planner_ui.save_current_scene.connect(save_scene)
  viewport = get_viewport()
  viewport.size_changed.connect(on_viewport_resized)

func set_scene_view_model(scene_vm: SceneBuilderViewModel):
  vm = scene_vm
  input_listener.rotate_left.connect(func():
    vm.rotate_left()
  )
  input_listener.rotate_right.connect(func():
    vm.rotate_right()
  )
  planner_ui.set_vm(vm)
  board.set_vm(vm)

## Save the provided scene with the save manager and update the current scene context.[br]
## [b]Returns:[/b] [void][br]
func save_scene():
  save_manager.save_scene_to_user(vm.scene)

## Set the provided scene as current and load its tile data into the board.[br]
## [b]Returns:[/b] [void][br]
func load_scene(scene: Scene):
  board.load_scene(scene.data)

## Forward viewport resize notifications to the planner UI.[br]
## [b]Returns:[/b] [void][br]
func on_viewport_resized():
  planner_ui.on_viewport_resized(viewport.size)
