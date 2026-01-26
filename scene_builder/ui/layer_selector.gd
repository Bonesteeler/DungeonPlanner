extends VBoxContainer

const TILE_LAYER_BUTTON_SCENE = preload("res://scene_builder/ui/TileLayerButton.tscn")

var view_model: LayerSelectorViewModel

@onready var layers_container: VBoxContainer = $%Layers

func set_vm(vm: LayerSelectorViewModel) -> void:
  view_model = vm
  vm.layers_updated.connect(_on_layers_changed)
  _on_layers_changed()

func _on_layers_changed() -> void:
  for i in range(layers_container.get_child_count() - 1, -1, -1):
    layers_container.get_child(i).queue_free()
  for layer_vm in view_model.get_layers_sorted_by_height():
    var layer_button = TILE_LAYER_BUTTON_SCENE.instantiate()
    layer_button.set_vm(layer_vm)
    layers_container.add_child(layer_button)

func _on_add_layer_button_pressed() -> void:
  view_model.add_tile_layer()