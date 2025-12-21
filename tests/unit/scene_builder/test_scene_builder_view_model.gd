extends GutTest

const test_mesh_path = "res://tests/test_data/test_mesh.tres"

var view_model: SceneBuilderViewModel

func before_each():
    view_model = SceneBuilderViewModel.new()

func test_init():
    assert_eq(view_model.scene.scene_name, SceneBuilderViewModel.DEFAULT_SCENE_NAME, "Should initialize with default scene name")
    assert_not_null(view_model.scene.id, "Should initialize with a unique ID")
    assert_not_null(view_model.scene.data, "Should initialize with a TileLayout")
    assert_not_null(view_model.selected_tile, "Should initialize with a SceneTileViewModel")

func test_rotate_left_rotates_by_90_degrees():
    view_model.selected_tile.rotation = Vector3.ZERO
    
    view_model.rotate_left()
    
    assert_eq(view_model.get_selected_tile_rotation().y, 90, "Should rotate left by 90 degrees")

func test_rotate_left_multiple_times():
    view_model.selected_tile.rotation = Vector3.ZERO
    
    view_model.rotate_left()
    view_model.rotate_left()
    view_model.rotate_left()
    
    assert_eq(view_model.get_selected_tile_rotation().y, 270, "Should rotate to 270 degrees after 3 rotations")

func test_rotate_right_rotates_by_negative_90_degrees():
    view_model.selected_tile.rotation = Vector3(0, 90, 0)

    view_model.rotate_right()

    assert_eq(view_model.get_selected_tile_rotation().y, 0, "Should rotate right by -90 degrees")

func test_rotate_right_wraps_around():
    view_model.selected_tile.rotation = Vector3.ZERO
    
    view_model.rotate_right()
    
    assert_eq(view_model.get_selected_tile_rotation().y, 270, "Should wrap to 270 degrees when rotating right from 0")

func test_get_selected_tile_returns_selected_tile():
    var mock_tile = Tile.new()
    mock_tile.id = "test_tile"
    mock_tile.name = "Test Tile"
    mock_tile.mesh_path = test_mesh_path
    view_model.set_selected_tile(mock_tile)
    var expected = SceneTileViewModel.new()
    expected.set_tile(mock_tile)
    var result = view_model.get_selected_tile()
    
    assert_eq(result.tile.id, expected.tile.id, "Should return tile with matching id")
    assert_eq(result.tile.name, expected.tile.name, "Should return tile with matching name")
    assert_eq(result.tile.mesh_path, expected.tile.mesh_path, "Should return tile with matching mesh_path")

func test_get_selected_tile_mesh_returns_mesh():
    var mock_mesh = BoxMesh.new()
    view_model.selected_tile.mesh = mock_mesh
    
    var result = view_model.get_selected_tile_mesh()
    
    assert_eq(result, mock_mesh, "Should return the selected tile's mesh")

func test_get_selected_tile_mesh_returns_null_when_no_mesh():
    view_model.selected_tile.mesh = null
    
    var result = view_model.get_selected_tile_mesh()
    
    assert_null(result, "Should return null when no mesh is set")

func test_set_selected_tile_mesh_updates_mesh():
    var mock_mesh = BoxMesh.new()
    
    view_model.set_selected_tile_mesh(mock_mesh)
    
    assert_eq(view_model.get_selected_tile_mesh(), mock_mesh, "Should update the selected tile's mesh")

func test_set_selected_tile_updates_tile():
    var tile = Tile.new()
    tile.name = "TestTile"
    tile.id = "test_id"
    tile.mesh_path = test_mesh_path
    
    view_model.set_selected_tile(tile)
    
    assert_eq(view_model.selected_tile.tile, tile, "Should update the selected tile's tile data")

func test_set_hovered_space():
    var space = Space.new()
    space.x = 2
    space.z = 3
    var tile = Tile.new()
    tile.name = "TestTile"
    tile.id = "test_id"
    tile.mesh_path = test_mesh_path
    view_model.selected_tile.set_tile(tile)
    
    view_model.set_hovered_space(space)
    
    assert_eq(view_model.preview_space, space, "Should set the preview space correctly")

