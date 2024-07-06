extends Node

class_name SaveManager

const savedScenesPath = "user://SavedScenes/"

var sceneNames: Array[String] = []

func _init():
  var dir = DirAccess.open("user://")
  if dir.dir_exists(savedScenesPath) == false:
    dir.make_dir(savedScenesPath)
  var savedScenesDir = DirAccess.open(savedScenesPath)
  savedScenesDir.list_dir_begin()
  var saveName = savedScenesDir.get_next()
  while saveName != "":
    if saveName.ends_with(".json"):
      sceneNames.append(saveName.replace(".json", ""))
    saveName = savedScenesDir.get_next()
  savedScenesDir.list_dir_end()

func load_scene_from_json(file_name: String) -> SceneData:
    var file = FileAccess.open(savedScenesPath + file_name + ".json", FileAccess.READ)
    if file == null:
      var newScene = SceneData.new(10, 10)
      newScene.sceneName = file_name
      return newScene
    var jsonString = file.get_as_text()
    var parsedScene = SceneData.new(10, 10)
    parsedScene.fromJson(jsonString)
    file.close()
    return parsedScene

func save_scene_to_json(scene: SceneData):
  var jsonString = scene.toJson()
  var file = FileAccess.open(savedScenesPath + scene.sceneName + ".json", FileAccess.WRITE)
  file.store_string(jsonString)
  file.close()