class_name ExportDialog
extends AcceptDialog
## ExportDialog
##
## [i]Dialog listing the tile ids in a scene alongside the number of times each tile appears,
## with buttons to copy individual tile ids or the full scene export data as JSON.[/i]

const EXPORT_TILE_ROW_SCENE = preload("res://ui/scene_manager/export_tile_row.tscn")

const COPY_ALL_TEXT = "Copy All"
const COPIED_TEXT = "Copied"
const COPIED_REVERT_SECONDS = 1.5
const MAX_SCROLL_HEIGHT = 300

@onready var copy_all_button: Button = $%CopyAllButton
@onready var empty_label: Label = $%EmptyLabel
@onready var scroll_container: ScrollContainer = $%ScrollContainer
@onready var rows: VBoxContainer = $%Rows

var _counts: Dictionary = {}

## Count the tiles in the scene, rebuild the row list, and show the dialog.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to export tile data for.[br]
func open(scene: Scene) -> void:
  _counts = scene.data.get_tile_counts()
  title = "Export: %s" % scene.scene_name
  _rebuild_rows()
  popup_centered()

func _rebuild_rows() -> void:
  for child in rows.get_children():
    child.free()
  empty_label.visible = _counts.is_empty()
  for tile_id in _sorted_ids():
    var row: ExportTileRow = EXPORT_TILE_ROW_SCENE.instantiate()
    row.set_tile_id(tile_id)
    row.set_count(_counts[tile_id])
    row.copy_pressed.connect(_on_row_copy_pressed.bind(row))
    rows.add_child(row)
  _fit_scroll_to_rows()

## Size the scroll container, capping the height so long tile lists scroll.[br]
func _fit_scroll_to_rows() -> void:
  scroll_container.custom_minimum_size.y = min(rows.get_combined_minimum_size().y, MAX_SCROLL_HEIGHT)

func _sorted_ids() -> Array:
  var ids = _counts.keys()
  ids.sort_custom(func(a, b): return _counts[a] > _counts[b])
  return ids

func _on_row_copy_pressed(tile_id: String, row: ExportTileRow) -> void:
  DisplayServer.clipboard_set(tile_id)
  row.flash_copied()

func _on_copy_all_pressed() -> void:
  var payload: Array = []
  for tile_id in _sorted_ids():
    payload.append({"tile_id": tile_id, "count": _counts[tile_id]})
  DisplayServer.clipboard_set(JSON.stringify(payload, "  "))
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
