class_name SceneItem
extends HBoxContainer

signal delete_pressed(scene_name: String)
signal scene_selected(scene_id: String)
signal upload_pressed(scene_id: String)

@export var select_enabled: bool = true:
    set(value):
        select_enabled = value
        if is_node_ready():
            $Select.visible = value
@export var delete_enabled: bool = true:
    set(value):
        delete_enabled = value
        if is_node_ready():
            $Delete.visible = value
@export var upload_enabled: bool = true:
    set(value):
        upload_enabled = value
        if is_node_ready():
            $Upload.visible = value

var scene_id: String
var scene_name: String

func _ready() -> void:
    $Select.visible = select_enabled
    $Delete.visible = delete_enabled
    $Upload.visible = upload_enabled

func set_id(new_id: String) -> void:
    scene_id = new_id

func set_scene_name(new_name: String) -> void:
    scene_name = new_name
    $Label.text = new_name

func forward_scene_selected():
    scene_selected.emit(scene_id)

func forward_delete_pressed() -> void:
    delete_pressed.emit(scene_name)

func forward_upload_pressed() -> void:
    upload_pressed.emit(scene_id)