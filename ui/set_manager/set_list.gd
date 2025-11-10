class_name SetList
extends VBoxContainer

const SET_LIST_ITEM_SCENE = preload("res://ui/set_manager/set_list_item.tscn")

var viewModel: SetListViewModel

@onready var set_list_container: VBoxContainer = $%SetListContainer

func _ready() -> void:
    viewModel = SetListViewModel.new(TileSets)
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