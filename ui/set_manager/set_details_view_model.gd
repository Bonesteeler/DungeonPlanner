class_name SetDetailsViewModel
extends RefCounted

signal current_set_changed(String)

var current_set: String = ""

func set_current_set(new_set_name: String) -> void:
  current_set = new_set_name
  current_set_changed.emit(new_set_name)

func get_current_set_name() -> String:
  return current_set
