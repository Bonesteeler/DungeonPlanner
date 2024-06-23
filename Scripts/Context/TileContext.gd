class_name TileContext
extends RefCounted

const INT_MAX = 2147483647
# Yes, this nesting is intended
const OFFSETS_2X4 = [[[1, 0]], [[0, -1]], [[-1, 0]], [[0, 1]]]

# TODO Rotation should probably be just y rotation and an enum for the direction
var rotation: Vector3
var prevRotation: Vector3
var tile: Tile = Tile.new()
var mesh: Mesh
var originX = INT_MAX
var originY = INT_MAX

func _init(x: int, y: int):
  set_position(x, y)

func set_position(x: int, y: int):
  originX = x
  originY = y

func rotate(degrees: int):
  prevRotation = rotation
  rotation.y += degrees
  if rotation.y >= 360:
    rotation.y -= 360
  if rotation.y < 0:
    rotation.y += 360

func get_offset_coords(yRotation: float) -> Array:
  if originX == INT_MAX or originY == INT_MAX:
    return []
  
  var rotationIdx = yRotation / 90
  match tile.size: 
    Tile.TileSize.T_2X2:
      return []
    Tile.TileSize.T_2X4:
      return OFFSETS_2X4[rotationIdx]
  print("Invalid size in context")
  return []

func get_other_occupied_space_coords() -> Array:
  var occupiedSpaces = []
  var offsetCoords = get_offset_coords(rotation.y)
  for offset in offsetCoords:
    var x = originX + offset[0]
    var y = originY + offset[1]
    occupiedSpaces.append([x, y])
  return occupiedSpaces

func get_prev_occupied_space_coords() -> Array:
  var occupiedSpaces = []
  var offsetCoords = get_offset_coords(prevRotation.y)
  for offset in offsetCoords:
    var x = originX + offset[0]
    var y = originY + offset[1]
    occupiedSpaces.append([x, y])
  return occupiedSpaces