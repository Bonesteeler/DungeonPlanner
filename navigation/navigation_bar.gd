class_name NavigationBar
extends Container

## NavigationBar
##
## Custom tab bar that sends signals when a tab is selected.[br]
## [b]Signals:[/b][br]
## - home_selected() - Emitted when the home tab is selected.
## - planner_selected() - Emitted when the planner tab is selected.

signal home_selected()
signal planner_selected()

func forward_home_selected():
    home_selected.emit()

func forward_planner_selected():
    planner_selected.emit()
