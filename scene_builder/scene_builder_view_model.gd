class_name SceneBuilderViewModel
extends RefCounted

signal id_updated()

const DEFAULT_SCENE_NAME = "Untitled Scene"

var scene: Scene
var selected_tile: SceneTileViewModel
var preview_space: Space
  
func _init(data: Scene = null):
  if data == null:
    scene = Scene.new()
    scene.scene_name = DEFAULT_SCENE_NAME
    scene.id = UUID.v7()
  else:
    scene = data
  selected_tile = SceneTileViewModel.new()

func rotate_left():
  selected_tile.rotate(90)
  selected_tile.set_validity(does_selected_tile_fit())

func rotate_right():
  selected_tile.rotate(-90)
  selected_tile.set_validity(does_selected_tile_fit())

func get_selected_tile() -> SceneTileViewModel:
  return selected_tile

func get_selected_tile_mesh() -> Mesh:
  return selected_tile.mesh

func set_selected_tile_mesh(mesh: Mesh):
  selected_tile.set_mesh(mesh)

func get_selected_tile_rotation() -> Vector3:
  return selected_tile.rotation

func set_selected_tile(tile: Tile):
  selected_tile.set_tile(tile)

func set_hovered_space(space: Space):
  preview_space = space
  selected_tile.set_validity(does_selected_tile_fit())

# Scene functions
func does_selected_tile_fit() -> bool:
  if selected_tile.tile == null:
    return false
  return scene.data.does_tile_fit(selected_tile.tile, Vector2(preview_space.x, preview_space.z), selected_tile.rotation)

func update_id(new_id: String) -> void:
  scene.id = new_id
  id_updated.emit()

func update_scene_name(new_name: String) -> void:
  scene.scene_name = new_name

func can_set_tile_at(x: int, y: int, tile_vm: SceneTileViewModel) -> bool:
  if tile_vm.tile == null:
    return false
  return scene.data.does_tile_fit(tile_vm.tile, Vector2(x, y), tile_vm.rotation)

func can_set_selected_tile_at(x: int, y: int) -> bool:
  if selected_tile.tile == null:
    return false
  return scene.data.does_tile_fit(selected_tile.tile, Vector2(x, y), selected_tile.rotation)

func set_tile_in_layout_at(x: int, y: int, tile_vm: SceneTileViewModel) -> void:
  if not can_set_tile_at(x, y, tile_vm):
    print("Cannot set tile at position: ", x, ", ", y)
    return
  scene.data.set_tile_at(x, y, tile_vm)

func set_selected_tile_in_layout_at(x: int, y: int) -> void:
  set_tile_in_layout_at(x, y, selected_tile)

func remove_tile_in_layout_at(x: int, y: int) -> void:
  scene.data.remove_tile_at(x, y)

func get_origin_tile(position: Vector2) -> PlacedTile:
  return scene.data.get_origin_tile(position)