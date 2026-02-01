class_name PlanningScene
extends Node
## PlanningScene
##
## [i]Controller for the planning scene that initializes the board, wires the UI to scene and save logic, and forwards viewport resize events to the UI.[/i][br]

const board_scene = preload("res://scene_builder/board/Board.tscn")

var save_manager: SaveManager = SaveManager.new()
var viewport: Viewport
var vm: SceneBuilderViewModel

@onready var board_container = $BoardContainer
@onready var planner_ui = $%PlannerUI
@onready var input_listener = $InputListener

## Initializes the planning scene by connecting UI signals and tracking viewport size changes.[br]
## [b]Returns:[/b] [void][br]
func _ready():
  planner_ui.save_current_scene.connect(save_scene)
  viewport = get_viewport()
  viewport.size_changed.connect(on_viewport_resized)

## Sets the scene view model and wires all input and UI signals.[br]
## [b]Parameters:[/b][br]
## [code]scene_vm[/code] : [SceneBuilderViewModel] — the view model for the scene builder.[br]
## [b]Returns:[/b] [void][br]
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
  planner_ui.tool_add_tile_selected.connect(func():
    vm.set_tool_type(CustomEnums.ToolType.ADD_TILE)
  )
  planner_ui.tool_select_tile_selected.connect(func():
    vm.set_tool_type(CustomEnums.ToolType.SELECT_TILE)
  )
  planner_ui.tool_remove_tile_selected.connect(func():
    vm.set_tool_type(CustomEnums.ToolType.REMOVE_TILE)
  )
  planner_ui.set_vm(vm)
  for layer_vm in vm.get_all_layer_vms():
    add_tile_layer(layer_vm)

## Saves the current scene using the save manager.[br]
## [b]Returns:[/b] [void][br]
func save_scene():
  save_manager.save_scene_to_user(vm.scene)

## Forwards viewport resize notifications to the planner UI.[br]
## [b]Returns:[/b] [void][br]
func on_viewport_resized():
  planner_ui.on_viewport_resized(viewport.size)

## Adds a new tile layer to the board container and connects its signals.[br]
## [b]Parameters:[/b][br]
## [code]layer_vm[/code] : [TileLayerViewModel] — the layer view model to add.[br]
## [b]Returns:[/b] [void][br]
func add_tile_layer(layer_vm: TileLayerViewModel):
  var new_board = board_scene.instantiate() as Board
  board_container.add_child(new_board)
  new_board.tile_selected.connect(planner_ui.on_tile_selected)
  new_board.updated.connect(planner_ui.on_board_updated)
  input_listener.key_shift_event.connect(new_board.set_shift_pressed)
  input_listener.key_alt_event.connect(new_board.set_alt_pressed)
  new_board.set_vm(vm, layer_vm)