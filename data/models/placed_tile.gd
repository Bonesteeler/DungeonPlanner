class_name PlacedTile
extends RefCounted
## PlacedTile
##
## [i]Represents a tile placed on the planning grid including its position, rotation, and the set of occupied grid spaces.[/i][br]
## [b]Properties:[/b][br]
## - [b]id[/b]: The unique identifier for the tile.[br]
## - [b]position[/b]: The tile's origin position in grid coordinates as a [code]Vector2[/code].[br]
## - [b]rotation[/b]: The tile's rotation in degrees as a [code]Vector3[/code]; only the Y component is used for grid rotation.[br]
## - [b]occupied_spaces[/b]: Calculated [code]Array[/code] of [code]Vector2[/code] positions on the grid that this placed tile occupies.[br]

# TODO replace field setters with proper setter methods.
# currently the occupied spaces are not updated when position or rotation change
# Or just make a proper constructor
var id: String:
  get(): 
    if tile_data == null:
      return ""
    return tile_data.id
var occupied_spaces: Array = []
var rotation: Vector3 = Vector3.ZERO
var position: Vector2 = Vector2.ZERO
var tile_data: Tile:
  set(value):
    tile_data = value
    update_tile_offset()

## Updates [code]occupied_spaces[/code] to match the current [code]position[/code] and [code]rotation[/code].[br]
## [b]Returns:[/b] [void] — updates [code]occupied_spaces[/code] in-place.[br]
func update_tile_offset():
  occupied_spaces.clear()
  occupied_spaces.append_array(calculate_occupied_spaces())

## Calculates which grid cells are occupied by this tile based on its [code]tile_data[/code], [code]position[/code], and [code]rotation[/code].[br]
## [b]Returns:[/b] [Array] — an array of [code]Vector2[/code] positions representing occupied grid cells.[br]
func calculate_occupied_spaces() -> Array:
  if tile_data == null:
    return []
  # Create base offsets based on tile size
  var x_size = tile_data.x_size
  var y_size = tile_data.y_size
  var x_end = x_size / 2
  var x_start = x_end - x_size + 1
  var y_end = y_size / 2
  var y_start = y_end - y_size + 1
  var occupied_space_offsets = []
  for x in range(x_start, x_end + 1):
    for y in range(y_start, y_end + 1):
      occupied_space_offsets.append(Vector2(x, y))
  # Rotate occupied spaces based on tile rotation
  while rotation.y < 0:
    rotation.y += 360
  while rotation.y >= 360:
    rotation.y -= 360
  if abs(rotation.y - 90) < 0.01:
    occupied_space_offsets = occupied_space_offsets.map(func(pos):
      return Vector2(pos.y, -pos.x))
  elif abs(rotation.y - 180) < 0.01:
    occupied_space_offsets = occupied_space_offsets.map(func(pos):
      return Vector2(-pos.x, -pos.y))
  elif abs(rotation.y - 270) < 0.01:
    occupied_space_offsets = occupied_space_offsets.map(func(pos):
      return Vector2(-pos.y, pos.x))
  # Combine offsets with position
  occupied_space_offsets = occupied_space_offsets.map(func(offset):
    return Vector2(position.x + offset.x, position.y + offset.y))
  return occupied_space_offsets