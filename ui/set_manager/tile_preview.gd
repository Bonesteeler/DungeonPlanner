class_name TilePreview
extends Node3D

const DISTANCE_PER_UNIT: float = 60.0
const ROTATION_SPEED: float = 0.66

@onready var camera: Camera3D = $Camera3D
@onready var mesh_instance: MeshInstance3D = $%PreviewMesh
@onready var rotator: Node3D = $Rotator

func _process(delta: float) -> void:
  rotator.rotate_y(ROTATION_SPEED * delta)

func set_tile(tile: Tile) -> void:
  mesh_instance.mesh = load(tile.mesh_path)
  var tile_position: Vector3 = Vector3(0, 0, 0)
  if tile.x_size % 2 == 0:
    tile_position.x = -25
  if tile.y_size % 2 == 0:
    tile_position.z = -25
  mesh_instance.position = tile_position

  var max_size = max(tile.x_size, tile.y_size)
  camera.position = Vector3(0, max_size * DISTANCE_PER_UNIT,  max_size * DISTANCE_PER_UNIT)