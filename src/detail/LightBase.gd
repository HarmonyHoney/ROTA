extends Node2D

var t := 0.0

export var time_scale := 1.5
export var sin_scale := 0.1

export var is_night := false
var night_ease := EaseMover.new(4.0)

onready var start_scale := scale


func _physics_process(delta):
	t += delta
	
	var s = 1.0 + (sin(t * time_scale) * sin_scale)
	
	if is_night:
		s *= night_ease.count(delta, fposmod(BG.frac - 0.2, 1.0) < 0.5)
	
	scale = start_scale * s
