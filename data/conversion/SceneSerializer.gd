class_name SceneSerializer
extends RefCounted

static func deserialize_scene(json: String) -> Scene:
  var data: Dictionary = JSON.parse_string(json)
  var scene = Scene.new()
  var layout = TileLayout.new()

  layout.tiles = []
  var tile_datas = data.get("tiles", [])
  for tile_data in tile_datas:
    var tile = PlacedTile.new()
    tile.id = tile_data.get("tileID", "")
    var y_rotation = tile_data.get("rotation", 0)
    tile.rotation = Vector3(0, float(y_rotation), 0) + PlanningContext.DEFAULT_ROTATION
    tile.position = Vector2(
      float(tile_data.get("xPos", 0)),
      float(tile_data.get("z", 0))
    )
    tile.update_tile_offset()
    layout.tiles.append(tile)

  layout.scene_name = data.get("name", "Untitled")
  scene.data = layout
  return scene