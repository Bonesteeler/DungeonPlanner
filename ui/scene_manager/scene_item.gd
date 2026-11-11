class_name SceneItem
extends MarginContainer

signal delete_pressed(scene_name: String)
signal scene_selected(scene_id: String)
signal upload_pressed(scene_id: String)
signal error_pressed(scene_name: String, missing_tile_ids: Array)

@export var select_enabled: bool = true:
    set(value):
        select_enabled = value
        if is_node_ready():
            %Select.visible = value
@export var delete_enabled: bool = true:
    set(value):
        delete_enabled = value
        if is_node_ready():
            %Delete.visible = value
@export var upload_enabled: bool = true:
    set(value):
        upload_enabled = value
        if is_node_ready():
            %Upload.visible = value

var scene_id: String
var scene_name: String
var missing_tile_ids: Array[String] = []

func _ready() -> void:
    %Select.visible = select_enabled and missing_tile_ids.is_empty()
    %Delete.visible = delete_enabled
    %Upload.visible = upload_enabled
    %Error.visible = not missing_tile_ids.is_empty()

func set_id(new_id: String) -> void:
    scene_id = new_id

func set_scene_name(new_name: String) -> void:
    scene_name = new_name
    %Label.text = new_name

func set_subtext(text: String) -> void:
    %Subtext.text = text
    %Subtext.visible = true

## Store the tiles missing from this scene and swap the Select button for the Error button when any are missing.[br]
## [b]Parameters:[/b][br]
## [code]ids[/code] : [Array[String]] — tile ids referenced by the scene that are not imported.[br]
func set_missing_tile_ids(ids: Array[String]) -> void:
    missing_tile_ids = ids
    if is_node_ready():
        %Select.visible = select_enabled and ids.is_empty()
        %Error.visible = not ids.is_empty()

func forward_scene_selected():
    scene_selected.emit(scene_id)

func forward_delete_pressed() -> void:
    delete_pressed.emit(scene_name)

func forward_upload_pressed() -> void:
    upload_pressed.emit(scene_id)

func forward_error_pressed() -> void:
    error_pressed.emit(scene_name, missing_tile_ids)