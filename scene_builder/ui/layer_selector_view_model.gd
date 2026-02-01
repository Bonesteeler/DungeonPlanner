class_name LayerSelectorViewModel
extends RefCounted
## LayerSelectorViewModel
##
## [i]View model for managing the selection and organization of tile layers in the scene builder.[/i][br]
## [b]Signals:[/b][br]
## - [code]layer_added(layer: TileLayerViewModel)[/code]: Emitted when a new layer is added to the collection.[br]
## - [code]layer_selected(layer: TileLayerViewModel)[/code]: Emitted when a layer is selected.[br]
## - [code]layers_updated()[/code]: Emitted when the layer collection or properties are modified.[br]

signal layer_added(layer: TileLayerViewModel)
signal layer_selected(layer: TileLayerViewModel)
signal layers_updated()

var layers: Array = []
var selected_layer_index: int = 0

## Initializes the layer collection with an array of layer view models.[br]
## [b]Parameters:[/b][br]
## [code]new_layer_vms[/code] : [Array] — array of TileLayerViewModel instances to add.[br]
## [b]Emits:[/b][br]
## - [code]layers_updated()[/code] after all layers are added and connected.[br]
## [b]Returns:[/b] [void][br]
func set_layer_vms(new_layer_vms: Array):
  for layer_vm in new_layer_vms:
    layer_vm.layer.id = layers.size()
    layer_vm.layer_updated.connect(_forward_layer_updated)
    layer_vm.layer_selected.connect(select_layer_with_id)
    layer_vm.delete_requested.connect(delete_layer)
    layers.append(layer_vm)
  selected_layer_index = 0
  layers_updated.emit() 

## Creates and adds a new tile layer to the collection.[br]
## [b]Emits:[/b][br]
## - [code]layer_added(new_layer)[/code] after the layer is created and connected.[br]
## - [code]layers_updated()[/code] after the layer is added to the collection.[br]
## [b]Returns:[/b] [void][br]
func add_tile_layer():
  var new_layer = TileLayerViewModel.new()
  new_layer.layer.id = layers.size()
  new_layer.layer_updated.connect(_forward_layer_updated)
  new_layer.layer_selected.connect(select_layer_with_id)
  new_layer.delete_requested.connect(delete_layer)
  layers.append(new_layer)
  layer_added.emit(new_layer) 
  layers_updated.emit()

## Removes a layer from the collection by its ID.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — the unique identifier of the layer to delete.[br]
## [b]Emits:[/b][br]
## - [code]layers_updated()[/code] after the layer is removed.[br]
## [b]Returns:[/b] [void][br]
func delete_layer(layer_id: int):
  for i in range(layers.size()):
    if layers[i].layer.id == layer_id:
      layers.remove_at(i)
      break
  layers_updated.emit()

## Returns a copy of the layers array sorted by height in descending order.[br]
## [b]Returns:[/b] [Array][br]
func get_layers_sorted_by_height() -> Array:
  var sorted_layers = layers.duplicate()
  sorted_layers.sort_custom(_compare_layer_height)
  return sorted_layers

## Compares two layers by their height property for sorting.[br]
## [b]Parameters:[/b][br]
## [code]a[/code] : [TileLayerViewModel] — the first layer to compare.[br]
## [code]b[/code] : [TileLayerViewModel] — the second layer to compare.[br]
## [b]Returns:[/b] [bool][br]
func _compare_layer_height(a: TileLayerViewModel, b: TileLayerViewModel) -> bool:
  return a.layer.height > b.layer.height

## Selects a layer by its ID and deselects all other layers.[br]
## [b]Parameters:[/b][br]
## [code]id[/code] : [int] — the unique identifier of the layer to select.[br]
## [b]Emits:[/b][br]
## - [code]layer_selected(selected_layer)[/code] after the layer is selected.[br]
## [b]Returns:[/b] [void][br]
func select_layer_with_id(id: int):
  var selected_layer: TileLayerViewModel
  for layer in layers:
    if layer.layer.id == id:
      selected_layer_index = id
      selected_layer = layer
      layer.set_selected(true)
    else:
      layer.set_selected(false)
  if selected_layer != null:
     layer_selected.emit(selected_layer)
  
## Updates the height of a specific layer.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — the unique identifier of the layer to modify.[br]
## [code]new_height[/code] : [float] — the new height value to assign.[br]
## [b]Emits:[/b][br]
## - [code]layers_updated()[/code] after the height is changed.[br]
## [b]Returns:[/b] [void][br]
func update_layer_height(layer_id: int, new_height: float):
  var layer = _get_layer_at_index(layer_id)
  if layer != null:
    layer.set_height(new_height)
    layers_updated.emit()

## Updates the visibility of a specific layer.[br]
## [b]Parameters:[/b][br]
## [code]layer_id[/code] : [int] — the unique identifier of the layer to modify.[br]
## [code]is_visible[/code] : [bool] — true to show the layer, false to hide it.[br]
## [b]Emits:[/b][br]
## - [code]layers_updated()[/code] after the visibility is changed.[br]
## [b]Returns:[/b] [void][br]
func update_layer_visibility(layer_id: int, is_visible: bool):
  var layer = _get_layer_at_index(layer_id)
  if layer != null:
    layer.set_visible(is_visible)
    layers_updated.emit()

## Finds and returns a layer by its ID.[br]
## [b]Parameters:[/b][br]
## [code]index[/code] : [int] — the unique identifier of the layer to find.[br]
## [b]Returns:[/b] [TileLayerViewModel][br]
func _get_layer_at_index(index: int) -> TileLayerViewModel:
  for layer in layers:
    if layer.layer.id == index:
      return layer
  return null

## Forwards layer_updated signals from child layers to listeners.[br]
## [b]Emits:[/b][br]
## - [code]layers_updated()[/code] when a child layer emits layer_updated.[br]
## [b]Returns:[/b] [void][br]
func _forward_layer_updated():
  layers_updated.emit()