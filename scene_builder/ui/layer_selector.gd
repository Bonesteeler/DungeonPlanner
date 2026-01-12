extends VBoxContainer

const TILE_LAYER_BUTTON_SCENE = preload("res://scene_builder/ui/TileLayerButton.tscn")

var view_model: LayerSelectorViewModel

@onready var layers_container: VBoxContainer = $%Layers

func set_vm(vm: LayerSelectorViewModel) -> void:
  view_model = vm
  view_model.layers_updated.connect(_on_layers_changed)
  _on_layers_changed()

func _on_layers_changed() -> void:
  for i in range(layers_container.get_child_count() - 1, -1, -1):
    layers_container.get_child(i).queue_free()
  for layer_vm in view_model.layers:
    var layer_button = TILE_LAYER_BUTTON_SCENE.instantiate()
    layer_button.set_vm(layer_vm)
    layers_container.add_child(layer_button)