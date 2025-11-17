extends GutTest

var view_model: TileDetailsViewModel

func before_each():
  view_model = TileDetailsViewModel.new()

func test_update_tile_sets_property():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.x_size = 2
  tile.y_size = 3

  view_model.update_tile(tile)

  assert_not_null(view_model.tile, "tile should be set")
  assert_eq(view_model.tile.name, "TestTile", "Should have correct tile")

func test_update_tile_emits_signal():
  watch_signals(view_model)

  var tile = Tile.new()
  tile.name = "SignalTile"

  view_model.update_tile(tile)

  assert_signal_emitted(view_model, "tile_changed", "Should emit tile_changed signal")

func test_get_width_text_format():
  var tile = Tile.new()
  tile.x_size = 3
  tile.y_size = 2

  view_model.update_tile(tile)

  var result = view_model.get_width_text()

  assert_eq(result, "Width: 6", "Should format width as x_size * 2")

func test_get_height_text_format():
  var tile = Tile.new()
  tile.x_size = 3
  tile.y_size = 4

  view_model.update_tile(tile)

  var result = view_model.get_height_text()

  assert_eq(result, "Length: 8", "Should format height as y_size * 2")

func test_get_width_text_with_1x1_tile():
  var tile = Tile.new()
  tile.x_size = 1
  tile.y_size = 1

  view_model.update_tile(tile)

  assert_eq(view_model.get_width_text(), "Width: 2", "1x1 tile should show Width: 2")
  assert_eq(view_model.get_height_text(), "Length: 2", "1x1 tile should show Length: 2")

func test_multiple_tile_updates():
  watch_signals(view_model)

  var tile1 = Tile.new()
  tile1.x_size = 2
  tile1.y_size = 2

  var tile2 = Tile.new()
  tile2.x_size = 3
  tile2.y_size = 4

  view_model.update_tile(tile1)
  assert_eq(view_model.get_width_text(), "Width: 4", "Should show first tile dimensions")

  view_model.update_tile(tile2)
  assert_eq(view_model.get_width_text(), "Width: 6", "Should update to second tile dimensions")
  assert_eq(view_model.get_height_text(), "Length: 8", "Should update to second tile dimensions")

  assert_signal_emit_count(view_model, "tile_changed", 2, "Should emit signal for each update")
