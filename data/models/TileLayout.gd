class_name TileLayout
extends RefCounted
## TileLayout
##
## [i]Represents a grid of placed tiles for a scene. Stores tile placement data and provides helpers to query and modify tiles on the planning grid.[/i][br]
## [b]Properties:[/b][br]
## - [b]scene_name[/b]: Scene name this layout is associated with.[br]
## - [b]tiles[/b]: Array of [code]PlacedTile[/code] instances currently placed in the layout.[br]
## [b]Constants:[/b][br]
## - [code]AUTHOR_STRING[/code]: Default author string for saved layouts.[br]
## - [code]SIZE[/code]: [code]Vector2[/code] — width and height in tiles for the planning grid.[br]

const AUTHOR_STRING = "A community member"
const SIZE = Vector2(20, 20)

var scene_name = ""
var tiles = []

## Returns a list of unique tile ids used in this layout.[br]
## [b]Returns:[/b] [Array] — an array of unique tile id values.[br]
func get_unique_tile_ids() -> Array:
  var unique_tile_ids: Dictionary = {}
  for tile in tiles:
    if not unique_tile_ids.has(tile.id):
      unique_tile_ids.set(tile.id, 1)
  return unique_tile_ids.keys()

## Check whether a tile exists at the given grid coordinates.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — X coordinate (column) on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate (row) on the planning grid.[br]
## [b]Returns:[/b] [bool] — `true` when a tile occupies the given coordinates, otherwise `false`.[br]
func has_tile_at(x: int, z: int) -> bool:
  for tile in tiles:
    if tile.position.x == x and tile.position.y == z:
      return true
  return false

## Determine if the provided position is occupied by any tile's occupied spaces, excluding the tile at a specified origin.
## [b]Parameters:[/b][br]
## [code]position[/code] : [Vector2] — The grid position to check.[br]
## [code]tile_origin[/code] : [Vector2] — The origin position of the tile to exclude from the check.[br]
## [b]Returns:[/b] [bool] — `true` if another tile occupies the given position, otherwise `false`.[br]
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

## Retrieve the placed tile located at the specified coordinates, if any.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — X coordinate on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate on the planning grid.[br]
## [b]Returns:[/b] [PlacedTile] or [null] — the placed tile at the coordinates or `null` when none found.[br]
func get_tile_at(x: int, z: int) -> PlacedTile:
  for tile in tiles:
    if tile.position.x == x and tile.position.y == z:
      return tile
  return null

## Find the tile that occupies the given position.
## [b]Parameters:[/b][br]
## [code]position[/code] : [Vector2] — Grid coordinates to locate the origin tile for.[br]
## [b]Returns:[/b] [PlacedTile] or [null] — the origin placed tile if found, otherwise `null`.[br]
func get_origin_tile(position: Vector2) -> PlacedTile:
  for tile in tiles:
    if tile.position.x == position.x and tile.position.y == position.y:
      return tile
    for occupied_space in tile.occupied_spaces:
      if occupied_space.x == position.x and occupied_space.y == position.y:
        return tile
  return null

## Place or update a tile at the given coordinates using the provided tile context.[br]
## Validates that the tile fits before placing and updates existing placement if present.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — X coordinate on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate on the planning grid.[br]
## [code]tile_context[/code] : [SceneContext.TileContext] — Context containing the tile id and rotation to apply.[br]
## [b]Returns:[/b] [void] — returns early if the tile does not fit.[br]
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
  saved_tile.tile_data = tile_context.tile
  saved_tile.rotation = tile_context.rotation
  saved_tile.update_tile_offset()
  return

## Remove a placed tile with origin at specified coordinates, if present.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — X coordinate on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate on the planning grid.[br]
## [b]Returns:[/b] [void] — prints a message when no tile exists at the coordinates.[br]
func remove_tile_at(x: int, z: int):
  for i in range(tiles.size()):
    if tiles[i].position.x == x and tiles[i].position.y == z:
      tiles.remove_at(i)
      return
  print("No tile found at position (", x, ", ", z, ") to remove.")

## Validate whether the given tile can be placed at the target position and rotation without overlapping or going out of bounds.[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — Tile resource to place.[br]
## [code]position[/code] : [Vector2] — Target origin coordinates on the planning grid.[br]
## [code]rotation[/code] : [Vector3] — Rotation to apply when calculating occupied spaces.[br]
## [b]Returns:[/b] [bool] — `true` if the tile fits, otherwise `false`.[br]
func does_tile_fit(tile: Tile, position: Vector2, rotation: Vector3) -> bool:
  var target_tile: PlacedTile = PlacedTile.new()
  target_tile.position = position
  target_tile.rotation = rotation
  target_tile.tile_data = tile
  var occupied_spaces = target_tile.calculate_occupied_spaces()
  for space in occupied_spaces:
    if has_position_in_tile_occupying_space_excluding_self(Vector2(space.x, space.y), position):
      return false
    if space.x < 0 or space.y < 0:
      return false
    if space.x >= SIZE.x or space.y >= SIZE.y:
      return false
  return true
