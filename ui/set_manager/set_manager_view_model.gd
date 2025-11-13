class_name SetManagerViewModel
extends MarginContainer

var set_details_vm: SetDetailsViewModel

@onready var import_tileset = $%ImportTileSet
@onready var set_details = $%SetDetails
@onready var set_list = $%Sets
@onready var tile_res: TileResources = TileSets

func _ready():
  var set_list_vm = SetListViewModel.new(tile_res)
  set_list.set_vm(set_list_vm)
  set_details_vm = SetDetailsViewModel.new()
  set_details.set_vm(set_details_vm)
  var import_tileset_vm = ImportTilesetViewModel.new()
  import_tileset.set_vm(import_tileset_vm)

func import_set_started() -> void:
  import_tileset.show_dialog()

func delete_set(tile_set_name: String) -> void:
  tile_res.remove_set(tile_set_name)

func select_set(tile_set_name: String) -> void:
  set_details_vm.set_current_set(tile_set_name)
