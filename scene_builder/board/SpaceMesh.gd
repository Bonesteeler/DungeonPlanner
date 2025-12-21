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
const NODE_ROTATION_OFFSET = Vector3.LEFT * 90

# Defaults to empty
var material = SPACE_MATERIAL
var selected_mesh: Mesh = EMPTY_SPACE_MESH
var tile_rotation = Vector3.ZERO

func _ready() -> void:
  set_node_rotation(tile_rotation)
  
## Set the node to represent an empty space.[br]
## [b]Returns:[/b] [void][br]
func set_empty():
  visible = true
  selected_mesh = EMPTY_SPACE_MESH
  tile_rotation = Vector3.ZERO
  material = SPACE_MATERIAL

## Set the [code]TileContext[/code] and color for this node.[br]
## [b]Parameters:[/b][br]
## [code]context[/code] : [PlanningContext.TileContext] — tile mesh and rotation to preview.[br]
## [code]is_error[/code] : [bool] — when true, use the error material to indicate an invalid placement.[br]
## [b]Returns:[/b] [void][br]
func set_values(vm: SceneTileViewModel):
  visible = true
  selected_mesh = vm.mesh
  tile_rotation = vm.rotation
  material = DEFAULT_MATERIAL
  set_node_color(material)
  set_node_rotation(tile_rotation)
  set_preview_mesh(selected_mesh)

## Set the preview material color to error or preview.[br]
## [b]Parameters:[/b][br]
## [code]is_valid[/code] : [bool] — when true, apply the error material; otherwise apply the preview material.[br]
## [b]Returns:[/b] [void][br]
func set_color(is_valid: bool):
  visible = true
  if get_active_material(0) == null:
    return
  if is_valid:
    set_surface_override_material(0, PREVIEW_MATERIAL)
  else:
    set_surface_override_material(0, ERROR_MATERIAL)

## Restore the mesh and material after a preview state.[br]
## [b]Returns:[/b] [void][br]
func exit_preview():
  mesh = selected_mesh
  set_node_rotation(tile_rotation)
  if selected_mesh != EMPTY_SPACE_MESH:
    set_node_color(DEFAULT_MATERIAL)
  else:
    set_node_color(SPACE_MATERIAL)

## Render the given mesh[br]
## [b]Parameters:[/b][br]
## [code]mesh_to_set[/code] : [Mesh] — mesh to preview on
## [b]Returns:[/b] [void][br]
func set_preview_mesh(mesh_to_set: Mesh):
  if mesh_to_set == null:
    mesh = EMPTY_SPACE_MESH
  else:
    mesh = mesh_to_set

## Set node the given rotation[br]
## [b]Parameters:[/b][br]
## [code]rotation_to_set[/code] : [Vector3] — rotation to preview
## [b]Returns:[/b] [void][br]
func set_node_rotation(rotation_to_set: Vector3):
  set_rotation_degrees(rotation_to_set + NODE_ROTATION_OFFSET)

## Set mesh of node to the given material[br]
## [b]Parameters:[/b][br]
## [code]material_to_set[/code] : [Material] — material to apply to
## [b]Returns:[/b] [void][br]
func set_node_color(material_to_set: Material):
  set_surface_override_material(0, material_to_set)

## Set the preview color based on validity[br]
## [b]Parameters:[/b][br]
## [code]is_valid[/code] : [bool] — whether the preview is valid
## [b]Returns:[/b] [void][br]
func set_preview_color(is_valid: bool):
  if is_valid:
    set_node_color(PREVIEW_MATERIAL)
  else:
    set_node_color(ERROR_MATERIAL)