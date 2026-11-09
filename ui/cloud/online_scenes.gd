class_name OnlineScenesPanel
extends VBoxContainer
## OnlineScenesPanel
##
## [i]Displays a paginated list of scenes available on the server for download.[/i][br]
## [b]Signals:[/b][br]
## - [code]request_scene_list(startIdx: int)[/code]: Emitted to fetch a page of scenes.[br]
## - [code]scene_import(scene: Scene)[/code]: Emitted when the user selects a scene to download.[br]

signal request_scene_list(startIdx: int)
signal scene_import(scene: Scene)

const SCENE_BROWSER_ITEM_SCENE = preload("res://main_menu/SceneBrowserItem.tscn")

var page_size: int = 0
var start_idx: int = 0
var total_scenes: int = 0

@onready var scene_list_container: VBoxContainer = $%SceneListContainer

func _ready() -> void:
	request_scene_list.emit(start_idx)

## Populate the list with scenes from a server response.[br]
## [b]Parameters:[/b][br]
## [code]response[/code] : [SceneListResponse] — paginated response from the backend.[br]
func set_scene_items(response: SceneListResponse) -> void:
	page_size = response.page_size
	total_scenes = response.scene_count
	for child in scene_list_container.get_children():
		child.queue_free()
	for scene: Scene in response.scenes:
		var item = SCENE_BROWSER_ITEM_SCENE.instantiate()
		item.set_scene(scene)
		scene_list_container.add_child(item)
		item.on_pressed.connect(_on_item_pressed)

func _on_item_pressed(scene: Scene) -> void:
	scene_import.emit(scene)

func _on_prev_button_pressed() -> void:
	start_idx -= page_size
	if start_idx < 0:
		start_idx = 0
	request_scene_list.emit(start_idx)

func _on_next_button_pressed() -> void:
	start_idx += page_size
	if total_scenes > 0 and start_idx >= total_scenes:
		start_idx = total_scenes - (total_scenes % page_size if total_scenes % page_size != 0 else page_size)
	request_scene_list.emit(start_idx)
