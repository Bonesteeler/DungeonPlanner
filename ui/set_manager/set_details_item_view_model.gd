class_name SetDetailsItemViewModel
extends Node
## SetDetailsItemViewModel
##
## [i]View model for managing the state of a single tile item in the set details view.[/i][br]
## [b]Properties:[/b][br]
## - [b]tile[/b]: [Tile] the tile being displayed.[br]
## [b]Signals:[/b][br]
## - [code]tile_changed()[/code]: Emitted when the tile is updated.[br]

signal tile_changed()

var tile: Tile

## Update the tile and emit change signal if different[br]
## [b]Parameters:[/b][br]
## [code]new_tile[/code] : [Tile] — tile to set.[br]
## [b]Emits:[/b][br]
## - [code]tile_changed()[/code][br]
func set_tile(new_tile: Tile) -> void:
	if tile == new_tile:
		return
	tile = new_tile
	tile_changed.emit()