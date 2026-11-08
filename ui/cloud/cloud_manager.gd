class_name CloudManager
extends MarginContainer
## CloudManager
##
## [i]Top-level scene for browsing, downloading, and uploading scenes via the backend.[/i][br]
## Hosts an [OnlineScenesPanel] for downloading server scenes and an [UploadScenesPanel]
## for uploading local scenes.[br]

var view_model: CloudManagerViewModel
var profile_view_model: ProfileViewModel

@onready var online_scenes: OnlineScenesPanel = $%OnlineScenes
@onready var upload_scenes: UploadScenesPanel = $%UploadScenes
@onready var profile: Profile = $%Profile

func _ready() -> void:
	view_model = CloudManagerViewModel.new()
	profile_view_model = ProfileViewModel.new()

	profile.log_in_pressed.connect(_on_log_in_pressed)
	profile.sign_up_pressed.connect(_on_sign_up_pressed)
	profile.log_out_pressed.connect(profile_view_model.log_out)
	profile_view_model.signed_out.connect(profile.set_login_state)
	if profile_view_model.is_logged_in():
		profile.set_logged_in_state(profile_view_model.get_email())

	online_scenes.request_scene_list.connect(view_model.request_scene_list)
	online_scenes.scene_import.connect(view_model.import_scene)

	upload_scenes.upload_requested.connect(view_model.upload_scene)
	upload_scenes.set_scenes(view_model.get_local_scenes())

	view_model.scene_list_updated.connect(online_scenes.set_scene_items)

	view_model.request_scene_list(0)

func _on_log_in_pressed() -> void:
	if await profile_view_model.login(profile.get_email(), profile.get_password()):
		_show_logged_in()
	else:
		profile.set_login_state(true)

func _on_sign_up_pressed() -> void:
	if await profile_view_model.signup(profile.get_username(), profile.get_email(), profile.get_password()):
		_show_logged_in()
	else:
		profile.set_signup_state(true)

func _show_logged_in() -> void:
	profile.clear_password()
	profile.set_logged_in_state(profile_view_model.get_email())
