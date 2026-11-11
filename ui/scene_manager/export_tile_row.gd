class_name ExportTileRow
extends HBoxContainer
## ExportTileRow
##
## [i]A single row in the export dialog showing a tile id, the number of times that
## tile appears in the scene, and a button to copy the tile id.[/i]

signal copy_pressed(tile_id: String)

const COPY_TEXT = "Copy"
const COPIED_TEXT = "Copied"
const COPIED_REVERT_SECONDS = 1.5

var tile_id: String

func set_tile_id(new_id: String) -> void:
  tile_id = new_id
  %TileId.text = new_id

func set_count(count: int) -> void:
  %Count.text = "x%d" % count

func forward_copy_pressed() -> void:
  copy_pressed.emit(tile_id)

## Swap the copy button's text to "Copied" and revert it after a short delay.[br]
func flash_copied() -> void:
  var copy_button: Button = %Copy
  copy_button.text = COPIED_TEXT
  var timer = get_tree().create_timer(COPIED_REVERT_SECONDS)
  timer.timeout.connect(func():
    if is_instance_valid(copy_button):
      copy_button.text = COPY_TEXT
  )
