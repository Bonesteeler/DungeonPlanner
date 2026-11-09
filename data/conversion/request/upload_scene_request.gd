class_name UploadSceneRequest
extends RefCounted

const PATH := "v1/scenes/add"

static func build(scene: Scene) -> Dictionary:
  return {
    "name": scene.scene_name,
    "author": scene.author,
    "layers": serialize_layers(scene.data.layers),
  }

## Sends the scene to the server; returns true when the server accepted it.
static func send(network: NetworkService, scene: Scene) -> bool:
  var response := await network.request(PATH, HTTPClient.METHOD_POST, build(scene), true)
  return response.ok

static func serialize_layers(layers: Array) -> Array:
  var serialized_layers = []
  for layer in layers:
    var serialized_layer = {
      "height": (int)(layer.height * 100),
      "tiles": serialize_tiles(layer.tiles)
    }
    serialized_layers.append(serialized_layer)
  return serialized_layers

static func serialize_tiles(tiles: Array) -> Array:
  var serialized_tiles = []
  for tile in tiles:
    var serialized_tile = {
      "tile_id": tile.id,
      "x_pos": (int)(tile.position.x),
      "y_pos": (int)(tile.position.y),
      "rotation": (int)(tile.rotation.y)
    }
    serialized_tiles.append(serialized_tile)
  return serialized_tiles
