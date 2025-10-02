extends PanelContainer

const DELETE_CONFIRMATION_STRING_TEMPLATE = "Are you sure you want to delete %s?"
const IMPORTED_SET_ITEM_SCENE = preload("res://main_menu/ImportedSetItem.tscn")
const PLANNING_SCENE_PATH = "res://scene_builder/PlannerScene.tscn"
const RECENT_SCENE_ITEM_SCENE = preload("res://main_menu/RecentSceneItem.tscn")
const UPLOAD_SUCCESS_STRING_TEMPLATE = "Successfully uploaded scene: %s"
const UPLOAD_FAILURE_STRING_TEMPLATE = "Failed to upload scene: %s"

var confirmation_dialog_target: String
var export_scene_name: String = ""
var save_manager: SaveManager

@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var imported_sets_container: VBoxContainer = $%ImportedSets
@onready var import_set: MarginContainer = $%ImportTileSetDialog
@onready var recent_scenes_container: VBoxContainer = $%RecentScenes
@onready var scene_browser: SceneBrowser = $%SceneBrowser
@onready var scene_import_dialog: FileDialog = $%SceneImportDialog
@onready var server_connection: ServerConnection = $%ServerConnection

func _ready():
  SceneContext.initialize()
  save_manager = SaveManager.new()
  scene_browser.scene_import.connect(save_manager.add_scene)
  save_manager.scene_added.connect(update_recent_scenes)
  update_recent_scenes()
  update_imported_sets()

func update_recent_scenes():
  #Delete existing scenes
  for child in recent_scenes_container.get_children():
    child.queue_free()
  var recent_scenes = save_manager.scenes
  var tile_resources = SceneContext.tile_resources
  for scene in recent_scenes:
    var button = RECENT_SCENE_ITEM_SCENE.instantiate()
    button.set_recent_scene_data(scene, tile_resources)
    button.delete_pressed.connect(delete_recent_scene.bind(scene.scene_name))
    button.select_pressed.connect(load_recent_scene.bind(scene.scene_name))
    button.upload_pressed.connect(upload_scene.bind(scene.scene_name))
    recent_scenes_container.add_child(button)

func update_imported_sets():
  var imported_sets = SceneContext.get_set_names()
  for child in imported_sets_container.get_children():
    child.queue_free()
  for imported_set in imported_sets:
    var new_item = IMPORTED_SET_ITEM_SCENE.instantiate()
    new_item.set_text(imported_set)
    new_item.delete_pressed.connect(delete_imported_set.bind(imported_set))
    imported_sets_container.add_child(new_item)

func import_set_pressed():
  import_set.initialize()

func on_set_imported():
  update_imported_sets()
  update_recent_scenes()

func load_recent_scene(scene_name: String):
  var scene_data = save_manager.load_scene_from_user(scene_name)
  SceneContext.get_instance(self).current_scene = scene_data
  change_to_planning_scene()

func upload_scene(scene_name: String):
  var scene_to_upload := save_manager.load_scene_from_user(scene_name)
  server_connection.upload_scene(scene_to_upload)

func on_upload_success(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.dialog_text = UPLOAD_SUCCESS_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()
  for recent_scene_node in recent_scenes_container.get_children():
    if recent_scene_node.is_scene(scene_name):
      recent_scene_node.disable_upload()

func on_upload_failure(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.dialog_text = UPLOAD_FAILURE_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()

func delete_imported_set(removed_set_name: String):
  confirmation_dialog_target = removed_set_name
  confirmation_dialog.confirmed.connect(delete_set_confirmed)
  confirmation_dialog.dialog_text = DELETE_CONFIRMATION_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()

func delete_set_confirmed():
  confirmation_dialog.confirmed.disconnect(delete_set_confirmed)
  SceneContext.remove_set(confirmation_dialog_target)
  update_imported_sets()
  update_recent_scenes()

func delete_recent_scene(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.confirmed.connect(delete_scene_confirmed)
  confirmation_dialog.dialog_text = DELETE_CONFIRMATION_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()

func delete_scene_confirmed():
  confirmation_dialog.confirmed.disconnect(delete_scene_confirmed)
  save_manager.delete_scene(confirmation_dialog_target)
  update_recent_scenes()

func on_new_scene():
  SceneContext.get_instance(self).current_scene = Scene.new()
  change_to_planning_scene()

func change_to_planning_scene():
  # Can't preload planning_scene because it causes circular dependencies
  var planning_scene = load(PLANNING_SCENE_PATH)
  var error = get_tree().change_scene_to_packed(planning_scene)
  if error != OK:
    print("Error loading planning scene: ", error_string(error))

func _on_import_scene_pressed() -> void:
  scene_import_dialog.popup_centered()

func _on_scene_import_dialog_file_selected(path: String) -> void:
  var scene_data = save_manager.load_scene_from_json(path)
  SceneContext.get_instance(self).current_scene = scene_data
  save_manager.save_scene_to_user(scene_data)
  change_to_planning_scene()
