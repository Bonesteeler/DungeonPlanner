class_name  TileLayerViewModel
extends RefCounted

signal delete_requested(layer_id: int)
signal layer_selected(layer_id: int)
signal layer_updated()
signal selected_updated()
signal visibility_changed(layer_id: int)

var layer: TileLayer = TileLayer.new()
var selected: bool = false
var visible: bool = true

func set_height(new_height: float) -> void:
  layer.height = new_height
  layer_updated.emit()

func set_layer(new_layer: TileLayer) -> void:
  layer = new_layer
  layer_updated.emit() 

func set_selected(is_selected: bool) -> void:
  if selected == is_selected:
    return 
  selected = is_selected
  selected_updated.emit()
  if selected:
    layer_selected.emit(layer.id)

func set_visible(is_visible: bool) -> void:
  visible = is_visible
  visibility_changed.emit(layer.id)

func trigger_delete() -> void:
  delete_requested.emit(layer.id)

## Returns the tile that occupies the specified position.[br]
## [b]Parameters:[/b][br]
## [code]position[/code] : [Vector2] — the position to query.[br]
## [b]Returns:[/b] [PlacedTile][br]
func get_origin_tile(position: Vector2) -> PlacedTile:
  return layer.get_origin_tile(position)

func get_height() -> Array:
  return layer.get_height()

func does_tile_fit(
    tile: Tile,
    position: Vector2,
    rotation: Vector3
) -> bool:
  # Delegate to the underlying layer's method
  return layer.does_tile_fit(tile, position, rotation)

func set_tile_at(
    x: int,
    y: int,
    tile_vm: SceneTileViewModel
) -> void:  
  layer.set_tile_at(x, y, tile_vm)