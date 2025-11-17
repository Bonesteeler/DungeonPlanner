class_name SetListItem
extends HBoxContainer
## SetListItem
##
## [i]UI component representing a single tile set in the set list.[/i][br]
## [b]Properties:[/b][br]
## - [b]text[/b]: [String] name of the tile set.[br]
## [b]Signals:[/b][br]
## - [code]delete_pressed(String)[/code]: Emitted when delete button is pressed.[br]
## - [code]select_pressed(String)[/code]: Emitted when item is selected.[br]

signal delete_pressed(String)
signal select_pressed(String)

var text: String = ""

## Set the displayed text for the tile set name[br]
## [b]Parameters:[/b][br]
## [code]new_text[/code] : [String] — tile set name to display.[br]
func set_text(new_text: String):
  text = new_text
  $%Name.text = text

## Forward delete button press with tile set name[br]
## [b]Emits:[/b][br]
## - [code]delete_pressed(text)[/code][br]
func forward_delete_pressed():
  delete_pressed.emit(text)

## Forward select button press with tile set name[br]
## [b]Emits:[/b][br]
## - [code]select_pressed(text)[/code][br]
func forward_select_pressed():
  select_pressed.emit(text)