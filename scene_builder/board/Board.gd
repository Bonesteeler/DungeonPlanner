class_name Board
extends Node3D
## Board
##
## [i]Grid of planning spaces for placing, selecting, and removing tiles. Handles hover
## previews, clicks, and loading a saved TileLayout into the board nodes.[/i][br]
## [b]Properties:[/b][br]
## - [b]board_nodes[/b] : [Array] — 2D array of instantiated space nodes for the board.[br]
## - [b]current_tool[/b] : [CustomEnums.ToolType] — active tool used for interactions (add/select/remove). [br]
## - [b]hovered_space[/b] : [Node3D] — currently hovered space node, used for previews.[br]
## - [b]space_scene[/b] : [PackedScene] — preloaded scene used to instantiate spaces.[br]
## [b]Signals:[/b][br]
## - [code]updated()[/code] : Emitted when the board data changes and UI should refresh.[br]
## - [code]tile_selected(tile_id: String)[/code] : Emitted when a tile is selected via the select tool.[br]
## [b]Constants:[/b][br]
## - [code]START_ROWS[/code], [code]START_COLS[/code] : Initial board dimensions in spaces.[br]
## - [code]SPACE_SIZE[/code] : Size in world units of a single planning space.[br]

signal updated()
signal tile_selected(tile_id: String)

const START_ROWS = 20
const START_COLS = 20
const SPACE_SIZE = 5

var alt_pressed: bool = false
var board_nodes: Array = []
var current_tool = CustomEnums.ToolType.ADD_TILE
var hovered_space: Space
var shift_pressed: bool = false
var space_scene = preload("res://scene_builder/board/Space.tscn")
var vm: SceneBuilderViewModel

## Create the initial grid of space nodes and wire up their signals.[br]
## [b]Returns:[/b] [void][br]
func create_board():
  const X_OFFSET = float(START_ROWS) / 2 * SPACE_SIZE * -1.0
  const Z_OFFSET = float(START_COLS) / 2 * SPACE_SIZE * -1.0
  for i in START_ROWS:
    var new_row = []
    new_row.resize(START_COLS)
    board_nodes.append(new_row)
    for j in START_COLS:
      var new_space: Node3D = space_scene.instantiate()
      new_space.x = i
      new_space.z = j
      add_child(new_space)
      board_nodes[i][j] = new_space
      new_space.set_position(Vector3(SPACE_SIZE * i + X_OFFSET, 0, SPACE_SIZE * j + Z_OFFSET))
      new_space.space_hover_enter.connect(on_space_hover_enter)
      new_space.space_hover_exit.connect(on_space_hover_exit)
      new_space.space_clicked.connect(on_space_clicked)
      new_space.set_preview_vm(vm.selected_tile)

func set_vm(view_model: SceneBuilderViewModel):
  vm = view_model
  create_board()
  load_scene(vm.scene.data)

## Handle hover enter on a space for the currently selected tool.[br]
## [b]Parameters:[/b][br]
## [code]space[/code] : [Node3D] — the space node that the pointer entered.[br]
## [b]Returns:[/b] [void][br]
func on_space_hover_enter(space: Node3D):
  hovered_space = space
  if is_camera_mode_active():
    return
  start_preview()
  
## Configures the preview for the currently hovered space based on the active tool.[br]
## [b]Returns:[/b] [void][br]
func start_preview():
  var space_position = Vector2(hovered_space.x, hovered_space.z)
  match current_tool: 
    CustomEnums.ToolType.ADD_TILE:
      # Error if tile doesn't fit
      vm.set_hovered_space(hovered_space)
      hovered_space.preview_vm.enable_rotation()
    CustomEnums.ToolType.SELECT_TILE:
      var hovered_tile = vm.get_origin_tile(space_position)
      if hovered_tile == null:
        return
      hovered_space = board_nodes[hovered_tile.position.x][hovered_tile.position.y]
      hovered_space.preview_vm.set_tile(hovered_space.vm.tile)
      hovered_space.preview_vm.set_rotation(hovered_space.vm.rotation)
      hovered_space.preview_vm.set_validity(true)
      hovered_space.preview_vm.disable_rotation()
    CustomEnums.ToolType.REMOVE_TILE:
      var hovered_tile = vm.get_origin_tile(space_position)
      if hovered_tile == null:
        return
      hovered_space = board_nodes[hovered_tile.position.x][hovered_tile.position.y]
      hovered_space.preview_vm.set_tile(hovered_space.vm.tile)
      hovered_space.preview_vm.set_rotation(hovered_space.vm.rotation)
      hovered_space.preview_vm.set_validity(false)
      hovered_space.preview_vm.disable_rotation()
  hovered_space.start_preview()

