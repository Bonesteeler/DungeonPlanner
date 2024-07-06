extends Node3D

var space_scene = preload("res://Scenes/Space.tscn")

const startRows = 10
const startCols = 10
const spaceSize = 5
const intMax = 2147483647

var board:Array = []
var hoveredSpace: Node3D
var context: SceneContext

# Called when the node enters the scene tree for the first time.
func connect_to_context(newContext: SceneContext):
  context = newContext
  context.context_updated.connect(on_context_updated)
      
func create_board():
  const xOffset = float(startRows) / 2 * spaceSize * -1.0
  const zOffset = float(startCols) / 2 * spaceSize * -1.0
  for i in startRows:
    var newRow = []
    newRow.resize(startCols)
    board.append(newRow)
    for j in startCols:
      var newSpace: Node3D = space_scene.instantiate()
      newSpace.x = i
      newSpace.z = j
      add_child(newSpace)
      board[i][j] = newSpace
      newSpace.set_position(Vector3(spaceSize * i + xOffset, 0, spaceSize * j + zOffset))
      newSpace.space_hover_enter.connect(on_space_hover_enter)
      newSpace.space_hover_exit.connect(on_space_hover_exit)
      newSpace.space_clicked.connect(on_space_clicked)

func on_space_hover_enter(space: Node3D):
  hoveredSpace = space
  var hoveredCoords = hoveredSpace.get_coords()
  context.selectedTileContext.set_position(hoveredCoords[0], hoveredCoords[1])
  var occupiedSpaceCoords = context.selectedTileContext.get_other_occupied_space_coords()
  var isChildSpaceOccupied = false
  for coords in occupiedSpaceCoords:
    if coords[0] < 0 or coords[0] >= startRows or coords[1] < 0 or coords[1] >= startCols:
      continue
    var currentTile = context.currentScene.getTileAt(coords[0], coords[1])
    print(currentTile.getFillState())
    currentTile.setFillState(SavedTile.TileFillState.HOVERED)
    if currentTile.getFillState() == SavedTile.TileFillState.OCCUPIED_CHILD || currentTile.getFillState() == SavedTile.TileFillState.OCCUPIED_ROOT:
      isChildSpaceOccupied = true
  print(isChildSpaceOccupied)
  hoveredSpace.start_preview(context.selectedTileContext, isChildSpaceOccupied)

func on_space_hover_exit(space: Node3D):
  if hoveredSpace != space:
    return
  var occupiedSpaceCoords = context.selectedTileContext.get_other_occupied_space_coords()
  for coords in occupiedSpaceCoords:
    if coords[0] < 0 or coords[0] >= startRows or coords[1] < 0 or coords[1] >= startCols:
      continue
    var currentTile = context.currentScene.getTileAt(coords[0], coords[1])
    if currentTile.getFillState() == SavedTile.TileFillState.HOVERED:
      currentTile.setFillState(SavedTile.TileFillState.EMPTY) 
  hoveredSpace.end_preview()
  hoveredSpace = null
  context.selectedTileContext.set_position(intMax, intMax)
      
func on_space_clicked(space: Node3D, x: int, y: int):
  if context.get_selected_tile_context().tile == null:
    return
  context.set_tile(x, y, context.get_selected_tile_context())
  space.set_tile(context.get_selected_tile_context())

func on_context_updated():
  if hoveredSpace != null:
    hoveredSpace.update_context(context.get_selected_tile_context())
    var prevCoords = context.selectedTileContext.get_prev_occupied_space_coords()
    for coords in prevCoords:
      if coords[0] < 0 or coords[0] >= startRows or coords[1] < 0 or coords[1] >= startCols:
        continue
      var coordContext = context.currentScene.getTileAt(coords[0], coords[1])
      var isVisible = coordContext.getFillState() == SavedTile.TileFillState.EMPTY || coordContext.getFillState() == SavedTile.TileFillState.OCCUPIED_ROOT
      board[coords[0]][coords[1]].set_visible(isVisible)

func load_scene(scene:SceneData):
  var updated = []
  for i in startRows:
    var newRow = []
    for j in startCols:
      newRow.append(false)
    updated.append(newRow)
  for tile in scene.tiles:
    var tileData = context.get_tile_from_id(tile.id)
    var tileContext = TileContext.new(intMax, intMax)
    tileContext.tile = tileData
    tileContext.rotation = tile.rotation
    tileContext.mesh = tileData.mesh
    board[tile.x][tile.z].set_tile(tileContext)
    updated[tile.x][tile.z] = true
  for i in startRows:
    for j in startCols:
      if !updated[i][j]:
        board[i][j].set_empty()
