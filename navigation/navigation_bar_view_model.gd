class_name NavigationBarViewModel
extends RefCounted

signal scene_builders_updated()

var scene_builders: Array = []

func add_scene_builder(scene: SceneBuilderViewModel) -> void:
  if has_scene_with_name(scene.scene_name):
    return
  scene_builders.append(scene)
  scene_builders_updated.emit()

func has_scene_with_name(name: String) -> bool:
  for scene in scene_builders:
    if scene.scene_name == name:
      return true
  return false

func get_scene_by_name(name: String) -> SceneBuilderViewModel:
  for scene in scene_builders:
    if scene.scene_name == name:
      return scene
  return null