class_name SceneItem
extends HBoxContainer

signal scene_selected(String)

var scene_id: String
var scene_name: String

func set_id(new_id: String) -> void:
    scene_id = new_id

func set_scene_name(new_name: String) -> void:
    scene_name = new_name
    $Label.text = new_name

func forward_scene_selected():
    scene_selected.emit(scene_id)