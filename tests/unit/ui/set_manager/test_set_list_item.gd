extends GutTest

const SET_LIST_ITEM_SCENE = preload("res://ui/set_manager/set_list_item.tscn")

var list_item: SetListItem

func before_each():
	list_item = SET_LIST_ITEM_SCENE.instantiate()
	add_child_autofree(list_item)

func test_set_text_updates_display():
	list_item.set_text("MyTileSet")
	
	assert_eq(list_item.text, "MyTileSet", "text property should be set")
	var name_label = list_item.get_node("%Name")
	assert_eq(name_label.text, "MyTileSet", "Name label should display the text")

func test_forward_delete_pressed_emits_signal():
	watch_signals(list_item)
	list_item.set_text("SetToDelete")
	
	list_item.forward_delete_pressed()
	
	assert_signal_emitted_with_parameters(
		list_item,
		"delete_pressed",
		["SetToDelete"]
	)

func test_forward_select_pressed_emits_signal():
	watch_signals(list_item)
	list_item.set_text("SetToSelect")
	
	list_item.forward_select_pressed()
	
	assert_signal_emitted_with_parameters(
		list_item,
		"select_pressed",
		["SetToSelect"]
	)

func test_multiple_operations():
	watch_signals(list_item)
	
	list_item.set_text("FirstSet")
	list_item.forward_select_pressed()
	
	assert_signal_emit_count(list_item, "select_pressed", 1)
	
	list_item.set_text("SecondSet")
	list_item.forward_delete_pressed()
	
	assert_signal_emit_count(list_item, "delete_pressed", 1)
	assert_signal_emitted_with_parameters(
		list_item,
		"delete_pressed",
		["SecondSet"]
	)
