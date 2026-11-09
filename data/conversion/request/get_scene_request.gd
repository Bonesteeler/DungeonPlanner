class_name GetSceneRequest
extends RefCounted

const PATH_TEMPLATE := "v1/scenes/%s"

const KEY_ID := "id"
const KEY_NAME := "name"
const KEY_AUTHOR := "author"
const KEY_LAYERS := "layers"
const KEY_HEIGHT := "height"
const KEY_TILES := "tiles"
const KEY_TILE_ID := "tile_id"
const KEY_ROTATION := "rotation"
const KEY_X_POS := "x_pos"
const KEY_Y_POS := "y_pos"

static func path(scene_id: String) -> String:
  return PATH_TEMPLATE % scene_id

## Builds a [Scene] from the server's scene payload.
static func deserialize(json: Dictionary) -> Scene:
  var scene := Scene.new()
  scene.id = json.get(KEY_ID, "")
  scene.scene_name = json.get(KEY_NAME, "Untitled Scene")
  scene.author = json.get(KEY_AUTHOR, "Unknown")
  scene.data = TileLayout.new()
  for layer_json in json.get(KEY_LAYERS, []):
    scene.data.layers.append(deserialize_layer(layer_json))
  if scene.data.layers.is_empty():
    scene.data.layers.append(TileLayer.new())
  scene.data.current_layer = scene.data.layers[0]
  return scene

static func deserialize_layer(json: Dictionary) -> TileLayer:
  var layer := TileLayer.new()
  # The server stores height as an integer scaled by 100.
  layer.height = float(json.get(KEY_HEIGHT, 0)) / 100.0
  for tile_json in json.get(KEY_TILES, []):
    if not (tile_json.has(KEY_X_POS) and tile_json.has(KEY_Y_POS)):
      continue
    layer.tiles.append(deserialize_tile(tile_json))
  return layer

static func deserialize_tile(json: Dictionary) -> PlacedTile:
  var tile := PlacedTile.new()
  var tile_id: String = json.get(KEY_TILE_ID, "")
  var tile_data: Tile = TileSets.get_tile_from_id(tile_id)
  if tile_data == null:
    tile_data = Tile.new()
    tile_data.id = tile_id
  tile.tile_data = tile_data
  tile.position = Vector2(float(json[KEY_X_POS]), float(json[KEY_Y_POS]))
  tile.rotation = Vector3(0, float(json.get(KEY_ROTATION, 0)), 0)
  return tile
