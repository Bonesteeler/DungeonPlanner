class_name NavigationBarViewModel
extends RefCounted

## NavigationBarViewModel
##
## [i]Manages non static data used in the navigation bar.[/i][br]
## [b]Properties:[/b][br]
## - [b]scene_builders[/b]: Array of [SceneBuilderViewModel]s.[br]
## [b]Signals:[/b][br]
## - [code]scene_builders_updated[/code]: Emitted when the scene builders change.[br]

signal scene_builders_updated()

var scene_builders: Array = []

## Adds a scene builder to the collection if its ID is not already present.[br]
## [b]Parameters:[/b][br]
## [code]vm[/code] : [SceneBuilderViewModel] — the scene builder view model to add.[br]
## [b]Emits:[/b][br]
## - [code]scene_builders_updated[/code] if the scene builder was successfully added[br]
func add_scene_builder(vm: SceneBuilderViewModel) -> void:
  if has_scene_with_id(vm.scene.id):
    return
  scene_builders.append(vm)
  vm.id_updated.connect(func(): scene_builders_updated.emit())
  scene_builders_updated.emit()

## Checks if a scene builder with the specified ID exists in the collection.[br]
## [b]Parameters:[/b][br]
## [code]id[/code] : [String] — the scene ID to search for.[br]
## [b]Returns:[/b] [bool][br]
func has_scene_with_id(id: String) -> bool:
  for vm in scene_builders:
    if vm.scene.id == id:
      return true
  return false

## Retrieves the scene builder with the specified ID.[br]
## [b]Parameters:[/b][br]
## [code]id[/code] : [String] — the scene ID to retrieve.[br]
## [b]Returns:[/b] [SceneBuilderViewModel] or [code]null[/code] if not found[br]
func get_scene_by_id(id: String) -> SceneBuilderViewModel:
  for vm in scene_builders:
    if vm.scene.id == id:
      return vm
  return null