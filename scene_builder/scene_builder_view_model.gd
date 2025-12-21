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

func does_selected_tile_fit() -> bool:
  if selected_tile.tile == null:
    return false
  return scene.data.does_tile_fit(selected_tile.tile, Vector2(preview_space.x, preview_space.z), selected_tile.rotation)

func update_id(new_id: String) -> void:
  scene.id = new_id
  id_updated.emit()