class_name SceneContext
extends Node

class TileContext:
  var rotation: Vector3
  var tile: Tile
  var mesh: Mesh
  var valid: bool

const DEFAULT_ROTATION = Vector3.LEFT * 90
const SAVED_SCENE_PATH = "user://SavedScenes/"
const NODE_PATH = "PlanningContext"
const USER_DIR = "user://"

static var current_scene: Scene
static var initialized: bool = false
static var selected_tile_context: TileContext

static func initialize():
  if initialized:
    return
  initialized = true
  var user_dir_access = DirAccess.open(USER_DIR)
  if not user_dir_access.dir_exists(SAVED_SCENE_PATH):
    user_dir_access.make_dir_recursive(SAVED_SCENE_PATH)
  selected_tile_context = TileContext.new()
  selected_tile_context.rotation = DEFAULT_ROTATION
  current_scene = Scene.new()
  current_scene.scene_name = ""

static func get_instance(from: Node) -> SceneContext:
  return from.get_tree().root.get_node_or_null(NODE_PATH) as SceneContext

static func get_selected_mesh() -> Mesh:
  return selected_tile_context.mesh

static func set_selected_mesh(mesh: Mesh):
  selected_tile_context.mesh = mesh

static func get_selected_tile_context() -> TileContext:
  return selected_tile_context

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

static func set_current_scene(new_scene: Scene):
  current_scene = new_scene

static func does_selected_tile_fit(position: Vector2) -> bool:
  if selected_tile_context.tile == null:
    return false
  return current_scene.data.does_tile_fit(
      selected_tile_context.tile, position, selected_tile_context.rotation)
