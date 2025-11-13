class_name SetList
extends VBoxContainer

const SET_LIST_ITEM_SCENE = preload("res://ui/set_manager/set_list_item.tscn")

signal delete_set(String)
signal import_set()
signal select_set(String)

var viewModel: SetListViewModel

@onready var set_list_container: VBoxContainer = $%SetListContainer

func set_vm(vm: SetListViewModel) -> void:
    viewModel = vm
    update_items()
    viewModel.sets_changed.connect(update_items)

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

func forward_delete_pressed(tile_set_name: String) -> void:
    delete_set.emit(tile_set_name)

func forward_import_pressed() -> void:
    import_set.emit()

func forward_select_pressed(tile_set_name: String) -> void:
    select_set.emit(tile_set_name)