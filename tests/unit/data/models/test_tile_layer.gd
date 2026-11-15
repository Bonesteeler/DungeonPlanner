extends GutTest

var layer: TileLayer


func before_each() -> void:
	# Fresh TileLayer for each test
	layer = TileLayer.new()


func test_set_tile_and_get_tile_at() -> void:
	var tile = Tile.new()
	tile.id = "tile_a"
	tile.x_size = 1
	tile.y_size = 1

	layer.set_tile_at(2, 3, tile, Vector3.ZERO)

	assert_true(layer.has_tile_at(2, 3))
	var found = layer.get_tile_at(2, 3)
	assert_true(found != null)
	assert_eq("tile_a", found.id)


func test_remove_tile_at() -> void:
	var tile = Tile.new()
	tile.id = "tile_b"
	tile.x_size = 1
	tile.y_size = 1

	layer.set_tile_at(0, 0, tile, Vector3.ZERO)
	assert_true(layer.has_tile_at(0, 0))

	layer.remove_tile_at(0, 0)
	assert_false(layer.has_tile_at(0, 0))


func test_get_origin_tile_for_occupied_space() -> void:
	# 2x2 tile placed at origin should report origin when queried from occupied cell
	var tile = Tile.new()
	tile.id = "tile_c"
	tile.x_size = 2
	tile.y_size = 2

	layer.set_tile_at(0, 0, tile, Vector3.ZERO)

	# The 2x2 tile placed at (0,0) occupies (0,0),(0,1),(1,0),(1,1)
	var origin = layer.get_origin_tile(Vector2(1, 1))
	assert_true(origin != null)
	assert_eq("tile_c", origin.id)
	# Origin coordinate returns the same placed tile
	var origin_at_origin = layer.get_origin_tile(Vector2(0, 0))
	assert_true(origin_at_origin != null)
	assert_eq("tile_c", origin_at_origin.id)


func test_does_tile_fit_detects_overlap_and_bounds() -> void:
	# Place a 2x2 tile at (0,0)
	var big_tile = Tile.new()
	big_tile.id = "big"
	big_tile.x_size = 2
	big_tile.y_size = 2

	layer.set_tile_at(0, 0, big_tile, Vector3.ZERO)

	# Small tile overlapping at (1,1) should NOT fit
	var small_tile = Tile.new()
	small_tile.id = "small"
	small_tile.x_size = 1
	small_tile.y_size = 1

	assert_false(layer.does_tile_fit(small_tile, Vector2(1, 1), Vector3.ZERO))
	# Placing away from occupied spaces should fit
	assert_true(layer.does_tile_fit(small_tile, Vector2(3, 3), Vector3.ZERO))

	# Out of bounds placement should fail
	assert_false(layer.does_tile_fit(small_tile, Vector2(-1, 0), Vector3.ZERO))
	assert_false(layer.does_tile_fit(small_tile, Vector2(TileLayer.SIZE.x, 0), Vector3.ZERO))
