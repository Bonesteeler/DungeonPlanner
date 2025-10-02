extends VBoxContainer

signal delete_pressed
signal select_pressed
signal upload_pressed

const MISSING_TILES_STRING = "Missing Tiles"
const READY_STRING = "Ready"

var scene: Scene
var tile_resources: TileResources

@onready var name_label: Label = $%Name
@onready var select_button: Button = $%Select
@onready var status_label: Label = $%Status
@onready var upload_button: Button = $%Upload

func _ready() -> void:
  if scene != null and tile_resources != null:
    update_nodes()

func is_scene(scene_name: String) -> bool:
  return scene.scene_name == scene_name

func set_recent_scene_data(new_scene: Scene, new_tile_resources: TileResources):
  scene = new_scene
  tile_resources = new_tile_resources
  update_nodes()

func update_nodes():
  if name_label != null:
    name_label.text = scene.scene_name
  if status_label != null and select_button != null:
    var has_tiles = tile_resources.has_tile_ids(scene.data.get_unique_tile_ids())
    if has_tiles:
      status_label.text = READY_STRING
      status_label.add_theme_color_override("font_color", Color.WHITE)
      select_button.disabled = false
    else:
      status_label.text = MISSING_TILES_STRING
      status_label.add_theme_color_override("font_color", Color.RED)
      select_button.disabled = true

func disable_upload():
  upload_button.disabled = true

func forward_delete_pressed():
  delete_pressed.emit()

func forward_upload_pressed():
  upload_pressed.emit()

func forward_select_pressed():
  select_pressed.emit()
