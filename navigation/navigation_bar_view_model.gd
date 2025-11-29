class_name NavigationBarViewModel
extends RefCounted

signal scene_builders_updated()

var scene_builders: Array = []

func add_scene_builder(scene: SceneBuilderViewModel) -> void:
  scene_builders.append(scene)
  scene_builders_updated.emit()

func get_scene_by_name(name: String) -> SceneBuilderViewModel:
  for scene in scene_builders:
    if scene.layout.name == name:
      return scene
  return null