class_name SetDetailsItem
extends VBoxContainer

var vm: SetDetailsItemViewModel

@onready var name_button: Button = $%Name
@onready var preview: TilePreview = $%TilePreview

func set_vm(view_model: SetDetailsItemViewModel) -> void:
  vm = view_model
  update_item()

func update_item() -> void:
  var tile = vm.tile
  name_button.text = tile.name
  preview.set_mesh(tile.mesh_path)