class_name TileLayerViewModel
extends RefCounted

signal layer_updated()
signal selected_updated()
signal visibility_changed()

var layer: TileLayer
var selected: bool = false
var visible: bool = true

func set_height(new_height: float) -> void:
  layer.height = new_height
  layer_updated.emit()

func set_layer(new_layer: TileLayer) -> void:
  layer = new_layer
  layer_updated.emit() 

func set_selected(is_selected: bool) -> void:
  selected = is_selected
  selected_updated.emit()

func set_visible(is_visible: bool) -> void:
  visible = is_visible
  visibility_changed.emit()