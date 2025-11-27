class_name SceneTileViewModel
extends RefCounted

var tile: Tile
var rotation: Vector3 = Vector3.ZERO
var mesh: Mesh

func rotate(delta: float):
  rotation.y += delta
  if rotation.y >= 360:
    rotation.y -= 360
  elif rotation.y < 0:
    rotation.y += 360

func set_tile(new_tile: Tile):
  if new_tile == null or new_tile.mesh_path == "":
    mesh = null
    return
  tile = new_tile
  mesh = load(tile.mesh_path)

func set_mesh(new_mesh: Mesh):
  mesh = new_mesh
