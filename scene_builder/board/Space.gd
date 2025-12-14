class_name Space
extends Node3D
## Space
##
## [i]Represents a single grid space on the planning board. Manages a child
## MeshInstance3D used for rendering tile previews and emits hover/click
## signals when the user interacts with the space.[/i][br]
## [b]Properties:[/b][br]
## - [b]x[/b]: X coordinate in grid space ([int]).[br]
## - [b]z[/b]: Z coordinate in grid space ([int]).[br]
## - [b]mesh_node[/b]: Reference to the child [code]MeshInstance3D[/code] that
##   renders the tile preview.[br]
## [b]Signals:[/b][br]
## - [code]space_hover_enter(Node3D)[/code]: Emitted when the mouse enters the space.[br]
## - [code]space_hover_exit(Node3D)[/code]: Emitted when the mouse exits the space.[br]
## - [code]space_clicked(Node3D, x, z)[/code]: Emitted when the space is clicked with the left mouse button.[br]

signal space_hover_enter(Node3D)
signal space_hover_exit(Node3D)
signal space_clicked(Node3D, x, z)

var x = 0
var z = 0

@onready var mesh_node = $Area3D/MeshInstance3D

## Update the mesh display to show a tile context and optional red overlay.[br]
## [b]Parameters:[/b][br]
## [code]context[/code] : [PlanningContext.TileContext] — tile data to display.[br]
## [code]is_red[/code] : [bool] — whether to render the tile with a red tint (for invalid placement).[br]
## [b]Returns:[/b] [void][br]
func update_context(context: PlanningContext.TileContext):
  mesh_node.set_tile_context(context, context.valid)

## Update the mesh color to indicate state (red for invalid, default otherwise). [br]
## [b]Parameters:[/b][br]
## [code]is_red[/code] : [bool] — whether the mesh should be shown in red.[br]
## [b]Returns:[/b] [void][br]
func update_color(is_red: bool):
  mesh_node.set_color(is_red)

## Set the mesh to display a [code]TileContext.[/code][br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [PlanningContext.TileContext] — tile data to set on the mesh.[br]
## [b]Returns:[/b] [void][br]
func set_tile(tile: PlanningContext.TileContext):
  mesh_node.set_tile(tile)

## End any active preview state on the mesh and return it to its previous display.[br]
## [b]Returns:[/b] [void][br]
func end_preview():
  mesh_node.exit_preview()

## Handle input events from the child Area3D and emit [code]space_clicked[/code]
## when the left mouse button is pressed on this space.[br]
## [b]Parameters:[/b][br]
## [code]_camera[/code] : [Camera3D] — camera that received the event. (unused)[br]
## [code]event[/code] : [InputEvent] — the input event from the Area3D.[br]
## [code]_pos[/code] : [Vector3] — collision position. (unused)[br]
## [code]_normal[/code] : [Vector3] — collision normal. (unused)[br]
## [code]_shape_idx[/code] : [int] — index of the shape that was hit. (unused)[br]
## [b]Emits:[/b][br]
## - [code]space_clicked(Node3D, x, z)[/code] when the left mouse button is pressed on this space.[br]
## [b]Returns:[/b] [void][br]
func _on_area_3d_input_event(_camera, event, _pos, _normal, _shape_idx):
  if not event is InputEventMouseButton:
    return
  event = event as InputEventMouseButton
  var button_clicked = event.get_button_index()
  if not event.is_pressed() or button_clicked != MOUSE_BUTTON_LEFT:
    return
  space_clicked.emit(self, x, z)

## Called when the mouse cursor enters the Area3D; emits [code]space_hover_enter[/code].[br]
## [b]Emits:[/b][br]
## - [code]space_hover_enter(Node3D)[/code] when the mouse enters this space.[br]
## [b]Returns:[/b] [void][br]
func _on_area_3d_mouse_entered():
  space_hover_enter.emit(self)

## Called when the mouse cursor exits the Area3D; emits [code]space_hover_exit[/code].[br]
## [b]Emits:[/b][br]
## - [code]space_hover_exit(Node3D)[/code] when the mouse exits this space.[br]
## [b]Returns:[/b] [void][br]
func _on_area_3d_mouse_exited():
  space_hover_exit.emit(self)

## Clear the mesh so the space appears empty (no tile). [br]
## [b]Returns:[/b] [void][br]
func set_empty():
  mesh_node.set_empty()
