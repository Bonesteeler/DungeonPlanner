class_name LoadSavedFiles
extends RefCounted
## LoadSavedFiles
## 
## A helper class responsible for importing tile sets from a directory of STL[br]
## files. This class coordinates file validation, import progress signalling,[br]
## and writing the resulting set definition to disk.[br]

signal import_started(int)
signal tile_imported()

const TILE_PATH = "user://Meshes/"

## Import a directory of STL files into a new DragonbiteTileSet[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — filesystem path to the directory containing[br]
## [code].stl[/code] files.[br]
## [code]set_name[/code] : [String] — unique name to assign to the imported tile set.[br]
## [b]Emits:[/b][br]
## - [code]import_started(total_tiles: [int])[/code] once at the start of an import[br]
## - [code]tile_imported()[/code] after each tile is imported[br]
## [b]Side-effects:[/b][br]
## - Writes a JSON set definition to [code]SceneContext.SET_DEFINITIONS_PATH[/code][br]
## - Adds the new set to [code]SceneContext.tile_resources[/code][br]
## [b]Returns:[/b] [void] — prints an error and returns early on failure.[br]
func import_tile_set_from_directory(path: String, set_name: String):
# TODO: Have this return the set instead of saving it
  # Check path was provided
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
  if SceneContext.get_set_names().has(set_name):
    print("Tile set with name ", set_name, " already exists")
    return

  var set_definition := {}
  var set_definition_dir = DirAccess.open(path)
  if set_definition_dir == null:
    print("Failed to open ", DirAccess.get_open_error())
    return

  var new_set := DragonbiteTileSet.new()
  # Get name
  new_set.name = set_name
  set_definition["name"] = set_name
  # Get tiles and import stl files
  var tiles = []
  var stl_file_paths := set_definition_dir.get_files()
  call_deferred("emit_import_started", stl_file_paths.size())

  print("Import thread starting for: ", path)
  for file_name in stl_file_paths:
    if file_name.get_extension() != "stl":
      continue
    var new_tile = new_set.import_tile(path + "/" + file_name)

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
  var result = JSON.stringify(set_definition, "  ")
  var json_path = SceneContext.SET_DEFINITIONS_PATH + set_name + ".json"
  var set_definition_json = FileAccess.open(json_path, FileAccess.WRITE)
  set_definition_json.store_string(result)
  set_definition_json.close()
  SceneContext.tile_resources.add_set(new_set)

## [b]Emits:[/b] [code]import_started(total_tiles: [int])[/code][br]
## [b]Parameters:[/b] [code]total_tiles[/code] : [int] — number of tiles that will be imported.[br]
func emit_import_started(total_tiles: int):
  import_started.emit(total_tiles)

## [b]Emits:[/b] [code]tile_imported()[/code]
func emit_tile_imported():
  tile_imported.emit()
