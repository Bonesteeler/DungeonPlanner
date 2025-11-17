extends GutTest

var view_model: SetDetailsItemViewModel

func before_each():
	view_model = SetDetailsItemViewModel.new()

func test_initial_state():
	assert_null(view_model.tile, "tile should start as null")

func test_set_tile_updates_property():
	var tile = Tile.new()
	tile.name = "TestTile"
	
	view_model.set_tile(tile)
	
	assert_not_null(view_model.tile, "tile should be set")
	assert_eq(view_model.tile.name, "TestTile", "Should have correct tile")

func test_set_tile_emits_signal():
	watch_signals(view_model)
	
	var tile = Tile.new()
	tile.name = "SignalTile"
	
	view_model.set_tile(tile)
	
	assert_signal_emitted(view_model, "tile_changed", "Should emit tile_changed signal")

func test_set_tile_does_not_emit_if_same_tile():
	var tile = Tile.new()
	tile.name = "SameTile"
	
	view_model.set_tile(tile)
	
	watch_signals(view_model)
	view_model.set_tile(tile)
	
	assert_signal_not_emitted(view_model, "tile_changed", "Should not emit if tile is the same")

func test_set_tile_emits_when_changing_tiles():
	var tile1 = Tile.new()
	tile1.name = "Tile1"
	var tile2 = Tile.new()
	tile2.name = "Tile2"
	
	view_model.set_tile(tile1)
	
	watch_signals(view_model)
	view_model.set_tile(tile2)
	
	assert_signal_emitted(view_model, "tile_changed", "Should emit when changing to a different tile")
	assert_eq(view_model.tile.name, "Tile2", "Should have updated to new tile")

func test_set_tile_to_null():
	var tile = Tile.new()
	tile.name = "TempTile"
	view_model.set_tile(tile)
	
	watch_signals(view_model)
	view_model.set_tile(null)
	
	assert_signal_emitted(view_model, "tile_changed", "Should emit when setting to null")
	assert_null(view_model.tile, "tile should be null")
