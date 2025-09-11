extends Node3D

signal updated()
signal tile_selected(tile_id: String)

const START_ROWS = 20
const START_COLS = 20
const SPACE_SIZE = 5

var board_nodes: Array = []
var current_tool = CustomEnums.ToolType.ADD_TILE
var hovered_space: Node3D
var space_scene = preload("res://scene_builder/board/Space.tscn")

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

func on_space_hover_enter(space: Node3D):
  hovered_space = space
  var space_position = Vector2(hovered_space.x, hovered_space.z)
  match current_tool:
    CustomEnums.ToolType.ADD_TILE:
      # Error if tile doesn't fit
      var is_red = not SceneContext.does_selected_tile_fit(space_position)
      hovered_space.update_context(SceneContext.get_selected_tile_context(), is_red)
    CustomEnums.ToolType.SELECT_TILE:
      var hovered_tile = SceneContext.current_scene.get_origin_tile(space_position)
      if hovered_tile == null:
        return
      hovered_space = board_nodes[hovered_tile.x][hovered_tile.z]
      hovered_space.update_color(false)
    CustomEnums.ToolType.REMOVE_TILE:
      var hovered_tile = SceneContext.current_scene.get_origin_tile(space_position)
      if hovered_tile == null:
        return
      hovered_space = board_nodes[hovered_tile.x][hovered_tile.z]
      hovered_space.update_color(true)

func on_space_hover_exit(space: Node3D):
  if hovered_space == space:
    hovered_space.end_preview()
    hovered_space = null
  else:
    var tile_origin = SceneContext.current_scene.get_origin_tile(Vector2(space.x, space.z))
    if tile_origin != null:
      var selected_space = board_nodes[tile_origin.x][tile_origin.z]
      selected_space.end_preview()

func on_space_clicked(space: Node3D, x: int, y: int):
  match current_tool:
    CustomEnums.ToolType.ADD_TILE:
      var selected_tile_context = SceneContext.get_selected_tile_context()
      if selected_tile_context.tile == null:
        return
      if not SceneContext.does_selected_tile_fit(Vector2(x, y)):
        return
      SceneContext.set_tile(x, y, selected_tile_context)
      space.set_tile(selected_tile_context)
      updated.emit()
    CustomEnums.ToolType.SELECT_TILE:
      var selected_tile = SceneContext.current_scene.get_origin_tile(Vector2(x, y))
      if selected_tile == null:
        return
      tile_selected.emit(selected_tile.id)
    CustomEnums.ToolType.REMOVE_TILE:
      var selected_tile = SceneContext.current_scene.get_origin_tile(Vector2(x, y))
      if selected_tile == null:
        return
      SceneContext.current_scene.remove_tile_at(selected_tile.x, selected_tile.z)
      var origin_space = board_nodes[selected_tile.x][selected_tile.z]
      origin_space.set_empty()
      updated.emit()

func on_context_updated():
  if hovered_space != null:
    var space_position = Vector2(hovered_space.x, hovered_space.z)
    # Error if tile doesn't fit
    var hover_error = not SceneContext.does_selected_tile_fit(space_position)
    hovered_space.update_context(SceneContext.get_selected_tile_context(), hover_error)

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
    var tile_data = SceneContext.get_tile_from_id(tile.id)
    if tile_data == null:
      print("Tile ID not found: %s" % tile.id)
      continue
    var tile_context = SceneContext.TileContext.new()
    tile_context.tile = tile_data
    tile_context.rotation = tile.rotation
    var mesh_path = tile_data.mesh_path
    if mesh_path != "":
      tile_context.mesh = load(mesh_path)
    board_nodes[tile.x][tile.z].set_tile(tile_context)
    is_updated[tile.x][tile.z] = true
  for i in START_ROWS:
    for j in START_COLS:
      if !is_updated[i][j]:
        board_nodes[i][j].set_empty()

func update_current_tool(tool_type: CustomEnums.ToolType):
  current_tool = tool_type
