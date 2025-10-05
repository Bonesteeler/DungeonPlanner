class_name StlToMesh
extends RefCounted
## StlToMesh
##
## [i]Utility to convert an STL file into a Godot ArrayMesh and align it to the planning grid.[/i][br]
## [b]Usage:[/b] Provide a filesystem path to an STL file when constructing this class.[br]The class computes a SHA-256 hash of the vertex data and exposes the resulting ArrayMesh via the [code]mesh[/code] property.[br]
## [b]Properties:[/b][br]
## - [b]mesh[/b]: The generated [code]ArrayMesh[/code].[br]
## - [b]mesh_hash[/b]: SHA-256 hex digest of the trimmed vertex data and file size.[br]
## - [b]x_size[/b], [b]y_size[/b]: Calculated tile lengths of the mesh in tiles (50 units per tile).[br]


#https://en.wikipedia.org/wiki/STL_(file_format)
class Triangle:
  var normal: Vector3
  var vertices: Array

var hash_input: PackedByteArray = PackedByteArray()
var mesh: ArrayMesh
var mesh_hash: String
var x_size: int
var y_size: int

## [b]Description:[/b] Initializes the StlToMesh instance by converting the provided STL file into an ArrayMesh and computing a SHA-256 hash of the vertex data.[br]
## [b]Parameters:[/b][br]
## - [code]source_path: String[/code] - Filesystem path to the input STL file.[br]
func _init(source_path: String):
  mesh = stl_file_to_array_mesh(source_path)
  var hasher = HashingContext.new()
  hasher.start(HashingContext.HashType.HASH_SHA256)
  hasher.update(hash_input)
  mesh_hash = hasher.finish().hex_encode()

## Opens an STL file, parses its triangles (ASCII or binary), aligns the mesh to the planning grid and converts it to an [code]ArrayMesh[/code].[br]
## [b]Parameters:[/b][br]
## - [code]stl_file: String[/code] - Path to the STL file to load.[br]
## [b]Returns:[/b] [code]ArrayMesh[/code] - The constructed mesh. Returns an empty ArrayMesh on failure.[br]
func stl_file_to_array_mesh(stl_file: String) -> ArrayMesh:
  var stl = FileAccess.open(stl_file, FileAccess.READ)

  var triangles = []
  if is_ascii(stl):
    triangles = convert_ascii(stl)
  else:
    triangles = convert_binary(stl)

  if triangles == []:
    push_error("Failed to convert STL file: " + stl_file)
    return ArrayMesh.new()

  #Position the mesh to align with the grid.
  triangles = position_mesh(triangles)
  hash_input.append(stl.get_length())
  stl.close()
  return save_mesh(triangles)

## Heuristically checks whether an open STL [code]FileAccess[/code] contains ASCII STL data.[br]
## [b]Parameters:[/b][br]
## - [code]file: FileAccess[/code] - An already-opened file handle to the STL file.[br]
## [b]Returns:[/b] [code]bool[/code] - True if the file appears to be ASCII STL, false otherwise.[br]
func is_ascii(file: FileAccess) -> bool:
  var current_pos = file.get_position()
  file.seek(0)
  # ASCII STL begins with "solid"
  var header = file.get_buffer(5)
  var result = header.get_string_from_ascii() == "solid"

  # Reset file position
  file.seek(current_pos)
  return result


## Parses an ASCII STL file from the provided [code]FileAccess[/code] and returns an array of Triangle objects.[br]
## [b]Parameters:[/b][br]
## - [code]file: FileAccess[/code] - An already-opened ASCII STL file handle.[br]
## [b]Returns:[/b] [code]Array[/code] - An array of [code]Triangle[/code] instances. Returns an empty array on parse error.[br]
func convert_ascii(file: FileAccess) -> Array:
  var surface_tool = SurfaceTool.new()
  surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

  var regex = RegEx.new()
  regex.compile("([\\w\\d\\.-]+)")

  # Skip first line with "solid" header.
  file.seek(0)
  var line = file.get_line()
  var triangles = []
  var triangle: Triangle
  var vertices = []

  while !file.eof_reached():
    line = file.get_line()
    var results = regex.search_all(line)
    if results == []:
      continue

    match results.get(0).strings[1]:
      "facet":
        # print("'Facet' found")
        if results.get(1).strings[1] != "normal":
          push_error("Expected 'normal' after 'facet'")
          return []

        triangle = Triangle.new()
        triangle.normal = Vector3(
          results.get(2).strings[1].to_float(),
          results.get(3).strings[1].to_float(),
          results.get(4).strings[1].to_float(),
        )
      "outer":
        if results.get(1).strings[1] != "loop":
          push_error("Expected 'loop' after 'outer'")
          return []

        vertices = []
      "vertex":
        var vertex_x = results.get(1).strings[1].to_float()
        var vertex_y = results.get(2).strings[1].to_float()
        var vertex_z = results.get(3).strings[1].to_float()
        vertices.append(
          Vector3(
            vertex_x,
            vertex_y,
            vertex_z,
          )
        )
        append_vertex_to_hash_input(vertex_x)
        append_vertex_to_hash_input(vertex_y)
        append_vertex_to_hash_input(vertex_z)
      "endloop":
        vertices.reverse()
        triangle.vertices = vertices
        triangles.append(triangle)
      _:
        print_verbose('Nothing to do on "endfacet" or "endsolid"')

  return triangles


