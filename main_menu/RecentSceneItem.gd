extends VBoxContainer
## RecentSceneItem
##
## [i]UI component representing a recent scene entry in the main menu.[/i][br]
## Displays scene information and provides controls for selecting, uploading, and deleting scenes.[br]
## [b]Signals:[/b][br]
## - [code]delete_pressed[/code]: Emitted when the delete button is pressed.[br]
## - [code]select_pressed[/code]: Emitted when the select button is pressed.[br]
## - [code]upload_pressed[/code]: Emitted when the upload button is pressed.[br]

signal delete_pressed
signal select_pressed
signal upload_pressed

const MISSING_TILES_STRING = "Missing Tiles"
const READY_STRING = "Ready"

var scene: Scene

@onready var name_label: Label = $%Name
@onready var select_button: Button = $%Select
@onready var status_label: Label = $%Status
@onready var upload_button: Button = $%Upload

## Initialize the component and update UI nodes if scene data is already set[br]
## [b]Returns:[/b] [void][br]
func _ready() -> void:
  if scene != null:
    update_nodes()

## Check if this item represents a scene with the given name[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — The scene name to compare against.[br]
## [b]Returns:[/b] [bool] — [code]true[/code] if the scene names match, [code]false[/code] otherwise.[br]
func is_scene(scene_name: String) -> bool:
  return scene.scene_name == scene_name

## Set the scene data for this item and update the UI[br]
## [b]Parameters:[/b][br]
## [code]new_scene[/code] : [Scene] — The scene data to assign to this item.[br]
## [b]Returns:[/b] [void][br]
func set_recent_scene_data(new_scene: Scene):
  scene = new_scene
  update_nodes()

## Update UI nodes to reflect current scene data[br]
## Checks for missing tiles and updates status label and button states accordingly.[br]
## [b]Returns:[/b] [void][br]
func update_nodes():
  if name_label != null:
    name_label.text = scene.scene_name
  if status_label != null and select_button != null:
    var has_tiles = TileSets.has_tile_ids(scene.data.get_unique_tile_ids())
    if has_tiles:
      status_label.text = READY_STRING
      status_label.add_theme_color_override("font_color", Color.WHITE)
      select_button.disabled = false
    else:
      status_label.text = MISSING_TILES_STRING
      status_label.add_theme_color_override("font_color", Color.RED)
      select_button.disabled = true

## Disable the upload button[br]
## [b]Returns:[/b] [void][br]
func disable_upload():
  upload_button.disabled = true

## Forward the delete button press event by emitting the delete_pressed signal[br]
## [b]Emits:[/b][br]
## - [code]delete_pressed[/code][br]
## [b]Returns:[/b] [void][br]
func forward_delete_pressed():
  delete_pressed.emit()

## Forward the upload button press event by emitting the upload_pressed signal[br]
## [b]Emits:[/b][br]
## - [code]upload_pressed[/code][br]
## [b]Returns:[/b] [void][br]
func forward_upload_pressed():
  upload_pressed.emit()

## Forward the select button press event by emitting the select_pressed signal[br]
## [b]Emits:[/b][br]
## - [code]select_pressed[/code][br]
## [b]Returns:[/b] [void][br]
func forward_select_pressed():
  select_pressed.emit()
