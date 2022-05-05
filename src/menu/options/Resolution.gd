extends Control

var cursor := 1

onready var list : Array = Shared.win_sizes
onready var res := $Resolution

func _ready():
	var f = list.find(Shared.win_size)
	if f != -1:
		cursor = f
	
	show()

func show():
	res.text = "< " + str(list[cursor].x) + " x " + str(list[cursor].y) + " >"

func axis_x(arg := 1):
	cursor = clamp(cursor + arg, 0, list.size() - 1)
	show()
	Shared.set_window_size(list[cursor])
