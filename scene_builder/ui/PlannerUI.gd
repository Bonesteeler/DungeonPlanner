extends MarginContainer
## PlannerUI
##
## [i]Main UI container for the scene builder, managing tools, tile selection, layers, and file operations.[/i][br]
## [b]Signals:[/b][br]
## - [code]save_current_scene[/code]: Emitted when the current scene should be saved.[br]
## - [code]tile_layer_added(layer_vm: TileLayerViewModel)[/code]: Emitted when a new tile layer is added.[br]
## - [code]tile_selected(tile: Tile)[/code]: Emitted when a tile is selected.[br]
## - [code]tool_add_tile_selected[/code]: Emitted when the add tile tool is selected.[br]
## - [code]tool_select_tile_selected[/code]: Emitted when the select tile tool is selected.[br]
## - [code]tool_remove_tile_selected[/code]: Emitted when the remove tile tool is selected.[br]
## - [code]quit_scene[/code]: Emitted when the user quits the scene.[br]

class UIContext:
  var current_scene: Scene = Scene.new()

signal save_current_scene()
signal tile_layer_added(layer_vm: TileLayerViewModel)
signal tile_selected(tile: Tile)
signal tool_add_tile_selected()
signal tool_select_tile_selected()
signal tool_remove_tile_selected()
signal quit_scene()

const TOOL_ADD_TILE_GROUP: StringName = "add_tile"
const TOOL_SELECT_TILE_GROUP: StringName = "select_tile"
const TOOL_REMOVE_TILE_GROUP: StringName = "remove_tile"
const UNSAVED_CHANGES_DONT_SAVE_ACTION: StringName = "dont_save"

var context: UIContext
var current_tool: CustomEnums.ToolType = CustomEnums.ToolType.ADD_TILE
var unsaved_changes: bool = false
var vm: SceneBuilderViewModel

@onready var file_button = $%FileButton
@onready var menu_bar = $%MenuBar
@onready var layer_selector = $%LayerSelector
@onready var save_as_dialog = $%SaveAsDialogControl
@onready var set_selector_node = $%SetSelectorControl
@onready var tile_info = $%TileInfo
@onready var tile_selector_node = $%TileSelectorControl
@onready var tool_info = $%ToolInfo
@onready var unsaved_changes_dialog = $%UnsavedChangesDialog
@onready var unsaved_changes_save_as_dialog = $%UnsavedChangesSaveAsDialog

## Initialize the UI, connect signals, and set up default state.[br]
## [b]Returns:[/b] [void][br]
func _ready():
  tile_selector_node.tile_selected.connect(set_selected_tile)
  set_selector_node.set_selected.connect(set_selected_set)
  file_button.save_scene.connect(_on_file_save)
  file_button.save_scene_as.connect(show_save_as_dialog)
  save_as_dialog.saved_with_name.connect(_on_save_as)
  context = UIContext.new()
  set_selected_set(TileSets.tile_sets[0])
  set_selector_node.set_selectable_sets(TileSets.tile_sets)

## Set the view model for the scene builder and wire up connections.[br]
## [b]Parameters:[/b][br]
## [code]scene_vm[/code] : [SceneBuilderViewModel] — the view model to bind to this UI.[br]
## [b]Emits:[/b][br]
## - [code]tile_layer_added(layer_vm: TileLayerViewModel)[/code] when a layer is added.[br]
## [b]Returns:[/b] [void][br]
func set_vm(scene_vm: SceneBuilderViewModel):
  vm = scene_vm
  tile_selected.connect(vm.set_selected_tile)
  var layer_selector_vm = LayerSelectorViewModel.new()
  layer_selector_vm.set_layer_vms(vm.get_all_layer_vms())
  layer_selector_vm.select_layer_with_id(0)
  layer_selector_vm.layer_added.connect(func(layer_vm: TileLayerViewModel):
    vm.add_tile_layer(layer_vm)
    tile_layer_added.emit(layer_vm)
  )
  layer_selector.set_vm(layer_selector_vm)

## Set the currently selected tile and emit the tile_selected signal.[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — the tile to select.[br]
## [b]Emits:[/b][br]
## - [code]tile_selected(tile: Tile)[/code].[br]
## [b]Returns:[/b] [void][br]
func set_selected_tile(tile: Tile):
  tile_selected.emit(tile)

## Set the selected tile from a copy operation and switch to add tool.[br]
## [b]Parameters:[/b][br]
## [code]tile[/code] : [Tile] — the tile to select, or null to do nothing.[br]
## [b]Emits:[/b][br]
## - [code]tile_selected(tile: Tile)[/code] if tile is not null.[br]
## - [code]tool_add_tile_selected[/code] if tile is not null.[br]
## [b]Returns:[/b] [void][br]
func set_selected_tile_from_copy(tile: Tile):
  if tile == null:
    return
  tile_selected.emit(tile)
  on_select_add_tool()

## Set the currently selected tile set.[br]
## [b]Parameters:[/b][br]
## [code]tile_set[/code] : [DragonbiteTileSet] — the tile set to select.[br]
## [b]Returns:[/b] [void][br]
func set_selected_set(tile_set: DragonbiteTileSet):
  tile_selector_node.set_selected_set(tile_set)

