class_name DirList
extends RefCounted
##
## Scans a directory for files and directories.
##
##
##

# Utility class for file operations. The var deliberately has the same name as the class to remind
# us that we are using the static class methods.
#var File = preload("res://data/conversion/files/File.gd")

# Internal data, not to be directly accessed from outside the class.
var _directories: Array = []
var _files: Array = []
var _filepath: String = ""
var _recursive: bool = false  #  Not implemented yet.

##
## Constructor
##
##  @param path The path to scan.
##  @param is_recursive If true, scan subdirectories too (not implemented yet).
##
func _init(path: String, is_recursive: bool = false) -> void:
  _directories = []
  _files = []

  set_path(path)
  _scan_directory(_filepath)
  _recursive = is_recursive


##
## Retrieve files, selectively, from the file list.
##
## @param extension The file extension to filter on (e.g. "stl"), or "" for all files.
##
## @todo Possibly expand to allow full regex filtering.
##
func get_files(extension: String = "") -> Array:
  var list := []
  for file in _files:
    if extension == "" or file.get_extension() == extension:
      list.append(file)

  return list


##
## Retrieve files, from the file list, with their path prepended.
##
## If the file list is empty, the directory is scanned first.
##
## @param extension The file extension to filter on (e.g. "stl"), or "" for all files.
## @param drop_ext If true, the extension is dropped from the filename.
##
func get_files_with_path(extension: String = "", drop_ext: bool = false) -> Array:
  if _files.size() == 0:
    _scan_directory()
  if _files.size() == 0:
    push_error("No files found in directory: " + _filepath)
    return []

  var list := []
  for file in _files:
    if file.get_extension() == extension or extension == "":
      var filename = file.get_file()
      if drop_ext:
        filename = File.name_sans_extension(filename)

      list.append(_filepath + filename)

  return list


func set_path(path: String) -> void:
  if !File.is_path_valid(path):
    push_error("Trying to initialise with invalid path: " + path)
    return

  if path.ends_with("/") == false:
    path += "/"
  _filepath = path


##
## Scan the directory for files and directories.
##
## @param path The path to scan. If empty, uses the path provided at initialisation.
##
func _scan_directory(path: String = "") -> void:
#region Sanity checks
  if path == "":
    path = _filepath
  else:
    if !File.is_path_valid(path):
      push_error("ScanDirectory initialized with invalid path: " + path)
      return

  if path.ends_with("/") == false:
    path += "/"
#endregion

  _directories.clear()
  _files.clear()

  var dir = DirAccess.open(path)
  if dir == null:
    push_error("DirList failed to open path: " + path)
    print("Failed to open ", DirAccess.get_open_error())
    return

  dir.list_dir_begin()
  var filename = dir.get_next()
  while filename != "":
    var filespec = "/".join([path, filename])

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