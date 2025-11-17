extends GutTest

var resources: TileResources

func before_each():
  # Fresh TileResources for each test
  resources = TileResources.new(false)

func test_add_single_set():
  var set_test = DragonbiteTileSet.new()
  set_test.name = "set_a"
  var tile_test = Tile.new()
  tile_test.id = "id_a"
  tile_test.name = "Tile A"
  set_test.tiles = [tile_test]
  resources.add_set(set_test)

  assert_true(resources.unique_tile_ids.has("id_a"))
  assert_eq(1, resources.tile_sets.size())

  # Non-existent id returns nulls
  var missing = resources.get_set_and_tile_data("no_such_id")
  assert_eq(null, missing[TileResources.KEY_SET])
  assert_eq(null, missing[TileResources.KEY_TILE])

func test_has_tile_ids():
  var set_test = DragonbiteTileSet.new()
  set_test.name = "set_c"
  var tile1_test = Tile.new(); tile1_test.id = "t1"
  var tile2_test = Tile.new(); tile2_test.id = "t2"
  set_test.tiles = [tile1_test, tile2_test]
  resources.add_set(set_test)

  assert_true(resources.has_tile_ids(["t1"]))
  assert_true(resources.has_tile_ids(["t1", "t2"]))
  assert_false(resources.has_tile_ids(["missing_id"]))

func test_has_tile_ids_multiple_sets():
  var set1 = DragonbiteTileSet.new()
  set1.name = "set_1"
  var tile1 = Tile.new(); tile1.id = "t1"
  set1.tiles = [tile1]
  resources.add_set(set1)

  var set2 = DragonbiteTileSet.new()
  set2.name = "set_2"
  var tile2 = Tile.new(); tile2.id = "t2"
  set2.tiles = [tile2]
  resources.add_set(set2)

  assert_true(resources.has_tile_ids(["t1", "t2"]))

func test_remove_set_cleans_ids_and_sets():
  var set_test = DragonbiteTileSet.new()
  set_test.name = "set_d"
  var tile_test = Tile.new()
  tile_test.id = "id_d"
  set_test.tiles = [tile_test]
  resources.add_set(set_test)

  # Ensure added
  assert_true(resources.unique_tile_ids.has("id_d"))
  assert_eq(1, resources.tile_sets.size())

  # Remove and verify cleanup
  resources.remove_set("set_d")
  # Expect file not found error
  assert_push_error(1, "File not found should have errored")
  assert_false(resources.unique_tile_ids.has("id_d"))
  assert_eq(0, resources.tile_sets.size())

func test_get_selected_set_out_of_bounds_returns_null():
  # No sets added, selected_set_idx out of range -> should return null
  resources.selected_set_idx = 5
  var result = resources.get_selected_set()
  assert_eq(null, result)