class_name SetDetailsViewModel
extends RefCounted
## SetDetailsViewModel
##
## [i]View model managing the currently selected tile set and its details.[/i][br]
## [b]Properties:[/b][br]
## - [b]current_set[/b]: [DragonbiteTileSet] the currently selected tile set.[br]
## [b]Signals:[/b][br]
## - [code]current_set_changed()[/code]: Emitted when the selected set changes.[br]

signal current_set_changed()

var current_set: DragonbiteTileSet = null

## Set the currently selected tile set[br]
## [b]Parameters:[/b][br]
## [code]new_set[/code] : [DragonbiteTileSet] — tile set to display.[br]
## [b]Emits:[/b][br]
## - [code]current_set_changed()[/code][br]
func set_current_set(new_set: DragonbiteTileSet) -> void:
  current_set = new_set
  current_set_changed.emit()

## Get the name of the current tile set[br]
## [b]Returns:[/b] [String] — name of current set, or empty string if none selected[br]
func get_current_set_name() -> String:
  if current_set == null:
    return ""
  return current_set.name

## Get the array of tiles from the current set[br]
## [b]Returns:[/b] [Array] — array of tiles, or empty array if none selected[br]
func get_current_set_tiles() -> Array:
  if current_set == null:
    return []
  return current_set.tiles