class_name DragonbiteTileSet
extends RefCounted

const tileClass = preload("res://Scripts/Data/Tile.gd")

const NAME_KEY = "name"
const TILE_KEY = "tiles"

var tiles:Array = []
var name:String = ""
var statusCount:Array = [0, 0, 0]

func load_from_json(json:Dictionary) -> bool:
  var startTime = Time.get_ticks_msec()
  for tileJson in json[TILE_KEY]:
    var tile: Tile = tileClass.new()
    tile.create_tile_from_json(tileJson)
    var status = tile.load_mesh()
    statusCount[status] += 1
    tiles.append(tile)
  name = json[NAME_KEY]
  var endTime = Time.get_ticks_msec()
  print("Loaded tileset " + name + " in " + str(endTime - startTime) + "ms")
  print("Cached: ", statusCount[0], " Created: ", statusCount[1], " Not found: ", statusCount[2])
  # Returning if meshes have been created, will need to update template
  return statusCount[1] > 0

func to_json():
  var jsonModel = {}
  jsonModel[NAME_KEY] = name
  var tileJsons = []
  for tile in tiles:
    tileJsons.append(tile.to_dict())
  jsonModel[TILE_KEY] = tileJsons
  return JSON.stringify(jsonModel)

func get_size() -> int:
  return tiles.size()
