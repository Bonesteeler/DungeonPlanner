extends GutTest

const test_mesh_path = "res://tests/test_data/test_mesh.tres"

var view_model: SceneBuilderViewModel

func before_each():
    view_model = SceneBuilderViewModel.new()

func test_init():
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
