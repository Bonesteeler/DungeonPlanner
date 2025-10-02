class_name SceneBrowser
extends VBoxContainer

signal request_scene_list(startIdx: int)
signal scene_import(scene: Scene)

const SCENE_BROWSER_ITEM_SCENE = preload("res://main_menu/SceneBrowserItem.tscn")

var page_size: int = 0
var start_idx: int = 0
var total_scenes: int = 0

@onready var scene_list_container: VBoxContainer = $%SceneListContainer

func _ready() -> void:
  # Example: Request the first page of scenes
  request_scene_list.emit(start_idx)

func set_scene_items(scenes: SceneListResponse) -> void:
  page_size = scenes.page_size
  total_scenes = scenes.scene_count
  # Clear existing items
  for child in scene_list_container.get_children():
    child.queue_free()
  for scene: Scene in scenes.scenes:
    var item = SCENE_BROWSER_ITEM_SCENE.instantiate()
    item.set_scene(scene)
    scene_list_container.add_child(item)
    item.on_pressed.connect(_on_scene_browser_item_pressed)

func _on_prev_button_pressed() -> void:
  start_idx -= page_size
  if start_idx < 0:
    start_idx = total_scenes - (total_scenes % page_size)
  request_scene_list.emit(start_idx)

func _on_next_button_pressed() -> void:
  start_idx += page_size
  if start_idx >= total_scenes:
    start_idx = 0
  request_scene_list.emit(start_idx)

func _on_scene_browser_item_pressed(scene: Scene) -> void:
    scene_import.emit(scene)
