extends Node2D

onready var p : Player = Shared.player

export var is_trailer := false

var clock := 0.0
onready var time := 2.2 if is_trailer else 4.0

var step = -1

func _ready():
	p.anim.play("jump")
	if is_trailer:
		p.dir_x = -1

func _physics_process(delta):
	clock += delta
	if clock > time:
		clock = 0.0
		
		if is_trailer:
			step += 1
			match step:
				0:
					p.joy = Vector2.LEFT
					time = 2.51
				1:
					p.joy = Vector2.ZERO
					time = 2.5
				2:
					p.joy = Vector2.RIGHT
					time = 2.52
				3:
					p.joy = Vector2.ZERO
					time = 10.0
		else:
			time = rand_range(1.0, 4.0)
			
			if p.joy == Vector2.ZERO:
				p.joy = Vector2.RIGHT if randf() > 0.5 else Vector2.LEFT
			else:
				p.joy = Vector2.ZERO
		


