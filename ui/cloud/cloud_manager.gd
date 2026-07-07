class_name CloudManager
extends MarginContainer
## CloudManager
##
## [i]Top-level scene for browsing, downloading, and uploading scenes via the backend.[/i][br]
## Hosts an [OnlineScenesPanel] for downloading server scenes and an [UploadScenesPanel]
## for uploading local scenes.[br]

var view_model: CloudManagerViewModel

@onready var online_scenes: OnlineScenesPanel = $%OnlineScenes
@onready var upload_scenes: UploadScenesPanel = $%UploadScenes

func _ready() -> void:
	view_model = CloudManagerViewModel.new()

	online_scenes.request_scene_list.connect(view_model.request_scene_list)
	online_scenes.scene_import.connect(view_model.import_scene)

	upload_scenes.upload_requested.connect(view_model.upload_scene)
	upload_scenes.set_scenes(view_model.get_local_scenes())

	view_model.scene_list_updated.connect(online_scenes.set_scene_items)

	view_model.request_scene_list(0)