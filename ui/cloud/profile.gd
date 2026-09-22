class_name Profile
extends MarginContainer
## Profile
##
## [i]Displays profile information, or login/signup forms.[/i][br]
## [b]Signals:[/b][br]
## - [code]log_in_pressed[/code]: Emitted when the log in button is pressed.[br]
## - [code]sign_up_pressed[/code]: Emitted when the sign up button is pressed.[br]
## - [code]log_out_pressed[/code]: Emitted when the log out button is pressed.[br]

signal log_in_pressed
signal sign_up_pressed
signal log_out_pressed

const LOG_IN_TEXT := "Log In"
const SIGN_UP_TEXT := "Sign Up"
const LOG_OUT_TEXT := "Log Out"

const LOG_IN_ERROR_TEXT := "Failed to log in"
const SIGN_UP_ERROR_TEXT := "Failed to sign up"

enum State {LOGIN, SIGNUP, LOGGED_IN}

var _state: State = State.LOGIN

@onready var username_entry: TextEdit = $%UsernameEntry
@onready var email_entry: TextEdit = $%EmailEntry
@onready var password_entry: TextEdit = $%PasswordEntry
@onready var username_label: Label = $%UsernameLabel
@onready var error_label: Label = $%ErrorLabel
@onready var primary_button: Button = $%PrimaryButton

func _ready() -> void:
  set_login_state()

## Show the login form: email, password, and login button.[br]
## [b]Parameters:[/b][br]
## [code]has_error[/code] : [bool] — whether to display the login error message (default: false).[br]
func set_login_state(has_error: bool = false) -> void:
  _state = State.LOGIN
  username_entry.visible = false
  username_label.visible = false
  email_entry.visible = true
  password_entry.visible = true
  primary_button.text = LOG_IN_TEXT
  set_error(has_error)

## Show the sign up form: username, email, password, and sign up button.[br]
## [b]Parameters:[/b][br]
## [code]has_error[/code] : [bool] — whether to display the sign up error message (default: false).[br]
func set_signup_state(has_error: bool = false) -> void:
  _state = State.SIGNUP
  username_entry.visible = true
  username_label.visible = false
  email_entry.visible = true
  password_entry.visible = true
  primary_button.text = SIGN_UP_TEXT
  set_error(has_error)

## Show the logged in view: username label and log out button.[br]
## [b]Parameters:[/b][br]
## [code]username[/code] : [String] — the logged in user's display name.[br]
func set_logged_in_state(username: String) -> void:
  _state = State.LOGGED_IN
  username_entry.visible = false
  email_entry.visible = false
  password_entry.visible = false
  username_label.visible = true
  username_label.text = username
  primary_button.text = LOG_OUT_TEXT
  set_error(false)

## Show or hide the error label for the current state.[br]
## [b]Parameters:[/b][br]
## [code]has_error[/code] : [bool] — whether to display the error message.[br]
func set_error(has_error: bool) -> void:
  var message := ""
  if has_error:
    match _state:
      State.LOGIN:
        message = LOG_IN_ERROR_TEXT
      State.SIGNUP:
        message = SIGN_UP_ERROR_TEXT
  error_label.visible = not message.is_empty()
  error_label.text = message

func _on_primary_button_pressed() -> void:
  match _state:
    State.LOGIN:
      log_in_pressed.emit()
    State.SIGNUP:
      sign_up_pressed.emit()
    State.LOGGED_IN:
      log_out_pressed.emit()
