class_name NavigationBarViewModel
extends RefCounted

signal scene_builders_updated()

var scene_builders: Array = []

func add_scene_builder(vm: SceneBuilderViewModel) -> void:
  if has_scene_with_id(vm.scene.id):
    return
  scene_builders.append(vm)
  vm.id_updated.connect(func(): scene_builders_updated.emit())
  scene_builders_updated.emit()

func has_scene_with_id(id: String) -> bool:
  for vm in scene_builders:
    if vm.scene.id == id:
      return true
  return false

func get_scene_by_id(id: String) -> SceneBuilderViewModel:
  for vm in scene_builders:
    if vm.scene.id == id:
      return vm
  return null