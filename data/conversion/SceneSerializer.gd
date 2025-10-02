class_name SceneSerializer
extends RefCounted

const KEY_AUTHOR = "author"
const KEY_TILES = "tiles"
const KEY_ID = "id"
const KEY_SCENE_NAME = "name"
const KEY_VERSION = "version"
const VERSION = 1

static func serialize(scene: Scene) -> String:
  var data: Dictionary = {
    KEY_AUTHOR: scene.author,
    KEY_ID: scene.id,
    KEY_SCENE_NAME: scene.scene_name,
    KEY_TILES: TileLayoutSerializer.serialize(scene.data),
    KEY_VERSION: VERSION
  }
  return JSON.stringify(data)

static func deserialize(json: String) -> Scene:
  return deserialize_dict(JSON.parse_string(json))

static func deserialize_dict(json: Dictionary) -> Scene:
  if not json.has(KEY_VERSION):
    return null
  var scene = Scene.new()
  scene.version = int(json.get(KEY_VERSION, 0))
  scene.author = json.get(KEY_AUTHOR, "Unknown")
  scene.data = TileLayoutSerializer.deserialize_dict({KEY_TILES: json.get(KEY_TILES, [])})
  scene.id = json.get(KEY_ID, "")
  scene.scene_name = json.get(KEY_SCENE_NAME, "Untitled Scene")
  scene.version = int(json.get(KEY_VERSION, 1))
  return scene
