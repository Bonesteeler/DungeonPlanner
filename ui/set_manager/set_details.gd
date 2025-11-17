class_name SetDetails
extends VBoxContainer
 ## SetDetails
##
## [i]UI component displaying all tiles in the currently selected tile set.[/i][br]
## [b]Properties:[/b][br]
## - [b]view_model[/b]: [SetDetailsViewModel] view model managing set data.[br]
## - [b]set_details_container[/b]: Container for tile item grid.[br]
## - [b]tile_label[/b]: Label displaying set name.[br]
## [b]Signals:[/b][br]
## - [code]tile_selected(tile)[/code]: Emitted when a tile is selected.[br]

signal tile_selected(tile)

var item_scene: PackedScene = preload("res://ui/set_manager/set_details_item.tscn")
var view_model: SetDetailsViewModel

@onready var set_details_container = $%SetDetailsContainer
@onready var tile_label = $%Title

## Initialize and connect resize signal[br]
func _ready():
  resized.connect(_on_resized)

## Set the view model and initialize container[br]
## [b]Parameters:[/b][br]
## [code]vm[/code] : [SetDetailsViewModel] — view model to bind.[br]
func set_vm(vm: SetDetailsViewModel) -> void:
  view_model = vm
  view_model.current_set_changed.connect(update_set)
  update_set()

## Rebuild the tile grid contents with current set's tiles[br]
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

## Handle resize by recalculating grid columns[br]
func _on_resized() -> void:
  var item_size = item_scene.instantiate().get_size()
  var seperation = get_theme_constant("h_separation")
  var columns = max(1, (self.get_size().x + seperation) / (item_size.x + seperation))
  set_details_container.columns = columns

## Forward tile selection signal from child items[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — selected tile.[br]
## [b]Emits:[/b][br]
## - [code]tile_selected(tile)[/code][br]
func forward_tile_selected(tile: Tile):
  tile_selected.emit(tile)