## Scene wrappers
func test_does_selected_tile_fit_success():
    var tile = Tile.new()
    tile.name = "TestTile"
    tile.id = "test_id"
    tile.mesh_path = test_mesh_path
    tile.x_size = 1
    tile.y_size = 1
    view_model.set_selected_tile(tile)
    
    var space = Space.new()
    space.x = 0
    space.z = 0
    view_model.set_hovered_space(space)

    var result = view_model.does_selected_tile_fit()
    
    assert_true(result, "Should return true when the selected tile fits at the preview space")

func test_does_selected_tile_fit_failure_no_space():
    var tile = Tile.new()
    tile.name = "TestTile"
    tile.id = "test_id"
    tile.mesh_path = test_mesh_path
    tile.x_size = 1
    tile.y_size = 1
    view_model.set_selected_tile(tile)
    view_model.set_hovered_space(null)
    
    var result = view_model.does_selected_tile_fit()

    assert_false(result, "Should return false when there is no preview space set")

func test_does_selected_tile_fit_failure_no_tile():
    view_model.set_selected_tile(null)
    var space = Space.new()
    space.x = 0
    space.z = 0
    view_model.set_hovered_space(space)

    var result = view_model.does_selected_tile_fit()
    
    assert_false(result, "Should return false when there is no selected tile set")

func test_update_id():
    var original_id = view_model.scene.id
    var new_id = "new_scene_id"
    
    watch_signals(view_model)
    view_model.update_id(new_id)
    
    assert_eq(view_model.scene.id, new_id, "Should update the scene ID")
    assert_signal_emitted(view_model, "id_updated", "Should emit id_updated signal")

func test_update_scene_name():
    var original_name = view_model.scene.scene_name
    var new_name = "New Scene Name"

    watch_signals(view_model)
    view_model.update_scene_name(new_name)

    assert_eq(view_model.scene.scene_name, new_name, "Should update the scene name")
    assert_signal_emitted(view_model, "scene_name_updated", "Should emit scene_name_updated signal")

func test_can_set_tile_at_returns_true_when_tile_fits():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  var tile_vm = SceneTileViewModel.new()
  tile_vm.set_tile(tile)
  
  var result = view_model.can_set_tile_at(0, 0, tile_vm)
  
  assert_true(result, "Should return true when tile fits at position")

func test_can_set_tile_at_returns_false_when_tile_is_null():
  var tile_vm = SceneTileViewModel.new()
  tile_vm.tile = null
  
  var result = view_model.can_set_tile_at(0, 0, tile_vm)
  
  assert_false(result, "Should return false when tile is null")

func test_can_set_tile_at_returns_false_when_tile_does_not_fit():
  var small_tile = Tile.new()
  small_tile.name = "TestTile"
  small_tile.id = "test_id"
  small_tile.mesh_path = test_mesh_path
  small_tile.x_size = 1
  small_tile.y_size = 1
  var small_tile_vm = SceneTileViewModel.new()
  small_tile_vm.set_tile(small_tile)
  
  var large_tile = Tile.new()
  large_tile.name = "LargeTile"
  large_tile.id = "large_id"
  large_tile.mesh_path = test_mesh_path
  large_tile.x_size = 2
  large_tile.y_size = 2
  var large_tile_vm = SceneTileViewModel.new()
  large_tile_vm.set_tile(large_tile)

  # Place large tile first to occupy space
  view_model.set_tile_in_layout_at(0, 0, large_tile_vm)
  
  # Try to small tile at the location the large one occupies
  var result = view_model.can_set_tile_at(1, 1, small_tile_vm)
  
  assert_false(result, "Should return false when tile does not fit at occupied position")

func test_can_set_tile_at_with_rotation():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  var tile_vm = SceneTileViewModel.new()
  tile_vm.set_tile(tile)
  tile_vm.rotation = Vector3(0, 90, 0)
  
  var result = view_model.can_set_tile_at(0, 0, tile_vm)
  
  assert_true(result, "Should check tile fit with rotation applied")

func test_can_set_selected_tile_at_returns_true_when_tile_fits():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  view_model.set_selected_tile(tile)
  
  var result = view_model.can_set_selected_tile_at(0, 0)
  
  assert_true(result, "Should return true when selected tile fits at position")

