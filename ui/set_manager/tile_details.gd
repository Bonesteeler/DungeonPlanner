class_name TileDetails
extends VBoxContainer

var view_model: TileDetailsViewModel

@onready var length_label: Label = $%Length
@onready var name_label: Label = $%Name
@onready var tile_preview: TilePreview = $%TilePreview
@onready var width_label: Label = $%Width

func set_vm(vm: TileDetailsViewModel) -> void:
  view_model = vm
  view_model.tile_changed.connect(update_details)
  update_details()

func update_details() -> void:
  if view_model == null || view_model.tile == null:
    return
  name_label.text = view_model.tile.name
  tile_preview.set_tile(view_model.tile)
  width_label.text = view_model.get_width_text()
  length_label.text = view_model.get_height_text()
  visible = true
