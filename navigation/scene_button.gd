class_name SceneButton
extends Button
## SceneButton
##
## [i]A button component that represents and triggers selection of a scene.[/i][br]
## [b]Signals:[/b][br]
## - [code]scene_selected(String)[/code]: Emitted when the button is pressed, passing the scene ID.[br]

signal scene_selected(String)

var scene_id: String = ""

## Configure the button with scene data[br]
## [b]Parameters:[/b][br]
## [code]new_scene[/code] : [Scene] — The scene object containing id and scene_name properties.[br]
## [b]Returns:[/b] [void][br]
func set_scene(new_scene: Scene) -> void:
  scene_id = new_scene.id
  text = new_scene.scene_name

## Handle button press event and emit scene selection signal[br]
## [b]Emits:[/b][br]
## - [code]scene_selected(scene_id: [String])[/code] with the current scene_id.[br]
func _on_button_pressed():
  scene_selected.emit(scene_id)