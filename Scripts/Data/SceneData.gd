class_name SceneData
extends RefCounted

var sceneName = ""
var tiles = []
var sizeX = 0
var sizeY = 0

func _init(x: int, y: int):
  sizeX = x
  sizeY = y
  for i in range(sizeX):
    for j in range(sizeY):
      var tile = SavedTile.new()
      tile.x = i
      tile.y = j
      tiles.append(tile)

func toJson() -> String:
  var data:Dictionary = {}
  data["sceneName"] = sceneName
  data["tiles"] = []
  for tile in tiles:
    var tileData:Dictionary = {}
    tileData["id"] = tile.id
    tileData["rotation"] = tile.rotation - PlanningContext.defaultRotation
    tileData["x"] = tile.x
    tileData["y"] = tile.y
    data["tiles"].append(tileData)
  return JSON.stringify(data)

func splitOnAnyOf(string: String, delimiters: String) -> Array: 
  var tokens = []
  var currentToken = ""
  for c in string:
    if delimiters.find(c) != -1:
      if currentToken != "":
        tokens.append(currentToken)
        currentToken = ""
    else:
      currentToken += c
  return tokens

func fromJson(json:String):
  tiles = []
  var data:Dictionary = JSON.parse_string(json)
  sceneName = data["sceneName"]
  for tileData in data["tiles"]:
    var tile = SavedTile.new()
    tile.id = tileData["id"]
    var rotation = splitOnAnyOf(tileData["rotation"], " ,()")
    tile.rotation = Vector3(float(rotation[0]), float(rotation[1]), float(rotation[2])) + PlanningContext.defaultRotation
    tile.x = tileData["x"]
    tile.y = tileData["y"]
    tiles.append(tile)

func getTileIdx(x:int, y:int) -> int:
  var idx = x * sizeY + y
  if idx < tiles.size():
    return idx
  return -1

func hasTileAt(x:int, y:int) -> bool:
  for tile in tiles:
    if tile.x == x and tile.y == y:
      return true
  return false

func getTileAt(x:int, y:int) -> SavedTile:
  var idx = getTileIdx(x, y)
  if idx == -1:
    return null
  return tiles[idx]

func setTileAt(x:int, y:int, context:TileContext):
  var savedTile: SavedTile = getTileAt(x, y)
  if savedTile == null:
    print("[SceneData] setTileAt: invalid tile index")
    return
  savedTile.rotation = context.rotation
  savedTile.id = context.tile.id
  savedTile.fillState = SavedTile.TileFillState.OCCUPIED_ROOT
  var childOccupiedCoords = context.get_other_occupied_space_coords()
  for coord in childOccupiedCoords:
    var childTile = getTileAt(coord[0], coord[1])
    if childTile != null:
      childTile.fillState = SavedTile.TileFillState.OCCUPIED_CHILD
  return
