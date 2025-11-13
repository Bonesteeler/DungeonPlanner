class_name LoadSavedFiles
extends RefCounted
## LoadSavedFiles
## 
## A helper class responsible for importing tile sets from a directory of STL[br]
## files. This class coordinates file validation, import progress signalling,[br]
## and writing the resulting set definition to disk.[br]

signal import_complete()
signal import_started(int)
signal tile_imported()

const TILE_PATH = "user://Meshes/"

var cancel_requested: bool = false

## Import a directory of STL files into a new DragonbiteTileSet. Updates disk and in memory tile set data.[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — filesystem path to the directory containing[br]
## [code].stl[/code] files.[br]
## [code]set_name[/code] : [String] — unique name to assign to the imported tile set.[br]
## [b]Emits:[/b][br]
## - [code]import_started(total_tiles: [int])[/code] once at the start of an import[br]
## - [code]tile_imported()[/code] after each tile is imported[br]
## [b]Returns:[/b] [void] — prints an error and returns early on failure.[br]
func import_tile_set_from_directory(path: String, set_name: String):
# TODO: Have this return the set instead of saving it
  # Check path was provided
  cancel_requested = false
  var dirs = path.split("/")
  var count = dirs.size()
  if count == 0:
    print("Attempted to load tile set at empty path")
    return

  for index in range(1, count):
    var segment = dirs.get(index)
    if !segment.is_valid_filename():
      print("File path has invalid characters (: / \\ ? * \" | % < >) in directory:")
      print("/".join(dirs.slice(1, index + 1))) # Show the actual directory that broke us.
      return

  # Check set_name is not already in use.
  if TileSets.get_set_names().has(set_name):
    print("Tile set with name ", set_name, " already exists")
    return

  var import_dir = DirList.new(path)
  var stl_paths = import_dir.get_files("stl", DirList.Mode.PATH_WITH_EXT)
  if stl_paths.size() == 0:
    print("No .stl files found in directory: ", path)
    return

  var set_definition := {}

  var new_set := DragonbiteTileSet.new()
  new_set.name = set_name
  set_definition["name"] = set_name
  call_deferred("emit_import_started", stl_paths.size())

  print("Import thread starting for: ", path)
  var tiles = []
  for file_path in stl_paths:
    if cancel_requested:
      print("Import cancelled, aborting import.")
      new_set.delete_tiles()
      return
    var new_tile = new_set.import_tile(file_path)

    var tile_definition = {}
    tile_definition[DragonbiteTileSet.KEY_TILE_NAME] = new_tile.name
    tile_definition[DragonbiteTileSet.KEY_TILE_ID] = new_tile.id

    var tile_res_path = TILE_PATH + set_name + "/" + new_tile.name + ".res"
    tile_definition[DragonbiteTileSet.KEY_TILE_RES_PATH] = tile_res_path
    tile_definition[DragonbiteTileSet.KEY_TILE_X_SIZE] = new_tile.x_size
    tile_definition[DragonbiteTileSet.KEY_TILE_Y_SIZE] = new_tile.y_size
    tiles.append(tile_definition)
    call_deferred("emit_tile_imported")
  set_definition["tiles"] = tiles

  # Save file
  if cancel_requested:
    print("Import cancelled, aborting import.")
    new_set.delete_tiles()
    return
  var result = JSON.stringify(set_definition, "  ")
  var json_path = TileSets.SET_DEFINITIONS_PATH + set_name + ".json"
  File.write_file_as_text(json_path, result)
  call_deferred("add_set", new_set)
  call_deferred("emit_import_complete")

func cancel_import():
  cancel_requested = true

## [b]Emits:[/b] [code]import_started(total_tiles: [int])[/code][br]
## [b]Parameters:[/b] [code]total_tiles[/code] : [int] — number of tiles that will be imported.[br]
func emit_import_started(total_tiles: int):
  import_started.emit(total_tiles)

## [b]Emits:[/b] [code]tile_imported()[/code]
func emit_tile_imported():
  tile_imported.emit()

## [b]Emits:[/b] [code]import_complete()[/code]
func emit_import_complete():
  import_complete.emit()

## Adds a new tile set to resources
func add_set(new_set: DragonbiteTileSet):
  TileSets.add_set(new_set)
