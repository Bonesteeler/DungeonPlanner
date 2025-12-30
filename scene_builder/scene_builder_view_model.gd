class_name SceneBuilderViewModel
extends RefCounted

## SceneBuilderViewModel
##
## [i]Manages the state and operations for the scene builder view.[/i][br]
## [b]Signals:[/b][br]
## - [code]id_updated[/code]: Emitted when the scene ID is updated.[br]
## - [code]scene_name_updated[/code]: Emitted when the scene name is updated.[br]

signal id_updated()
signal scene_name_updated()

const DEFAULT_SCENE_NAME = "Untitled Scene"

var scene: Scene
var selected_tile: SceneTileViewModel
var preview_space: Space

## Initializes a new SceneBuilderViewModel with an optional existing scene.[br]
## [b]Parameters:[/b][br]
## [code]data[/code] : [Scene] — existing scene to load, or [code]null[/code] if not provided.[br]
func _init(data: Scene = null):
  if data == null:
    scene = Scene.new()
    scene.scene_name = DEFAULT_SCENE_NAME
    scene.id = UUID.v7()
  else:
    scene = data
  selected_tile = SceneTileViewModel.new()

## Rotates the selected tile 90 degrees counter-clockwise.[br]
func rotate_left():
  selected_tile.rotate(90)
  selected_tile.set_validity(does_selected_tile_fit())

## Rotates the selected tile 90 degrees clockwise.[br]
func rotate_right():
  selected_tile.rotate(-90)
  selected_tile.set_validity(does_selected_tile_fit())

## Returns the view model of the currently selected tile.[br]
## [b]Returns:[/b] [SceneTileViewModel][br]
func get_selected_tile() -> SceneTileViewModel:
  return selected_tile

## Returns the mesh of the currently selected tile.[br]
## [b]Returns:[/b] [Mesh][br]
func get_selected_tile_mesh() -> Mesh:
  return selected_tile.mesh

## Sets the mesh for the selected tile.[br]
## [b]Parameters:[/b][br]
## [code]mesh[/code] : [Mesh] — the mesh to assign to the selected tile.[br]
func set_selected_tile_mesh(mesh: Mesh):
  selected_tile.set_mesh(mesh)

## Returns the rotation of the selected tile.[br]
## [b]Returns:[/b] [Vector3][br]
func get_selected_tile_rotation() -> Vector3:
  return selected_tile.rotation

## Sets the selected tile from a tile definition.[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — the tile to select.[br]
func set_selected_tile(tile: Tile):
  selected_tile.set_tile(tile)

## Sets the space being previewed.[br]
## [b]Parameters:[/b][br]
## [code]space[/code] : [Space] — the space to preview for tile placement.[br]
func set_hovered_space(space: Space):
  preview_space = space
  selected_tile.set_validity(does_selected_tile_fit())

# Scene functions
## Checks if the selected tile can fit at the previewed space.[br]
## [b]Returns:[/b] [bool][br]
func does_selected_tile_fit() -> bool:
  if preview_space == null or selected_tile.tile == null:
    return false
  return scene.data.does_tile_fit(selected_tile.tile, Vector2(preview_space.x, preview_space.z), selected_tile.rotation)

## Updates the scene ID and emits the [code]id_updated[/code] signal.[br]
## [b]Parameters:[/b][br]
## [code]new_id[/code] : [String] — the new scene ID.[br]
## [b]Emits:[/b][br]
## - [code]id_updated()[/code][br]
func update_id(new_id: String) -> void:
  scene.id = new_id
  id_updated.emit()

## Updates the scene name and emits the [code]scene_name_updated[/code] signal.[br]
## [b]Parameters:[/b][br]
## [code]new_name[/code] : [String] — the new scene name.[br]
## [b]Emits:[/b][br]
## - [code]scene_name_updated()[/code][br]
func update_scene_name(new_name: String) -> void:
  scene.scene_name = new_name
  scene_name_updated.emit()

## Checks if a tile can be placed at the specified coordinates.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — x coordinate.[br]
## [code]y[/code] : [int] — y coordinate.[br]
## [code]tile_vm[/code] : [SceneTileViewModel] — the view model to check.[br]
## [b]Returns:[/b] [bool][br]
func can_set_tile_at(x: int, y: int, tile_vm: SceneTileViewModel) -> bool:
  if tile_vm.tile == null:
    return false
  return scene.data.does_tile_fit(tile_vm.tile, Vector2(x, y), tile_vm.rotation)

## Checks if the selected tile can be placed at the specified coordinates.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — x coordinate.[br]
## [code]y[/code] : [int] — y coordinate.[br]
## [b]Returns:[/b] [bool][br]
func can_set_selected_tile_at(x: int, y: int) -> bool:
  if selected_tile.tile == null:
    return false
  return scene.data.does_tile_fit(selected_tile.tile, Vector2(x, y), selected_tile.rotation)

## Places a tile at the specified coordinates if able.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — x coordinate.[br]
## [code]y[/code] : [int] — y coordinate.[br]
## [code]tile_vm[/code] : [SceneTileViewModel] — the view model to place.[br]
func set_tile_in_layout_at(x: int, y: int, tile_vm: SceneTileViewModel) -> void:
  if not can_set_tile_at(x, y, tile_vm):
    print("Cannot set tile at position: ", x, ", ", y)
    return
  scene.data.set_tile_at(x, y, tile_vm)

## Places the selected tile at the specified coordinates if able.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — x coordinate.[br]
## [code]y[/code] : [int] — y coordinate.[br]
func set_selected_tile_in_layout_at(x: int, y: int) -> void:
  set_tile_in_layout_at(x, y, selected_tile)

## Removes the tile at the specified coordinates.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — x coordinate.[br]
## [code]y[/code] : [int] — y coordinate.[br]
func remove_tile_in_layout_at(x: int, y: int) -> void:
  scene.data.remove_tile_at(x, y)

## Returns the tile that occupies the specified position.[br]
## [b]Parameters:[/b][br]
## [code]position[/code] : [Vector2] — the position to query.[br]
## [b]Returns:[/b] [PlacedTile][br]
func get_origin_tile(position: Vector2) -> PlacedTile:
  return scene.data.get_origin_tile(position)