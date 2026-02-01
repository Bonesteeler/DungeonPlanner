extends Node3D
## InputListener
##
## [i]Listens for keyboard input related to rotating the scene and emits
## signals for left and right rotation actions.[/i][br]
## [b]Signals:[/b][br]
## - [code]key_alt_event(pressed: bool)[/code] : Emitted when the Alt key is pressed or released.[br]
## - [code]key_shift_event(pressed: bool)[/code] : Emitted when the Shift key is pressed or released.[br]
## - [code]rotate_left()[/code] : Emitted when a left rotation is triggered.[br]
## - [code]rotate_right()[/code] : Emitted when a right rotation is triggered.[br]

signal key_alt_event(pressed: bool)
signal key_shift_event(pressed: bool)
signal rotate_left()
signal rotate_right()

## Listen for keyboard input and dispatch rotation actions.[br]
## [b]Parameters:[/b][br]
## - [code]event[/code] : [InputEvent] — Input event passed to the node.[br]
## [b]Emits:[/b][br]
## - [code]rotate_left()[/code] when the left rotation key is pressed.[br]
## - [code]rotate_right()[/code] when the right rotation key is pressed.[br]
## [b]Returns:[/b] [void][br]
func _input(event: InputEvent):
  if event is InputEventKey:
    var pressed = event.is_pressed()
    if event.keycode == KEY_SHIFT:
      key_shift_event.emit(pressed)
    if event.keycode == KEY_ALT:
      key_alt_event.emit(pressed)
    if pressed:
      if event.keycode == KEY_Q:
        rotate_left.emit()
      if event.keycode == KEY_E:
        rotate_right.emit()