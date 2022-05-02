extends Control
class_name OnOff

onready var label := $Label2
var is_on := false

func act():
	is_on = !is_on
	set_label()
	set_value()

func axis_x(arg):
	if (is_on and arg == -1) or (!is_on and arg == 1):
		act()

func set_label(arg := is_on):
	label.text = "< " + ("ON" if arg else "OFF") + " >"

func set_value():
	pass
