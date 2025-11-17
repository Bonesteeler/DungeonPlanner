extends GutTest

const SET_LIST_SCENE = preload("res://ui/set_manager/set_list.tscn")

var set_list: SetList
var view_model: SetListViewModel
var mock_resources: TileResources

func before_each():
	mock_resources = TileResources.new()
	view_model = SetListViewModel.new(mock_resources)
	set_list = SET_LIST_SCENE.instantiate()
	add_child_autofree(set_list)

func test_set_vm_initializes_list():
	set_list.set_vm(view_model)
	
	assert_not_null(set_list.viewModel, "viewModel should be set")
	assert_eq(set_list.viewModel, view_model, "viewModel should match")

func test_update_items_clears_existing_items():
	# Add some tile sets
	var set1 = DragonbiteTileSet.new()
	set1.name = "Set1"
	var set2 = DragonbiteTileSet.new()
	set2.name = "Set2"
	mock_resources.add_set(set1)
	mock_resources.add_set(set2)
	
	set_list.set_vm(view_model)
	
	var container = set_list.get_node("%SetListContainer")
	assert_eq(container.get_child_count(), 2, "Should have 2 items initially")
	
	# Remove one set and update
	mock_resources.tile_sets.remove_at(0)
	
	# Wait for children to be freed
	await wait_frames(2)
	
	assert_eq(container.get_child_count(), 1, "Should have 1 item after update")

func test_update_items_creates_list_items():
	var set1 = DragonbiteTileSet.new()
	set1.name = "TestSet1"
	var set2 = DragonbiteTileSet.new()
	set2.name = "TestSet2"
	mock_resources.add_set(set1)
	mock_resources.add_set(set2)
	
	set_list.set_vm(view_model)
	
	var container = set_list.get_node("%SetListContainer")
	assert_eq(container.get_child_count(), 2, "Should create 2 list items")
	
	var first_item = container.get_child(0)
	assert_eq(first_item.text, "TestSet1", "First item should have correct text")

func test_forward_delete_pressed_emits_signal():
	watch_signals(set_list)
	
	set_list.forward_delete_pressed("SetToDelete")
	
	assert_signal_emitted_with_parameters(
		set_list,
		"delete_set",
		["SetToDelete"]
	)

func test_forward_select_pressed_emits_signal():
	watch_signals(set_list)
	
	set_list.forward_select_pressed("SetToSelect")
	
	assert_signal_emitted_with_parameters(
		set_list,
		"select_set",
		["SetToSelect"]
	)

func test_forward_import_pressed_emits_signal():
	watch_signals(set_list)
	
	set_list.forward_import_pressed()
	
	assert_signal_emitted(set_list, "import_set", "Should emit import_set signal")

func test_list_items_connect_signals():
	var test_set = DragonbiteTileSet.new()
	test_set.name = "SignalTestSet"
	mock_resources.add_set(test_set)
	
	set_list.set_vm(view_model)
	watch_signals(set_list)
	
	var container = set_list.get_node("%SetListContainer")
	var item = container.get_child(0)
	
	# Trigger the item's signals
	item.forward_delete_pressed()
	assert_signal_emitted_with_parameters(
		set_list,
		"delete_set",
		["SignalTestSet"]
	)
	
	item.forward_select_pressed()
	assert_signal_emitted_with_parameters(
		set_list,
		"select_set",
		["SignalTestSet"]
	)

func test_update_on_view_model_sets_changed():
	set_list.set_vm(view_model)
	
	var container = set_list.get_node("%SetListContainer")
	assert_eq(container.get_child_count(), 0, "Should start empty")
	
	# Add a set and trigger update
	var new_set = DragonbiteTileSet.new()
	new_set.name = "DynamicSet"
	mock_resources.add_set(new_set)
	
	# Wait for signal propagation
	await wait_frames(2)
	
	assert_eq(container.get_child_count(), 1, "Should update when view model emits sets_changed")
