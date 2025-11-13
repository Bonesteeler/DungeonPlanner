class_name TileResources
extends Node
## TileResources
##
## [i]Manager of imported Dragonbite tile sets.[/i][br]
## [b]Properties:[/b][br]
## - [b]tile_sets[/b]: [Array] — list of loaded [code]DragonbiteTileSet[/code] instances.[br]
## - [b]unique_tile_ids[/b]: [Dictionary] — Unique ids of all imported tiles.[br]
## [b]Constants:[/b][br]
## - [code]KEY_SET[/code]: Key used in dictionaries returned by [code]get_set_and_tile_data[/code] to reference the tile set.[br]
## - [code]KEY_TILE[/code]: Key used in dictionaries returned by [code]get_set_and_tile_data[/code] to reference the tile object.[br]

signal tile_sets_changed()

const SET_DEFINITIONS_PATH = "user://SetDefinitions/"
const KEY_SET = "set"
const KEY_TILE = "tile"

var selected_set_idx = 0
var tile_sets: Array = []
var unique_tile_ids: Dictionary = {}

func _init() -> void:
  var dir_access = DirAccess.open(SET_DEFINITIONS_PATH)
  if not dir_access.dir_exists(SET_DEFINITIONS_PATH):
    dir_access.make_dir_recursive(SET_DEFINITIONS_PATH)
  load_set_definitions()

## Load tile set definitions from app data.[br]
func load_set_definitions():
  var start_time = Time.get_ticks_msec()
  var dir_paths = DirList.new(SET_DEFINITIONS_PATH)
  var set_files = dir_paths.get_files("json", DirList.Mode.PATH_WITH_EXT)
  for set_file in set_files:
    var contents = File.read_file_as_text(set_file)
    var json = JSON.new()
    json.parse(contents)
    add_imported_set(json.data)
  var end_time = Time.get_ticks_msec()
  print("Tile sets loaded in ", (end_time - start_time) / 1000.0, " sec")

## Create and add a DragonbiteTileSet from JSON data.[br]
## [b]Parameters:[/b][br]
## [code]json[/code] : [Dictionary] — JSON representation of a Dragonbite tile set to load.[br]
## [b]Returns:[/b] [void][br]
func add_imported_set(json: Dictionary):
  var new_set := DragonbiteTileSet.new()
  new_set.load_from_json(json)
  add_set(new_set)

## Import a directory or list of STL files into a new DragonbiteTileSet and add it to the manager.[br]
## [b]Parameters:[/b][br]
## [code]name_set[/code] : [String] — name to assign to the imported tile set.[br]
## [code]stl_file_paths[/code] : [Array] — array of filesystem paths to .stl files to import.[br]
## [b]Returns:[/b] [void][br]
func import_set(name_set: String, stl_file_paths: Array):
  var new_set := DragonbiteTileSet.new()
  new_set.import_set(name_set, stl_file_paths)
  add_set(new_set)

## Register a [code]DragonbiteTileSet[/code][br]
## [b]Parameters:[/b][br]
## [code]new_set[/code] : [DragonbiteTileSet] — tile set to add to [code]tile_sets[/code].[br]
## [b]Returns:[/b] [void][br]
func add_set(new_set: DragonbiteTileSet):
  for tile in new_set.tiles:
    # Hash collision, should be very rare unless an identical model is imported twice
    if unique_tile_ids.has(tile.id):
      print("Hash collision detected for tile ID: %s" % tile.id)
    unique_tile_ids.set(tile.id, 1)
  tile_sets.append(new_set)
  tile_sets_changed.emit()

## Return the names of all loaded tile sets.[br]
## [b]Returns:[/b] [Array] — list of tile set names as strings.[br]
func get_set_names() -> Array:
  var set_names = []
  for tile_set in tile_sets:
    set_names.append(tile_set.name)
  return set_names

## Return the currently selected [code]DragonbiteTileSet[/code].[br]
## [b]Returns:[/b] [DragonbiteTileSet] — the selected tile set or null if no set is selected.[br]
func get_selected_set() -> DragonbiteTileSet:
  if selected_set_idx < 0 or selected_set_idx >= tile_sets.size():
    print("Selected set index out of bounds: %d" % selected_set_idx)
    return null
  return tile_sets[selected_set_idx]

## Find a tile by its unique id and return both the containing set and the tile.[br]
## [b]Parameters:[/b][br]
## [code]tile_id[/code] : [String] — unique identifier for the tile to look up.[br]
## [b]Returns:[/b] [Dictionary] — map with [code]KEY_SET[/code] and [code]KEY_TILE[/code]; values are the set and tile, or [code]null[/code] when not found.[br]
func get_set_and_tile_data(tile_id: String) -> Dictionary:
  for tile_set in tile_sets:
    for tile in tile_set.tiles:
      if tile.id == tile_id:
        return {KEY_SET: tile_set, KEY_TILE: tile}
  return {KEY_SET: null, KEY_TILE: null}

## Remove a tile set by name, delete its tiles, and remove their ids from the unique id registry.[br]
## [b]Parameters:[/b][br]
## [code]name_set[/code] : [String] — name of the tile set to remove.[br]
## [b]Returns:[/b] [void][br]
func remove_set(name_set: String):
  for i in range(tile_sets.size()):
    if tile_sets[i].name == name_set:
      for tile in tile_sets[i].tiles:
        unique_tile_ids.erase(tile.id)
      tile_sets[i].delete_tiles()
      tile_sets.remove_at(i)
      var file_path = SET_DEFINITIONS_PATH + name_set + ".json"
      File.delete_file(file_path)
      tile_sets_changed.emit()
      return

## Check whether all provided tile ids are present in the manager's registry.[br]
## [b]Parameters:[/b][br]
## [code]tile_ids[/code] : [Array] — list of tile id strings to verify.[br]
## [b]Returns:[/b] [bool] — [code]true[/code] if every id exists in [code]unique_tile_ids[/code], otherwise [code]false[/code].[br]
func has_tile_ids(tile_ids: Array) -> bool:
  for tile_id in tile_ids:
    if not unique_tile_ids.has(tile_id):
      return false
  return true

## Find and return a tile by its unique id.[br]
## [b]Parameters:[/b][br]
## [code]id[/code] : [String] — unique identifier of the tile to find.[br]
## [b]Returns:[/b] [Tile] — the matching tile, or [code]null[/code] if not found.[br]
func get_tile_from_id(id: String) -> Tile:
  for tile_set in tile_sets:
    for tile in tile_set.tiles:
      if tile.id == id:
        return tile
  return null