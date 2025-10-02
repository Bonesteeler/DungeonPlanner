class_name Scene
extends RefCounted

var author: String
var data: TileLayout
var id: String
var scene_name: String
var version: int

func _init():
  author = TileLayout.AUTHOR_STRING
  data = TileLayout.new()
  id = ""
  scene_name = ""
  version = 1