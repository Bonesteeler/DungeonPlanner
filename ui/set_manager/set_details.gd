class_name SetDetails
extends VBoxContainer

var viewModel: SetDetailsViewModel

@onready var titleLabel = $%Title

func set_vm(vm: SetDetailsViewModel) -> void:
    viewModel = vm
    viewModel.current_set_changed.connect(update_title)
    update_title(viewModel.get_current_set_name())

func update_title(new_set_name: String) -> void:
    titleLabel.text = new_set_name