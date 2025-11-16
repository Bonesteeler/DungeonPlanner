class_name SetDetails
extends VBoxContainer

signal tile_selected(tile)

var item_scene: PackedScene = preload("res://ui/set_manager/set_details_item.tscn")
var view_model: SetDetailsViewModel

@onready var set_details_container = $%SetDetailsContainer
@onready var tile_label = $%Title

func _ready():
  resized.connect(_on_resized)

func set_vm(vm: SetDetailsViewModel) -> void:
  view_model = vm
  view_model.current_set_changed.connect(update_set)
  update_set()

func update_set() -> void:
  for i in range(set_details_container.get_child_count() - 1, -1, -1):
    set_details_container.get_child(i).queue_free()
  for tile in view_model.get_current_set_tiles():
    var item = item_scene.instantiate()
    item.selected.connect(forward_tile_selected)
    set_details_container.add_child(item)
    var vm = SetDetailsItemViewModel.new()
    vm.set_tile(tile)
    item.set_vm(vm)
  tile_label.text = view_model.get_current_set_name()

func _on_resized() -> void:
  var item_size = item_scene.instantiate().get_size()
  var seperation = get_theme_constant("h_separation")
  var columns = max(1, (self.get_size().x + seperation) / (item_size.x + seperation))
  set_details_container.columns = columns

func forward_tile_selected(tile: Tile):
  tile_selected.emit(tile)