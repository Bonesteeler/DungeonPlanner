extends GutTest

const LAYER_ID = 0

const SOURCE_PATH_A = "res://tiles/a_tile.stl"
const SOURCE_PATH_B = "res://tiles/b_tile.stl"

var resources: TileResources
var view_model: ExportDialogViewModel


func before_each() -> void:
	resources = TileResources.new(false)
	var tile_set = DragonbiteTileSet.new()
	tile_set.name = "set_a"
	var tile = Tile.new()
	tile.id = "id_a"
	tile.source_path = SOURCE_PATH_A
	tile_set.tiles = [tile] as Array[Tile]
	resources.add_set(tile_set)
	view_model = ExportDialogViewModel.new(resources)


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


func _entries_by_id() -> Dictionary:
	var entries = {}
	for entry in view_model.get_entries():
		entries[entry.tile_id] = entry
	return entries


func test_is_empty_for_empty_scene() -> void:
	view_model.open(_scene_with_tile_ids([]))
	assert_true(view_model.is_empty())


func test_entry_uses_source_path_for_imported_tile() -> void:
	view_model.open(_scene_with_tile_ids(["id_a"]))
	var entry: ExportTileEntry = _entries_by_id()["id_a"]
	assert_eq(SOURCE_PATH_A, entry.source_path)
	assert_eq(SOURCE_PATH_A, entry.display_text())


func test_entry_falls_back_to_tile_id_when_not_imported() -> void:
	view_model.open(_scene_with_tile_ids(["id_missing"]))
	var entry: ExportTileEntry = _entries_by_id()["id_missing"]
	assert_eq("", entry.source_path)
	assert_eq("id_missing", entry.display_text())


func test_entries_with_source_paths_sorted_lexicographically_first() -> void:
	var tile_set = DragonbiteTileSet.new()
	tile_set.name = "set_b"
	var tile = Tile.new()
	tile.id = "id_b"
	tile.source_path = SOURCE_PATH_B
	tile_set.tiles = [tile] as Array[Tile]
	resources.add_set(tile_set)
	view_model.open(_scene_with_tile_ids(["id_b", "id_missing", "id_a"]))
	var ids = []
	for entry in view_model.get_entries():
		ids.append(entry.tile_id)
	assert_eq(["id_a", "id_b", "id_missing"], ids)


func test_entries_without_source_paths_sorted_by_count_descending() -> void:
	view_model.open(
		_scene_with_tile_ids(["id_low", "id_high", "id_high", "id_mid", "id_mid", "id_mid"])
	)
	var ids = []
	for entry in view_model.get_entries():
		ids.append(entry.tile_id)
	assert_eq(["id_mid", "id_high", "id_low"], ids)


func test_build_export_payload_uses_sorted_entries() -> void:
	view_model.open(_scene_with_tile_ids(["id_a", "id_missing", "id_a"]))
	assert_eq(
		[{"source_path": SOURCE_PATH_A, "count": 2}, {"tile_id": "id_missing", "count": 1}],
		view_model.build_export_payload()
	)
