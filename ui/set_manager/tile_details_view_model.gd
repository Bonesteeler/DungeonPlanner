class_name TileDetailsViewModel
extends RefCounted
## TileDetailsViewModel
##
## [i]View model for displaying detailed information about a single tile.[/i][br]
## [b]Properties:[/b][br]
## - [b]tile[/b]: [Tile] the currently displayed tile.[br]
## [b]Signals:[/b][br]
## - [code]tile_changed()[/code]: Emitted when the displayed tile is updated.[br]
## [b]Constants:[/b][br]
## - [code]LENGTH_TEMPLATE[/code]: Format string for length display.[br]
## - [code]WIDTH_TEMPLATE[/code]: Format string for width display.[br]

signal tile_changed()

const LENGTH_TEMPLATE = "Length: %d"
const WIDTH_TEMPLATE = "Width: %d"

var tile: Tile

## Update the displayed tile[br]
## [b]Parameters:[/b][br]
## [code]new_tile[/code] : [Tile] — tile to display.[br]
## [b]Emits:[/b][br]
## - [code]tile_changed()[/code][br]
func update_tile(new_tile: Tile) -> void:
  tile = new_tile
  tile_changed.emit()

## Get formatted height text for display[br]
## [b]Returns:[/b] [String] — formatted height string with tile length in 2-inch increments[br]
func get_height_text() -> String:
  return LENGTH_TEMPLATE % (tile.y_size * 2)

## Get formatted width text for display[br]
## [b]Returns:[/b] [String] — formatted width string with tile width in 2-inch increments[br]
func get_width_text() -> String:
  return WIDTH_TEMPLATE % (tile.x_size * 2)