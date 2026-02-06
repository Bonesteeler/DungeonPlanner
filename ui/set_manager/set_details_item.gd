class_name SetDetailsItem
extends VBoxContainer
## SetDetailsItem
##
## [i]UI component displaying a single tile in the set details view with name and preview.[/i][br]
## [b]Properties:[/b][br]
## - [b]vm[/b]: [SetDetailsItemViewModel] view model for this item.[br]
## - [b]name_button[/b]: [Button] button displaying tile name.[br]
## - [b]image[/b]: [TextureRect] image preview of the tile.[br]
## [b]Signals:[/b][br]
## - [code]selected(tile)[/code]: Emitted when the tile is selected.[br]

const IMAGE_PATH_TEMPLATE = "user://TileImages/%s.png"

signal selected(tile)

var vm: SetDetailsItemViewModel

@onready var name_button: Button = $%Name
@onready var image: TextureRect = $%Image

## Set the view model and update display[br]
## [b]Parameters:[/b][br]
## [code]view_model[/code] : [SetDetailsItemViewModel] — view model to bind.[br]
func set_vm(view_model: SetDetailsItemViewModel) -> void:
  vm = view_model
  update_item()

## Update the item display with current tile data[br]
func update_item() -> void:
  var tile = vm.tile
  name_button.text = tile.name
  var tile_image = Image.load_from_file(IMAGE_PATH_TEMPLATE % tile.id)
  var texture = ImageTexture.create_from_image(tile_image)
  image.texture = texture

## Emit selected signal with the current tile[br]
## [b]Emits:[/b][br]
## - [code]selected(tile)[/code][br]
func emit_selected():
  selected.emit(vm.tile)