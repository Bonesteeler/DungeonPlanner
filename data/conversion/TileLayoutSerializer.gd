class_name TileLayoutSerializer
extends RefCounted
## TileLayoutSerializer
## 
## [i]Helpers to serialize and deserialize TileLayout objects to and from JSON.[/i][br]
## [b]Usage:[/b] Use the static methods to convert a TileLayout into a JSON string or reconstruct a TileLayout from JSON data.[br]

const KEY_SCENE_NAME = "sceneName"
const KEY_NAME = "name"
const KEY_TILES = "tiles"
const KEY_ID = "id"
const KEY_ROTATION = "rotation"
const KEY_TILE_ID = "tileID"
const KEY_X_POS = "xPos"
const KEY_Y_POS = "yPos"

## Serializes a TileLayout into a JSON string.[br]
## [b]Parameters:[/b] [code]scene: TileLayout[/code][br]
## [b]Returns:[/b] [code]String[/code][br]
static func serialize(scene: TileLayout) -> String:
  var data: Dictionary = {
    KEY_SCENE_NAME: scene.scene_name
  }
  var tiles_data = []
  for tile in scene.tiles:
    var tile_data: Dictionary = {
      KEY_ID: tile.id,
      KEY_ROTATION: tile.rotation,
      KEY_X_POS: tile.position.x,
      KEY_Y_POS: tile.position.y
    }
    tiles_data.append(tile_data)
  data[KEY_TILES] = tiles_data
  return JSON.stringify(data)

## Deserializes a JSON string into a TileLayout[br]
## [b]Parameters:[/b] [code]json: String[/code][br]
## [b]Returns:[/b] [code]TileLayout[/code][br]
static func deserialize(json: String) -> TileLayout:
  return deserialize_dict(JSON.parse_string(json))

## Constructs a TileLayout from a parsed Dictionary representation.[br]
## [b]Parameters:[/b] [code]json: Dictionary[/code][br]
## [b]Returns:[/b] [code]TileLayout[/code][br]
static func deserialize_dict(json: Dictionary) -> TileLayout:
  var layout = TileLayout.new()
  layout.scene_name = json.get(KEY_NAME, "Untitled Scene")
  var test = json.get(KEY_TILES, [])
  if typeof(test) != TYPE_ARRAY:
    var nested_tiles = JSON.parse_string(test)
    test = nested_tiles.get(KEY_TILES, [])
  for tile_data in test:
    var tile = PlacedTile.new()
    var rotation = split_on_any_of(tile_data[KEY_ROTATION], " ,()")
    tile.rotation = Vector3(
        float(rotation[0]),
        float(rotation[1]),
        float(rotation[2])
    )
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
    tile.tile_data = TileSets.get_tile_from_id(tile_data[KEY_ID])
    layout.tiles.append(tile)
  return layout

## Splits a string into tokens using any character found in the delimiters string.[br]
## [b]Parameters:[/b] [code]string: String[/code], [code]delimiters: String[/code][br]
## [b]Returns:[/b] [code]Array[/code] of token strings extracted from the input.[br]
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