## Parses a binary STL file from the provided [code]FileAccess[/code] and returns an array of Triangle objects.[br]
## [b]Parameters:[/b][br]
## - [code]file: FileAccess[/code] - An already-opened binary STL file handle.[br]
## [b]Returns:[/b] [code]Array[/code] - An array of [code]Triangle[/code] instances.[br]
func convert_binary(file: FileAccess) -> Array:
  #Skip header
  file.seek(80)

  #Read file
  var triangles = []
  var facet_count = file.get_32()
  for i in range(facet_count):
    var triangle = Triangle.new()
    var normal_x = file.get_float()
    var normal_y = file.get_float()
    var normal_z = file.get_float()
    triangle.normal = Vector3(normal_x, normal_y, normal_z)

    var vertices = []
    for j in range(3):
      var vertex_x = file.get_float()
      var vertex_y = file.get_float()
      var vertex_z = file.get_float()
      vertices.append(Vector3(vertex_x, vertex_y, vertex_z))
      append_vertex_to_hash_input(vertex_x)
      append_vertex_to_hash_input(vertex_y)
      append_vertex_to_hash_input(vertex_z)
    vertices.reverse()
    triangle.vertices = vertices
    triangles.append(triangle)

    # 2 unused bytes
    file.seek(file.get_position() + 2)

  return triangles

## Adds a single vertex coordinate to the internal hash input buffer.[br]
## [b]Parameters:[/b][br]
## - [code]vertex: float[/code] - A single vertex coordinate value (x, y, or z).[br]
## [b]Returns:[/b] Nothing.[br]
func append_vertex_to_hash_input(vertex: float):
  # Truncating to thousandths place to avoid precision issues
  hash_input.append(int(vertex * 1000))

## Computes the bounding box of the parsed triangles and recenters the mesh so it aligns with the project's planning grid (50-unit tiles).[br]
## [b]Parameters:[/b][br]
## - [code]triangles: Array[/code] - An array of [code]Triangle[/code] instances to position.[br]
## [b]Returns:[/b] [code]Array[/code] - The modified array of triangles with vertex positions shifted.[br]
func position_mesh(triangles: Array) -> Array:
  #Center the mesh, calculate the bounding box
  var max_vertex: Vector3 = Vector3(-INF, -INF, -INF)
  var min_vertex: Vector3 = Vector3(INF, INF, INF)
  for triangle in triangles:
    for vertex in triangle.vertices:
      max_vertex = max_vector(max_vertex, vertex)
      min_vertex = min_vector(min_vertex, vertex)

  var center: Vector3 = (max_vertex + min_vertex) / 2
  x_size = get_tile_length(min_vertex.x, max_vertex.x)
  if x_size % 2 == 0:
    center.x -= 25
  y_size = get_tile_length(min_vertex.y, max_vertex.y)
  if y_size % 2 == 0:
    center.y += 25
  for triangle in triangles:
    for i in range(3):
      #Center the mesh, mesh is centered on x and z axis, and above Z axis
      #Rotation to make this be the right way up is in default tile
      triangle.vertices[i][0] -= center[0]
      triangle.vertices[i][1] -= center[1]
      triangle.vertices[i][2] -= min_vertex[2]
  return triangles

## Converts an array of Triangle instances into an [code]ArrayMesh[/code].[br]
## [b]Parameters:[/b][br]
## - [code]triangles: Array[/code] - Array of [code]Triangle[/code] instances to include in the mesh.[br]
## [b]Returns:[/b] [code]ArrayMesh[/code] - The committed mesh.[br]
func save_mesh(triangles: Array) -> ArrayMesh:
  var surface_tool = SurfaceTool.new()
  surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
  for triangle in triangles:
    surface_tool.set_normal(triangle.normal)
    for vertex in triangle.vertices:
      surface_tool.add_vertex(vertex)
  return surface_tool.commit()

## Returns a component-wise maximum of two [code]Vector3[/code] values.[br]
## [b]Parameters:[/b][br]
## - [code]a: Vector3[/code][br]
## - [code]b: Vector3[/code][br]
## [b]Returns:[/b] [code]Vector3[/code] - Component-wise maximum.[br]
func max_vector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

## Returns a component-wise minimum of two [code]Vector3[/code] values.[br]
## [b]Parameters:[/b][br]
## - [code]a: Vector3[/code][br]
## - [code]b: Vector3[/code][br]
## [b]Returns:[/b] [code]Vector3[/code] - Component-wise minimum.[br]
func min_vector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

## Calculates the number of 50-unit tiles that fit between two coordinates, rounding to the nearest tile (leftover >= 25 rounds up).[br]
## [b]Parameters:[/b][br]
## - [code]min_val: float[/code] - Minimum coordinate value.[br]
## - [code]max_val: float[/code] - Maximum coordinate value.[br]
## [b]Returns:[/b] [code]int[/code] - Number of tiles.[br]
func get_tile_length(min_val: float, max_val: float) -> int:
  var diff = max_val - min_val
  var tile_count = int(diff / 50)
  var leftover = diff - (tile_count * 50)
  if leftover >= 25:
    tile_count += 1
  return tile_count
