class_name SetListViewModel
extends RefCounted
## SetListViewModel
##
## [i]A ViewModel for managing the data and logic of a SetList.[/i][br]
## [b]Properties:[/b][br]
## - [b]sets[/b]: [Array] list of tile set names.[br]
## - [b]res[/b]: [TileResources] resource manager for tile sets.[br]
## [b]Signals:[/b][br]
## - [code]sets_changed()[/code]: Emitted when the tile set list changes.[br]

signal sets_changed()

var sets: Array = []
var res: TileResources

## Initialize with tile resources and load initial set list[br]
## [b]Parameters:[/b][br]
## [code]resources[/code] : [TileResources] — tile resource manager.[br]
func _init(resources: TileResources) -> void:
    res = resources
    sets = res.get_set_names()
    res.tile_sets_changed.connect(update_set_list)

## Refresh the set list from resources and emit change signal[br]
## [b]Emits:[/b][br]
## - [code]sets_changed()[/code][br]
func update_set_list() -> void:
    sets = res.get_set_names()
    sets_changed.emit()

## Get the current list of tile set names[br]
## [b]Returns:[/b] [Array] — array of tile set name strings[br]
func get_set_list() -> Array:
    return sets
