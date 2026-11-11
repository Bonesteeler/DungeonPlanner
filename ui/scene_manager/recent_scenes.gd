class_name RecentScenes
extends VBoxContainer

const SCENE_ITEM_SCENE = preload("res://ui/scene_manager/scene_item.tscn")

var view_model: SceneManagerViewModel

@onready var recent_scenes_container: HFlowContainer = $%RecentScenesContainer

signal delete_scene_requested(scene_id: String)
signal scene_selected(scene_id: String)
signal upload_scene(scene_id: String)
signal export_scene(scene_id: String)
signal show_error(scene_name: String, missing_tile_ids: Array)

## Set vm which provides data for this view
func set_vm(vm: SceneManagerViewModel):
    view_model = vm
    view_model.recent_scenes_updated.connect(set_scene_list)
    set_scene_list()

## Update the scene list from the view model[br]
func set_scene_list():
    # Clear existing items
    for child in recent_scenes_container.get_children():
        child.queue_free()

    # Add new items
    var scenes = view_model.get_recent_scenes()
    for scene in scenes:
        var item = SCENE_ITEM_SCENE.instantiate()
        item.upload_enabled = false
        item.set_id(scene.id)
        item.set_scene_name(scene.scene_name)
        item.set_subtext(view_model.get_tiles_status_text(scene))
        item.set_missing_tile_ids(view_model.get_missing_tile_ids(scene))
        item.scene_selected.connect(_on_scene_item_selected)
        item.delete_pressed.connect(_on_scene_item_delete)
        item.error_pressed.connect(_on_scene_item_error)
        item.upload_pressed.connect(_on_scene_item_upload)
        item.export_pressed.connect(_on_scene_item_export)
        recent_scenes_container.add_child(item)

## Find scene from view model by ID and emit scene_selected signal[br]
## [b]Parameters:[/b][br]
## - [code]scene_id[/code] : [String] — ID of the selected scene.[br]
func _on_scene_item_selected(scene_id: String):
    if scene_id != "":
        scene_selected.emit(scene_id)

## Find scene from view model by ID and emit delete_scene_requested signal[br]
## [b]Parameters:[/b][br]
## - [code]scene_id[/code] : [String] — ID of the scene to delete.[br]
func _on_scene_item_delete(scene_id: String):
    if scene_id != "":
        delete_scene_requested.emit(scene_id)

## Emit upload_pressed signal[br]
## [b]Parameters:[/b][br]
## - [code]scene_id[/code] : [String] — ID of the scene to upload.[br]
func _on_scene_item_upload(scene_id: String):
    if scene_id != "":
        upload_scene.emit(scene_id)

## Emit export_pressed signal[br]
## [b]Parameters:[/b][br]
## - [code]scene_id[/code] : [String] — ID of the scene to export.[br]
func _on_scene_item_export(scene_id: String):
    if scene_id != "":
        export_scene.emit(scene_id)

## Forward error from a scene item[br]
## [b]Parameters:[/b][br]
## - [code]scene_name[/code] : [String] — name of the scene with missing tiles.[br]
## - [code]missing_tile_ids[/code] : [Array] — tile ids referenced by the scene that are not imported.[br]
func _on_scene_item_error(scene_name: String, missing_tile_ids: Array):
    show_error.emit(scene_name, missing_tile_ids)