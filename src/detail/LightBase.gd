extends Node2D

var t := 0.0

export var time_scale := 1.5
export var sin_scale := 0.1

onready var start_scale := scale

func _physics_process(delta):
	
	t += delta
	
	var s = 1.0 + (sin(t * time_scale) * sin_scale)
	scale = start_scale * s
