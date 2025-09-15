class_name TileLayoutSerializer
extends RefCounted

const KEY_AUTHOR = "author"
const KEY_SCENE_NAME = "sceneName"
const KEY_NAME = "name"
const KEY_TILES = "tiles"
const KEY_ID = "id"
const KEY_ROTATION = "rotation"
const KEY_TILE_ID = "tileID"
const KEY_X_POS = "xPos"
const KEY_Y_POS = "yPos"

static func serialize(scene: Scene) -> String:
  var data: Dictionary = {}
  data[KEY_NAME] = scene.data.scene_name
  data[KEY_TILES] = []
  for tile in scene.data.tiles:
    var tile_data: Dictionary = {}
    tile_data[KEY_TILE_ID] = tile.id
    tile_data[KEY_ROTATION] = tile.rotation - PlanningContext.DEFAULT_ROTATION
    tile_data[KEY_X_POS] = tile.position.x
    tile_data[KEY_Y_POS] = tile.position.y
    data[KEY_TILES].append(tile_data)
  return JSON.stringify(data)

static func deserialize(json: String) -> TileLayout:
  var data: Dictionary = JSON.parse_string(json)
  var layout = TileLayout.new()
  layout.scene_name = data[KEY_SCENE_NAME]
  for tile_data in data[KEY_TILES]:
    var tile = PlacedTile.new()
    tile.id = tile_data[KEY_ID]
    var rotation = split_on_any_of(tile_data[KEY_ROTATION], " ,()")
    tile.rotation = Vector3(
        float(rotation[0]),
        float(rotation[1]),
        float(rotation[2])
    ) + PlanningContext.DEFAULT_ROTATION
    if tile_data.has(KEY_X_POS) and tile_data.has(KEY_Y_POS):
      tile.position = Vector2(
          float(tile_data[KEY_X_POS]),
          float(tile_data[KEY_Y_POS])
      )
    elif tile_data.has("x") and tile_data.has("z"):
      tile.position = Vector2(
          float(tile_data["x"]),
          float(tile_data["z"])
      )
    else:
      continue
    layout.tiles.append(tile)
  return layout

static func split_on_any_of(string: String, delimiters: String) -> Array:
  var tokens = []
  var current_token = ""
  for c in string:
    if delimiters.find(c) != -1:
      if current_token != "":
        tokens.append(current_token)
        current_token = ""
    else:
      current_token += c
  return tokens
