class_name SceneManager
extends MarginContainer
## SceneManager
##
## [i]UI component for managing scenes, allowing users to view, select, and create scenes.[/i][br]

const DELETE_CONFIRMATION_STRING_TEMPLATE = "Are you sure you want to delete %s?"

signal scene_selected(vm: SceneBuilderViewModel)

var confirmation_dialog_target: String
var view_model: SceneManagerViewModel

@onready var confirmation_dialog: ConfirmationDialog = $%ConfirmationDialog
@onready var scene_selector: SceneSelector = $%SceneSelector
@onready var recent_scenes: RecentScenes = $%RecentScenes

func _ready():
    view_model = SceneManagerViewModel.new(SceneSaveService)

    scene_selector.set_vm(view_model)
    scene_selector.scene_selected.connect(_on_scene_selected)
    scene_selector.new_scene_requested.connect(_on_new_scene_requested)
    scene_selector.delete_scene_requested.connect(_on_delete_scene_requested)

    recent_scenes.set_vm(view_model)
    recent_scenes.scene_selected.connect(_on_scene_selected)
    recent_scenes.delete_scene_requested.connect(_on_delete_scene_requested)
    recent_scenes.upload_scene.connect(_on_upload_scene_request)

func _on_scene_selected(scene_id: String) -> void:
    var scene_data = view_model.find_scene_by_id(scene_id)
    view_model.mark_scene_as_recent(scene_data)
    if scene_data != null:
      var new_scene_vm = SceneBuilderViewModel.new(scene_data)
      scene_selected.emit(new_scene_vm)

func _on_new_scene_requested() -> void:
    var scene_view_model = SceneBuilderViewModel.new()
    scene_selected.emit(scene_view_model)

## Show confirmation dialog before deleting a recent scene[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene to delete.[br]
## [b]Returns:[/b] [void][br]
func _on_delete_scene_requested(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.confirmed.connect(delete_scene_confirmed)
  confirmation_dialog.dialog_text = DELETE_CONFIRMATION_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()


## Callback for confirmed scene deletion[br]
## [b]Returns:[/b] [void][br]
func delete_scene_confirmed():
  confirmation_dialog.confirmed.disconnect(delete_scene_confirmed)
  SceneSaveService.delete_scene(confirmation_dialog_target)
  scene_selector.set_scene_list()

## Send upload request[br]
## [b]Parameters:[/b][br]## [code]scene_id[/code] : [String] — ID of the scene to upload
## [b]Returns:[/b] [void][br]
func _on_upload_scene_request(scene_id: String):
    if scene_id != "":
        view_model.upload_scene(scene_id)
