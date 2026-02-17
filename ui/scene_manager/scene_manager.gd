class_name SceneManager
extends MarginContainer
## SceneManager
##
## [i]UI component for managing scenes, allowing users to view, select, and create scenes.[/i][br]

signal scene_selected(vm: SceneBuilderViewModel)

var view_model: SceneManagerViewModel

@onready var scene_selector: SceneSelector = $%SceneSelector

func _ready():
    # Initialize view model with SceneSaveService and set it to the selector
    view_model = SceneManagerViewModel.new(SceneSaveService)
    scene_selector.set_vm(view_model)
    
    # Connect signals
    scene_selector.scene_selected.connect(_on_scene_selected)
    scene_selector.new_scene_requested.connect(_on_new_scene_requested)

func _on_scene_selected(scene_id: String) -> void:
    var scene_data = view_model.find_scene_by_id(scene_id)
    if scene_data != null:
      var new_scene_vm = SceneBuilderViewModel.new(scene_data)
      scene_selected.emit(new_scene_vm)

func _on_new_scene_requested() -> void:
    var scene_view_model = SceneBuilderViewModel.new()
    scene_selected.emit(scene_view_model)
