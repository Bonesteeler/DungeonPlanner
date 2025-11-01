extends GutTest

func test_tile_offsets_1x1():
  var tile = Tile.new()
  var placed_tile = PlacedTile.new()
  tile.x_size = 1
  tile.y_size = 1
  placed_tile.position = Vector2(0, 0)
  placed_tile.rotation = Vector3(0, 0, 0)
  placed_tile.tile_data = tile
  assert_eq(placed_tile.occupied_spaces.size(), 1, "1x1 tile should occupy 1 space")
  assert_true(placed_tile.occupied_spaces.has(Vector2(0, 0)), "1x1 tile should occupy (0,0)")

func test_tile_offsets_2x2():
  var tile = Tile.new()
  var placed_tile = PlacedTile.new()
  tile.x_size = 2
  tile.y_size = 2
  placed_tile.position = Vector2(0, 0)
  placed_tile.rotation = Vector3(0, 0, 0)
  placed_tile.tile_data = tile
  assert_eq(placed_tile.occupied_spaces.size(), 4, "2x2 tile should occupy 4 spaces")
  assert_eq(placed_tile.occupied_spaces, [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1)], "2x2 tile occupied spaces mismatch")

func test_tile_offsets_3x3():
  var tile = Tile.new()
  var placed_tile = PlacedTile.new()
  tile.x_size = 3
  tile.y_size = 3
  placed_tile.position = Vector2(0, 0)
  placed_tile.rotation = Vector3(0, 0, 0)
  placed_tile.tile_data = tile
  assert_eq(placed_tile.occupied_spaces.size(), 9, "3x3 tile should occupy 9 spaces")
  assert_eq(placed_tile.occupied_spaces, [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)], "3x3 tile occupied spaces mismatch")