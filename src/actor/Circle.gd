tool
extends Node2D

export var radius := 50.0 setget set_radius

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.white)

func set_radius(arg := radius):
	radius = abs(arg)
	update()
