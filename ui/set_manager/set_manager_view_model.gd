class_name SetManagerViewModel
extends MarginContainer

var set_details_vm: SetDetailsViewModel
var tile_details_vm: TileDetailsViewModel

@onready var import_tileset = $%ImportTileSet
@onready var set_details = $%SetDetails
@onready var set_list = $%Sets
@onready var tile_details = $%TileDetails
@onready var tile_res: TileResources = TileSets

func _ready():
  var set_list_vm = SetListViewModel.new(tile_res)
  set_list.set_vm(set_list_vm)
  set_details_vm = SetDetailsViewModel.new()
  set_details.set_vm(set_details_vm)
  var import_tileset_vm = ImportTilesetViewModel.new()
  import_tileset.set_vm(import_tileset_vm)
  tile_details_vm = TileDetailsViewModel.new()
  tile_details.set_vm(tile_details_vm)

func import_set_started() -> void:
  import_tileset.show_dialog()

func delete_set(tile_set_name: String) -> void:
  tile_res.remove_set(tile_set_name)

func select_set(tile_set_name: String) -> void:
  var selected_set := tile_res.get_set(tile_set_name)
  set_details_vm.set_current_set(selected_set)

func set_tile_in_details(tile: Tile) -> void:
  tile_details_vm.update_tile(tile)
