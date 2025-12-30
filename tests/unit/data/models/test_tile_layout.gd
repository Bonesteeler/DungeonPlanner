extends GutTest

var layout: TileLayout

func before_each():
  # Fresh TileLayout for each test
  layout = TileLayout.new()

func test_set_tile_and_get_tile_at():
  var tile = Tile.new()
  tile.id = "tile_a"
  tile.x_size = 1
  tile.y_size = 1

  var ctx = SceneTileViewModel.new()
  ctx.tile = tile
  ctx.rotation = Vector3.ZERO

  layout.set_tile_at(2, 3, ctx)

  assert_true(layout.has_tile_at(2, 3))
  var found = layout.get_tile_at(2, 3)
  assert_true(found != null)
  assert_eq("tile_a", found.id)

func test_remove_tile_at():
  var tile = Tile.new()
  tile.id = "tile_b"
  tile.x_size = 1
  tile.y_size = 1

  var ctx = SceneTileViewModel.new()
  ctx.tile = tile
  ctx.rotation = Vector3.ZERO

  layout.set_tile_at(0, 0, ctx)
  assert_true(layout.has_tile_at(0, 0))

  layout.remove_tile_at(0, 0)
  assert_false(layout.has_tile_at(0, 0))

func test_get_origin_tile_for_occupied_space():
  # 2x2 tile placed at origin should report origin when queried from occupied cell
  var tile = Tile.new()
  tile.id = "tile_c"
  tile.x_size = 2
  tile.y_size = 2

  var ctx = SceneTileViewModel.new()
  ctx.tile = tile
  ctx.rotation = Vector3.ZERO

  layout.set_tile_at(0, 0, ctx)

  # The 2x2 tile placed at (0,0) occupies (0,0),(0,1),(1,0),(1,1)
  var origin = layout.get_origin_tile(Vector2(1, 1))
  assert_true(origin != null)
  assert_eq("tile_c", origin.id)
  # Origin coordinate returns the same placed tile
  var origin_at_origin = layout.get_origin_tile(Vector2(0, 0))
  assert_true(origin_at_origin != null)
  assert_eq("tile_c", origin_at_origin.id)

func test_does_tile_fit_detects_overlap_and_bounds():
  # Place a 2x2 tile at (0,0)
  var big_tile = Tile.new()
  big_tile.id = "big"
  big_tile.x_size = 2
  big_tile.y_size = 2

  var ctx_big = SceneTileViewModel.new()
  ctx_big.tile = big_tile
  ctx_big.rotation = Vector3.ZERO

  layout.set_tile_at(0, 0, ctx_big)

  # Small tile overlapping at (1,1) should NOT fit
  var small_tile = Tile.new()
  small_tile.id = "small"
  small_tile.x_size = 1
  small_tile.y_size = 1

  var ctx_small = SceneTileViewModel.new()
  ctx_small.tile = small_tile
  ctx_small.rotation = Vector3.ZERO

  assert_false(layout.does_tile_fit(small_tile, Vector2(1, 1), ctx_small.rotation))
  # Placing away from occupied spaces should fit
  assert_true(layout.does_tile_fit(small_tile, Vector2(3, 3), ctx_small.rotation))

  # Out of bounds placement should fail
  assert_false(layout.does_tile_fit(small_tile, Vector2(-1, 0), ctx_small.rotation))
  assert_false(layout.does_tile_fit(small_tile, Vector2(TileLayout.SIZE.x, 0), ctx_small.rotation))

func test_get_unique_tile_ids():
  # Place tiles using set_tile_at so PlacedTile objects are created correctly
  var tile_a = Tile.new(); tile_a.id = "id_a"; tile_a.x_size = 1; tile_a.y_size = 1
  var ctx_a = SceneTileViewModel.new()
  ctx_a.tile = tile_a
  ctx_a.rotation = Vector3.ZERO
  layout.set_tile_at(0, 0, ctx_a)

  var tile_b = Tile.new(); tile_b.id = "id_b"; tile_b.x_size = 1; tile_b.y_size = 1
  var ctx_b = SceneTileViewModel.new()
  ctx_b.tile = tile_b
  ctx_b.rotation = Vector3.ZERO
  layout.set_tile_at(1, 1, ctx_b)

  # duplicate id should only appear once
  var tile_a_dup = Tile.new(); tile_a_dup.id = "id_a"; tile_a_dup.x_size = 1; tile_a_dup.y_size = 1
  var ctx_a_dup = SceneTileViewModel.new()
  ctx_a_dup.tile = tile_a_dup
  ctx_a_dup.rotation = Vector3.ZERO
  layout.set_tile_at(2, 2, ctx_a_dup)

  var unique = layout.get_unique_tile_ids()
  assert_true(unique.has("id_a"))
  assert_true(unique.has("id_b"))
  assert_eq(2, unique.size())
