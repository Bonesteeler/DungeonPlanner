extends GutTest

var view_model: NavigationBarViewModel


func before_each() -> void:
	view_model = NavigationBarViewModel.new()


func _make_scene_builder(scene_id: String) -> SceneBuilderViewModel:
	var builder := SceneBuilderViewModel.new()
	builder.scene.id = scene_id
	return builder


func test_add_scene_builder_adds_builder_and_emits() -> void:
	watch_signals(view_model)

	view_model.add_scene_builder(_make_scene_builder("scene-1"))

	assert_eq(view_model.scene_builders.size(), 1, "Should add the scene builder")
	assert_signal_emitted(view_model, "scene_builders_updated")


func test_add_scene_builder_ignores_duplicate_id() -> void:
	view_model.add_scene_builder(_make_scene_builder("scene-1"))
	watch_signals(view_model)

	view_model.add_scene_builder(_make_scene_builder("scene-1"))

	assert_eq(view_model.scene_builders.size(), 1, "Should not add a builder with a duplicate id")
	assert_signal_not_emitted(view_model, "scene_builders_updated")


func test_remove_scene_builder_removes_matching_builder() -> void:
	view_model.add_scene_builder(_make_scene_builder("keep"))
	view_model.add_scene_builder(_make_scene_builder("remove"))
	watch_signals(view_model)

	view_model.remove_scene_builder("remove")

	assert_eq(view_model.scene_builders.size(), 1, "Should remove only the matching builder")
	assert_true(view_model.has_scene_with_id("keep"), "Should keep other builders")
	assert_false(view_model.has_scene_with_id("remove"), "Should remove the matching builder")
	assert_signal_emitted(view_model, "scene_builders_updated")


func test_remove_scene_builder_without_match_does_not_emit() -> void:
	view_model.add_scene_builder(_make_scene_builder("keep"))
	watch_signals(view_model)

	view_model.remove_scene_builder("missing")

	assert_eq(view_model.scene_builders.size(), 1, "Should not remove any builder")
	assert_signal_not_emitted(view_model, "scene_builders_updated")


func test_remove_scene_builder_removes_all_matching_entries() -> void:
	view_model.scene_builders.append(_make_scene_builder("dup"))
	view_model.scene_builders.append(_make_scene_builder("dup"))
	view_model.scene_builders.append(_make_scene_builder("keep"))
	watch_signals(view_model)

	view_model.remove_scene_builder("dup")

	assert_eq(view_model.scene_builders.size(), 1, "Should remove every matching builder")
	assert_true(view_model.has_scene_with_id("keep"), "Should keep non-matching builders")
	assert_eq(
		get_signal_emit_count(view_model, "scene_builders_updated"),
		1,
		"Should emit scene_builders_updated only once"
	)
