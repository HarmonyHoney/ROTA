extends Node2D

onready var p : Player = $Player


func _ready():
	randomize()
	yield(get_tree().create_timer(4.0), "timeout")
	attract()


func attract():
	p.joy = Vector2.RIGHT if randf() > 0.5 else Vector2.LEFT
	yield(get_tree().create_timer(rand_range(0.5, 4.0)), "timeout")
	p.joy = Vector2.ZERO
	yield(get_tree().create_timer(rand_range(1.0, 4.0)), "timeout")
	attract()
