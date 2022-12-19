extends Node2D

onready var gem_back := $Back
onready var gem_fill := $Back/Fill

export var from_fill := Color("ff00e9")
export var from_back := Color("af00ff")
export var to_fill := Color("fffb00")
export var to_back := Color("ffdd00")

var fade_easy = EaseMover.new()
var is_fade := false

func _physics_process(delta):
	if is_fade:
		fade_easy.count(delta)
		gem_back.color = from_back.linear_interpolate(to_back, fade_easy.smooth())
		gem_fill.color = from_fill.linear_interpolate(to_fill, fade_easy.smooth())
		if fade_easy.clock == 0 or fade_easy.is_complete:
			is_fade = false

func set_color(is_collected := true):
	gem_back.color = to_back if is_collected else from_back
	gem_fill.color = to_fill if is_collected else from_fill

func fade_color(arg := true):
	is_fade = true
	fade_easy.show = arg
	fade_easy.clock = 0 if arg else fade_easy.time
	
	
