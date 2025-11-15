class_name SetDetailsViewModel
extends RefCounted

signal current_set_changed()

var current_set: DragonbiteTileSet = null

func set_current_set(new_set: DragonbiteTileSet) -> void:
  current_set = new_set
  current_set_changed.emit()

func get_current_set_name() -> String:
  if current_set == null:
    return ""
  return current_set.name

func get_current_set_tiles() -> Array:
  if current_set == null:
    return []
  return current_set.tiles