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

const board_scene = preload("res://scene_builder/board/Board.tscn")

var save_manager: SaveManager = SaveManager.new()
var viewport: Viewport
var vm: SceneBuilderViewModel

@onready var board_container = $BoardContainer
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
  planner_ui.tile_layer_added.connect(func(layer_vm: TileLayerViewModel):
    add_tile_layer(layer_vm)
  )
  planner_ui.set_vm(vm)
  for layer_vm in vm.get_all_layer_vms():
    add_tile_layer(layer_vm)

## Save the provided scene with the save manager and update the current scene context.[br]
## [b]Returns:[/b] [void][br]
func save_scene():
  save_manager.save_scene_to_user(vm.scene)

## Forward viewport resize notifications to the planner UI.[br]
## [b]Returns:[/b] [void][br]
func on_viewport_resized():
  planner_ui.on_viewport_resized(viewport.size)

## Adds a new tile layer to the board and UI.[br]
## [b]Parameters:[/b][br]
func add_tile_layer(layer_vm: TileLayerViewModel):
  var new_board = board_scene.instantiate() as Board
  board_container.add_child(new_board)
  new_board.tile_selected.connect(planner_ui.on_tile_selected)
  new_board.updated.connect(planner_ui.on_board_updated)
  new_board.set_vm(vm, layer_vm)