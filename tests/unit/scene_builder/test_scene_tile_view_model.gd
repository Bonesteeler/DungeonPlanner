extends GutTest

const test_mesh_path = "res://tests/test_data/test_mesh.tres"

var view_model: SceneTileViewModel
var test_tile: Tile
var test_mesh: Mesh

func before_each():
  view_model = SceneTileViewModel.new()
  test_tile = Tile.new()
  test_tile.mesh_path = test_mesh_path
  test_mesh = BoxMesh.new()

func test_set_rotation():
  watch_signals(view_model)
  var new_rotation = Vector3(0, 45, 0)
  view_model.set_rotation(new_rotation)
  
  assert_eq(view_model.rotation, new_rotation)
  assert_signal_emitted(view_model, "rotation_changed")

func test_rotate_increments_y():
  view_model.rotation = Vector3.ZERO
  view_model.rotate(45)
  
  assert_eq(view_model.rotation.y, 45)

func test_rotate_wraps_at_360():
  view_model.rotation = Vector3(0, 350, 0)
  view_model.rotate(20)
  
  assert_eq(view_model.rotation.y, 10)

func test_rotate_wraps_negative():
  view_model.rotation = Vector3.ZERO
  view_model.rotate(-10)
  
  assert_eq(view_model.rotation.y, 350)

func test_rotate_disabled():
  watch_signals(view_model)
  view_model.rotation = Vector3.ZERO
  view_model.disable_rotation()
  view_model.rotate(45)
  
  assert_signal_not_emitted(view_model, "rotation_changed")
  assert_eq(view_model.rotation.y, 0)

func test_rotation_enabled():
  watch_signals(view_model)
  view_model.rotation = Vector3.ZERO
  view_model.disable_rotation()
  view_model.rotate(45)

  assert_signal_not_emitted(view_model, "rotation_changed")
  assert_eq(view_model.rotation.y, 0)

  view_model.enable_rotation()
  view_model.rotate(45)
  assert_signal_emitted(view_model, "rotation_changed")
  assert_eq(view_model.rotation.y, 45)

func test_set_validity_true():
  watch_signals(view_model)

  view_model.set_validity(false)
  assert_false(view_model.valid)
  assert_signal_emitted(view_model, "validity_changed")

func test_set_validity_no_signal_if_unchanged():
  watch_signals(view_model)
  view_model.valid = true
  view_model.set_validity(true)
  assert_signal_not_emitted(view_model, "validity_changed")

func test_set_tile():
  view_model.set_tile(test_tile)
  
  assert_eq(view_model.tile, test_tile)
  assert_not_null(view_model.mesh)

func test_set_tile_null():
  view_model.set_tile(null)
  
  assert_null(view_model.mesh)

func test_set_tile_empty_mesh_path():
  test_tile.mesh_path = ""
  view_model.set_tile(test_tile)
  
  assert_null(view_model.mesh)

func test_set_mesh():
  watch_signals(view_model)
  view_model.set_mesh(test_mesh)
  
  assert_eq(view_model.mesh, test_mesh)
  assert_signal_emitted(view_model, "mesh_updated")

func test_to_tile_context():
  view_model.set_tile(test_tile)
  view_model.set_rotation(Vector3(0, 90, 0))
  view_model.set_validity(false)
  
  var context = view_model.to_tile_context()
  
  assert_eq(context.tile, test_tile)
  assert_eq(context.rotation, Vector3(0, 90, 0))
  assert_false(context.valid)

func test_duplicate():
  view_model.set_tile(test_tile)
  view_model.set_rotation(Vector3(0, 45, 0))
  view_model.set_validity(false)
  
  var duplicated = view_model.duplicate()
  
  assert_eq(duplicated.tile, test_tile)
  assert_eq(duplicated.rotation, Vector3(0, 45, 0))
  assert_false(duplicated.valid)
  assert_eq(duplicated.mesh, view_model.mesh)

func test_duplicate_independence():
  view_model.set_rotation(Vector3(0, 45, 0))
  var duplicated = view_model.duplicate()
  
  duplicated.set_rotation(Vector3(0, 90, 0))
  
  assert_eq(view_model.rotation.y, 45)
  assert_eq(duplicated.rotation.y, 90)
