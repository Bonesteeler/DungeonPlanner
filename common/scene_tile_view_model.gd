class_name SceneTileViewModel
extends RefCounted
## SceneTileViewModel
##
## [i]View model for managing a scene tile's mesh, rotation, validity, and state.[/i][br]
## [b]Signals:[/b][br]
## - [code]mesh_updated[/code]: Emitted when the mesh changes.[br]
## - [code]rotation_changed[/code]: Emitted when the rotation changes.[br]
## - [code]validity_changed[/code]: Emitted when the validity state changes.[br]

signal mesh_updated()
signal rotation_changed()
signal validity_changed()

var mesh: Mesh
var rotation: Vector3
var rotation_enabled: bool = true
var tile: Tile
var valid: bool = true

## Sets the rotation to the specified value and emits [code]rotation_changed[/code]. Ignores rotation enabled[br]
## [b]Parameters:[/b][br]
## [code]new_rotation[/code] : [Vector3] — the new rotation value.
func set_rotation(new_rotation: Vector3):
  rotation = new_rotation
  rotation_changed.emit()

## Rotates the tile around the Y axis by the given delta. Only occurs if rotation is enabled[br]
## [b]Parameters:[/b][br]
## [code]delta[/code] : [float] — the rotation delta in degrees.
func rotate(delta: float):
  if not rotation_enabled:
    return
  rotation.y += delta
  if rotation.y >= 360:
    rotation.y -= 360
  elif rotation.y < 0:
    rotation.y += 360
  rotation_changed.emit()

## Enables rotation input.
func enable_rotation():
  rotation_enabled = true

## Disables rotation input.
func disable_rotation():
  rotation_enabled = false

## Sets the validity state and emits [code]validity_changed[/code] if the value changes.[br]
## [b]Parameters:[/b][br]
## [code]new_validity[/code] : [bool] — the new validity state.
func set_validity(new_validity: bool):
  if valid != new_validity:
    valid = new_validity
    validity_changed.emit()

## Sets the tile and loads its resource.[br]
## [b]Parameters:[/b][br]
## [code]new_tile[/code] : [Tile] — the new tile resource to assign.
func set_tile(new_tile: Tile):
  if new_tile == null or new_tile.mesh_path == "":
    mesh = null
    return
  tile = new_tile
  mesh = load(tile.mesh_path)

## Sets the mesh and emits [code]mesh_updated[/code].[br]
## [b]Parameters:[/b][br]
## [code]new_mesh[/code] : [Mesh] — the new mesh resource.
func set_mesh(new_mesh: Mesh):
  mesh = new_mesh
  mesh_updated.emit()

## Creates a deep copy of this view model with the same properties.[br]
## [b]Returns:[/b] [SceneTileViewModel][br]
func duplicate() -> SceneTileViewModel:
  var new_vm = SceneTileViewModel.new()
  new_vm.mesh = mesh
  new_vm.rotation = rotation
  new_vm.tile = tile
  new_vm.valid = valid
  return new_vm