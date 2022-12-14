extends Node

var is_playing := false
var step := 0
var clock := 0.0

var player

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	clock += delta
	
	match step:
		0:
			if clock > 0.5:
				next_step()
		1:
			if clock > 0.6:
				next_step()
				
				Cam.set_process(true)
		2:
			if clock > 0.3:
				end()

func next_step():
	clock = 0.0
	step += 1

func begin():
	player = Shared.player
	if !is_instance_valid(player):
		return
	
	is_playing = true
	Cutscene.start()
	Cam.set_process(false)
	player.move_and_collide(Vector2(0, -850))
	player.anim.play("jump")
	Cam.position += Vector2(0, -400)
	#MenuMakeover.outfit(MenuMakeover.pale)
	if is_instance_valid(Shared.door_in):
		Shared.door_in.visible = false
		Shared.door_in.arrow.is_locked = true
	
	set_physics_process(true)
	clock = 0.0
	step = 0

func end():
	is_playing = false
	Cutscene.end()
	Cam.set_process(true)
	
	set_physics_process(false)

