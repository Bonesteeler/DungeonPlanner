class_name SetManagerViewModel
extends MarginContainer

@onready var set_details = $%SetDetails
@onready var set_list = $%Sets
@onready var tile_res: TileResources = TileSets

func _ready():
  var set_list_vm = SetListViewModel.new(tile_res)
  set_list.set_vm(set_list_vm)
  var set_details_vm = SetDetailsViewModel.new()
  set_details.set_vm(set_details_vm)

func delete_set(tile_set_name: String) -> void:
  print("Deleted set: %s" % tile_set_name) 

func select_set(tile_set_name: String) -> void:
  set_details.viewModel.set_current_set(tile_set_name)
