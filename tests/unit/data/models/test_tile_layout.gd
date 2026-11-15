extends GutTest

var layout: TileLayout
var test_layer_id: int = 0


func before_each() -> void:
	# Fresh TileLayout for each test
	layout = TileLayout.new()
	# Create a default layer for testing
	var layer = TileLayer.new()
	layer.id = test_layer_id
	layout.layers.append(layer)
	layout.current_layer = layer


func test_set_tile_and_get_tile_at() -> void:
	var tile = Tile.new()
	tile.id = "tile_a"
	tile.x_size = 1
	tile.y_size = 1

	layout.set_tile_at(test_layer_id, 2, 3, tile, Vector3.ZERO)

	assert_true(layout.has_tile_at(test_layer_id, 2, 3))
	var found = layout.get_tile_at(test_layer_id, 2, 3)
	assert_true(found != null)
	assert_eq("tile_a", found.tile_data.id)


func test_remove_tile_at() -> void:
	var tile = Tile.new()
	tile.id = "tile_b"
	tile.x_size = 1
	tile.y_size = 1

	layout.set_tile_at(test_layer_id, 0, 0, tile, Vector3.ZERO)
	assert_true(layout.has_tile_at(test_layer_id, 0, 0))

	layout.remove_tile_at(test_layer_id, 0, 0)
	assert_false(layout.has_tile_at(test_layer_id, 0, 0))


func test_get_origin_tile_for_occupied_space() -> void:
	# 2x2 tile placed at origin should report origin when queried from occupied cell
	var tile = Tile.new()
	tile.id = "tile_c"
	tile.x_size = 2
	tile.y_size = 2

	layout.set_tile_at(test_layer_id, 0, 0, tile, Vector3.ZERO)

	# The 2x2 tile placed at (0,0) occupies (0,0),(0,1),(1,0),(1,1)
	var origin = layout.get_origin_tile(test_layer_id, Vector2(1, 1))
	assert_true(origin != null)
	assert_eq("tile_c", origin.tile_data.id)
	# Origin coordinate returns the same placed tile
	var origin_at_origin = layout.get_origin_tile(test_layer_id, Vector2(0, 0))
	assert_true(origin_at_origin != null)
	assert_eq("tile_c", origin_at_origin.tile_data.id)


func test_does_tile_fit_detects_overlap_and_bounds() -> void:
	# Place a 2x2 tile at (0,0)
	var big_tile = Tile.new()
	big_tile.id = "big"
	big_tile.x_size = 2
	big_tile.y_size = 2

	layout.set_tile_at(test_layer_id, 0, 0, big_tile, Vector3.ZERO)

	# Small tile overlapping at (1,1) should NOT fit
	var small_tile = Tile.new()
	small_tile.id = "small"
	small_tile.x_size = 1
	small_tile.y_size = 1

	assert_false(layout.does_tile_fit(test_layer_id, small_tile, Vector2(1, 1), Vector3.ZERO))
	# Placing away from occupied spaces should fit
	assert_true(layout.does_tile_fit(test_layer_id, small_tile, Vector2(3, 3), Vector3.ZERO))

	# Out of bounds placement should fail
	assert_false(layout.does_tile_fit(test_layer_id, small_tile, Vector2(-1, 0), Vector3.ZERO))
	assert_false(
		layout.does_tile_fit(test_layer_id, small_tile, Vector2(TileLayout.SIZE.x, 0), Vector3.ZERO)
	)


func test_get_unique_tile_ids() -> void:
	# Place tiles using set_tile_at so PlacedTile objects are created correctly
	var tile_a = Tile.new()
	tile_a.id = "id_a"
	tile_a.x_size = 1
	tile_a.y_size = 1
	layout.set_tile_at(test_layer_id, 0, 0, tile_a, Vector3.ZERO)

	var tile_b = Tile.new()
	tile_b.id = "id_b"
	tile_b.x_size = 1
	tile_b.y_size = 1
	layout.set_tile_at(test_layer_id, 1, 1, tile_b, Vector3.ZERO)

	# duplicate id should only appear once
	var tile_a_dup = Tile.new()
	tile_a_dup.id = "id_a"
	tile_a_dup.x_size = 1
	tile_a_dup.y_size = 1
	layout.set_tile_at(test_layer_id, 2, 2, tile_a_dup, Vector3.ZERO)

	var unique = layout.get_unique_tile_ids()
	assert_true(unique.has("id_a"))
	assert_true(unique.has("id_b"))
	assert_eq(2, unique.size())


func _place_tile(tile_id: String, x: int, z: int) -> void:
	var tile = Tile.new()
	tile.id = tile_id
	tile.x_size = 1
	tile.y_size = 1
	layout.set_tile_at(test_layer_id, x, z, tile, Vector3.ZERO)


func test_get_tile_counts_empty_layout() -> void:
	assert_eq({}, layout.get_tile_counts())


func test_get_tile_counts_distinct_ids() -> void:
	_place_tile("id_a", 0, 0)
	_place_tile("id_b", 1, 1)
	assert_eq({"id_a": 1, "id_b": 1}, layout.get_tile_counts())


func test_get_tile_counts_accumulates_duplicates() -> void:
	_place_tile("id_a", 0, 0)
	_place_tile("id_a", 1, 1)
	_place_tile("id_b", 2, 2)
	assert_eq({"id_a": 2, "id_b": 1}, layout.get_tile_counts())


func test_get_tile_counts_accumulates_across_layers() -> void:
	_place_tile("id_a", 0, 0)
	_place_tile("id_a", 1, 1)

	var second_layer = TileLayer.new()
	second_layer.id = 1
	layout.layers.append(second_layer)

	var tile = Tile.new()
	tile.id = "id_a"
	tile.x_size = 1
	tile.y_size = 1
	layout.set_tile_at(second_layer.id, 0, 0, tile, Vector3.ZERO)

	assert_eq({"id_a": 3}, layout.get_tile_counts())


func test_get_tile_counts_includes_tiles_without_tile_data() -> void:
	_place_tile("id_a", 0, 0)
	layout.current_layer.tiles.append(PlacedTile.new())
	layout.current_layer.tiles.append(PlacedTile.new())
	assert_eq({"id_a": 1, "": 2}, layout.get_tile_counts())
