class_name NavigationBarViewModel
extends RefCounted

var scene_builders: Array = []

func add_scene_builder(scene: SceneBuilderViewModel) -> void:
  scene_builders.append(scene)

func get_scene_by_name(name: String) -> SceneBuilderViewModel:
  for scene in scene_builders:
    if scene.layout.name == name:
      return scene
  return null