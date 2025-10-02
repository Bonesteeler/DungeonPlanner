class_name TileLayout
extends RefCounted

const AUTHOR_STRING = "A community member"
const SIZE = Vector2(20, 20)

var scene_name = ""
var tiles = []

func get_unique_tile_ids() -> Array:
  var unique_tile_ids: Dictionary = {}
  for tile in tiles:
    if not unique_tile_ids.has(tile.id):
      unique_tile_ids.set(tile.id, 1)
  return unique_tile_ids.keys()

func has_tile_at(x: int, z: int) -> bool:
  for tile in tiles:
    if tile.position.x == x and tile.position.y == z:
      return true
  return false

func has_position_in_tile_occupying_space_excluding_self(
    position: Vector2,
    tile_origin: Vector2
) -> bool:
  for tile in tiles:
    if tile.position.x == tile_origin.x and tile.position.y == tile_origin.y:
      continue # Skip the tile at the given position
    for occupied_space in tile.occupied_spaces:
      if occupied_space.x == position.x and occupied_space.y == position.y:
        return true
  return false

func get_tile_at(x: int, z: int) -> PlacedTile:
  for tile in tiles:
    if tile.position.x == x and tile.position.y == z:
      return tile
  return null

func get_origin_tile(position: Vector2) -> PlacedTile:
  for tile in tiles:
    if tile.position.x == position.x and tile.position.y == position.y:
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
    saved_tile.position = Vector2(x, z)
    tiles.append(saved_tile)
  saved_tile.id = tile_context.tile.id
  saved_tile.rotation = tile_context.rotation
  saved_tile.update_tile_offset()
  return

func remove_tile_at(x: int, z: int):
  for i in range(tiles.size()):
    if tiles[i].position.x == x and tiles[i].position.y == z:
      tiles.remove_at(i)
      return
  print("No tile found at position (", x, ", ", z, ") to remove.")

func does_tile_fit(tile: Tile, position: Vector2, rotation: Vector3) -> bool:
  var target_tile: PlacedTile = PlacedTile.new()
  target_tile.position = position
  target_tile.rotation = rotation
  target_tile.id = tile.id
  var occupied_spaces = target_tile.calculate_occupied_spaces()
  for space in occupied_spaces:
    if has_position_in_tile_occupying_space_excluding_self(Vector2(space.x, space.y), position):
      return false
    if space.x < 0 or space.y < 0:
      return false
    if space.x >= SIZE.x or space.y >= SIZE.y:
      return false
  return true
