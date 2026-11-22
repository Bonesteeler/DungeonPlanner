extends GutTest

var test_dir := "user://test_stl_to_mesh"
var binary_path := test_dir + "/test.stl"
var converter: StlToMesh


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


func before_each() -> void:
	var dir := DirAccess.open("user://")
	dir.make_dir_recursive(test_dir)
	var ascii_path := test_dir + "/converter.stl"
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
	File.write_file_as_text(ascii_path, ascii_stl)
	converter = StlToMesh.new(ascii_path)


func after_each() -> void:
	delete_directory(test_dir)


func write_binary_stl(path: String, facet_count: int, facet_values: Array = []) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	var header := PackedByteArray()
	header.resize(80)
	file.store_buffer(header)
	file.store_32(facet_count)
	for value in facet_values:
		file.store_float(value)
	if !facet_values.is_empty():
		file.store_16(0)
	file.close()


func test_convert_binary_rejects_excessive_facet_count() -> void:
	write_binary_stl(binary_path, 0xFFFFFFFF)
	var file := FileAccess.open(binary_path, FileAccess.READ)

	var triangles := converter.convert_binary(file)
	file.close()

	assert_push_error("Invalid binary STL facet count")
	assert_true(triangles.is_empty(), "An impossible facet count should return no triangles")


func test_convert_binary_rejects_truncated_header() -> void:
	var file := FileAccess.open(binary_path, FileAccess.WRITE)
	var bytes := PackedByteArray()
	bytes.resize(83)
	file.store_buffer(bytes)
	file.close()
	file = FileAccess.open(binary_path, FileAccess.READ)

	var triangles := converter.convert_binary(file)
	file.close()

	assert_push_error("Invalid binary STL: file is too short")
	assert_true(triangles.is_empty(), "A truncated header should return no triangles")


func test_convert_binary_rejects_truncated_facet() -> void:
	write_binary_stl(binary_path, 1, [0.0, 0.0, 1.0])
	var file := FileAccess.open(binary_path, FileAccess.READ)

	var triangles := converter.convert_binary(file)
	file.close()

	assert_push_error("Invalid binary STL facet count")
	assert_true(triangles.is_empty(), "A truncated facet should return no triangles")


func test_convert_binary_parses_valid_facet() -> void:
	write_binary_stl(
		binary_path,
		1,
		[0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 50.0, 0.0, 0.0, 0.0, 50.0, 0.0]
	)
	var file := FileAccess.open(binary_path, FileAccess.READ)

	var triangles := converter.convert_binary(file)
	file.close()

	assert_eq(triangles.size(), 1, "A valid binary STL should contain one triangle")
	assert_eq(triangles[0].normal, Vector3(0, 0, 1))
	assert_eq(triangles[0].vertices[0], Vector3(0, 50, 0))
	assert_eq(triangles[0].vertices[1], Vector3(50, 0, 0))
	assert_eq(triangles[0].vertices[2], Vector3(0, 0, 0))
