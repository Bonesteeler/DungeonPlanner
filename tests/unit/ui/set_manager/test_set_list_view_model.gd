extends GutTest

var view_model: SetListViewModel
var mock_resources: TileResources

func before_each():
  mock_resources = TileResources.new(false)
  view_model = SetListViewModel.new(mock_resources)

func test_init_loads_initial_set_list():
  # TileResources will have 0 sets by default
  var sets = view_model.get_set_list()
  assert_eq(sets.size(), 0, "Should start with empty set list")

func test_get_set_list_returns_set_names():
  # Create mock tile sets
  var set1 = DragonbiteTileSet.new()
  set1.name = "TestSet1"
  var set2 = DragonbiteTileSet.new()
  set2.name = "TestSet2"

  mock_resources.add_set(set1)
  mock_resources.add_set(set2)

  view_model.update_set_list()

  var sets = view_model.get_set_list()
  assert_eq(sets.size(), 2, "Should have 2 sets")
  assert_has(sets, "TestSet1", "Should contain TestSet1")
  assert_has(sets, "TestSet2", "Should contain TestSet2")

func test_update_set_list_refreshes_from_resources():
  watch_signals(view_model)
  var initial_sets = view_model.get_set_list()
  assert_eq(initial_sets.size(), 0, "Should start empty")

  # Add a set to resources
  var new_set = DragonbiteTileSet.new()
  new_set.name = "NewSet"
  mock_resources.add_set(new_set)

  assert_signal_emitted(view_model, "sets_changed", "Should emit sets_changed signal")
  var updated_sets = view_model.get_set_list()
  assert_eq(updated_sets.size(), 1, "Should have 1 set after update")
  assert_has(updated_sets, "NewSet", "Should contain NewSet")

func test_update_set_list_emits_sets_changed_signal():
  watch_signals(view_model)

  view_model.update_set_list()

  assert_signal_emitted(view_model, "sets_changed", "Should emit sets_changed signal")
