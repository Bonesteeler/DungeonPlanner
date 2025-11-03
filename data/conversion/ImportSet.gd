class_name ImportSet
extends RefCounted
##
## Imports a set of stl_files into a TileGroup.
##

signal import_started(int)
signal tile_imported()

# Utility class for file operations. The var deliberately has the same name as the class to remind
# us that we are using the static class methods.
#var File = preload("res://data/conversion/files/File.gd")
var dir_lists: DirList
var set_name: String = ""
var pathname: String = ""
var stl_files: Array[String] = []
var tile_set: TileGroup
var tiles: Array = []


##
## Constructor
##
## @param tile_set_name The name of the tile set to create.
## @param path The path to the directory containing the .stl files.
##
func _init(tile_set_name: String, path: String):
#region Sanity checks
  # Check set_name is not already in use.
  if SceneContext.get_set_names().has(tile_set_name):
    push_error("Tile set with set_name ", tile_set_name, " already exists")
    return

  if !File.is_path_valid(path):
    push_error("ImportSet initialized with invalid path: " + path)
    return
#endregion

  self.pathname = path
  self.set_name = tile_set_name


func emit_import_started(total_tiles: int) -> void:
  import_started.emit(total_tiles)


func emit_tile_imported() -> void:
  tile_imported.emit()


##
## Import all .stl files, from the initialised directory, into a new TileGroup.
##
func import_tiles () -> void:
#region Sanity checks
  self.dir_lists = DirList.new(pathname)
  stl_files = dir_lists.get_files("stl", DirList.Mode.NAME_NO_EXT)
  if stl_files.size() == 0:
    push_error("No .stl stl_files found in directory: " + pathname)
    return
#endregion

  tile_set = TileGroup.new(set_name, pathname)

  print("Import thread starting for: ", pathname)
  call_deferred("emit_import_started", dir_lists._files.size())

  for file in stl_files:
    tile_set.import_tile(file) # Imports the tile and adds it to the set.

#region Save file  ## I would treat this as conversion and give it its own class.
  var result = JSON.stringify(tile_set, "  ")
  var json_path = SceneContext.SET_DEFINITIONS_PATH + set_name + ".json"
  var set_definition_json = FileAccess.open(json_path, FileAccess.WRITE)
  if FileAccess.get_open_error() != OK:
    push_error("Failed to open file for writing: " + json_path)
    return
  set_definition_json.store_string(result)
  set_definition_json.close()
#endregion

  var scene_context = SceneTree.current_scene.get_first_node_in_group("SceneContext")
  if scene_context == null:
    push_error("Failed to find SceneContext node to add new tile set")
    return

  scene_context.tile_resources.add_set(self.tile_set)
  return