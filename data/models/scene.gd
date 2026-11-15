class_name Scene
extends RefCounted
## Scene
##
## [i]Data class representing a user-created planning scene.[/i][br]
## [b]Properties:[/b][br]
## - [b]author[/b]: Author string.[br]
## - [b]data[/b]: The contained [code]TileLayout[/code] describing the placed tiles.[br]
## - [b]id[/b]: Unique identifier for the scene.[br]
## - [b]scene_name[/b]: Human-readable name.[br]
## - [b]version[/b]: Integer version of the scene data format.[br]

var author: String = TileLayout.AUTHOR_STRING
var data: TileLayout = TileLayout.new()
var id: String = ""
var scene_name: String = ""
var version: int = 1
