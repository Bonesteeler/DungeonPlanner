class_name SetManagerViewModel
extends MarginContainer
## SetManagerViewModel
##
## [i]Main controller for the set manager UI, coordinating all view models and views.[/i][br]
## [b]Properties:[/b][br]
## - [b]set_details_vm[/b]: [SetDetailsViewModel] view model for tile set details.[br]
## - [b]tile_details_vm[/b]: [TileDetailsViewModel] view model for individual tile details.[br]
## - [b]import_tileset[/b]: [ImportTileset] import dialog control.[br]
## - [b]set_details[/b]: [SetDetails] tile set details display.[br]
## - [b]set_list[/b]: [SetList] list of available tile sets.[br]
## - [b]tile_details[/b]: [TileDetails] individual tile details display.[br]
## - [b]tile_res[/b]: [TileResources] singleton for tile resource management.[br]

var file_loader: LoadSavedFiles = LoadSavedFiles.new()
var set_details_vm: SetDetailsViewModel
var tile_details_vm: TileDetailsViewModel

@onready var import_tileset = $%ImportTileSet
@onready var photographer = $%Photographer
@onready var set_details = $%SetDetails
@onready var set_list = $%Sets
@onready var tile_details = $%TileDetails
@onready var tile_res: TileResources = TileSets

## Initialize all view models and bind them to views[br]
func _ready():
  var set_list_vm = SetListViewModel.new(tile_res)
  set_list.set_vm(set_list_vm)
  set_details_vm = SetDetailsViewModel.new()
  set_details.set_vm(set_details_vm)
  var import_tileset_vm = ImportTilesetViewModel.new(file_loader, photographer)
  import_tileset.set_vm(import_tileset_vm)
  tile_details_vm = TileDetailsViewModel.new()
  tile_details.set_vm(tile_details_vm)

## Show the import dialog[br]
func import_set_started() -> void:
  import_tileset.show_dialog()

## Delete a tile set by name[br]
## [b]Parameters:[/b][br]
## [code]tile_set_name[/code] : [String] — name of the tile set to remove.[br]
func delete_set(tile_set_name: String) -> void:
  tile_res.remove_set(tile_set_name)

## Select and display a tile set by name[br]
## [b]Parameters:[/b][br]
## [code]tile_set_name[/code] : [String] — name of the tile set to display.[br]
func select_set(tile_set_name: String) -> void:
  var selected_set := tile_res.get_set(tile_set_name)
  await photographer.generate_images_of_tiles(selected_set.tiles)
  set_details_vm.set_current_set(selected_set)

## Update tile details view with a selected tile[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — tile to display in details panel.[br]
func set_tile_in_details(tile: Tile) -> void:
  tile_details_vm.update_tile(tile)