func test_can_set_selected_tile_at_returns_false_when_tile_is_null():
  view_model.selected_tile.tile = null
  
  var result = view_model.can_set_selected_tile_at(0, 0)
  
  assert_false(result, "Should return false when selected tile is null")

func test_can_set_selected_tile_at_returns_false_when_tile_does_not_fit():
  var small_tile = Tile.new()
  small_tile.name = "TestTile"
  small_tile.id = "test_id"
  small_tile.mesh_path = test_mesh_path
  small_tile.x_size = 1
  small_tile.y_size = 1
  var small_tile_vm = SceneTileViewModel.new()
  small_tile_vm.set_tile(small_tile)
  
  var large_tile = Tile.new()
  large_tile.name = "LargeTile"
  large_tile.id = "large_id"
  large_tile.mesh_path = test_mesh_path
  large_tile.x_size = 2
  large_tile.y_size = 2
  var large_tile_vm = SceneTileViewModel.new()
  large_tile_vm.set_tile(large_tile)

  # Place large tile first to occupy space
  view_model.set_tile_in_layout_at(0, 0, large_tile_vm)
  
  # Set small tile as selected and try to place at occupied location
  view_model.set_selected_tile(small_tile)
  var result = view_model.can_set_selected_tile_at(1, 1)
  
  assert_false(result, "Should return false when selected tile does not fit at occupied position")

func test_can_set_selected_tile_at_with_rotation():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  view_model.set_selected_tile(tile)
  view_model.selected_tile.rotation = Vector3(0, 90, 0)
  
  var result = view_model.can_set_selected_tile_at(0, 0)
  
  assert_true(result, "Should check selected tile fit with rotation applied")

func test_set_tile_in_layout_at_places_tile_when_it_fits():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  var tile_vm = SceneTileViewModel.new()
  tile_vm.set_tile(tile)
  
  view_model.set_tile_in_layout_at(0, 0, tile_vm)
  
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_eq(placed_tile.tile_data, tile, "Should place tile at position when it fits")

func test_set_tile_in_layout_at_does_not_place_when_tile_is_null():
  var tile_vm = SceneTileViewModel.new()
  tile_vm.tile = null
  
  view_model.set_tile_in_layout_at(0, 0, tile_vm)
  
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_null(placed_tile, "Should not place tile when tile is null")

func test_set_tile_in_layout_at_does_not_place_when_tile_does_not_fit():
  var small_tile = Tile.new()
  small_tile.name = "TestTile"
  small_tile.id = "test_id"
  small_tile.mesh_path = test_mesh_path
  small_tile.x_size = 1
  small_tile.y_size = 1
  var small_tile_vm = SceneTileViewModel.new()
  small_tile_vm.set_tile(small_tile)
  
  var large_tile = Tile.new()
  large_tile.name = "LargeTile"
  large_tile.id = "large_id"
  large_tile.mesh_path = test_mesh_path
  large_tile.x_size = 2
  large_tile.y_size = 2
  var large_tile_vm = SceneTileViewModel.new()
  large_tile_vm.set_tile(large_tile)

  view_model.set_tile_in_layout_at(0, 0, large_tile_vm)
  view_model.set_tile_in_layout_at(1, 1, small_tile_vm)
  
  var placed_tile = view_model.get_origin_tile(Vector2(1, 1))
  assert_eq(placed_tile.tile_data, large_tile, "Large tile should occupy the space")

func test_set_tile_in_layout_at_with_rotation():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  var tile_vm = SceneTileViewModel.new()
  tile_vm.set_tile(tile)
  tile_vm.rotation = Vector3(0, 90, 0)
  
  view_model.set_tile_in_layout_at(0, 0, tile_vm)
  
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_not_null(placed_tile, "Should place tile with rotation applied")

func test_set_selected_tile_in_layout_at_places_tile_when_it_fits():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  view_model.set_selected_tile(tile)
  
  view_model.set_selected_tile_in_layout_at(0, 0)
  
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_not_null(placed_tile, "Should place selected tile at position when it fits")

