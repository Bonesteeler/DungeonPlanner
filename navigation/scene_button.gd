class_name SceneButton
extends Button

signal scene_selected(String)

var scene_name: String = ""

func set_scene_name(new_name: String) -> void:
  scene_name = new_name
  text = new_name

func _on_button_pressed():
  scene_selected.emit(scene_name)