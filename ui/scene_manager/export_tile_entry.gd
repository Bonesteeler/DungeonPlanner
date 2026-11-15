class_name ExportTileEntry
extends RefCounted
## ExportTileEntry
##
## [i]A single tile's export data.[/i][br]
## [b]Properties:[/b][br]
## - [b]tile_id[/b]: [String] — unique identifier of the tile.[br]
## - [b]count[/b]: [int] — number of times the tile appears in the scene.[br]
## - [b]source_path[/b]: [String] — filesystem path of the source file, or empty[br]

var tile_id: String
var count: int
var source_path: String = ""


## The text to display for this entry: source path if present, tile id fallback.[br]
## [b]Returns:[/b] [String] — display text for the entry.[br]
func display_text() -> String:
	if source_path.is_empty():
		return tile_id
	return source_path
