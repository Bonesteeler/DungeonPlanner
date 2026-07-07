class_name UploadSceneRequest
extends RefCounted

static func serialize(scene: Scene) -> String:
  return JSON.stringify({
    "Name": scene.scene_name,
    "Author": scene.author,
    "Layers": serialize_layers(scene.data.layers),
  })

static func serialize_layers(layers: Array) -> Array:
  var serialized_layers = []
  for layer in layers:
    var serialized_layer = {
      "Height": (int)(layer.height * 100),
      "Tiles": serialize_tiles(layer.tiles)
    }
    serialized_layers.append(serialized_layer)
  return serialized_layers

static func serialize_tiles(tiles: Array) -> Array:
  var serialized_tiles = []
  for tile in tiles:
    var serialized_tile = {
      "TileID": tile.id,
      "XPos": (int)(tile.position.x),
      "YPos": (int)(tile.position.y),
      "Rotation": (int)(tile.rotation.y)
    }
    serialized_tiles.append(serialized_tile)
  return serialized_tiles