extends Node3D

signal rotate_left()
signal rotate_right()

func connect_context(context: SceneContext):
	rotate_left.connect(context.left_rotation)
	rotate_right.connect(context.right_rotation)
 
func _input(event: InputEvent):
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_Q:
			rotate_left.emit()
		if event.keycode == KEY_E:
			rotate_right.emit()
		
