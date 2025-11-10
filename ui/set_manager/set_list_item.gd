class_name SetListItem
extends HBoxContainer

signal delete_pressed

func set_text(text: String):
  $%Name.text = text

func forward_delete_pressed():
  delete_pressed.emit()