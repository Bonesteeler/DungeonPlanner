class_name SetList
extends VBoxContainer
## SetList
##
## [i]UI component displaying a vertical list of tile sets with import and selection controls.[/i][br]
## [b]Properties:[/b][br]
## - [b]viewModel[/b]: [SetListViewModel] view model managing set list data.[br]
## - [b]set_list_container[/b]: [VBoxContainer] container for set list items.[br]
## [b]Signals:[/b][br]
## - [code]delete_set(String)[/code]: Emitted when a set is deleted.[br]
## - [code]import_set()[/code]: Emitted when import is requested.[br]
## - [code]select_set(String)[/code]: Emitted when a set is selected.[br]

const SET_LIST_ITEM_SCENE = preload("res://ui/set_manager/set_list_item.tscn")

signal delete_set(String)
signal import_set()
signal select_set(String)

var viewModel: SetListViewModel

@onready var set_list_container: VBoxContainer = $%SetListContainer

## Set the view model and initialize the list display[br]
## [b]Parameters:[/b][br]
## [code]vm[/code] : [SetListViewModel] — view model to bind.[br]
func set_vm(vm: SetListViewModel) -> void:
    viewModel = vm
    update_items()
    viewModel.sets_changed.connect(update_items)

## Rebuild the list items from view model data[br]
func update_items() -> void:
    # Clear existing items
    for child in set_list_container.get_children():
        child.queue_free()
    
    var sets = viewModel.get_set_list()
    for s in sets:
        var item = SET_LIST_ITEM_SCENE.instantiate()
        item.set_text(s)
        set_list_container.add_child(item)
        item.delete_pressed.connect(forward_delete_pressed)
        item.select_pressed.connect(forward_select_pressed)

## Forward delete signal from list item[br]
## [b]Parameters:[/b][br]
## [code]tile_set_name[/code] : [String] — name of set to delete.[br]
## [b]Emits:[/b][br]
## - [code]delete_set(tile_set_name)[/code][br]
func forward_delete_pressed(tile_set_name: String) -> void:
    delete_set.emit(tile_set_name)

## Forward import button press[br]
## [b]Emits:[/b][br]
## - [code]import_set()[/code][br]
func forward_import_pressed() -> void:
    import_set.emit()

## Forward select signal from list item[br]
## [b]Parameters:[/b][br]
## [code]tile_set_name[/code] : [String] — name of set to select.[br]
## [b]Emits:[/b][br]
## - [code]select_set(tile_set_name)[/code][br]
func forward_select_pressed(tile_set_name: String) -> void:
    select_set.emit(tile_set_name)