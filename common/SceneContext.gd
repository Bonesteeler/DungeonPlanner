class_name SceneContext
extends Node

class TileContext:
  var rotation: Vector3
  var tile: Tile
  var mesh: Mesh

const DEFAULT_ROTATION = Vector3.LEFT * 90
const SAVED_SCENE_PATH = "user://SavedScenes/"
const SET_DEFINITIONS_PATH = "user://SetDefinitions/"
const NODE_PATH = "PlanningContext"
const USER_DIR = "user://"

static var current_scene: TileLayout
static var initialized: bool = false
static var selected_tile_context: TileContext
static var tile_resources: TileResources

static func initialize():
  if initialized:
    return
  initialized = true
  var user_dir_access = DirAccess.open(USER_DIR)
  if not user_dir_access.dir_exists(SAVED_SCENE_PATH):
    user_dir_access.make_dir_recursive(SAVED_SCENE_PATH)
  if not user_dir_access.dir_exists(SET_DEFINITIONS_PATH):
    user_dir_access.make_dir_recursive(SET_DEFINITIONS_PATH)
  tile_resources = TileResources.new()
  load_tile_resources()
  selected_tile_context = TileContext.new()
  selected_tile_context.rotation = DEFAULT_ROTATION
  current_scene = TileLayout.new()
  current_scene.scene_name = "New Scene"

static func get_instance(from: Node) -> SceneContext:
  return from.get_tree().root.get_node_or_null(NODE_PATH) as SceneContext

static func load_tile_resources():
  var start_time = Time.get_ticks_msec()
  var set_definitions_dir = DirAccess.open(SET_DEFINITIONS_PATH)
  if set_definitions_dir == null:
    print("Failed to open ", SET_DEFINITIONS_PATH)
    return
  set_definitions_dir.list_dir_begin()
  var file_name = set_definitions_dir.get_next()
  while file_name != "":
    add_imported_tile_set(SET_DEFINITIONS_PATH + file_name)
    file_name = set_definitions_dir.get_next()
  var end_time = Time.get_ticks_msec()
  set_definitions_dir.list_dir_end()
  print("Resources loaded in ", (end_time - start_time) / 1000.0, " sec")

static func add_imported_tile_set(path: String):
  var file_contents = FileAccess.get_file_as_string(path)
  var parsed_json = JSON.parse_string(file_contents)
  tile_resources.add_imported_set(parsed_json)

static func remove_set(set_id: String):
  tile_resources.remove_set(set_id)
  var set_definitions_dir = DirAccess.open(SET_DEFINITIONS_PATH)
  if set_definitions_dir == null:
    print("Failed to open ", SET_DEFINITIONS_PATH)
    return
  set_definitions_dir.remove(set_id + ".json")

static func get_selected_mesh() -> Mesh:
  return selected_tile_context.mesh

static func set_selected_mesh(mesh: Mesh):
  selected_tile_context.mesh = mesh

static func get_selected_tile_context() -> TileContext:
  return selected_tile_context

static func get_set_names() -> Array:
  var set_names = []
  for tile_set in tile_resources.tile_sets:
    set_names.append(tile_set.name)
  return set_names

static func left_rotation():
  var new_rotation = selected_tile_context.rotation.y + 90
  if new_rotation >= 360:
    new_rotation -= 360
  selected_tile_context.rotation[1] = new_rotation

static func right_rotation():
  var new_rotation = selected_tile_context.rotation.y - 90
  if new_rotation < 0:
    new_rotation += 360
  selected_tile_context.rotation[1] = new_rotation

static func get_selected_rotation() -> Vector3:
  return selected_tile_context.rotation

static func update_selected_tile(new_selected: Tile):
  if new_selected == null or new_selected.mesh_path == "":
    selected_tile_context.mesh = null
    return
  selected_tile_context.tile = new_selected
  selected_tile_context.mesh = load(new_selected.mesh_path)

static func set_tile(x: int, z: int, tile: TileContext):
  current_scene.set_tile_at(x, z, tile)

static func set_current_scene(new_scene: TileLayout):
  current_scene = new_scene

static func get_tile_from_id(id: String) -> Tile:
  for tile_set in tile_resources.tile_sets:
    for tile in tile_set.tiles:
      if tile.id == id:
        return tile
  return null

static func does_selected_tile_fit(position: Vector2) -> bool:
  if selected_tile_context.tile == null:
    return false
  return current_scene.does_tile_fit(
      selected_tile_context.tile, position, selected_tile_context.rotation)