## Handle hover exit for a space.[br]
## [b]Parameters:[/b][br]
## [code]space[/code] : [Node3D] — the space node that the pointer left.[br]
## [b]Returns:[/b] [void][br]
func on_space_hover_exit(space: Node3D):
  if hovered_space == space:
    hovered_space.end_preview()
    hovered_space = null
  else:
    var tile_origin = vm.get_origin_tile(Vector2(space.x, space.z))
    if tile_origin != null:
      var selected_space = board_nodes[tile_origin.position.x][tile_origin.position.y]
      selected_space.end_preview()

## Handle mouse click on a space for the currently selected tool.[br]
## [b]Parameters:[/b][br]
## [code]space[/code] : [Node3D] — the clicked space node.[br]
## [code]x[/code] : [int] — board X coordinate of the clicked space.[br]
## [code]y[/code] : [int] — board Y coordinate of the clicked space.[br]
## [b]Emits:[/b][br]
## - [code]updated()[/code][br]
## - [code]tile_selected(tile_id: String)[/code][br]
## [b]Returns:[/b] [void][br]
func on_space_clicked(space: Node3D, x: int, y: int):
  if is_camera_mode_active():
    return
  match current_tool:
    CustomEnums.ToolType.ADD_TILE:
      if vm.can_set_selected_tile_at(x, y):
        vm.set_selected_tile_in_layout_at(x, y)
        space.set_view_model(vm.get_selected_tile().duplicate())
        updated.emit()
    CustomEnums.ToolType.SELECT_TILE:
      var selected_tile = vm.get_origin_tile(Vector2(x, y))
      if selected_tile == null:
        return
      tile_selected.emit(selected_tile.id)
    CustomEnums.ToolType.REMOVE_TILE:
      var selected_tile = vm.get_origin_tile(Vector2(x, y))
      if selected_tile == null:
        return
      vm.remove_tile_in_layout_at(selected_tile.position.x, selected_tile.position.y)
      var origin_space = board_nodes[selected_tile.position.x][selected_tile.position.y]
      origin_space.set_empty()
      updated.emit()

## Updates shift state for board interactions.[br]
## [b]Parameters:[/b][br]
## [code]pressed[/code] : [bool] — whether the shift key is currently pressed.[br]
## [b]Returns:[/b] [void][br]
func set_shift_pressed(pressed: bool):
  shift_pressed = pressed
  if not is_camera_mode_active():
    start_preview()
  elif hovered_space != null:
    hovered_space.end_preview()

## Updates alt state for board interactions.[br]
## [b]Parameters:[/b][br]
## [code]pressed[/code] : [bool] — whether the alt key is currently pressed.[br]
## [b]Returns:[/b] [void][br]
func set_alt_pressed(pressed: bool):
  alt_pressed = pressed
  if not is_camera_mode_active():
    start_preview()
  elif hovered_space != null:
    hovered_space.end_preview()

## Load a saved TileLayout into the board, instantiating tile contexts and meshes as needed.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [TileLayout] — saved scene data containing tiles to place on the board.[br]
## [b]Returns:[/b] [void][br]
func load_scene(scene: TileLayout):
  if scene == null:
    return
  var is_updated = []
  for i in START_ROWS:
    var new_row = []
    for j in START_COLS:
      new_row.append(false)
    is_updated.append(new_row)
  for tile in scene.tiles:
    var tile_data = TileSets.get_tile_from_id(tile.id)
    if tile_data == null:
      print("Tile ID not found: %s" % tile.id)
      continue
    var tile_vm = SceneTileViewModel.new()
    tile_vm.set_tile(tile_data)
    tile_vm.set_rotation(tile.rotation)
    var mesh_path = tile_data.mesh_path
    if mesh_path != "":
      tile_vm.set_mesh(load(mesh_path))
    board_nodes[tile.position.x][tile.position.y].set_view_model(tile_vm)
    is_updated[tile.position.x][tile.position.y] = true
  for i in START_ROWS:
    for j in START_COLS:
      if !is_updated[i][j]:
        board_nodes[i][j].set_empty()

## Set the active interaction tool for the board (add, select, remove).[br]
## [b]Parameters:[/b][br]
## [code]tool_type[/code] : [CustomEnums.ToolType] — new tool to use for user interactions.[br]
## [b]Returns:[/b] [void][br]
func update_current_tool(tool_type: CustomEnums.ToolType):
  current_tool = tool_type

## Returns if a camera mode is active that should disable board interactions.[br]
## [b]Returns:[/b] [bool][br]
func is_camera_mode_active() -> bool:
  return shift_pressed or alt_pressed
