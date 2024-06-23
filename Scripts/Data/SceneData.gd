class_name SceneData
extends RefCounted

class SavedTile:
  var id = ""
  var rotation: Vector3
  var x = 0
  var z = 0

var sceneName = ""
var tiles = []

func toJson() -> String:
  var data:Dictionary = {}
  data["sceneName"] = sceneName
  data["tiles"] = []
  for tile in tiles:
    var tileData:Dictionary = {}
    tileData["id"] = tile.id
    tileData["rotation"] = tile.rotation - PlanningContext.defaultRotation
    tileData["x"] = tile.x
    tileData["z"] = tile.z
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
    tile.z = tileData["z"]
    tiles.append(tile)

func hasTileAt(x:int, z:int) -> bool:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return true
  return false

func getTileAt(x:int, z:int) -> SavedTile:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return tile
  return null

func setTileAt(x:int, z:int, context:TileContext):
  var savedTile: SavedTile
  if (hasTileAt(x, z)):
    savedTile = getTileAt(x, z)
    savedTile.rotation = context.rotation
    savedTile.id = context.tile.id
  else:
    savedTile = SavedTile.new()
    savedTile.id = context.tile.id
    savedTile.rotation = context.rotation
    savedTile.x = x
    savedTile.z = z
    tiles.append(savedTile)
  return
