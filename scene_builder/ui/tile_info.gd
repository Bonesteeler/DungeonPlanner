extends VBoxContainer
## TileInfo
##
## [i]A UI container that displays information about a selected tile and allows copying it.[/i][br]
## [b]Signals:[/b][br]
## - [code]copy_tile(selected: Tile)[/code]: Emitted when the user requests to copy the selected tile.[br]

signal copy_tile(selected: Tile)

const NAME_TEMPLATE: String = "Name: %s"
const SET_TEMPLATE: String = "Set: %s"

var selected_tile: Tile

@onready var tile_name_label = $%Name
@onready var tile_set_label = $%Set

## Update the displayed tile information with the given tile and tileset name.[br]
## [b]Parameters:[/b][br]
## [code]tileset_name[/code] : [String] — the name of the tile set containing the tile.[br]
## [code]tile[/code] : [Tile] — the tile to display information for.[br]
func set_state(tileset_name: String, tile: Tile):
  selected_tile = tile
  tile_name_label.text = NAME_TEMPLATE % selected_tile.name
  tile_set_label.text = SET_TEMPLATE % tileset_name

## Emit the copy_tile signal with the currently selected tile if one exists.[br]
## [b]Emits:[/b][br]
## - [code]copy_tile(selected_tile: Tile)[/code] if a tile is selected[br]
func forward_copy_tile():
  if selected_tile == null:
    return
  copy_tile.emit(selected_tile)
