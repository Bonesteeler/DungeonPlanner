class_name  TileLayerViewModel
extends RefCounted
## TileLayerViewModel
##
## [i]View model for managing tile layer state and operations in the scene builder.[/i][br]
## [b]Signals:[/b][br]
## - [code]delete_requested(layer_id: int)[/code]: Emitted when the layer should be deleted.[br]
## - [code]layer_selected(layer_id: int)[/code]: Emitted when the layer is selected.[br]
## - [code]layer_updated()[/code]: Emitted when the layer's properties are modified.[br]
## - [code]selected_updated()[/code]: Emitted when the layer's selection state changes.[br]
## - [code]visibility_changed(layer_id: int)[/code]: Emitted when the layer's visibility is toggled.[br]

signal delete_requested(layer_id: int)
signal layer_selected(layer_id: int)
signal layer_updated()
signal selected_updated()
signal visibility_changed(layer_id: int)

var layer: TileLayer = TileLayer.new()
var selected: bool = false
var visible: bool = true

## Sets the height of the layer.[br]
## [b]Parameters:[/b][br]
## [code]new_height[/code] : [float] — the new height value to assign to the layer.[br]
## [b]Emits:[/b][br]
## - [code]layer_updated()[/code] after the height is changed.[br]
## [b]Returns:[/b] [void][br]
func set_height(new_height: float) -> void:
  layer.height = new_height
  layer_updated.emit()

## Replaces the current layer with a new layer instance.[br]
## [b]Parameters:[/b][br]
## [code]new_layer[/code] : [TileLayer] — the layer instance to assign.[br]
## [b]Emits:[/b][br]
## - [code]layer_updated()[/code] after the layer is replaced.[br]
## [b]Returns:[/b] [void][br]
func set_layer(new_layer: TileLayer) -> void:
  layer = new_layer
  layer_updated.emit() 

## Updates the selection state of the layer.[br]
## [b]Parameters:[/b][br]
## [code]is_selected[/code] : [bool] — true to select the layer, false to deselect.[br]
## [b]Emits:[/b][br]
## - [code]selected_updated()[/code] when the selection state changes.[br]
## - [code]layer_selected(layer.id)[/code] when the layer becomes selected.[br]
## [b]Returns:[/b] [void][br]
func set_selected(is_selected: bool) -> void:
  if selected == is_selected:
    return 
  selected = is_selected
  selected_updated.emit()
  if selected:
    layer_selected.emit(layer.id)

## Updates the visibility state of the layer.[br]
## [b]Parameters:[/b][br]
## [code]is_visible[/code] : [bool] — true to show the layer, false to hide it.[br]
## [b]Emits:[/b][br]
## - [code]visibility_changed(layer.id)[/code] after the visibility is changed.[br]
## [b]Returns:[/b] [void][br]
func set_visible(is_visible: bool) -> void:
  visible = is_visible
  visibility_changed.emit(layer.id)

## Requests deletion of the layer.[br]
## [b]Emits:[/b][br]
## - [code]delete_requested(layer.id)[/code] to signal that the layer should be deleted.[br]
## [b]Returns:[/b] [void][br]
func trigger_delete() -> void:
  delete_requested.emit(layer.id)

## Returns the tile that occupies the specified position.[br]
## [b]Parameters:[/b][br]
## [code]position[/code] : [Vector2] — the position to query.[br]
## [b]Returns:[/b] [PlacedTile][br]
func get_origin_tile(position: Vector2) -> PlacedTile:
  return layer.get_origin_tile(position)

## Returns the height of the layer.[br]
## [b]Returns:[/b] [float][br]
func get_height() -> float:
  return layer.get_height()

## Checks whether a tile can be placed at the specified position and rotation.[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — the tile to check for placement.[br]
## [code]position[/code] : [Vector2] — the grid position to check.[br]
## [code]rotation[/code] : [Vector3] — the rotation to apply to the tile.[br]
## [b]Returns:[/b] [bool][br]
func does_tile_fit(
    tile: Tile,
    position: Vector2,
    rotation: Vector3
) -> bool:
  # Delegate to the underlying layer's method
  return layer.does_tile_fit(tile, position, rotation)

## Places a tile at the specified grid coordinates.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — the x-coordinate on the grid.[br]
## [code]y[/code] : [int] — the y-coordinate on the grid.[br]
## [code]tile_vm[/code] : [SceneTileViewModel] — the tile view model to place.[br]
## [b]Returns:[/b] [void][br]
func set_tile_at(
    x: int,
    y: int,
    tile_vm: SceneTileViewModel
) -> void:  
  layer.set_tile_at(x, y, tile_vm)

## Removes a tile from the specified grid coordinates.[br]
## [b]Parameters:[/b][br]
## [code]x[/code] : [int] — the x-coordinate on the grid.[br]
## [code]y[/code] : [int] — the y-coordinate on the grid.[br]
## [b]Returns:[/b] [void][br]
func remove_tile_at(x: int, y: int) -> void:
  layer.remove_tile_at(x, y)