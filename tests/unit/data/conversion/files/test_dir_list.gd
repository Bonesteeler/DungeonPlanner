extends GutTest

var base_dir := "user://test_dirlist"

func delete_directory(path: String) -> void:
  var d := DirAccess.open(path)
  if (d == null):
    return
  d.list_dir_begin()
  var item := d.get_next()
  while (item != ''):
    var full_path := path + "/" + item
    if (FileAccess.file_exists(full_path)):
      d.remove(full_path)
    elif (DirAccess.dir_exists_absolute(full_path)):
      delete_directory(full_path)
      d.remove(full_path)
    item = d.get_next()
  d.list_dir_end()

func before_each():
  var dir := DirAccess.open("user://")
  dir.make_dir_recursive(base_dir)

func after_each():
  delete_directory(base_dir)

func test_get_files_path_ext():
  var test_path := base_dir + "/test1.stl"
  File.write_file_as_text(test_path, "Test content 1")
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("stl", DirList.Mode.PATH_WITH_EXT)
  assert_eq(files.size(), 1)
  assert_eq(files[0], test_path)

func test_get_files_path_no_ext():
  var test_path := base_dir + "/test1.stl"
  File.write_file_as_text(test_path, "Test content 1")
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("stl", DirList.Mode.PATH_NO_EXT)
  assert_eq(files.size(), 1)
  assert_eq(files[0], base_dir + "/test1")

func test_get_files_name_no_ext():
  var test_path := base_dir + "/test1.stl"
  File.write_file_as_text(test_path, "Test content 1")
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("stl", DirList.Mode.NAME_NO_EXT)
  assert_eq(files.size(), 1)
  assert_eq(files[0], "test1")

func test_get_files_name_with_ext():
  var test_path := base_dir + "/test1.stl"
  File.write_file_as_text(test_path, "Test content 1")
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("stl", DirList.Mode.NAME_WITH_EXT)
  assert_eq(files.size(), 1)
  assert_eq(files[0], "test1.stl")

func test_get_files_no_matching_extension():
  var test_path := base_dir + "/test1.txt"
  File.write_file_as_text(test_path, "Test content 1")
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("stl", DirList.Mode.NAME_NO_EXT)
  assert_eq(files.size(), 0)

func test_get_files_filter():
  var test_path1 := base_dir + "/test1.txt"
  var test_path2 := base_dir + "/test2.stl"
  File.write_file_as_text(test_path1, "Test content 1")
  File.write_file_as_text(test_path2, "Test content 2")
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("stl")
  assert_eq(files.size(), 1)
  assert_true("test2.stl" in files)

func test_get_files_no_filter():
  var test_path1 := base_dir + "/test1.txt"
  var test_path2 := base_dir + "/test2.stl"
  File.write_file_as_text(test_path1, "Test content 1")
  File.write_file_as_text(test_path2, "Test content 2")
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("")
  assert_eq(files.size(), 2)
  assert_true("test1.txt" in files)
  assert_true("test2.stl" in files)

func test_get_files_empty_directory():
  var test_dir_list := DirList.new(base_dir)
  var files = test_dir_list.get_files("stl")
  assert_push_error("No files found in directory: " + base_dir)
  assert_eq(files.size(), 0)
