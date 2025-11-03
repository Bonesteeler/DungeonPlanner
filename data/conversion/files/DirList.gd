class_name DirList
extends RefCounted
##
## Loads files and directories from the given path.
##

# Utility class for file operations. The var deliberately has the same name as the class to remind
# us that we are using the static class methods.
#var File = preload("res://data/conversion/files/File.gd")

# Internal data, not to be directly accessed from outside the class.
var _directories: Array = []
var _files: Array = []
var _filepath: String = ""
var _recursive: bool = false # Not implemented yet.

# Add enum to control returned format instead of strings.
enum Mode {
  NAME_WITH_EXT,
  NAME_NO_EXT,
  PATH_WITH_EXT,
  PATH_NO_EXT
}

##
## Constructor
##
##  @param path The path to scan.
##  @param is_recursive If true, scan subdirectories too (not implemented yet).
##
func _init(path: String, is_recursive: bool = false) -> void:
  _directories = []
  _files = []

  _set_path(path)
  _load_directory()
  _recursive = is_recursive


##
## Retrieve files, selectively, from the file list.
##
## @param extension The file extension to filter on (e.g. "stl"), or "" for all files.
## @param mode One of Mode.* controlling returned string format (default Mode.NAME_WITH_EXT)
##
func get_files(extension: String = "", mode: int = Mode.NAME_WITH_EXT) -> Array:
  # Ensure directory scanned
  if _files.size() == 0:
    _load_directory()
  if _files.size() == 0:
    push_error("No files found in directory: " + _filepath)
    return []

  var list := []
  var include_path := (mode == Mode.PATH_WITH_EXT or mode == Mode.PATH_NO_EXT)
  var keep_ext := (mode == Mode.NAME_WITH_EXT or mode == Mode.PATH_WITH_EXT)

  for file: String in _files:
    if extension == "" or file.get_extension() == extension:
      var filename := file.get_file() # filename with extension
      if not keep_ext:
        filename = File.name_sans_extension(filename)

      if include_path:
        list.append(_filepath + filename)
      else:
        list.append(filename)

  return list


func _set_path(path: String) -> void:
  if !File.is_path_valid(path):
    push_error("Trying to initialise with invalid path: " + path)
    return

  if path.ends_with("/") == false:
    path += "/"
  _filepath = path


##
## Loads files and directories from the given path.
##
func _load_directory() -> void:
  if _filepath == "":
    push_error("DirList path is empty.")
    return

  _directories.clear()
  _files.clear()

  var dir = DirAccess.open(_filepath)
  if dir == null:
    push_error("DirList failed to open path: " + _filepath)
    print("Failed to open ", DirAccess.get_open_error())
    return

  dir.list_dir_begin()
  var filename = dir.get_next()
  while filename != "":
    var filespec := "/".join([_filepath, filename])

    if dir.current_is_dir():
      _directories.append(filespec)
    else:
      _files.append(filespec)

    filename = dir.get_next()
  # Close the stream
  dir.list_dir_end()

  self._directories.sort()
  self._files.sort()
  return