extends GutTest

const TILE_A := "e3cfba8a137d96bb4bce43f8f777614b72ce8760478e9d3fe9081fcc577da67f"
const TILE_B := "f874e827014cdd0f67caef9a9261d9f50e80dc0feb0bd42410b96517bda7d738"

func _payload() -> Dictionary:
  return {
    "id": "7cb666f7-e132-496c-b2a5-4c39756a9996",
    "name": "ServerTest",
    "author": "Changed on server",
    "unique_tile_ids": [TILE_A, TILE_B],
    "layers": [ {
      "height": 50,
      "tiles": [
        {"tile_id": TILE_A, "rotation": 90, "x_pos": 10, "y_pos": 4},
        {"tile_id": TILE_B, "rotation": 0, "x_pos": 12, "y_pos": 4},
      ],
    }],
  }

func test_path_inserts_scene_id():
  assert_eq(GetSceneRequest.path("abc"), "v1/scenes/abc")

func test_deserialize_reads_scene_fields():
  var scene := GetSceneRequest.deserialize(_payload())
  assert_eq(scene.id, "7cb666f7-e132-496c-b2a5-4c39756a9996")
  assert_eq(scene.scene_name, "ServerTest")
  assert_eq(scene.author, "Changed on server")

func test_deserialize_divides_layer_height_by_100():
  var scene := GetSceneRequest.deserialize(_payload())
  assert_eq(scene.data.layers.size(), 1)
  assert_eq(scene.data.layers[0].height, 0.5)

func test_deserialize_maps_tile_position_and_rotation():
  var scene := GetSceneRequest.deserialize(_payload())
  var tiles: Array = scene.data.layers[0].tiles
  assert_eq(tiles.size(), 2)
  assert_eq(tiles[0].position, Vector2(10, 4))
  assert_eq(tiles[0].rotation, Vector3(0, 90, 0))
  assert_eq(tiles[1].position, Vector2(12, 4))

func test_deserialize_keeps_id_of_uninstalled_tile():
  var scene := GetSceneRequest.deserialize(_payload())
  var tiles: Array = scene.data.layers[0].tiles
  assert_eq(tiles[0].id, TILE_A)
  assert_eq(tiles[1].id, TILE_B)

func test_deserialize_skips_tile_without_position():
  var json := _payload()
  json.layers[0].tiles.append({"tile_id": TILE_A, "rotation": 0})
  var scene := GetSceneRequest.deserialize(json)
  assert_eq(scene.data.layers[0].tiles.size(), 2)

func test_deserialize_without_layers_adds_default_layer():
  var scene := GetSceneRequest.deserialize({"id": "x", "name": "Empty"})
  assert_eq(scene.data.layers.size(), 1)
  assert_eq(scene.data.current_layer, scene.data.layers[0])
