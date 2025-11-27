class_name NavigationBar
extends Container

## NavigationBar
##
## Custom tab bar that sends signals when a tab is selected.[br]
## [b]Signals:[/b][br]
## - home_selected() - Emitted when the home tab is selected.
## - planner_selected(string) - Emitted when the planner tab is selected.
## - set_selected() - Emitted when the sets tab is selected.

signal home_selected()
signal planner_selected(string)
signal sets_selected()

func forward_home_selected():
    home_selected.emit()

func forward_planner_selected(tab_name: String):
    planner_selected.emit(tab_name)

func forward_sets_selected():
    sets_selected.emit()
