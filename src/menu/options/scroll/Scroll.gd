extends Control
class_name Scroll

onready var label := $Label2

var cursor := 0
export var count := 0
export var list : PoolStringArray = ["zero", "one", "two"]

func axis_x(arg):
	cursor = clamp(cursor + arg, 0, (list.size() - 1) if count == 0 else count)
	set_label()
	set_value()

func set_label():
	label.text = "< " + str(list[cursor] if count == 0 else cursor) + " >"

func set_value():
	pass
