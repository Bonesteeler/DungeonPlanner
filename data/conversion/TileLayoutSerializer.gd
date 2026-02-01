class_name TileLayoutSerializer
extends RefCounted
## TileLayoutSerializer
## 
## [i]Helpers to serialize and deserialize TileLayout objects to and from JSON.[/i][br]
## [b]Usage:[/b] Use the static methods to convert a TileLayout into a JSON string or reconstruct a TileLayout from JSON data.[br]

const KEY_LAYERS = "layers"

## Serializes a TileLayout into a JSON string.[br]
## [b]Parameters:[/b] [code]scene: TileLayout[/code][br]
## [b]Returns:[/b] [code]String[/code][br]
static func serialize(scene: TileLayout) -> Array:
  var layers = []
  for layer in scene.layers:
    var layer_data: Dictionary = TileLayerSerializer.serialize(layer)
    layers.append(layer_data)
  return layers

## Deserializes a JSON string into a TileLayout[br]
## [b]Parameters:[/b] [code]json: String[/code][br]
## [b]Returns:[/b] [code]TileLayout[/code][br]
static func deserialize(json: String) -> TileLayout:
  return deserialize_array(JSON.parse_string(json))

## Constructs a TileLayout from a parsed Dictionary representation.[br]
## [b]Parameters:[/b] [code]json: Dictionary[/code][br]
## [b]Returns:[/b] [code]TileLayout[/code][br]
static func deserialize_array(json: Array) -> TileLayout:
  var layout = TileLayout.new()
  for layer in json:
    var tile_layer = TileLayerSerializer.deserialize(layer)
    layout.layers.append(tile_layer)
  if layout.layers.size() == 0:
    layout.layers.append(TileLayer.new())
  layout.current_layer = layout.layers[0]
  return layout
