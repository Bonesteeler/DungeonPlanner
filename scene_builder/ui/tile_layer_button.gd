class_name TileLayerButton
extends PanelContainer

var is_ready: bool = false
var view_model: TileLayerViewModel

@onready var background: Panel = $Background
@onready var height_text: TextEdit = $%Height
@onready var visibility_button: CheckButton = $%Visible

func _ready() -> void:
  is_ready = true
  if view_model != null:
    update_visibility()
    update_height()
    update_selected()

func set_vm(vm: TileLayerViewModel) -> void:
  view_model = vm
  
  view_model.layer_updated.connect(update_height)
  view_model.visibility_changed.connect(update_visibility)
  view_model.selected_updated.connect(update_selected)
  if is_ready:
    update_visibility()
    update_height()
    update_selected()

func _on_height_text_changed() -> void:
  var new_text = height_text.text
  if new_text.is_valid_int():
    var int_value = new_text.to_int() 
    view_model.set_height(int_value)

func update_height() -> void:
  height_text.text = str(view_model.layer.height)

func update_selected() -> void:
  print(view_model.selected)

func update_visibility() -> void:
  visibility_button.button_pressed = view_model.visible

func _on_visibility_button_toggled(pressed: bool) -> void:
  view_model.set_visible(pressed)