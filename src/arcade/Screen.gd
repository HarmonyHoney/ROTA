extends Node2D

@export var colors : PackedColorArray = []

@export var wait_range := Vector2(0.1, 0.6)
var clock := 0.0

func _process(delta):
	clock -= delta
	if clock < 0:
		clock = randf_range(wait_range.x, wait_range.y)
		modulate = colors[randi() % colors.size()]
