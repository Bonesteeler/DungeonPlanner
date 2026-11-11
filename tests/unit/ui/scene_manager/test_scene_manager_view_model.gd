extends GutTest

const LAYER_ID = 0

var resources: TileResources
var view_model: SceneManagerViewModel

func before_each():
  resources = TileResources.new(false)
  var tile_set = DragonbiteTileSet.new()
  tile_set.name = "set_a"
  var tile = Tile.new()
  tile.id = "id_a"
  tile_set.tiles = [tile] as Array[Tile]
  resources.add_set(tile_set)
  view_model = SceneManagerViewModel.new(SceneSaveService, resources)

func _scene_with_tile_ids(tile_ids: Array) -> Scene:
  var scene = Scene.new()
  var layer = TileLayer.new()
  layer.id = LAYER_ID
  for i in range(tile_ids.size()):
    var tile = Tile.new()
    tile.id = tile_ids[i]
    var placed = PlacedTile.new()
    placed.tile_data = tile
    layer.tiles.append(placed)
  scene.data.layers.append(layer)
  return scene

func test_status_available_when_all_tiles_present():
  var scene = _scene_with_tile_ids(["id_a"])
  assert_eq(SceneManagerViewModel.TILES_AVAILABLE_TEXT, view_model.get_tiles_status_text(scene))

func test_status_missing_when_a_tile_absent():
  var scene = _scene_with_tile_ids(["id_a", "id_missing"])
  assert_eq(SceneManagerViewModel.TILES_MISSING_TEXT, view_model.get_tiles_status_text(scene))

func test_status_available_for_empty_scene():
  var scene = _scene_with_tile_ids([])
  assert_eq(SceneManagerViewModel.TILES_AVAILABLE_TEXT, view_model.get_tiles_status_text(scene))

func test_get_missing_tile_ids_returns_absent_ids():
  var scene = _scene_with_tile_ids(["id_a", "id_missing_1", "id_missing_2"])
  assert_eq(["id_missing_1", "id_missing_2"], view_model.get_missing_tile_ids(scene))

func test_get_missing_tile_ids_empty_when_all_present():
  var scene = _scene_with_tile_ids(["id_a"])
  assert_eq([], view_model.get_missing_tile_ids(scene))

func test_tile_sets_changed_refreshes_scene_lists():
  watch_signals(view_model)
  var tile_set = DragonbiteTileSet.new()
  tile_set.name = "set_b"
  var tile = Tile.new()
  tile.id = "id_b"
  tile_set.tiles = [tile] as Array[Tile]
  resources.add_set(tile_set)
  assert_signal_emitted(view_model, "scenes_updated")
  assert_signal_emitted(view_model, "recent_scenes_updated")
