class_name TileLayerButton
extends PanelContainer
## TileLayerButton
##
## [i]A UI button representing a tile layer with controls for height, visibility, selection, and deletion.[/i][br]

const selected_color = Color(0.051, 0.076, 0.171, 1.0)
const unselected_color = Color(0.005, 0.027, 0.1, 1.0)

var is_ready: bool = false
var view_model: TileLayerViewModel

@onready var height_text: LineEdit = $%Height
@onready var visibility_button: CheckButton = $%Visible

## Initialize the button and update its state from the view model if available.[br]
func _ready() -> void:
  is_ready = true
  if view_model != null:
    update_visibility(view_model.layer.id)
    update_height()
    update_selected()

## Set the view model and connect to its signals.[br]
## [b]Parameters:[/b][br]
## [code]vm[/code] : [TileLayerViewModel] — the view model containing layer data and state.[br]
func set_vm(vm: TileLayerViewModel) -> void:
  view_model = vm
  
  view_model.layer_updated.connect(update_height)
  view_model.visibility_changed.connect(update_visibility)
  view_model.selected_updated.connect(update_selected)
  if is_ready:
    update_visibility(view_model.layer.id)
    update_height()
    update_selected()

## Handle height text input changes and update the layer height if valid.[br]
## [b]Parameters:[/b][br]
## [code]new_text[/code] : [String] — the new text entered in the height field.[br]
func _on_height_text_changed(new_text: String) -> void:
  if new_text.is_valid_float():
    var float_value = new_text.to_float()
    view_model.set_height(float_value)
  else:
    height_text.text = str(view_model.layer.height)

## Update the height text field to reflect the current layer height.[br]
func update_height() -> void:
  height_text.text = str(view_model.layer.height)

## Update the button's background color based on selection state.[br]
func update_selected() -> void:
  if view_model.selected:
    set_background_color(selected_color)
  else:
    set_background_color(unselected_color)

## Set the background color of the panel container.[br]
## [b]Parameters:[/b][br]
## [code]color[/code] : [Color] — the color to set as the background.[br]
func set_background_color(color: Color) -> void:
  var stylebox = StyleBoxFlat.new()
  stylebox.bg_color = color
  self.add_theme_stylebox_override("panel", stylebox)

## Update the visibility button state to match the layer's visibility.[br]
## [b]Parameters:[/b][br]
## [code]_layer_id[/code] : [int] — the ID of the layer (unused).[br]
func update_visibility(_layer_id: int) -> void:
  visibility_button.button_pressed = view_model.visible

## Handle delete button press and trigger layer deletion.[br]
func _on_delete_button_pressed() -> void:
  view_model.trigger_delete()

## Handle visibility button toggle and update layer visibility.[br]
## [b]Parameters:[/b][br]
## [code]pressed[/code] : [bool] — whether the visibility button is pressed.[br]
func _on_visibility_button_toggled(pressed: bool) -> void:
  view_model.set_visible(pressed)

## Handle select button press and mark the layer as selected.[br]
func _on_select_pressed() -> void:
  view_model.set_selected(true)
