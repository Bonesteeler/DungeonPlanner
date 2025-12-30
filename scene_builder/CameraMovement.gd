extends Node3D
## CameraMovement
##
## [i]Handles camera controls for the planning scene: panning, rotation, and zoom using mouse buttons and the mouse wheel.[/i][br]
## [b]Properties:[/b][br]
## - [b]camera[/b]: [Camera3D] — onready reference to the child Camera3D node.[br]
## [b]Constants:[/b][br]
## - [code]PITCH_MIN[/code]: Minimum pitch angle (radians).[br]
## - [code]PITCH_MAX[/code]: Maximum pitch angle (radians).[br]
## - [code]ROTATE_SPEED[/code]: Rotation sensitivity multiplier.[br]
## - [code]TRANSFORM_SPEED[/code]: Translation (pan) sensitivity multiplier.[br]
## - [code]ZOOM_COEFFICIENT[/code]: Zoom scaling coefficient based on camera size.[br]
## - [code]ZOOM_MAX[/code]: Maximum allowed camera size.[br]
## - [code]ZOOM_MIN[/code]: Minimum allowed camera size.[br]
## - [code]ZOOM_PERCENT[/code]: Fractional zoom step per wheel tick.[br]

const PITCH_MIN = -1.0
const PITCH_MAX = 0.25
const ROTATE_SPEED = 0.005
const TRANSFORM_SPEED = 0.1
const ZOOM_COEFFICIENT = 0.0154
const ZOOM_MAX = 150.0
const ZOOM_MIN = 20.0
const ZOOM_PERCENT = 0.1

var alt_pressed = false
var left_clicked = false
var shift_pressed = false

@onready var camera = $Camera3D

## Update mouse button state and process zoom wheel[br]
## [b]Parameters:[/b][br]
## [code]event[/code] : [InputEventMouseButton] — mouse button event to process.[br]
## [b]Returns:[/b] [void][br]
func handle_mouse_button(event: InputEventMouseButton):
  var event_button = event.get_button_index()
  if event_button == MOUSE_BUTTON_LEFT:
    left_clicked = event.is_pressed()
    return
  # Zoom
  if event_button == MOUSE_BUTTON_WHEEL_DOWN:
    camera.size += camera.size * ZOOM_PERCENT
    if camera.size > ZOOM_MAX:
      camera.size = ZOOM_MAX
  if event_button == MOUSE_BUTTON_WHEEL_UP:
    camera.size -= camera.size * ZOOM_PERCENT
    if camera.size < ZOOM_MIN:
      camera.size = ZOOM_MIN

## Apply panning or rotation based on current mouse button state[br]
## [b]Parameters:[/b][br]
## [code]event[/code] : [InputEventMouseMotion] — relative motion used for translation or rotation.[br]
## [b]Returns:[/b] [void][br]
func handle_mouse_motion(event: InputEventMouseMotion):
  # Pan
  if left_clicked and shift_pressed:
    var x_translation = - event.relative.x * TRANSFORM_SPEED * (ZOOM_COEFFICIENT * camera.size)
    var z_translation = - event.relative.y * TRANSFORM_SPEED * (ZOOM_COEFFICIENT * camera.size)
    transform = transform.translated_local(Vector3(x_translation, 0, z_translation))
  # Rotate
  if left_clicked and alt_pressed:
    transform = transform.rotated(Vector3.UP, -event.relative.x * ROTATE_SPEED)
    var current_euler = transform.basis.get_euler()
    var rotation_amount = - event.relative.y * ROTATE_SPEED
    var pitch_result = current_euler.x + rotation_amount
    if pitch_result < PITCH_MIN:
      rotation_amount = PITCH_MIN - current_euler.x
    elif pitch_result > PITCH_MAX:
      rotation_amount = PITCH_MAX - current_euler.x
    transform = transform.rotated_local(Vector3.RIGHT, rotation_amount)

## Update shift key state[br]
## [b]Parameters:[/b][br]
## [code]pressed[/code] : [bool] — true if the Shift key is pressed, false if released.[br]
## [b]Returns:[/b] [void][br]
func set_shift_pressed(pressed: bool):
  shift_pressed = pressed

## Update alt key state[br]
## [b]Parameters:[/b][br]
## [code]pressed[/code] : [bool] — true if the Alt key is pressed, false if released.[br]
## [b]Returns:[/b] [void][
func set_alt_pressed(pressed: bool):
  alt_pressed = pressed 

## Dispatch input events to mouse handlers[br]
## [b]Parameters:[/b][br]
## [code]event[/code] : [InputEvent] — raw input event from Godot's input system; routed to specific handlers.[br]
## [b]Returns:[/b] [void][br]
func _input(event):
  if event is InputEventMouseButton:
    handle_mouse_button(event as InputEventMouseButton)
  if event is InputEventMouseMotion:
    handle_mouse_motion(event as InputEventMouseMotion)
