class_name TileLayout
extends RefCounted
## TileLayout
##
## [i]Represents a grid of placed tiles for a scene. Stores tile placement data and provides helpers to query and modify tiles on the planning grid.[/i][br]
## [b]Properties:[/b][br]
## - [b]scene_name[/b]: Scene name this layout is associated with.[br]
## - [b]layers[/b]: Array of [code]TileLayer[/code] instances currently placed in the layout.[br]
## [b]Constants:[/b][br]
## - [code]AUTHOR_STRING[/code]: Default author string for saved layouts.[br]
## - [code]SIZE[/code]: [code]Vector2[/code] — width and height in tiles for the planning grid.[br]

const AUTHOR_STRING = "A community member"
const SIZE = Vector2(20, 20)

var current_layer: TileLayer = null
var scene_name = ""
var layers = []

## Returns a list of unique tile ids used in this layout.[br]
## [b]Returns:[/b] [Array] — an array of unique tile id values.[br]
func get_unique_tile_ids() -> Array:
  var unique_tile_ids: Dictionary = {}
  for layer in layers:
    for tile in layer.tiles:
      if not unique_tile_ids.has(tile.id):
        unique_tile_ids.set(tile.id, 1)
  return unique_tile_ids.keys()

## Gets layer by its id.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to retrieve.[br]
## [b]Returns:[/b] [TileLayer] or [null] — the layer with the given ID, or `null` if not found.[br]
func get_layer_by_id(layer_id: int) -> TileLayer:
  for layer in layers:
    if layer.id == layer_id:
      return layer
  return null

## Check whether a tile exists at the given grid coordinates.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to check.[br]
## [code]x[/code] : [int] — X coordinate (column) on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate (row) on the planning grid.[br]
## [b]Returns:[/b] [bool] — `true` when a tile occupies the given coordinates, otherwise `false`.[br]
func has_tile_at(layer_id: int, x: int, z: int) -> bool:
  var layer = get_layer_by_id(layer_id)
  if layer == null:
    return false
  return layer.has_tile_at(x, z)

## Determine if the provided position is occupied by any tile's occupied spaces, excluding the tile at a specified origin.
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to check.[br]
## [code]position[/code] : [Vector2] — The grid position to check.[br]
## [code]tile_origin[/code] : [Vector2] — The origin position of the tile to exclude from the check.[br]
## [b]Returns:[/b] [bool] — `true` if another tile occupies the given position, otherwise `false`.[br]
func has_position_in_tile_occupying_space_excluding_self(
    layer_id: int,
    position: Vector2,
    tile_origin: Vector2
) -> bool:
  var layer = get_layer_by_id(layer_id)
  if layer == null:
    return false
  return layer.has_position_in_tile_occupying_space_excluding_self(position, tile_origin)

## Retrieve the placed tile located at the specified coordinates, if any.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to check.[br]
## [code]x[/code] : [int] — X coordinate on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate on the planning grid.[br]
## [b]Returns:[/b] [PlacedTile] or [null] — the placed tile at the coordinates or `null` when none found.[br]
func get_tile_at(layer_id: int, x: int, z: int) -> PlacedTile:
  var layer = get_layer_by_id(layer_id)
  if layer == null:
    return null
  return layer.get_tile_at(x, z)

## Find the tile that occupies the given position.
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to check.[br]
## [code]position[/code] : [Vector2] — Grid coordinates to locate the origin tile for.[br]
## [b]Returns:[/b] [PlacedTile] or [null] — the origin placed tile if found, otherwise `null`.[br]
func get_origin_tile(layer_id: int, position: Vector2) -> PlacedTile:
  var layer = get_layer_by_id(layer_id)
  if layer == null:
    return null
  return layer.get_origin_tile(position)

## Place or update a tile at the given coordinates using the provided tile context.[br]
## Validates that the tile fits before placing and updates existing placement if present.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to place on.[br]
## [code]x[/code] : [int] — X coordinate on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate on the planning grid.[br]
## [code]tile_context[/code] : [SceneTileViewModel] — vm of tile to set.[br]
## [b]Returns:[/b] [void] — returns early if the layer is not found or the tile does not fit.[br]
func set_tile_at(layer_id: int, x: int, z: int, tile_context: SceneTileViewModel):
  var layer = get_layer_by_id(layer_id)
  if layer == null:
    return
  layer.set_tile_at(x, z, tile_context)

## Remove a placed tile with origin at specified coordinates, if present.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to remove from.[br]
## [code]x[/code] : [int] — X coordinate on the planning grid.[br]
## [code]z[/code] : [int] — Z coordinate on the planning grid.[br]
## [b]Returns:[/b] [void] — prints a message when no tile exists at the coordinates.[br]
func remove_tile_at(layer_id: int, x: int, z: int):
  var layer = get_layer_by_id(layer_id)
  if layer == null:
    return
  layer.remove_tile_at(x, z)

## Validate whether the given tile can be placed at the target position and rotation without overlapping or going out of bounds.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — ID of the layer to check.[br]
## [code]tile[/code] : [Tile] — Tile resource to place.[br]
## [code]position[/code] : [Vector2] — Target origin coordinates on the planning grid.[br]
## [code]rotation[/code] : [Vector3] — Rotation to apply when calculating occupied spaces.[br]
## [b]Returns:[/b] [bool] — `true` if the tile fits, otherwise `false`.[br]
func does_tile_fit(layer_id: int, tile: Tile, position: Vector2, rotation: Vector3) -> bool:
  var layer = get_layer_by_id(layer_id)
  if layer == null:
    return false
  return layer.does_tile_fit(tile, position, rotation)
