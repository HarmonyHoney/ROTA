tool
extends Node2D

export var dir : int = 0 setget set_dir

func set_dir(arg):
	dir = 3 if arg < 0 else (arg % 4)
	rotation_degrees = dir * 90

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.arrow(dir, position)
	elif body.is_in_group("box"):
		body.arrow(dir)
