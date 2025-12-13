class_name SceneBuilderViewModel
extends RefCounted

const DEFAULT_SCENE_NAME = "Untitled Scene"

var scene: Scene
var selected_tile: SceneTileViewModel
  
func _init(data: Scene = null):
  if data == null:
    scene = Scene.new()
    scene.scene_name = DEFAULT_SCENE_NAME
  else:
    scene = data
  selected_tile = SceneTileViewModel.new()

func rotate_left():
  selected_tile.rotate(90)

func rotate_right():
  selected_tile.rotate(-90)

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

func does_selected_tile_fit(position: Vector2) -> bool:
  if selected_tile.tile == null:
    return false
  return scene.data.does_tile_fit(selected_tile.tile, position, selected_tile.rotation)
