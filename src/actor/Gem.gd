extends Node2D

onready var gem_back := $Back
onready var gem_fill := $Back/Fill

export var col_1a := Color("ffdd00")
export var col_1b := Color("fffb00")
export var col_2a := Color("af00ff")
export var col_2b := Color("ff00e9")

var fade_clock := 0.0
var fade_time := 1.0

var fill_from := Color.white
var fill_to := Color.black
var back_from := Color.white
var back_to := Color.black

var is_change := false

func _physics_process(delta):
	if is_change:
		if fade_clock < fade_time:
			fade_clock = min(fade_clock + delta, fade_time)
			var s = smoothstep(0, 1, fade_clock / fade_time)
			gem_fill.color = fill_from.linear_interpolate(fill_to, s)
			gem_back.color = back_from.linear_interpolate(back_to, s)
		else:
			is_change = false

func fade_color(is_collected := false):
	is_change = true
	back_from = gem_back.color
	fill_from = gem_fill.color
	back_to = col_1a if is_collected else col_2a
	fill_to = col_1b if is_collected else col_2b
