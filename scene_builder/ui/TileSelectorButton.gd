extends MarginContainer
## TileSelectorButton
##
## [i]A button container for selecting tiles in the scene builder UI.[/i][br]
## [b]Signals:[/b][br]
## - [code]tile_pressed(int)[/code]: Emitted when the button is pressed, passing the tile index.[br]

signal tile_pressed(int)

var index = 0

@onready var button = $Button

## Update the button's visual state and properties based on the provided TileViewModel.[br]
## [b]Parameters:[/b][br]
## [code]tile_vm[/code] : [TileViewModel] — view model containing the tile data and display state.[br]
func update_state(tile_vm: TileViewModel):
  if tile_vm.hidden:
    button.visible = false
  else:
    button.visible = true
    index = tile_vm.index
    button.disabled = false
    button.tooltip_text = tile_vm.tile.name
    button.text = tile_vm.tile.name

## Handle button press events and emit the tile_pressed signal with the current index.[br]
## [b]Emits:[/b][br]
## - [code]tile_pressed(index: [int])[/code] with the current tile index[br]
func _on_button_pressed():
  tile_pressed.emit(index)
