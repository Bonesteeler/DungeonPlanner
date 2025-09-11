class_name TileLayout
extends RefCounted

const AUTHOR_STRING = "A community member"
const SIZE = Vector2(20, 20)
const KEY_AUTHOR = "author"
const KEY_SCENE_NAME = "sceneName"
const KEY_NAME = "name"
const KEY_TILES = "tiles"

var scene_name = ""
var tiles = []

func get_unique_tile_ids() -> Dictionary:
  var unique_tile_ids: Dictionary = {}
  for tile in tiles:
    if not unique_tile_ids.has(tile.id):
      unique_tile_ids.set(tile.id, 1)
  return unique_tile_ids

func to_json() -> String:
  var data: Dictionary = {}
  data[TileLayout.KEY_SCENE_NAME] = scene_name
  data[TileLayout.KEY_TILES] = []
  for tile in tiles:
    var tile_data: Dictionary = {}
    tile_data[PlacedTile.KEY_ID] = tile.id
    tile_data[PlacedTile.KEY_ROTATION] = tile.rotation - PlanningContext.DEFAULT_ROTATION
    tile_data[PlacedTile.KEY_X] = tile.x
    tile_data[PlacedTile.KEY_Z] = tile.z
    data[TileLayout.KEY_TILES].append(tile_data)
  return JSON.stringify(data)

func from_json(json: String):
  tiles = []
  var data: Dictionary = JSON.parse_string(json)
  scene_name = data[TileLayout.KEY_SCENE_NAME]
  for tile_data in data[TileLayout.KEY_TILES]:
    var tile = PlacedTile.new()
    tile.id = tile_data[PlacedTile.KEY_ID]
    var rotation = split_on_any_of(tile_data[PlacedTile.KEY_ROTATION], " ,()")
    tile.rotation = Vector3(
        float(rotation[0]),
        float(rotation[1]),
        float(rotation[2])
    ) + PlanningContext.DEFAULT_ROTATION
    tile.x = tile_data[PlacedTile.KEY_X]
    tile.z = tile_data[PlacedTile.KEY_Z]
    tile.update_tile_offset()
    tiles.append(tile)

func from_server_json(json: Dictionary) -> TileLayout:
  tiles = []
  scene_name = json[TileLayout.KEY_NAME]
  for tile_data in json[TileLayout.KEY_TILES]:
    var tile = PlacedTile.new()
    tile.id = tile_data[PlacedTile.KEY_TILE_ID]
    var y_rotation = tile_data[PlacedTile.KEY_ROTATION]
    tile.rotation = Vector3(
        0,
        y_rotation,
        0
    ) + PlanningContext.DEFAULT_ROTATION
    tile.x = tile_data[PlacedTile.KEY_X_POS]
    tile.z = tile_data[PlacedTile.KEY_Y_POS]
    tile.update_tile_offset()
    tiles.append(tile)
  return self

func to_server_json() -> String:
  var data: Dictionary = {}
  data[TileLayout.KEY_NAME] = scene_name
  data[TileLayout.KEY_AUTHOR] = AUTHOR_STRING
  data[TileLayout.KEY_TILES] = []
  for tile in tiles:
    var tile_data: Dictionary = {}
    tile_data[PlacedTile.KEY_TILE_ID] = tile.id
    var y_rotation = tile.rotation.y - PlanningContext.DEFAULT_ROTATION.y
    tile_data[PlacedTile.KEY_ROTATION] = y_rotation
    tile_data[PlacedTile.KEY_X_POS] = tile.x
    tile_data[PlacedTile.KEY_Y_POS] = tile.z
    data[TileLayout.KEY_TILES].append(tile_data)
  return JSON.stringify(data)

func split_on_any_of(string: String, delimiters: String) -> Array:
  var tokens = []
  var current_token = ""
  for c in string:
    if delimiters.find(c) != -1:
      if current_token != "":
        tokens.append(current_token)
        current_token = ""
    else:
      current_token += c
  return tokens

func has_tile_at(x: int, z: int) -> bool:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return true
  return false

func has_position_in_tile_occupying_space_excluding_self(
    position: Vector2,
    tile_origin: Vector2
) -> bool:
  for tile in tiles:
    if tile.x == tile_origin.x and tile.z == tile_origin.y:
      continue # Skip the tile at the given position
    for occupied_space in tile.occupied_spaces:
      if occupied_space.x == position.x and occupied_space.y == position.y:
        return true
  return false

func get_tile_at(x: int, z: int) -> PlacedTile:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return tile
  return null

func get_origin_tile(position: Vector2) -> PlacedTile:
  for tile in tiles:
    if tile.x == position.x and tile.z == position.y:
      return tile
    for occupied_space in tile.occupied_spaces:
      if occupied_space.x == position.x and occupied_space.y == position.y:
        return tile
  return null

func set_tile_at(x: int, z: int, tile_context: SceneContext.TileContext):
  if not does_tile_fit(tile_context.tile, Vector2(x, z), tile_context.rotation):
    return
  var saved_tile: PlacedTile
  if (has_tile_at(x, z)):
    saved_tile = get_tile_at(x, z)
  else:
    saved_tile = PlacedTile.new()
    saved_tile.x = x
    saved_tile.z = z
    tiles.append(saved_tile)
  saved_tile.id = tile_context.tile.id
  saved_tile.rotation = tile_context.rotation
  saved_tile.update_tile_offset()
  return

func remove_tile_at(x: int, z: int):
  for i in range(tiles.size()):
    if tiles[i].x == x and tiles[i].z == z:
      tiles.remove_at(i)
      return
  print("No tile found at position (", x, ", ", z, ") to remove.")

func does_tile_fit(tile: Tile, position: Vector2, rotation: Vector3) -> bool:
  var targetTile: PlacedTile = PlacedTile.new()
  targetTile.position = position
  targetTile.rotation = rotation
  targetTile.id = tile.id
  var occupied_spaces = targetTile.calculate_occupied_spaces()
  for space in occupied_spaces:
    if has_position_in_tile_occupying_space_excluding_self(Vector2(space.x, space.y), position):
      return false
    if space.x < 0 or space.y < 0:
      return false
    if space.x >= SIZE.x or space.y >= SIZE.y:
      return false
  return true
