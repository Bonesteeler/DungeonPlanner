class_name Tile
extends RefCounted
## Tile
##
## [i]Represents a tile resource used by the planner. Handles importing/conversion of STL files to Godot ArrayMesh resources, caching metadata, and storing the saved mesh path.[/i][br]
## [b]Properties:[/b][br]
## - [b]name[/b][br]
## - [b]mesh_path[/b]: Filesystem path to the saved [code]ArrayMesh[/code] resource.[br]
## - [b]id[/b]: Hash id.[br]
## - [b]x_size[/b], [b]y_size[/b]: Tile dimensions in planning grid units.[br]

enum TileStatus {CACHED, CREATED, NOT_FOUND, CACHE_MISS}

var name = ""
var mesh_path: String = ""
var id: String = ""
var x_size: int = 0
var y_size: int = 0

## Load tile metadata from an imported JSON dictionary and verify the mesh resource exists.[br]
## [b]Parameters:[/b][br]
## [code]json[/code] : [Dictionary] — JSON payload to be imported[br]
## [b]Returns:[/b] [TileStatus] — [b]CACHED[/b] if the resource exists and metadata was loaded, [b]CACHE_MISS[/b] if the mesh resource was not found.[br]
func load_imported_tile(json: Dictionary) -> TileStatus:
  var res_path = json.get(DragonbiteTileSet.KEY_TILE_RES_PATH, "")
  if !FileAccess.file_exists(res_path):
    return TileStatus.CACHE_MISS
  name = json.get(DragonbiteTileSet.KEY_TILE_NAME, "")
  if (name == ""):
    print("Tile name is empty")
  id = json.get(DragonbiteTileSet.KEY_TILE_ID, "")
  if (id == ""):
    print("Tile ID is empty")
  mesh_path = res_path
  x_size = json.get(DragonbiteTileSet.KEY_TILE_X_SIZE, 1)
  y_size = json.get(DragonbiteTileSet.KEY_TILE_Y_SIZE, 1)
  return TileStatus.CACHED

## Convert an STL file into a Godot ArrayMesh and save it to the provided destination path.[br]
## [b]Parameters:[/b][br]
## [code]source_path[/code] : [String] — filesystem path to the source .stl file to import.[br]
## [code]destination_path[/code] : [String] — filesystem path where the resulting [code]ArrayMesh[/code] resource should be saved (e.g. user://meshes/tile.meshres).[br]
## [b]Returns:[/b] [TileStatus] — [b]CREATED[/b] on successful import and save, [b]CACHED[/b] if destination already exists, [b]NOT_FOUND[/b] if the source file is missing or a required directory failed to be created.[br]
func create_tile(source_path: String, destination_path: String) -> TileStatus:
  if !FileAccess.file_exists(source_path):
    print("Source file does not exist: ", source_path)
    return TileStatus.NOT_FOUND
  if FileAccess.file_exists(destination_path):
    print("Destination file already exists: ", destination_path)
    return TileStatus.CACHED
  var start_time = Time.get_ticks_msec()
  var stl_to_mesh = StlToMesh.new(source_path)
  var array_mesh: ArrayMesh = stl_to_mesh.mesh
  id = stl_to_mesh.mesh_hash
  x_size = stl_to_mesh.x_size
  y_size = stl_to_mesh.y_size
  var end_time = Time.get_ticks_msec()
  name = source_path.get_file().get_slice(".", 0)
  print("Imported ", name, " in ", end_time - start_time, " ms")
  var dir = DirAccess.open("user://")
  var destination_dir = destination_path.get_base_dir()
  if !dir.dir_exists(destination_dir):
    var res = dir.make_dir_recursive(destination_dir)
    if res != OK:
      print("Failed to create directory: ", destination_dir, " with error: ", res)
      return TileStatus.NOT_FOUND
  var save_status = ResourceSaver.save(array_mesh, destination_path, ResourceSaver.FLAG_CHANGE_PATH)
  mesh_path = destination_path
  if (save_status != OK):
    print("Failed to save mesh to ", destination_path, " with status ", save_status)
  return TileStatus.CREATED
