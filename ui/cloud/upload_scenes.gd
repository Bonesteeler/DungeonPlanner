class_name UploadScenesPanel
extends VBoxContainer
## UploadScenesPanel
##
## [i]Displays a list of locally saved scenes with an option to upload each to the server.[/i][br]
## [b]Signals:[/b][br]
## - [code]upload_requested(scene_id: String)[/code]: Emitted when the user requests uploading a scene.[br]

signal upload_requested(scene_id: String)

const RECENT_SCENE_ITEM_SCENE = preload("res://main_menu/RecentSceneItem.tscn")

@onready var upload_list_container: VBoxContainer = $%UploadListContainer

## Populate the upload list with local scenes.[br]
## [b]Parameters:[/b][br]
## [code]scenes[/code] : [Array[Scene]] — list of locally saved scenes.[br]
func set_scenes(scenes: Array[Scene]) -> void:
	for child in upload_list_container.get_children():
		child.queue_free()
	for scene in scenes:
		var item = RECENT_SCENE_ITEM_SCENE.instantiate()
		item.set_recent_scene_data(scene)
		upload_list_container.add_child(item)
		item.upload_pressed.connect(func(): upload_requested.emit(scene.id))
