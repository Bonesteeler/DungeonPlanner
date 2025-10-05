class_name SpaceMesh
extends MeshInstance3D
## SpaceMesh
##
## [i]Node used by the planning scene to render a tile.[/i][br]
## [b]Properties:[/b][br]
## - [b]selected_mesh[/b]: The currently selected [code]Mesh[/code] used for placement previews.[br]
## - [b]tile_rotation[/b]: Rotation to apply to the mesh when placed, as [code]Vector3[/code].[br]
## - [b]is_space_mesh_set[/b]: Whether the selected mesh is an actual tile mesh or the empty-space placeholder.[br]
## [b]Constants:[/b][br]
## - [code]DEFAULT_MATERIAL[/code], [code]PREVIEW_MATERIAL[/code], [code]ERROR_MATERIAL[/code], [code]SPACE_MATERIAL[/code], [code]EMPTY_SPACE_MESH[/code]: Preloaded resources used for rendering and placeholders.[br]

const DEFAULT_MATERIAL = preload("res://scene_builder/board/DefaultMaterial.tres")
const PREVIEW_MATERIAL = preload("res://scene_builder/board/HoveredMaterial.tres")
const ERROR_MATERIAL = preload("res://scene_builder/board/ErrorMaterial.tres")
const SPACE_MATERIAL = preload("res://scene_builder/board/SpaceMaterial.tres")
const EMPTY_SPACE_MESH = preload("res://scene_builder/board/SpaceMesh.tres")

# Defaults to empty
var selected_mesh: Mesh = EMPTY_SPACE_MESH
var tile_rotation = Vector3.ZERO
var is_space_mesh_set = false

## Restore the mesh and material after a preview state.[br]
## [b]Returns:[/b] [void][br]
func exit_preview():
  mesh = selected_mesh
  set_rotation_degrees(tile_rotation)
  if get_active_material(0) == null:
    return
  if is_space_mesh_set:
    set_surface_override_material(0, DEFAULT_MATERIAL)
  else:
    set_surface_override_material(0, SPACE_MATERIAL)

## Set the [code]TileContext[/code] and color for this node.[br]
## [b]Parameters:[/b][br]
## [code]context[/code] : [PlanningContext.TileContext] — tile mesh and rotation to preview.[br]
## [code]is_error[/code] : [bool] — when true, use the error material to indicate an invalid placement.[br]
## [b]Returns:[/b] [void][br]
func set_tile_context(context: PlanningContext.TileContext, is_error: bool = false):
  visible = true
  var new_mesh: Mesh = context.mesh
  if new_mesh != null:
    mesh = new_mesh
    if get_active_material(0) != null:
      var new_material = PREVIEW_MATERIAL
      if is_error:
        new_material = ERROR_MATERIAL
      set_surface_override_material(0, new_material)
    set_rotation_degrees(context.rotation)

## Set the preview material color to error or preview.[br]
## [b]Parameters:[/b][br]
## [code]is_error[/code] : [bool] — when true, apply the error material; otherwise apply the preview material.[br]
## [b]Returns:[/b] [void][br]
func set_color(is_error: bool):
  visible = true
  if get_active_material(0) == null:
    return
  if is_error:
    set_surface_override_material(0, ERROR_MATERIAL)
  else:
    set_surface_override_material(0, PREVIEW_MATERIAL)

## Set the [code]TileContext[/code] for the node.[br]
## [b]Parameters:[/b][br]
## [code]new_tile[/code] : [PlanningContext.TileContext] — tile data (mesh and rotation) to set as selected.[br]
## [b]Returns:[/b] [void][br]
func set_tile(new_tile: PlanningContext.TileContext):
  visible = true
  if new_tile == null or get_active_material(0) == null:
    return
  set_surface_override_material(0, DEFAULT_MATERIAL)
  selected_mesh = new_tile.mesh
  mesh = selected_mesh
  tile_rotation = new_tile.rotation
  set_rotation_degrees(tile_rotation)
  is_space_mesh_set = true

## Set the node to represent an empty space.[br]
## [b]Returns:[/b] [void][br]
func set_empty():
  visible = true
  set_surface_override_material(0, SPACE_MATERIAL)
  mesh = EMPTY_SPACE_MESH
  selected_mesh = EMPTY_SPACE_MESH
  tile_rotation = Vector3.ZERO
  set_rotation_degrees(Vector3.ZERO)
  is_space_mesh_set = false
