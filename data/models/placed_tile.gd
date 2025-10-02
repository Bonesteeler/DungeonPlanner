class_name PlacedTile
extends RefCounted

# TODO replace field setters with proper setter methods.
# currently the occupied spaces are not updated when position or rotation change
var id: String = "" :
  set(value):
    id = value
    tile_data = SceneContext.get_tile_from_id(id)
    if tile_data == null:
      print("[PlacedTile] Tile with ID ", id, " not found in context.")
      return
    update_tile_offset()
var occupied_spaces: Array = []
var rotation: Vector3 = Vector3.ZERO
var position: Vector2 = Vector2.ZERO
var tile_data: Tile

func update_tile_offset():
  occupied_spaces.clear()
  occupied_spaces.append_array(calculate_occupied_spaces())

func calculate_occupied_spaces() -> Array:
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