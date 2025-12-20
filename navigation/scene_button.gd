class_name SceneButton
extends Button

signal scene_selected(String)

var scene_id: String = ""

func set_scene(new_scene: Scene) -> void:
  scene_id = new_scene.id
  text = new_scene.scene_name

func _on_button_pressed():
  scene_selected.emit(scene_id)