class_name ExportDialogViewModel
extends RefCounted
## ExportDialogViewModel
##
## [i]View model for the export dialog. Converts a scene's tile counts into export entries
## carrying each tile's source path when it exists in tile resources, sorts them for display,
## and provides the clipboard payload for the dialog.[/i][br]
## [b]Properties:[/b][br]
## - [b]tile_resources[/b]: [TileResources] — tile resource manager used to resolve source paths.[br]

var tile_resources: TileResources

var _entries: Array[ExportTileEntry] = []

## Initialize with a TileResources instance.[br]
## [b]Parameters:[/b][br]
## [code]resources[/code] : [TileResources] — tile resource manager.[br]
func _init(resources: TileResources = TileSets):
    tile_resources = resources

## Populate entries from the scene, then sort them for display: imported tiles (with source
## paths) first, ordered lexicographically by source path, followed by unimported tiles
## ordered by count descending.[br]
## [b]Parameters:[/b][br]
## [code]scene[/code] : [Scene] — the scene to export tile data for.[br]
func open(scene: Scene) -> void:
    _entries = []
    var counts: Dictionary = scene.data.get_tile_counts()
    for tile_id in counts:
        var entry := ExportTileEntry.new()
        entry.tile_id = tile_id
        entry.count = counts[tile_id]
        var tile: Tile = tile_resources.get_tile_from_id(tile_id)
        if tile != null:
            entry.source_path = tile.source_path
        _entries.append(entry)
    _sort_entries()

## [b]Returns:[/b] [Array[ExportTileEntry]] — the sorted export entries.[br]
func get_entries() -> Array[ExportTileEntry]:
    return _entries

## [b]Returns:[/b] [bool] — [code]true[/code] when there are no entries.[br]
func is_empty() -> bool:
    return _entries.is_empty()

## Build the copy-all clipboard payload in the same order as the displayed rows.[br]
## [b]Returns:[/b] [Array] — list of [code]{"source_path": ..., "count": ...}[/code] or [code]{"tile_id": ..., "count": ...}[/code] dictionaries.[br]
func build_export_payload() -> Array:
    var payload: Array = []
    for entry in _entries:
        if entry.source_path.is_empty():
            payload.append({"tile_id": entry.tile_id, "count": entry.count})
        else:
            payload.append({"source_path": entry.source_path, "count": entry.count})
    return payload

## Sort the entries in place: imported tiles (with source paths) first, ordered
## lexicographically by source path, followed by unimported tiles ordered by count descending.
func _sort_entries() -> void:
    var with_source_path: Array[ExportTileEntry] = []
    var without_source_path: Array[ExportTileEntry] = []
    for entry in _entries:
        if entry.source_path.is_empty():
            without_source_path.append(entry)
        else:
            with_source_path.append(entry)
    with_source_path.sort_custom(func(a: ExportTileEntry, b: ExportTileEntry): return a.source_path < b.source_path)
    without_source_path.sort_custom(func(a: ExportTileEntry, b: ExportTileEntry): return a.count > b.count)
    _entries = with_source_path + without_source_path
