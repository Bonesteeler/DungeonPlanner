class_name SetListItem
extends HBoxContainer

signal delete_pressed(String)
signal select_pressed(String)

var text: String = ""

func set_text(new_text: String):
  text = new_text
  $%Name.text = text

func forward_delete_pressed():
  delete_pressed.emit(text)

func forward_select_pressed():
  select_pressed.emit(text)