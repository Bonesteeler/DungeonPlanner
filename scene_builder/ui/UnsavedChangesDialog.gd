extends AcceptDialog


func _ready() -> void:
	add_button("Don't save", true, "dont_save")
	add_cancel_button("Cancel")
