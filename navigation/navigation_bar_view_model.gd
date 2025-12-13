class_name NavigationBarViewModel
extends RefCounted

signal scene_builders_updated()

var scene_builders: Array = []

func add_scene_builder(vm: SceneBuilderViewModel) -> void:
  if has_scene_with_name(vm.scene.scene_name):
    return
  scene_builders.append(vm)
  scene_builders_updated.emit()

func has_scene_with_name(name: String) -> bool:
  for vm in scene_builders:
    if vm.scene.scene_name == name:
      return true
  return false

func get_scene_by_name(name: String) -> SceneBuilderViewModel:
  for vm in scene_builders:
    if vm.scene.scene_name == name:
      return vm
  return null