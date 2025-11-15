class_name TilePreview
extends Node3D

const ROTATION_SPEED: float = 0.66

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _process(delta: float) -> void:
  mesh_instance.rotate_y(ROTATION_SPEED * delta)

func set_mesh(path: String) -> void:
  mesh_instance.mesh = load(path)
