extends MeshInstance3D

var defaultMaterial = preload ("res://Materials/DefaultMaterial.tres")
var previewMaterial = preload ("res://Materials/HoveredMaterial.tres")
var spaceMaterial = preload ("res://Materials/SpaceMaterial.tres")
var emptySpaceMesh = preload ("res://Meshes/SpaceMesh.tres")
var setMesh: Mesh = preload ("res://Meshes/SpaceMesh.tres")
var setRotation = Vector3.ZERO
var set = false

func start_preview(tile: TileContext):
  set_surface_override_material(0, previewMaterial)
  set_preview_context(tile)

func exit_preview():
  mesh = setMesh
  set_rotation_degrees(setRotation)
  if get_active_material(0) == null:
    return
  if set:
    set_surface_override_material(0, defaultMaterial)
  else:
    set_surface_override_material(0, spaceMaterial)

func set_preview_context(context: TileContext):
  var selectedMesh: Mesh = context.mesh
  if selectedMesh != null:
    mesh = selectedMesh
    if get_active_material(0) != null:
      set_surface_override_material(0, previewMaterial)
    set_rotation_degrees(context.rotation)
	
func set_tile(newTile: TileContext):
  if newTile == null or get_active_material(0) == null:
    return
  set_surface_override_material(0, defaultMaterial)
  setMesh = newTile.mesh
  mesh = setMesh
  setRotation = newTile.rotation
  set_rotation_degrees(setRotation)
  set = true

func set_empty():
  set_surface_override_material(0, spaceMaterial)
  mesh = emptySpaceMesh
  setMesh = emptySpaceMesh
  setRotation = Vector3.ZERO
  set_rotation_degrees(Vector3.ZERO)
  set = false
