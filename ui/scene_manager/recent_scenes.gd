class_name RecentScenes
extends VBoxContainer

const SCENE_ITEM_SCENE = preload("res://ui/scene_manager/scene_item.tscn")

var view_model: SceneManagerViewModel

@onready var recent_scenes_container: VBoxContainer = $%RecentScenesContainer

signal delete_scene_requested(scene_id: String)
signal scene_selected(scene_id: String)

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
        item.set_id(scene.id)
        item.set_scene_name(scene.scene_name)
        item.scene_selected.connect(_on_scene_item_selected)
        item.delete_pressed.connect(_on_scene_item_delete)
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