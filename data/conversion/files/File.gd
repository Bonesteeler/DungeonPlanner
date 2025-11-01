class_name File
extends RefCounted
##
## File: Utility class for file operations in Godot (all static)
##


##
## Delete a file at the given path.
##
static func delete_file(path: String) -> bool:
  if not FileAccess.file_exists(path):
    push_error("File does not exist: %s" % path)
    return false
  var err = DirAccess.remove_absolute(path)
  if err != OK:
    push_error("Failed to delete file: %s" % path)
    return false
  return true

##
## Check if a file exists at the given path.
##
static func file_exists(path: String) -> bool:
  return FileAccess.file_exists(path)


##
## Check if a path is valid (no invalid characters in any directory).
##
static func is_path_valid(path: String) -> bool:
  var dirs = path.split("/")
  var count = dirs.size()
  if count == 0:
    push_error("DirList initialized with empty path")
    return false

  for index in range(1, count):
    var segment = dirs.get(index)
    if !segment.is_valid_filename():
      push_error("File path has invalid characters (: / \\ ? * \" | % < >) in directory:")
      push_error("/".join(dirs.slice(1, index + 1))) # Show the actual directory that broke us.
      return false

  return true


##
## Get the filename without its extension if it has one.
## Note: This can bite you if the filename has multiple dots,
## or a single dot not used to separate the extension.
##
static func name_sans_extension(file: String) -> String:
  var dot_index = file.rfind(".")
  if dot_index < 1:
    return file
  return file.substr(0, dot_index)


##
## Read the entire contents of a file as text.
##
## Opens and closes the file automatically.
##
static func read_file_as_text(path: String) -> String:
  var file := FileAccess.open(path, FileAccess.READ)
  if not file:
    push_error("Failed to open file for reading: %s" % path)
    return ""
  var content := file.get_as_text()
  file.close()
  return content


##
## Write the given content to a file as text.
##
## Opens and closes the file automatically.
##
static func write_file_as_test(path: String, content: String) -> bool:
  var file := FileAccess.open(path, FileAccess.WRITE)
  if not file:
    push_error("Failed to open file for writing: %s" % path)
    return false
  file.store_string(content)
  file.close()
  return true