@tool
extends Node2D

@export var is_var := false: set = set_is_var
@export var circle_size := 10.0: set = set_circle

func set_is_var(arg):
	is_var = arg
	update()

func set_circle(arg):
	circle_size = arg
	update()

func _draw():
	draw_circle(Vector2.ZERO, circle_size, Color.WHITE)
