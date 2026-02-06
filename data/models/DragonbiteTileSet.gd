class_name DragonbiteTileSet
extends RefCounted
## DragonbiteTileSet
##
## [i]Container for imported tiles used by the DungeonPlanner. Manages loading from JSON, importing STL files as tiles, and basic tileset operations such as retrieval and deletion.[/i][br]
## [b]Properties:[/b][br]
## - [b]tiles[/b]: Array — Loaded [code]Tile[/code] objects for this tileset.[br]
## - [b]name[/b]: String — Name of the tileset used for storage under [code]user://Meshes/[/code].[br]

const MESHES_PATH = "user://Meshes/"
const KEY_NAME = "name"
const KEY_TILES = "tiles"
const KEY_TILE_IMAGE_PATH = "imagePath"
const KEY_TILE_NAME = "name"
const KEY_TILE_ID = "id"
const KEY_TILE_RES_PATH = "resPath"
const KEY_TILE_X_SIZE = "xSize"
const KEY_TILE_Y_SIZE = "ySize"

var tiles: Array[Tile] = []
var name: String = ""

## Load a tileset from a JSON dictionary produced by the tile exporter.[br]
## [b]Parameters:[/b][br]
## [code]json[/code] : [Dictionary] — JSON dictionary containing tiles under the [code]KEY_TILES[/code] key and the tileset name under [code]KEY_NAME[/code].[br]
## [b]Returns:[/b] [void] — populates the [code]tiles[/code] array and sets [code]name[/code].[br]
func load_from_json(json: Dictionary):
  var status_count: Array = [0, 0, 0, 0]
  var start_time = Time.get_ticks_msec()
  for tile_json in json[KEY_TILES]:
    var tile := Tile.new()
    var status = tile.load_imported_tile(tile_json)
    status_count[status] += 1
    tiles.append(tile)
  name = json[KEY_NAME]
  var end_time = Time.get_ticks_msec()
  print("Loaded tileset " + name + " in " + str(end_time - start_time) + "ms")
  print("Cached: ", status_count[0], " Created: ", status_count[1], " Not found: ", status_count[2])

## Import a list of STL files into this tileset and save their mesh resources under [code]user://Meshes/[/code].[br]
## [b]Parameters:[/b][br]
## [code]set_name[/code] : [String] — Name to assign to the tileset; used as a directory under [code]user://Meshes/[/code].[br]
## [code]stl_file_paths[/code] : [PackedStringArray] — Array of filesystem paths to [.stl] files to import.[br]
## [b]Returns:[/b] [void] — creates [code].res[/code] mesh resources for each STL file and appends tiles to [code]tiles[/code].[br]
func import_set(set_name: String, stl_file_paths: PackedStringArray):
  name = set_name
  var start_time = Time.get_ticks_msec()
  for path in stl_file_paths:
    import_tile(path)
  var end_time = Time.get_ticks_msec()
  print("Imported tileset " + name + " in " + str(end_time - start_time) + "ms")

## Import a single STL file into the currently named tileset.[br]
## [b]Parameters:[/b][br]
## [code]stl_file_path[/code] : [String] — Filesystem path to the [.stl] file to import.[br]
## [b]Returns:[/b] [Tile] — the created or cached [code]Tile[/code] on success; [code]null[/code] on failure.[br]
func import_tile(stl_file_path: String) -> Tile:
  var new_tile := Tile.new()
  var dest_file = File.name_sans_extension(stl_file_path.get_file())
  var dest_path = MESHES_PATH + name + "/" + dest_file + ".res"
  var status = new_tile.create_tile(stl_file_path, dest_path)
  if status == Tile.TileStatus.CREATED or status == Tile.TileStatus.CACHED:
    tiles.append(new_tile)
    return new_tile
  print("Failed to import tile from ", stl_file_path)
  return null

## Delete all mesh resource files for this tileset from [code]user://Meshes/[/code] and remove the set directory.[br]
## [b]Returns:[/b] [void] — prints an error and returns early if the mesh directory cannot be opened.[br]
func delete_tiles():
  var mesh_dir = DirAccess.open(MESHES_PATH + name)
  if mesh_dir == null:
    print("Failed to open mesh directory for tileset: ", name)
    return
  mesh_dir.list_dir_begin()
  var file_name = mesh_dir.get_next()
  while file_name != "":
    mesh_dir.remove(file_name)
    file_name = mesh_dir.get_next()
  mesh_dir.list_dir_end()
  mesh_dir.change_dir("..")
  mesh_dir.remove(name)

## Retrieve a tile by its index in the tiles array.[br]
## [b]Parameters:[/b][br]
## [code]index[/code] : [int] — zero-based index of the tile to retrieve.[br]
## [b]Returns:[/b] [Tile] — the requested [code]Tile[/code] or [code]null[/code] if the index is out of bounds.[br]
func get_tile(index: int) -> Tile:
  if index < 0 or index >= tiles.size():
    print("Index out of bounds: ", index, " for tileset ", name)
    return null
  return tiles[index]

## Get the number of tiles currently loaded in this tileset.[br]
## [b]Returns:[/b] [int] — count of entries in [code]tiles[/code].[br]
func get_size() -> int:
  return tiles.size()

## Get all tiles in this tileset as an array.[br]
## [b]Returns:[/b] [Array] — array of all tiles in [code]tiles[/code].[br]
func get_all_tiles() -> Array[Tile]:
  return tiles.duplicate()