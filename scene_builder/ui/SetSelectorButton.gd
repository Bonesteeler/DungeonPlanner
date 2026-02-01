extends MarginContainer
## SetSelectorButton
##
## [i]A button container for selecting tile sets in the scene builder UI.[/i][br]
## [b]Signals:[/b][br]
## - [code]set_button_pressed(int)[/code]: Emitted when the button is pressed, passing the tile set index.[br]

signal set_button_pressed(int)

var index = 0

## Update the button's visual state and properties based on the provided SetViewModel.[br]
## [b]Parameters:[/b][br]
## [code]set_vm[/code] : [SetViewModel] — view model containing the tile set data and display state.[br]
func update_state(set_vm: SetViewModel):
  if set_vm.hidden:
    $Button.visible = false
  else:
    $Button.visible = true
    index = set_vm.index
    $Button.disabled = false
    $Button.tooltip_text = set_vm.tile_set.name
    $Button.text = set_vm.tile_set.name

## Handle button press events and emit the set_button_pressed signal with the current index.[br]
## [b]Emits:[/b][br]
## - [code]set_button_pressed(index: [int])[/code] with the current tile set index[br]
func _on_button_pressed():
  set_button_pressed.emit(index)
