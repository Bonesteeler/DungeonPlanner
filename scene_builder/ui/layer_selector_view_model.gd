class_name LayerSelectorViewModel
extends RefCounted
## LayerSelectorViewModel
##
## [i]ViewModel for managing the selection of layers within the scene builder UI.[/i][br]

signal layer_added(layer: TileLayerViewModel)
signal layer_selected(layer: TileLayer)
signal layers_updated()

var layers: Array = []
var selected_layer_index: int = 0

func set_layer_vms(new_layer_vms: Array):
  for layer_vm in new_layer_vms:
    layer_vm.layer.id = layers.size()
    layer_vm.layer_updated.connect(_forward_layer_updated)
    layer_vm.layer_selected.connect(select_layer_with_id)
    layer_vm.delete_requested.connect(delete_layer)
    layers.append(layer_vm)
  selected_layer_index = 0
  layers_updated.emit() 

func add_tile_layer():
  var new_layer = TileLayerViewModel.new()
  new_layer.layer.id = layers.size()
  new_layer.layer_updated.connect(_forward_layer_updated)
  new_layer.layer_selected.connect(select_layer_with_id)
  new_layer.delete_requested.connect(delete_layer)
  layers.append(new_layer)
  layer_added.emit(new_layer) 
  layers_updated.emit()

func delete_layer(layer_id: int):
  for i in range(layers.size()):
    if layers[i].layer.id == layer_id:
      layers.remove_at(i)
      break
  layers_updated.emit()

func get_layers_sorted_by_height() -> Array:
  var sorted_layers = layers.duplicate()
  sorted_layers.sort_custom(_compare_layer_height)
  return sorted_layers

func _compare_layer_height(a: TileLayerViewModel, b: TileLayerViewModel) -> bool:
  return a.layer.height > b.layer.height

func select_layer_with_id(id: int):
  var selected_layer: TileLayerViewModel
  for layer in layers:
    if layer.layer.id == id:
      selected_layer_index = id
      selected_layer = layer
      layer.set_selected(true)
    else:
      layer.set_selected(false)
  layer_selected.emit(selected_layer)
  
func update_layer_height(layer_id: int, new_height: float):
  var layer = _get_layer_at_index(layer_id)
  if layer != null:
    layer.set_height(new_height)
    layers_updated.emit()

func update_layer_visibility(layer_id: int, is_visible: bool):
  var layer = _get_layer_at_index(layer_id)
  if layer != null:
    layer.set_visible(is_visible)
    layers_updated.emit()

func _get_layer_at_index(index: int) -> TileLayerViewModel:
  for layer in layers:
    if layer.layer.id == index:
      return layer
  return null

func _forward_layer_updated():
  layers_updated.emit()
