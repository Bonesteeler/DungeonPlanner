class_name TileLayerSerializer
extends RefCounted
## TileLayoutSerializer
## 
## [i]Helpers to serialize and deserialize TileLayout objects to and from JSON.[/i][br]
## [b]Usage:[/b] Use the static methods to convert a TileLayout into a JSON string or reconstruct a TileLayout from JSON data.[br]
const KEY_HEIGHT = "height"
const KEY_ID = "id"
const KEY_ROTATION = "rotation"
const KEY_TILES = "tiles"
const KEY_X_POS = "xPos"
const KEY_Y_POS = "yPos"

static func serialize(layer: TileLayer) -> Dictionary:
  var data: Dictionary = {}
  var tiles_data = []
  for tile in layer.tiles:
    var tile_data: Dictionary = {
      KEY_ID: tile.id,
      KEY_ROTATION: str(tile.rotation),
      KEY_X_POS: tile.position.x,
      KEY_Y_POS: tile.position.y
    }
    tiles_data.append(tile_data)
  data[KEY_TILES] = tiles_data
  data[KEY_HEIGHT] = layer.height
  return data

static func deserialize(json: Dictionary) -> TileLayer:
  var deserialized_layer = TileLayer.new()
  var tiles = json.get(KEY_TILES, [])
  for tile_data in tiles:
    var tile = PlacedTile.new()
    var rotation = split_on_any_of(tile_data[KEY_ROTATION], " ,()")
    tile.rotation = Vector3(
        float(rotation[0]),
        float(rotation[1]),
        float(rotation[2])
    )
    if not (tile_data.has(KEY_X_POS) and tile_data.has(KEY_Y_POS)):
      continue
    tile.position = Vector2(
        float(tile_data[KEY_X_POS]),
        float(tile_data[KEY_Y_POS])
    )
    tile.tile_data = TileSets.get_tile_from_id(tile_data[KEY_ID])
    tile.id = tile_data[KEY_ID]
    deserialized_layer.tiles.append(tile)
  deserialized_layer.height = json.get(KEY_HEIGHT, 0)
  return deserialized_layer

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