class_name MainMenu
extends PanelContainer
## MainMenu
##
## [i]Main menu UI for managing scene files, including creating new scenes, loading recent scenes, and importing/exporting scene data.[/i][br]

const UPLOAD_SUCCESS_STRING_TEMPLATE = "Successfully uploaded scene: %s"
const UPLOAD_FAILURE_STRING_TEMPLATE = "Failed to upload scene: %s"

var confirmation_dialog_target: String
var export_scene_name: String = ""

@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var scene_browser: SceneBrowser = $%SceneBrowser
@onready var scene_import_dialog: FileDialog = $%SceneImportDialog

## Initialize the save manager and connect signals for scene management[br]
## [b]Returns:[/b] [void][br]
func _ready():
  scene_browser.scene_import.connect(SceneSaveService.add_scene)

## Upload a saved scene to the server[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene to upload.[br]
## [b]Returns:[/b] [void][br]
func upload_scene(scene_name: String):
  var scene_to_upload := SceneSaveService.load_scene_from_user(scene_name)
  Backend.upload_scene(scene_to_upload)

## Display a success message after a scene is uploaded[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the successfully uploaded scene.[br]
## [b]Returns:[/b] [void][br]
func on_upload_success(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.dialog_text = UPLOAD_SUCCESS_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()

## Display a failure message when a scene upload fails[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — name of the scene that failed to upload.[br]
## [b]Returns:[/b] [void][br]
func on_upload_failure(scene_name: String):
  confirmation_dialog_target = scene_name
  confirmation_dialog.dialog_text = UPLOAD_FAILURE_STRING_TEMPLATE % confirmation_dialog_target
  confirmation_dialog.popup_centered()
