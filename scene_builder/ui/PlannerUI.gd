extends MarginContainer

class UIContext:
  var current_scene: Scene = Scene.new()
  var recent_scenes: Array[Scene] = []

signal load_scene(scene_name: String)
signal new_scene()
signal save_current_scene(scene: Scene)
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
var resources: TileResources
var unsaved_changes: bool = false

@onready var file_button = $%FileButton
@onready var menu_bar = $%MenuBar
@onready var save_as_dialog = $%SaveAsDialogControl
@onready var set_selector_node = $%SetSelectorControl
@onready var tile_info = $%TileInfo
@onready var tile_selector_node = $%TileSelectorControl
@onready var tool_info = $%ToolInfo
@onready var unsaved_changes_dialog = $%UnsavedChangesDialog
@onready var unsaved_changes_save_as_dialog = $%UnsavedChangesSaveAsDialog

func _ready():
  tile_selector_node.tile_selected.connect(set_selected_tile)
  set_selector_node.set_selected.connect(set_selected_set)
  file_button.new_scene.connect(_on_file_new)
  file_button.load_scene.connect(_on_file_load)
  file_button.save_scene.connect(_on_file_save)
  file_button.save_scene_as.connect(show_save_as_dialog)
  file_button.quit_scene.connect(on_quit)
  save_as_dialog.saved_with_name.connect(_on_save_as)
  context = UIContext.new()
  if SceneContext.current_scene != null:
    context.current_scene = SceneContext.current_scene

func set_tile_resources(new_resources: TileResources):
  resources = new_resources
  set_selected_set(resources.tile_sets[0])
  set_selector_node.set_selectable_sets(resources.tile_sets)

func set_selected_tile(tile: Tile):
  tile_selected.emit(tile)

func set_selected_tile_from_copy(tile: Tile):
  if tile == null:
    return
  tile_selected.emit(tile)
  on_select_add_tool()

func set_selected_set(tile_set: DragonbiteTileSet):
  tile_selector_node.set_selected_set(tile_set)

func set_recent_scenes(scenes: Array[Scene]):
  context.recent_scenes = scenes
  file_button.set_saves(context.recent_scenes)

func _on_file_new():
  context.current_scene = Scene.new()
  new_scene.emit()

func _on_file_load(scene_name: String):
  var loaded_scene: Scene = null
  for scene in context.recent_scenes:
    if scene.scene_name == scene_name:
      loaded_scene = scene
      break
  if loaded_scene != null:
    context.current_scene = loaded_scene
    load_scene.emit(loaded_scene)
  else:
    push_error("Scene " + scene_name + " not found in recent scenes.")

func _on_file_save():
  if context.current_scene.scene_name == "":
    show_save_as_dialog()
    return
  unsaved_changes = false
  save_current_scene.emit(context.current_scene)

func show_save_as_dialog():
  save_as_dialog.visible = true

func _on_save_as(scene_name: String):
  context.current_scene.scene_name = scene_name
  unsaved_changes = false
  save_current_scene.emit(context.current_scene)
  file_button.set_saves(context.recent_scenes)

func on_quit():
  if unsaved_changes:
    unsaved_changes_dialog.visible = true
  else:
    quit_scene.emit()

func on_viewport_resized(new_size: Vector2):
  set_selector_node.on_viewport_resized(new_size)
  tile_selector_node.on_viewport_resized(new_size)

func on_board_updated() -> void:
  unsaved_changes = true

func unsaved_changes_save():
  if SceneContext.current_scene.scene_name == "":
    unsaved_changes_save_as_dialog.visible = true
  else:
    save_current_scene.emit(SceneContext.current_scene)
    quit_scene.emit()

func unsaved_changes_custom(action: StringName):
  if UNSAVED_CHANGES_DONT_SAVE_ACTION == action:
    quit_scene.emit()
  else:
    print("Unknown unsaved changes action: ", action)

func on_unsaved_changes_save_as_dialog_saved(scene_name: String) -> void:
  SceneContext.current_scene.scene_name = scene_name
  save_current_scene.emit(SceneContext.current_scene.scene_name)
  quit_scene.emit()

func on_select_add_tool():
  current_tool = CustomEnums.ToolType.ADD_TILE
  show_only_tool_info_of_group(TOOL_ADD_TILE_GROUP)
  tool_add_tile_selected.emit()

func on_select_select_tool():
  current_tool = CustomEnums.ToolType.SELECT_TILE
  show_only_tool_info_of_group(TOOL_SELECT_TILE_GROUP)
  tool_select_tile_selected.emit()

func on_select_remove_tool():
  current_tool = CustomEnums.ToolType.REMOVE_TILE
  show_only_tool_info_of_group(TOOL_REMOVE_TILE_GROUP)
  tool_remove_tile_selected.emit()

func show_only_tool_info_of_group(group: StringName):
  for child in tool_info.get_children():
    if child.get_groups().has(group):
      child.visible = true
    else:
      child.visible = false

func on_tile_selected(tile_id: String) -> void:
  var tile_data = SceneContext.tile_resources.get_set_and_tile_data(tile_id)
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
