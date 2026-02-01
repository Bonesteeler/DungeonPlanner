class_name MainMenu
extends PanelContainer
## MainMenu
##
## [i]Main menu UI for managing scene files, including creating new scenes, loading recent scenes, and importing/exporting scene data.[/i][br]
## [b]Signals:[/b][br]
## - [code]scene_selected(vm: SceneBuilderViewModel)[/code]: Emitted when a scene is selected to be loaded into the editor.[br]

const DELETE_CONFIRMATION_STRING_TEMPLATE = "Are you sure you want to delete %s?"
const PLANNING_SCENE_PATH = "res://tab_bar/tab_bar_container.tscn"
const RECENT_SCENE_ITEM_SCENE = preload("res://main_menu/RecentSceneItem.tscn")
const UPLOAD_SUCCESS_STRING_TEMPLATE = "Successfully uploaded scene: %s"
const UPLOAD_FAILURE_STRING_TEMPLATE = "Failed to upload scene: %s"

signal scene_selected(vm: SceneBuilderViewModel)

var confirmation_dialog_target: String
var export_scene_name: String = ""
var save_manager: SaveManager

@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var recent_scenes_container: VBoxContainer = $%RecentScenes
@onready var scene_browser: SceneBrowser = $%SceneBrowser
@onready var scene_import_dialog: FileDialog = $%SceneImportDialog
@onready var server_connection: ServerConnection = $%ServerConnection

## Initialize the save manager and connect signals for scene management[br]
## [b]Returns:[/b] [void][br]
func _ready():
  save_manager = SaveManager.new()
  scene_browser.scene_import.connect(save_manager.add_scene)
  save_manager.scene_added.connect(update_recent_scenes)
  update_recent_scenes()

## Refresh the list of recent scenes displayed in the UI[br]
## [b]Returns:[/b] [void][br]
func update_recent_scenes():
  #Delete existing scenes
  for child in recent_scenes_container.get_children():
    child.queue_free()
  var recent_scenes = save_manager.scenes
  for scene in recent_scenes:
    var button = RECENT_SCENE_ITEM_SCENE.instantiate()
    button.set_recent_scene_data(scene)
    button.delete_pressed.connect(delete_recent_scene.bind(scene.scene_name))
    button.select_pressed.connect(load_recent_scene.bind(scene.scene_name))
    button.upload_pressed.connect(upload_scene.bind(scene.scene_name))
    recent_scenes_container.add_child(button)

## Callback for when a scene import is completed[br]
## [b]Returns:[/b] [void][br]
func on_set_imported():
  update_recent_scenes()

## Load a recent scene by name and emit the scene_selected signal[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene to load from saved data.[br]
## [b]Emits:[/b][br]
## - [code]scene_selected(vm: SceneBuilderViewModel)[/code] when the scene is successfully loaded[br]
## [b]Returns:[/b] [void][br]
func load_recent_scene(scene_name: String):
  var scene_data = save_manager.load_scene_from_user(scene_name)
  var scene_view_model = SceneBuilderViewModel.new(scene_data)
  scene_selected.emit(scene_view_model)

## Upload a saved scene to the server[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene to upload.[br]
## [b]Returns:[/b] [void][br]
func upload_scene(scene_name: String):
  var scene_to_upload := save_manager.load_scene_from_user(scene_name)
  server_connection.upload_scene(scene_to_upload)

## Display a success message after a scene is uploaded[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the successfully uploaded scene.[br]
## [b]Returns:[/b] [void][br]
func on_upload_success(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.dialog_text = UPLOAD_SUCCESS_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()
  for recent_scene_node in recent_scenes_container.get_children():
    if recent_scene_node.is_scene(scene_name):
      recent_scene_node.disable_upload()

## Display a failure message when a scene upload fails[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene that failed to upload.[br]
## [b]Returns:[/b] [void][br]
func on_upload_failure(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.dialog_text = UPLOAD_FAILURE_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()

## Show a confirmation dialog before deleting an imported tile set[br]
## [b]Parameters:[/b][br]
## [code]removed_set_name[/code] : [String] — name of the tile set to delete.[br]
## [b]Returns:[/b] [void][br]
func delete_imported_set(removed_set_name: String):
  confirmation_dialog_target = removed_set_name
  confirmation_dialog.confirmed.connect(delete_set_confirmed)
  confirmation_dialog.dialog_text = DELETE_CONFIRMATION_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()

## Callback for confirmed tile set deletion[br]
## [b]Returns:[/b] [void][br]
func delete_set_confirmed():
  confirmation_dialog.confirmed.disconnect(delete_set_confirmed)
  TileSets.remove_set(confirmation_dialog_target)
  update_recent_scenes()

## Show a confirmation dialog before deleting a recent scene[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene to delete.[br]
## [b]Returns:[/b] [void][br]
func delete_recent_scene(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.confirmed.connect(delete_scene_confirmed)
  confirmation_dialog.dialog_text = DELETE_CONFIRMATION_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()

## Callback for confirmed scene deletion[br]
## [b]Returns:[/b] [void][br]
func delete_scene_confirmed():
  confirmation_dialog.confirmed.disconnect(delete_scene_confirmed)
  save_manager.delete_scene(confirmation_dialog_target)
  update_recent_scenes()

## Create and select a new empty scene[br]
## [b]Emits:[/b][br]
## - [code]scene_selected(vm: SceneBuilderViewModel)[/code] with a new empty view model[br]
## [b]Returns:[/b] [void][br]
func on_new_scene():
  var scene_view_model = SceneBuilderViewModel.new()
  scene_selected.emit(scene_view_model)

## Change the current scene to the planning scene[br]
## [b]Returns:[/b] [void][br]
func change_to_planning_scene():
  # Can't preload planning_scene because it causes circular dependencies
  var planning_scene = load(PLANNING_SCENE_PATH)
  var error = get_tree().change_scene_to_packed(planning_scene)
  if error != OK:
    print("Error loading planning scene: ", error_string(error))

## Show the file dialog for importing a scene from JSON[br]
## [b]Returns:[/b] [void][br]
func _on_import_scene_pressed() -> void:
  scene_import_dialog.popup_centered()

## Load and save an imported scene, then switch to the planning scene[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — filesystem path to the JSON scene file.[br]
## [b]Returns:[/b] [void][br]
func _on_scene_import_dialog_file_selected(path: String) -> void:
  var scene_data = save_manager.load_scene_from_json(path)
  save_manager.save_scene_to_user(scene_data)
  change_to_planning_scene()