func test_set_selected_tile_in_layout_at_does_not_place_when_tile_is_null():
  view_model.selected_tile.tile = null
  
  view_model.set_selected_tile_in_layout_at(0, 0)
  
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_null(placed_tile, "Should not place selected tile when tile is null")

func test_set_selected_tile_in_layout_at_does_not_place_when_tile_does_not_fit():
  var small_tile = Tile.new()
  small_tile.name = "TestTile"
  small_tile.id = "test_id"
  small_tile.mesh_path = test_mesh_path
  small_tile.x_size = 1
  small_tile.y_size = 1
  
  var large_tile = Tile.new()
  large_tile.name = "LargeTile"
  large_tile.id = "large_id"
  large_tile.mesh_path = test_mesh_path
  large_tile.x_size = 2
  large_tile.y_size = 2
  var large_tile_vm = SceneTileViewModel.new()
  large_tile_vm.set_tile(large_tile)

  view_model.set_tile_in_layout_at(0, 0, large_tile_vm)
  view_model.set_selected_tile(small_tile)
  view_model.set_selected_tile_in_layout_at(1, 1)
  
  var placed_tile = view_model.get_origin_tile(Vector2(1, 1))
  assert_eq(placed_tile.tile_data, large_tile, "Large tile should occupy the space")

func test_set_selected_tile_in_layout_at_with_rotation():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  view_model.set_selected_tile(tile)
  view_model.selected_tile.rotation = Vector3(0, 90, 0)
  
  view_model.set_selected_tile_in_layout_at(0, 0)
  
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_not_null(placed_tile, "Should place selected tile with rotation applied")

func test_remove_tile_in_layout_at_removes_tile():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  var tile_vm = SceneTileViewModel.new()
  tile_vm.set_tile(tile)
  
  view_model.set_tile_in_layout_at(0, 0, tile_vm)
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_eq(placed_tile.tile_data, tile, "Should place tile in layout")

  view_model.remove_tile_in_layout_at(0, 0)
  
  placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_null(placed_tile, "Should remove tile from layout")

func test_remove_tile_in_layout_with_no_tile():
  view_model.remove_tile_in_layout_at(0, 0)
  
  var placed_tile = view_model.get_origin_tile(Vector2(0, 0))
  assert_null(placed_tile, "Should handle removing tile when none exists without error")

func test_get_origin_tile_returns_placed_tile():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  var tile_vm = SceneTileViewModel.new()
  tile_vm.set_tile(tile)
  
  view_model.set_tile_in_layout_at(0, 0, tile_vm)
  
  var result = view_model.get_origin_tile(Vector2(0, 0))
  assert_eq(result.tile_data, tile, "Should return correct tile data")

func test_get_origin_tile_returns_null_when_no_tile():
  var result = view_model.get_origin_tile(Vector2(0, 0))
  
  assert_null(result, "Should return null when no tile at position")

func test_get_origin_tile_with_large_tile():
  var large_tile = Tile.new()
  large_tile.name = "LargeTile"
  large_tile.id = "large_id"
  large_tile.mesh_path = test_mesh_path
  large_tile.x_size = 3
  large_tile.y_size = 3
  var large_tile_vm = SceneTileViewModel.new()
  large_tile_vm.set_tile(large_tile)
  
  view_model.set_tile_in_layout_at(0, 0, large_tile_vm)
  
  var result = view_model.get_origin_tile(Vector2(0, 0))
  assert_eq(result.tile_data, large_tile, "Should return correct large tile data")
  result = view_model.get_origin_tile(Vector2(1, 1))
  assert_eq(result.tile_data, large_tile, "Should return correct large tile data for occupied space")

func test_get_origin_tile_after_removal():
  var tile = Tile.new()
  tile.name = "TestTile"
  tile.id = "test_id"
  tile.mesh_path = test_mesh_path
  tile.x_size = 1
  tile.y_size = 1
  var tile_vm = SceneTileViewModel.new()
  tile_vm.set_tile(tile)
  
  view_model.set_tile_in_layout_at(0, 0, tile_vm)
  view_model.remove_tile_in_layout_at(0, 0)
  
  var result = view_model.get_origin_tile(Vector2(0, 0))
  assert_null(result, "Should return null after tile is removed")
