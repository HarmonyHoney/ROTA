extends Node

func act():
	Cutscene.is_playing = true
	Cam.set_process(false)
	Cam.global_position += Vector2(0, -400)
	
	if is_instance_valid(Shared.player):
		var p = Shared.player
		p.move_and_collide(Vector2(0, -850))
		p.is_floor = false
		p.has_jumped = true
		p.anim.play("jump")
		
	if is_instance_valid(Shared.door_in):
		Shared.door_in.modulate.a = 0.0
		Shared.door_in.arrow.is_locked = true
	
	yield(get_tree().create_timer(1.2), "timeout")
	Cam.set_process(true)
	yield(get_tree().create_timer(0.2), "timeout")
	Cutscene.is_playing = false
