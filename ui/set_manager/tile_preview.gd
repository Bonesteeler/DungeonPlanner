class_name TilePreview
extends Node3D
## TilePreview
##
## [i]3D preview component for displaying tile meshes.[/i][br]
## [b]Properties:[/b][br]
## - [b]rotating[/b]: [bool] enables the mesh rotating in preview.[br]
## - [b]camera[/b]: [Camera3D] camera for viewing the tile.[br]
## - [b]mesh_instance[/b]: [MeshInstance3D] displays the tile mesh.[br]
## - [b]rotator[/b]: [Node3D] node used for rotation transform.[br]

const DISTANCE_PER_UNIT: float = 60.0
const ROTATION_SPEED: float = 0.66
const VERTICAL_OFFSET: float = 25.0

@export var rotating: bool = false

@onready var camera: Camera3D = $Camera3D
@onready var mesh_instance: MeshInstance3D = $%PreviewMesh
@onready var rotator: Node3D = $Rotator

## Rotate the preview if rotation is enabled[br]
## [b]Parameters:[/b][br]
## [code]delta[/code] : [float] — time elapsed since last frame.[br]
func _process(delta: float) -> void:
  if rotating:
    rotator.rotate_y(ROTATION_SPEED * delta)

## Set the tile to preview and position camera automatically[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — tile to display in preview.[br]
func set_tile(tile: Tile) -> void:
  mesh_instance.mesh = load(tile.mesh_path)
  var tile_position: Vector3 = Vector3(0, 0, 0)
  if tile.x_size % 2 == 0:
    tile_position.x = -25
  if tile.y_size % 2 == 0:
    tile_position.z = -25
  mesh_instance.position = tile_position

  var max_size = max(tile.x_size, tile.y_size)
  max_size = max(max_size, 1)
  camera.position = Vector3(0, max_size * DISTANCE_PER_UNIT + VERTICAL_OFFSET, max_size * DISTANCE_PER_UNIT)

## Enable or disable rotation[br]
## [b]Parameters:[/b][br]
## [code]value[/code] : [bool] — whether rotation should be enabled.[br]
func set_rotating(value: bool) -> void:
  rotating = value