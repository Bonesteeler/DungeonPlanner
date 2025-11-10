class_name SetListViewModel
extends RefCounted
## SetListViewModel
##
## A ViewModel for managing the data and logic of a SetList.

signal sets_changed()

var sets: Array = []
var res: TileResources

func _init(resources: TileResources) -> void:
    res = resources
    sets = res.get_set_names()
    res.tile_sets_changed.connect(update_set_list)
  
func update_set_list() -> void:
    sets = res.get_set_names()
    sets_changed.emit()

func get_set_list() -> Array:
    return sets
