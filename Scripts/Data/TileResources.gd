class_name TileResources
extends RefCounted

const dragonBiteTileSetClass = preload ("res://Scripts/Data/DragonbiteTileSet.gd")

var tileSets: Array = []
var selectedSetIdx = 0

func add_set_from_path(path: String):
  var newSet = dragonBiteTileSetClass.new()
  var fileContents = FileAccess.get_file_as_string(path)
  var parsedJson = JSON.parse_string(fileContents)
  
  #If meshs have been created, update the json
  if newSet.load_from_json(parsedJson):
    var updatedJson = newSet.to_json()
    print("Updated json: ", updatedJson)
    var jsonFile = FileAccess.open(path, FileAccess.WRITE)
    jsonFile.store_string(updatedJson)
    
  tileSets.append(newSet)

func get_selected_set() -> DragonbiteTileSet:
  return tileSets[selectedSetIdx]
