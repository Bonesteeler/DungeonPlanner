extends GutTest

var test_dir := "user://test"
var test_path := str(test_dir, "/gut_test_file.txt")

func delete_directory(path):
  var d = DirAccess.open(path)
  if (d == null):
    return
  d.list_dir_begin()
  var item = d.get_next()
  while (item != ''):
    var full_path = path + "/" + item
    if (FileAccess.file_exists(full_path)):
      d.remove(full_path)
    elif (DirAccess.dir_exists_absolute(full_path)):
      delete_directory(full_path)
      d.remove(full_path)
    item = d.get_next()
  d.list_dir_end()

func before_each():
  var dir = DirAccess.open("user://")
  dir.make_dir_recursive(test_dir)

func after_each():
  delete_directory(test_dir)

func test_read_write_file():
  var expected = "Hello from GUT file test\nLine2"
  File.write_file_as_text(test_path, expected)
  assert_file_exists(test_path)
  assert_file_not_empty(test_path)
  var res = File.read_file_as_text(test_path)
  assert_eq(res, expected)

func test_read_file_does_not_exist():
  var res = File.read_file_as_text(test_path)
  assert_push_error(1, "Failed to open file for reading: %s" % test_path)
  assert_eq(res, "")

func test_write_dir_does_not_exist():
  var invalid_path = str(test_dir, "/invalid/test.txt")
  var res = File.write_file_as_text(invalid_path, "Some content")
  assert_push_error(1, "Failed to open file for writing: %s" % invalid_path)
  assert_eq(res, false)

func test_file_delete():
  File.write_file_as_text(test_path, "to be deleted")
  assert_file_exists(test_path)
  File.delete_file(test_path)
  assert_file_does_not_exist(test_path)

func test_name_sans_extension():
  assert_eq("file", File.name_sans_extension("file.txt"))
  assert_eq("archive.tar", File.name_sans_extension("archive.tar.gz"))
  assert_eq("no_extension", File.name_sans_extension("no_extension"))
  assert_eq(".hiddenfile", File.name_sans_extension(".hiddenfile"))