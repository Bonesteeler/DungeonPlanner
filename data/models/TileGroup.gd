class_name TileGroup
extends Resource
##
## Represents a collection of tiles.
##

const KEY_TILE_ID = "id"
const KEY_TILE_IMAGE_PATH = "imagePath"
const KEY_TILE_NAME = "name"
const KEY_TILE_X_SIZE = "xSize"
const KEY_TILE_Y_SIZE = "ySize"
const KEY_TILE_RES_PATH = "resPath"
const KEY_TILES = "tiles"
const MESHES_PATH = "user://Meshes/"
const TILE_PATH = "user://Meshes/"

var data: Dictionary = {}
var name: String = ""
var path: String = ""
var tiles: Array[Tile] = []


func _init(collection_name, pathspec: String) -> void:
  self.name = collection_name
  self.path = pathspec


##
## Import a tile, from an STL file, into this tileset.
##
## @param stl_file_path The path to the STL file to import.
##      Note it has no extension so it can be used for naming the .res file.
##
func import_tile(stl_file_path: String):
  var new_tile := Tile.new()
  var dest_file = stl_file_path.get_file()
  var dest_path = MESHES_PATH + name + "/" + dest_file + ".res"

  var status = new_tile.create_tile(stl_file_path + ".stl", dest_path)

  if !(status == Tile.TileStatus.CREATED or status == Tile.TileStatus.CACHED):
    push_error("Failed to import tile from ", stl_file_path + ".stl")
    return null

  new_tile.name = stl_file_path.get_file()
  data[TileGroup.KEY_TILE_NAME] = new_tile.name
  data[TileGroup.KEY_TILE_ID] = new_tile.id
  data[TileGroup.KEY_TILE_RES_PATH] ="/".join([TILE_PATH, set_name, new_tile.name + ".res"])
  data[TileGroup.KEY_TILE_X_SIZE] = new_tile.x_size
  data[TileGroup.KEY_TILE_Y_SIZE] = new_tile.y_size

  tiles.append(new_tile)
  call_deferred("emit_tile_imported")
  return