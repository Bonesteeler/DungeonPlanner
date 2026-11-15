extends GutTest

var base_dir := "user://test_tile"

var ascii_stl := """solid test
facet normal 0 0 1
 outer loop
  vertex 0 0 0
  vertex 50 0 0
  vertex 0 50 0
 endloop
endfacet
endsolid test
"""


func delete_directory(path: String) -> void:
	var d := DirAccess.open(path)
	if d == null:
		return
	d.list_dir_begin()
	var item := d.get_next()
	while item != "":
		var full_path := path + "/" + item
		if FileAccess.file_exists(full_path):
			d.remove(full_path)
		elif DirAccess.dir_exists_absolute(full_path):
			delete_directory(full_path)
			d.remove(full_path)
		item = d.get_next()
	d.list_dir_end()


func before_each():
	var dir := DirAccess.open("user://")
	dir.make_dir_recursive(base_dir)


func after_each():
	delete_directory(base_dir)


func test_create_tile_imports_source_path():
	var source_path := base_dir + "/source.stl"
	File.write_file_as_text(source_path, ascii_stl)
	var tile := Tile.new()
	var status = tile.create_tile(source_path, base_dir + "/tile.res")
	assert_eq(status, Tile.TileStatus.CREATED, "Tile should be created from a valid STL")
	assert_eq(
		tile.source_path, source_path, "source_path should be the STL file passed to create_tile"
	)


func test_create_tile_missing_source_doesnt_set_source_path():
	var source_path := base_dir + "/missing.stl"
	var tile := Tile.new()
	var status = tile.create_tile(source_path, base_dir + "/tile.res")
	assert_eq(status, Tile.TileStatus.NOT_FOUND, "Missing source file should return NOT_FOUND")
	assert_eq(tile.source_path, "", "source_path should not be set when the source file is missing")


func test_create_tile_existing_destination_still_sets_source_path():
	var source_path := base_dir + "/source.stl"
	File.write_file_as_text(source_path, ascii_stl)
	var destination_path := base_dir + "/tile.res"
	File.write_file_as_text(destination_path, "already here")
	var tile := Tile.new()
	var status = tile.create_tile(source_path, destination_path)
	assert_eq(status, Tile.TileStatus.CACHED, "Existing destination should return CACHED")
	assert_eq(
		tile.source_path,
		source_path,
		"source_path should be set even when the destination already exists"
	)


func test_load_imported_tile_restores_source_path():
	var res_path := base_dir + "/tile.res"
	File.write_file_as_text(res_path, "mesh resource placeholder")
	var tile := Tile.new()
	var status = (
		tile
		. load_imported_tile(
			{
				DragonbiteTileSet.KEY_TILE_RES_PATH: res_path,
				DragonbiteTileSet.KEY_TILE_NAME: "tile",
				DragonbiteTileSet.KEY_TILE_ID: "abc123",
				DragonbiteTileSet.KEY_TILE_SOURCE_PATH: "/import/dir/tile.stl",
				DragonbiteTileSet.KEY_TILE_X_SIZE: 1,
				DragonbiteTileSet.KEY_TILE_Y_SIZE: 1,
			}
		)
	)
	assert_eq(status, Tile.TileStatus.CACHED, "Existing mesh resource should return CACHED")
	assert_eq(
		tile.source_path, "/import/dir/tile.stl", "source_path should be restored from the JSON"
	)


func test_load_imported_tile_without_source_path_defaults_to_empty():
	var res_path := base_dir + "/tile.res"
	File.write_file_as_text(res_path, "mesh resource placeholder")
	var tile := Tile.new()
	var status = (
		tile
		. load_imported_tile(
			{
				DragonbiteTileSet.KEY_TILE_RES_PATH: res_path,
				DragonbiteTileSet.KEY_TILE_NAME: "tile",
				DragonbiteTileSet.KEY_TILE_ID: "abc123",
				DragonbiteTileSet.KEY_TILE_X_SIZE: 1,
				DragonbiteTileSet.KEY_TILE_Y_SIZE: 1,
			}
		)
	)
	assert_eq(status, Tile.TileStatus.CACHED, "Existing mesh resource should return CACHED")
	assert_eq(tile.source_path, "", "source_path should default to empty for old set definitions")
