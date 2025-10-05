class_name SceneSerializer
extends RefCounted
## SceneSerializer
##
## Serializes and deserializes [code]Scene[/code] objects to and from JSON. [br]

const KEY_AUTHOR = "author"
const KEY_TILES = "tiles"
const KEY_ID = "id"
const KEY_SCENE_NAME = "name"
const KEY_VERSION = "version"
const VERSION = 1

## Serializes a [code]Scene[/code] instance into a JSON [code]String[/code]. [br]
## [b]Parameters:[/b] [code]scene: Scene[/code] - The scene to serialize. Must have a valid [code]data[/code] (tile layout). [br]
## [b]Returns:[/b] JSON [code]String[/code] representation of the scene.
static func serialize(scene: Scene) -> String:
  var data: Dictionary = {
    KEY_AUTHOR: scene.author,
    KEY_ID: scene.id,
    KEY_SCENE_NAME: scene.scene_name,
    KEY_TILES: TileLayoutSerializer.serialize(scene.data),
    KEY_VERSION: VERSION
  }
  return JSON.stringify(data)

## Parses a JSON [code]String[/code] and returns a [code]Scene[/code] object. [br]
## [b]Parameters:[/b] [code]json: String[/code] - JSON string produced by [code]serialize[/code]. [br]
## [b]Returns:[/b] A [code]Scene[/code] instance, or [code]null[/code] if parsing/validation fails.
static func deserialize(json: String) -> Scene:
  return deserialize_dict(JSON.parse_string(json))

## Builds a [code]Scene[/code] from a Dictionary (already parsed JSON). [br]
## [b]Parameters:[/b] [code]json: Dictionary[/code] - Dictionary with keys matching the serialized format. [br]
## [b]Returns:[/b] A [code]Scene[/code] object, or [code]null[/code] when required fields (like [code]version[/code]) are missing.
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
