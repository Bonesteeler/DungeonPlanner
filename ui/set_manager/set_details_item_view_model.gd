class_name SetDetailsItemViewModel
extends Node

signal tile_changed()

var tile: Tile

func set_tile(new_tile: Tile) -> void:
	if tile == new_tile:
		return
	tile = new_tile
	tile_changed.emit()