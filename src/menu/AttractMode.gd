extends Node2D

onready var p : Player = Shared.player


func _ready():
	Cam.target_node = self
#	Cam.position = position
#	Cam.offset = Vector2(-300, 0)
#	Cam.turn_offset = Cam.offset
#
#	Cam.set_process(false)
#
#	randomize()
#	yield(get_tree().create_timer(6.0), "timeout")
#	attract()
	

func attract():
	p.joy = Vector2.RIGHT if randf() > 0.5 else Vector2.LEFT
	yield(get_tree().create_timer(rand_range(0.8, 4.0)), "timeout")
	p.joy = Vector2.ZERO
	yield(get_tree().create_timer(rand_range(1.0, 4.0)), "timeout")
	attract()
