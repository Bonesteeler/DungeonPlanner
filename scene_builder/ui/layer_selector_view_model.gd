class_name LayerSelectorViewModel
extends RefCounted
## LayerSelectorViewModel
##
## [i]ViewModel for managing the selection of layers within the scene builder UI.[/i][br]

signal layer_selected(layer: TileLayer)
signal layers_updated()

var layers: Array = []
var selected_layer_index: int = 0

func set_layers(new_layers: Array):
  for layer in new_layers:
    var vm = TileLayerViewModel.new()
    vm.layer = layer
    layers.append(vm)
  selected_layer_index = 0
  layers_updated.emit() 

func add_new_layer():
  var new_layer = TileLayerViewModel.new()
  new_layer.id = layers.size()
  layers.append(new_layer) 
  layers_updated.emit()

func get_layers_sorted_by_height() -> Array:
  var sorted_layers = layers.duplicate()
  sorted_layers.sort_custom(_compare_layer_height)
  return sorted_layers

func _compare_layer_height(a: TileLayer, b: TileLayer) -> bool:
  return a.height > b.height

func select_layer_at_index(index: int):
  for layer in layers:
    if layer.id == index:
      selected_layer_index = index
      layer_selected.emit(layer)
      return

func update_layer_height(layer_id: int, new_height: float):
  var layer = _get_layer_at_index(layer_id)
  if layer != null:
    layer.height = new_height
    layers_updated.emit()

func update_layer_visibility(layer_id: int, is_visible: bool):
  var layer = _get_layer_at_index(layer_id)
  if layer != null:
    layer.is_visible = is_visible
    layers_updated.emit()

func _get_layer_at_index(index: int) -> TileLayerViewModel:
  for layer in layers:
    if layer.id == index:
      return layer
  return null