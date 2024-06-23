class_name Tile
extends RefCounted

enum TileStatus {CACHED, CREATED, NOT_FOUND}
enum TileSize {T_2X2, T_2X4, T_4X4, T_6X6, T_8X8}

const missingImagePath = "res://Images/Missing.png"

var id = ""
var imagePath = ""
var stlPath = ""
var mesh: Mesh
var stlToMesh = StlToMesh.new()
var size: TileSize

const ID_KEY = "id"
const IMAGE_PATH_KEY = "imagePath"
const SIZE_KEY = "size"
const STL_PATH_KEY = "stlPath"

func create_tile_from_json(json: Dictionary):
  id = json.get(ID_KEY, "")
  imagePath = json.get(IMAGE_PATH_KEY, "")
  if (imagePath == ""):
    imagePath = missingImagePath
  stlPath = json.get(STL_PATH_KEY, "")
  size = json.get(SIZE_KEY, TileSize.T_2X2) 

func to_dict() -> Dictionary:
  return {
    ID_KEY: id,
    IMAGE_PATH_KEY: imagePath,
    STL_PATH_KEY: stlPath,
    SIZE_KEY: size
  }

func load_mesh() -> TileStatus:
  if stlPath != "":
    var resPath = stlPath.replace("stl", "res").replace("res://", "user://")
    # Get mesh from cache
    if FileAccess.file_exists(resPath):
      mesh = load(resPath)
      return TileStatus.CACHED
      
    # Import mesh from STL file
    if FileAccess.file_exists(stlPath):
      var startTime = Time.get_ticks_msec()
      var imported = stlToMesh.stlFileToArrayMesh(stlPath)
      mesh = imported.mesh
      size = imported.size
      var endTime = Time.get_ticks_msec()

      print("Imported ", id, " in ", endTime - startTime, " ms")
      var dir = DirAccess.open("user://")
      if dir.dir_exists(resPath.get_base_dir()) == false:
        dir.make_dir_recursive(resPath.get_base_dir())
      var saveStatus = ResourceSaver.save(mesh, resPath, ResourceSaver.FLAG_CHANGE_PATH)
      if (saveStatus != OK):
        print("Failed to save mesh to ", resPath, " with status ", saveStatus)
      return TileStatus.CREATED
    else:
      print("STL file does not exist: ", stlPath) 
  return TileStatus.NOT_FOUND
