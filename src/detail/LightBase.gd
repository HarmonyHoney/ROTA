extends Node2D

var t := 0.0

export var time_scale := 1.5
export var sin_scale := 0.1

export var is_night := false
var night_ease := EaseMover.new(4.0)
var night_min := 0.3

onready var start_scale := scale

func _ready():
	night_ease.clock = night_ease.time * int(Clouds.moon_frac > night_min)

func _physics_process(delta):
	t += delta
	
	var s = 1.0 + (sin(t * time_scale) * sin_scale)
	
	if is_night:
		s *= night_ease.count(delta, Clouds.moon_frac > night_min)
	
	scale = start_scale * s
