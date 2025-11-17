extends GutTest

var view_model: SetDetailsViewModel

func before_each():
  view_model = SetDetailsViewModel.new()

func test_initial_state():
  assert_null(view_model.current_set, "Should start with null current_set")
  assert_eq(view_model.get_current_set_name(), "", "Should return empty string when no set is selected")
  assert_eq(view_model.get_current_set_tiles().size(), 0, "Should return empty array when no set is selected")

func test_set_current_set_updates_property():
  var tile_set = DragonbiteTileSet.new()
  tile_set.name = "TestSet"

  view_model.set_current_set(tile_set)

  assert_not_null(view_model.current_set, "current_set should be set")
  assert_eq(view_model.current_set.name, "TestSet", "Should have correct set")

func test_set_current_set_emits_signal():
  watch_signals(view_model)

  var tile_set = DragonbiteTileSet.new()
  tile_set.name = "SignalSet"

  view_model.set_current_set(tile_set)

  assert_signal_emitted(view_model, "current_set_changed", "Should emit current_set_changed")

func test_get_current_set_name_returns_set_name():
  var tile_set = DragonbiteTileSet.new()
  tile_set.name = "MyTileSet"
  view_model.set_current_set(tile_set)

  var result = view_model.get_current_set_name()

  assert_eq(result, "MyTileSet", "Should return the set name")

func test_get_current_set_tiles_returns_tiles():
  var tile_set = DragonbiteTileSet.new()
  tile_set.name = "TileSet"

  var tile1 = Tile.new()
  tile1.name = "Tile1"
  var tile2 = Tile.new()
  tile2.name = "Tile2"

  tile_set.tiles.append(tile1)
  tile_set.tiles.append(tile2)

  view_model.set_current_set(tile_set)

  var tiles = view_model.get_current_set_tiles()

  assert_eq(tiles.size(), 2, "Should return all tiles from the set")
  assert_eq(tiles[0].name, "Tile1", "First tile should be correct")
  assert_eq(tiles[1].name, "Tile2", "Second tile should be correct")

func test_changing_set_updates_tiles():
  var set1 = DragonbiteTileSet.new()
  set1.name = "Set1"
  var tile1 = Tile.new()
  tile1.name = "Tile1"
  set1.tiles.append(tile1)

  var set2 = DragonbiteTileSet.new()
  set2.name = "Set2"
  var tile2 = Tile.new()
  tile2.name = "Tile2"
  var tile3 = Tile.new()
  tile3.name = "Tile3"
  set2.tiles.append(tile2)
  set2.tiles.append(tile3)

  view_model.set_current_set(set1)
  assert_eq(view_model.get_current_set_tiles().size(), 1, "Should have 1 tile from set1")

  view_model.set_current_set(set2)
  assert_eq(view_model.get_current_set_tiles().size(), 2, "Should have 2 tiles from set2")