class_name TileDetailsViewModel
extends RefCounted

signal tile_changed()

const LENGTH_TEMPLATE = "Length: %d"
const WIDTH_TEMPLATE = "Width: %d"

var tile: Tile

func update_tile(new_tile: Tile) -> void:
  tile = new_tile
  tile_changed.emit()

func get_height_text() -> String:
  return LENGTH_TEMPLATE % (tile.y_size * 2)

func get_width_text() -> String:
  return WIDTH_TEMPLATE % (tile.x_size * 2)