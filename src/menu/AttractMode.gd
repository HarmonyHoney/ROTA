extends Node2D

onready var p : Player = Shared.player

var clock := 0.0
var time := 4.0

func _ready():
	p.anim.play("jump")

func _physics_process(delta):
	clock += delta
	if clock > time:
		clock = 0.0
		time = rand_range(1.0, 4.0)
		
		if p.joy == Vector2.ZERO:
			p.joy = Vector2.RIGHT if randf() > 0.5 else Vector2.LEFT
		else:
			p.joy = Vector2.ZERO
