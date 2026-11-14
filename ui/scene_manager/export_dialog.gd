class_name ExportDialog
extends AcceptDialog
## ExportDialog
##
## [i]Dialog listing the tiles in a scene alongside the number of times each tile appears,
## with buttons to copy individual entries or the full scene export data as JSON. Imported
## tiles are shown by their source path; unimported tiles fall back to their tile id.[/i]

const EXPORT_TILE_ROW_SCENE = preload("res://ui/scene_manager/export_tile_row.tscn")

const COPY_ALL_TEXT = "Copy All Tiles to Clipboard"
const COPIED_TEXT = "Copied"
const COPIED_REVERT_SECONDS = 1.5
const MAX_SCROLL_HEIGHT = 300

@onready var copy_all_button: Button = $%CopyAllButton
@onready var empty_label: Label = $%EmptyLabel
@onready var scroll_container: ScrollContainer = $%ScrollContainer
@onready var rows: VBoxContainer = $%Rows

var view_model: ExportDialogViewModel

func _ready() -> void:
  view_model = ExportDialogViewModel.new()

## Count the tiles in the scene, rebuild the row list, and show the dialog.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to export tile data for.[br]
func open(scene: Scene) -> void:
  view_model.open(scene)
  title = "Export: %s" % scene.scene_name
  _rebuild_rows()
  popup_centered()

func _rebuild_rows() -> void:
  for child in rows.get_children():
    child.free()
  empty_label.visible = view_model.is_empty()
  for entry in view_model.get_entries():
    var row: ExportTileRow = EXPORT_TILE_ROW_SCENE.instantiate()
    row.set_label_text(entry.display_text())
    row.set_count(entry.count)
    row.copy_pressed.connect(_on_row_copy_pressed.bind(row))
    rows.add_child(row)
  _fit_scroll_to_rows()

## Size the scroll container, capping the height so long tile lists scroll.[br]
func _fit_scroll_to_rows() -> void:
  scroll_container.custom_minimum_size.y = min(rows.get_combined_minimum_size().y, MAX_SCROLL_HEIGHT)

func _on_row_copy_pressed(label_text: String, row: ExportTileRow) -> void:
  DisplayServer.clipboard_set(label_text)
  row.flash_copied()

func _on_copy_all_pressed() -> void:
  DisplayServer.clipboard_set(JSON.stringify(view_model.build_export_payload(), "  "))
  _flash_copied(copy_all_button)

## Swap a copy button's text to "Copied" and revert it after a short delay.[br]
func _flash_copied(button: Button) -> void:
  var original_text = button.text
  button.text = COPIED_TEXT
  var timer = get_tree().create_timer(COPIED_REVERT_SECONDS)
  timer.timeout.connect(func():
    if is_instance_valid(button):
      button.text = original_text
  )
