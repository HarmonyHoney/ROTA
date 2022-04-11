extends Control

var list := [Vector2(640, 360), Vector2(960, 540), Vector2(1280, 720), Vector2(1600, 900),
Vector2(1920, 1080), Vector2(2560, 1440), Vector2(3840, 2160)]

var cursor := 1

onready var res := $Resolution

func _ready():
	var f = list.find(OS.window_size)
	if f != -1:
		cursor = f
	
	show()

func show():
	res.text = "< " + str(list[cursor].x) + " x " + str(list[cursor].y) + " >"

func axis_x(arg := 1):
	cursor = clamp(cursor + arg, 0, list.size() - 1)
	show()
	OS.window_size = list[cursor]

func act():
	axis_x(0)
