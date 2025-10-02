extends Node

const MAIN_MENU_SCENE_PATH = "res://main_menu/MainMenu.tscn"

var save_manager: SaveManager = SaveManager.new()
var viewport

@onready var board = $Board
@onready var planner_ui = $%PlannerUI
@onready var input_listener = $InputListener

func _ready():
  board.create_board()
  board.load_scene(SceneContext.current_scene.data)
  planner_ui.set_tile_resources(SceneContext.tile_resources)
  planner_ui.tile_selected.connect(SceneContext.update_selected_tile)
  planner_ui.new_scene.connect(new_scene)
  planner_ui.save_current_scene.connect(save_scene)
  planner_ui.load_scene.connect(load_scene)
  planner_ui.set_recent_scenes(save_manager.scenes)
  planner_ui.quit_scene.connect(quit_scene)
  viewport = get_viewport()
  viewport.size_changed.connect(on_viewport_resized)

func new_scene():
  var new_data = TileLayout.new()
  SceneContext.current_scene.data = new_data
  board.load_scene(new_data)

func save_scene(scene: Scene):
  SceneContext.current_scene = scene
  save_manager.save_scene_to_user(scene)

func load_scene(scene: Scene):
  SceneContext.set_current_scene(scene)
  board.load_scene(scene.data)

func quit_scene():
  # Can't preload main menu scene because it causes circular dependencies
  var main_menu_scene = load(MAIN_MENU_SCENE_PATH)
  var error = get_tree().change_scene_to_packed(main_menu_scene)
  if error != OK:
    push_error("Failed to change scene: " + str(error))

func on_viewport_resized():
  planner_ui.on_viewport_resized(viewport.size)
