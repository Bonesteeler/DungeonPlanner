class_name TileDetails
extends VBoxContainer
## TileDetails
##
## [i]UI component displaying detailed information about a selected tile.[/i][br]
## [b]Properties:[/b][br]
## - [b]view_model[/b]: [TileDetailsViewModel] view model managing tile data.[br]
## - [b]length_label[/b]: [Label] displays tile length.[br]
## - [b]name_label[/b]: [Label] displays tile name.[br]
## - [b]tile_preview[/b]: [TilePreview] 3D preview of the tile.[br]
## - [b]width_label[/b]: [Label] displays tile width.[br]

var view_model: TileDetailsViewModel

@onready var length_label: Label = $%Length
@onready var name_label: Label = $%Name
@onready var tile_preview: TilePreview = $%TilePreview
@onready var width_label: Label = $%Width

## Set the view model and initialize display[br]
## [b]Parameters:[/b][br]
## [code]vm[/code] : [TileDetailsViewModel] — view model to bind.[br]
func set_vm(vm: TileDetailsViewModel) -> void:
  view_model = vm
  view_model.tile_changed.connect(update_details)
  update_details()

## Update all detail displays with current tile data[br]
func update_details() -> void:
  if view_model == null || view_model.tile == null:
    return
  name_label.text = view_model.tile.name
  tile_preview.set_tile(view_model.tile)
  width_label.text = view_model.get_width_text()
  length_label.text = view_model.get_height_text()
  visible = true
