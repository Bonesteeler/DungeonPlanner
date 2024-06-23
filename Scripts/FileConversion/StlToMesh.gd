class_name StlToMesh
extends RefCounted

#https://en.wikipedia.org/wiki/STL_(file_format)
class Triangle:
  var normal: Vector3
  var vertices: Array

class ImportedMesh:
  var mesh: ArrayMesh
  var size: Tile.TileSize

const ONE_TILE_SIZE = 25

func stlFileToArrayMesh(stl_file: String) -> ImportedMesh:
  var stl = FileAccess.open(stl_file, FileAccess.READ)

  var triangles = []
  var res = ImportedMesh.new()
  if isAscii(stl):
    res.mesh = convertAscii(stl)
    stl.close()
    return res
  else:
    triangles = convertBinary(stl)
  triangles = homeMesh(triangles)
  res.mesh = saveMesh(triangles)
  res.size = determineSize(triangles)
  stl.close()
  return res

func isAscii(file: FileAccess) -> bool:
  var currentPos = file.get_position()
  file.seek(0)
  # ASCII STL begins with "solid"
  var header = file.get_buffer(5)
  var is_ascii = header.get_string_from_ascii() == "solid"
  
  # Reset file position
  file.seek(currentPos)
  return is_ascii

func convertBinary(file: FileAccess) -> Array:
  #Skip header
  file.seek(80)

  #Read file
  var triangles = []
  var facetCount = file.get_32()
  for i in range(facetCount):
    var triangle = Triangle.new()
    var normalX = file.get_float()
    var normalY = file.get_float()
    var normalZ = file.get_float()
    triangle.normal = Vector3(normalX, normalY, normalZ)

    var vertices = []
    for j in range(3):
      var vertexX = file.get_float()
      var vertexY = file.get_float()
      var vertexZ = file.get_float()
      vertices.append(Vector3(vertexX, vertexY, vertexZ))
    vertices.reverse()
    triangle.vertices = vertices
    triangles.append(triangle)

    # 2 unused bytes
    file.seek(file.get_position() + 2)
  return triangles

func homeMesh(triangles: Array) -> Array:
  #Root of mesh should be 25 units right and down of top left corner
  var maxVertex: Vector3 = Vector3(-INF, -INF, -INF)
  var minVertex: Vector3 = Vector3(INF, INF, INF)
  for triangle in triangles:
    for vertex in triangle.vertices:
      maxVertex = maxVector(maxVertex, vertex)
      minVertex = minVector(minVertex, vertex)

  var targetOffset: Vector3 = Vector3(-25, -25, 0)
  for triangle in triangles:
    for i in range(3):
      #Center the mesh, mesh is centered on x and y axis, and above z axis
      #Rotate to make this be the right way up is in default tile rotation 
      triangle.vertices[i][0] -= minVertex[0] - targetOffset[0]
      triangle.vertices[i][1] -= minVertex[1] - targetOffset[1]
      triangle.vertices[i][2] -= minVertex[2]

  maxVertex = Vector3(-INF, -INF, -INF)
  minVertex = Vector3(INF, INF, INF)
  for triangle in triangles:
    for vertex in triangle.vertices:
      maxVertex = maxVector(maxVertex, vertex)
      minVertex = minVector(minVertex, vertex)
  return triangles  
  
func saveMesh(triangles: Array) -> ArrayMesh:
  var surfaceTool = SurfaceTool.new()
  surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
  for triangle in triangles:
    surfaceTool.set_normal(triangle.normal)
    for vertex in triangle.vertices:
      surfaceTool.add_vertex(vertex)
  return surfaceTool.commit()

func determineSize(triangles: Array) -> Tile.TileSize:
  var maxVertex = Vector3(-INF, -INF, -INF)
  var minVertex = Vector3(INF, INF, INF)
  for triangle in triangles:
    for vertex in triangle.vertices:
      maxVertex = maxVector(maxVertex, vertex)
      minVertex = minVector(minVertex, vertex)
  var size = maxVertex - minVertex
  print(size)
  if withinTolerance(size, ONE_TILE_SIZE * 2, ONE_TILE_SIZE * 2):
    return Tile.TileSize.T_2X2
  if withinTolerance(size, ONE_TILE_SIZE * 2, ONE_TILE_SIZE * 4) or withinTolerance(size, ONE_TILE_SIZE * 4, ONE_TILE_SIZE * 2):
    return Tile.TileSize.T_2X4
  if withinTolerance(size, ONE_TILE_SIZE * 4, ONE_TILE_SIZE * 4):
    return Tile.TileSize.T_4X4
  if withinTolerance(size, ONE_TILE_SIZE * 6, ONE_TILE_SIZE * 6):
    return Tile.TileSize.T_6X6
  if withinTolerance(size, ONE_TILE_SIZE * 8, ONE_TILE_SIZE * 8):
    return Tile.TileSize.T_8X8
  return Tile.TileSize.T_2X2

func maxVector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

func minVector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

func withinTolerance(size: Vector3, xGoal: float, yGoal: float) -> bool:
  var tolerance = 0.1
  return abs(size[0] - xGoal) < size[0] * tolerance and abs(size[1] - yGoal) < size[1] * tolerance

# TODO Double check that this works
func convertAscii(file: FileAccess) -> ArrayMesh:
  var surfaceTool = SurfaceTool.new()
  surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
  # Skip header
  var line = file.get_line()
  var vertices = []
  while !file.eof_reached():
    line = file.get_line()
    match line.begins_with(line):
      "facet":
        var normal = line.split(" ").slice(2)
        surfaceTool.set_normal(Vector3(normal[0].to_float(), normal[1].to_float(), normal[2].to_float()))
      "outer loop":
        vertices = []
      "vertex":
        var vertex = line.split(" ").slice(1)
        vertices.append(Vector3(vertex[0].to_float(), vertex[1].to_float(), vertex[2].to_float()))
      "endloop":
        vertices.reverse()
        for v in vertices:
          surfaceTool.add_vertex(v)
      #Nothing to do on "endfacet" or "endsolid"
  return surfaceTool.commit()
