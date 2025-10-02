extends Container

signal on_pressed(scene_id: Scene)

const AUTHOR_STRING_TEMPLATE = "by: %s"

var scene_data: Scene

@onready var name_label = $%Name
@onready var author_label = $%Author

func _ready() -> void:
  name_label.text = scene_data.scene_name
  author_label.text = AUTHOR_STRING_TEMPLATE % scene_data.author

func set_scene(scene: Scene) -> void:
  scene_data = scene
  if name_label != null:
      name_label.text = scene_data.scene_name
  if author_label != null:
      author_label.text = AUTHOR_STRING_TEMPLATE % scene_data.author

func forward_pressed() -> void:
  on_pressed.emit(scene_data)