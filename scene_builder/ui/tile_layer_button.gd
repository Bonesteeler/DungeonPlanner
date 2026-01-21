class_name TileLayerButton
extends PanelContainer

const selected_color = Color(0.051, 0.076, 0.171, 1.0)
const unselected_color = Color(0.005, 0.027, 0.1, 1.0)

var is_ready: bool = false
var view_model: TileLayerViewModel

@onready var height_text: LineEdit = $%Height
@onready var visibility_button: CheckButton = $%Visible

func _ready() -> void:
  is_ready = true
  if view_model != null:
    update_visibility(view_model.layer.id)
    update_height()
    update_selected()

func set_vm(vm: TileLayerViewModel) -> void:
  view_model = vm
  
  view_model.layer_updated.connect(update_height)
  view_model.visibility_changed.connect(update_visibility)
  view_model.selected_updated.connect(update_selected)
  if is_ready:
    update_visibility(view_model.layer.id)
    update_height()
    update_selected()

func _on_height_text_changed(new_text: String) -> void:
  if new_text.is_valid_float():
    var float_value = new_text.to_float() 
    view_model.set_height(float_value)
  else:
    height_text.text = str(view_model.layer.height)

func update_height() -> void:
  height_text.text = str(view_model.layer.height)

func update_selected() -> void:
  if view_model.selected:
    set_background_color(selected_color)
  else:
    set_background_color(unselected_color)

func set_background_color(color: Color) -> void:
  var stylebox = StyleBoxFlat.new()
  stylebox.bg_color = color
  self.add_theme_stylebox_override("panel", stylebox)

func update_visibility(_layer_id: int) -> void:
  visibility_button.button_pressed = view_model.visible

func _on_delete_button_pressed() -> void:
  view_model.trigger_delete()

func _on_visibility_button_toggled(pressed: bool) -> void:
  view_model.set_visible(pressed)

func _on_select_pressed() -> void:
  view_model.set_selected(true)