## Handle file save action, showing save-as dialog if scene is unnamed.[br]
## [b]Emits:[/b][br]
## - [code]save_current_scene[/code] if the scene has a valid name.[br]
## [b]Returns:[/b] [void][br]
func _on_file_save():
  if vm.scene.scene_name == SceneBuilderViewModel.DEFAULT_SCENE_NAME or vm.scene.scene_name == "":
    show_save_as_dialog()
    return
  unsaved_changes = false
  save_current_scene.emit()

## Display the save-as dialog.[br]
## [b]Returns:[/b] [void][br]
func show_save_as_dialog():
  save_as_dialog.visible = true

## Handle save-as dialog completion with a new scene name.[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — the name to assign to the scene.[br]
## [b]Emits:[/b][br]
## - [code]save_current_scene[/code].[br]
## [b]Returns:[/b] [void][br]
func _on_save_as(scene_name: String):
  vm.update_scene_name(scene_name)
  vm.update_id(UUID.v7())
  unsaved_changes = false
  save_current_scene.emit()

## Handle viewport resize events and propagate to child controls.[br]
## [b]Parameters:[/b][br]
## [code]new_size[/code] : [Vector2] — the new viewport size.[br]
## [b]Returns:[/b] [void][br]
func on_viewport_resized(new_size: Vector2):
  set_selector_node.on_viewport_resized(new_size)
  tile_selector_node.on_viewport_resized(new_size)

## Mark the scene as having unsaved changes.[br]
## [b]Returns:[/b] [void][br]
func on_board_updated() -> void:
  unsaved_changes = true

## Initiate save process for unsaved changes, showing save-as dialog if needed.[br]
## [b]Returns:[/b] [void][br]
func unsaved_changes_save():
  if vm.scene.scene_name == SceneBuilderViewModel.DEFAULT_SCENE_NAME or vm.scene.scene_name == "":
    unsaved_changes_save_as_dialog.visible = true

## Handle custom actions from the unsaved changes dialog.[br]
## [b]Parameters:[/b][br]
## [code]action[/code] : [StringName] — the action to perform (e.g., "dont_save").[br]
## [b]Emits:[/b][br]
## - [code]quit_scene[/code] if action is "dont_save".[br]
## [b]Returns:[/b] [void][br]
func unsaved_changes_custom(action: StringName):
  if UNSAVED_CHANGES_DONT_SAVE_ACTION == action:
    quit_scene.emit()
  else:
    print("Unknown unsaved changes action: ", action)

## Handle save-as dialog completion from unsaved changes workflow.[br]
## [b]Parameters:[/b][br]
## [code]scene_name[/code] : [String] — the name to assign to the scene.[br]
## [b]Emits:[/b][br]
## - [code]save_current_scene[/code].[br]
## [b]Returns:[/b] [void][br]
func on_unsaved_changes_save_as_dialog_saved(scene_name: String) -> void:
  vm.update_scene_name(scene_name)
  save_current_scene.emit()

## Select the add tile tool and update UI state.[br]
## [b]Emits:[/b][br]
## - [code]tool_add_tile_selected[/code].[br]
## [b]Returns:[/b] [void][br]
func on_select_add_tool():
  current_tool = CustomEnums.ToolType.ADD_TILE
  show_only_tool_info_of_group(TOOL_ADD_TILE_GROUP)
  tool_add_tile_selected.emit()

## Select the select tile tool and update UI state.[br]
## [b]Emits:[/b][br]
## - [code]tool_select_tile_selected[/code].[br]
## [b]Returns:[/b] [void][br]
func on_select_select_tool():
  current_tool = CustomEnums.ToolType.SELECT_TILE
  show_only_tool_info_of_group(TOOL_SELECT_TILE_GROUP)
  tool_select_tile_selected.emit()

## Select the remove tile tool and update UI state.[br]
## [b]Emits:[/b][br]
## - [code]tool_remove_tile_selected[/code].[br]
## [b]Returns:[/b] [void][br]
func on_select_remove_tool():
  current_tool = CustomEnums.ToolType.REMOVE_TILE
  show_only_tool_info_of_group(TOOL_REMOVE_TILE_GROUP)
  tool_remove_tile_selected.emit()

## Show tool info UI elements belonging to the specified group.[br]
## [b]Parameters:[/b][br]
## [code]group[/code] : [StringName] — the group name to show.[br]
## [b]Returns:[/b] [void][br]
func show_only_tool_info_of_group(group: StringName):
  for child in tool_info.get_children():
    if child.get_groups().has(group):
      child.visible = true
    else:
      child.visible = false

## Update tile info display based on selected tile ID.[br]
## [b]Parameters:[/b][br]
## [code]tile_id[/code] : [String] — the unique identifier of the tile to select.[br]
## [b]Returns:[/b] [void][br]
func on_tile_selected(tile_id: String) -> void:
  var tile_data = TileSets.get_set_and_tile_data(tile_id)
  if tile_data[TileResources.KEY_TILE] == null:
    print("Tile with ID ", tile_id, " not found in resources.")
    return
  if tile_data[TileResources.KEY_SET] == null:
    print("Tile set for tile ID ", tile_id, " not found in resources.")
    return
  tile_info.set_state(
      tile_data[TileResources.KEY_SET].name,
      tile_data[TileResources.KEY_TILE]
  )
