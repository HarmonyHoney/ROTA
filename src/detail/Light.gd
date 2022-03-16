tool
extends Node2D

export var radius := 50.0 setget set_radius

var t := 0.0

export var time_scale := 1.5
export var sin_scale := 0.1

export var is_preview := false setget set_preview

func _physics_process(delta):
	if Engine.editor_hint and !is_preview: return
	
	t += delta
	
	var s = 1.0 + (sin(t * time_scale) * sin_scale)
	scale = Vector2.ONE * s

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.white)

func set_radius(arg := radius):
	radius = abs(arg)
	update()

func set_preview(arg := is_preview):
	is_preview = arg
	scale = Vector2.ONE
