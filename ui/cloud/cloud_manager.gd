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
@onready var log_in_profile: Profile = $%Profile
@onready var sign_up_profile: Profile = $%SignUpProfile
@onready var auth_toggle_button: Button = $%AuthToggleButton

func _ready() -> void:
	view_model = CloudManagerViewModel.new()
	profile_view_model = ProfileViewModel.new()

	log_in_profile.log_in_pressed.connect(_on_log_in_pressed)
	sign_up_profile.set_signup_state()
	sign_up_profile.sign_up_pressed.connect(_on_sign_up_pressed)
	log_in_profile.log_out_pressed.connect(profile_view_model.log_out)
	profile_view_model.signed_out.connect(_on_signed_out)
	auth_toggle_button.pressed.connect(_on_auth_toggle_pressed)
	if profile_view_model.is_logged_in():
		_show_logged_in()
	else:
		_show_login_form()

	online_scenes.request_scene_list.connect(view_model.request_scene_list)
	online_scenes.scene_import.connect(view_model.import_scene)

	upload_scenes.upload_requested.connect(view_model.upload_scene)
	upload_scenes.set_scenes(view_model.get_local_scenes())

	view_model.scene_list_updated.connect(online_scenes.set_scene_items)

	view_model.request_scene_list(0)

func _on_log_in_pressed() -> void:
	if await profile_view_model.login(log_in_profile.get_email(), log_in_profile.get_password()):
		_show_logged_in()
		_refresh_scene_list()
	else:
		log_in_profile.set_login_state(true)

func _on_sign_up_pressed() -> void:
	if await profile_view_model.signup(sign_up_profile.get_username(), sign_up_profile.get_email(), sign_up_profile.get_password()):
		sign_up_profile.clear_password()
		_show_logged_in()
		_refresh_scene_list()
	else:
		sign_up_profile.set_signup_state(true)

func _on_signed_out() -> void:
	log_in_profile.set_login_state()
	sign_up_profile.set_signup_state()
	_show_login_form()
	_refresh_scene_list()

# Page 1 because the total count can differ per user.
func _refresh_scene_list() -> void:
	online_scenes.start_idx = 0
	view_model.request_scene_list(0)

func _show_logged_in() -> void:
	log_in_profile.clear_password()
	log_in_profile.set_logged_in_state(profile_view_model.get_email())
	log_in_profile.visible = true
	sign_up_profile.visible = false
	auth_toggle_button.visible = false

func _show_login_form() -> void:
	log_in_profile.visible = true
	sign_up_profile.visible = false
	auth_toggle_button.visible = true
	auth_toggle_button.text = "Need an account? Sign Up"

func _show_sign_up_form() -> void:
	log_in_profile.visible = false
	sign_up_profile.visible = true
	auth_toggle_button.visible = true
	auth_toggle_button.text = "Have an account? Log In"

func _on_auth_toggle_pressed() -> void:
	if log_in_profile.visible:
		_show_sign_up_form()
	else:
		_show_login_form()
