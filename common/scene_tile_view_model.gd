class_name SceneTileViewModel
extends RefCounted

signal mesh_updated()
signal rotation_changed()
signal validity_changed()

var mesh: Mesh
var rotation: Vector3
var tile: Tile
var valid: bool = true

func set_rotation(new_rotation: Vector3):
  rotation = new_rotation
  rotation_changed.emit()

func rotate(delta: float):
  rotation.y += delta
  if rotation.y >= 360:
    rotation.y -= 360
  elif rotation.y < 0:
    rotation.y += 360
  rotation_changed.emit()

func set_validity(new_validity: bool):
  if valid != new_validity:
    valid = new_validity
    validity_changed.emit()

func set_tile(new_tile: Tile):
  if new_tile == null or new_tile.mesh_path == "":
    mesh = null
    return
  tile = new_tile
  mesh = load(tile.mesh_path)

func set_mesh(new_mesh: Mesh):
  mesh = new_mesh
  mesh_updated.emit()

func to_tile_context() -> PlanningContext.TileContext:
  var context = PlanningContext.TileContext.new()
  context.tile = tile
  context.rotation = rotation
  context.mesh = mesh
  context.valid = valid
  return context

func duplicate() -> SceneTileViewModel:
  var new_vm = SceneTileViewModel.new()
  new_vm.mesh = mesh
  new_vm.rotation = rotation
  new_vm.tile = tile
  new_vm.valid = valid
  return new_vm