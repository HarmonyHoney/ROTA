extends Node

func act():
	var p = Shared.player
	var d = Shared.door_in
	for i in [p, d]:
		if !is_instance_valid(i): return
	
	Cutscene.is_playing = true
	Cam.target_node = null
	Cam.global_position += Vector2(0, -400)
	Cam.target_pos = Cam.global_position
	Cam.emit_signal("moved")
	
	d.modulate.a = 0.0
	d.arrow.is_locked = true
	
	p.move_and_collide(Vector2(0, -600))
	p.door_exit = null
	p.is_floor = false
	p.has_jumped = true
	p.anim.play("jump")
	p.spr_easy.show = false
	
	if Wipe.is_wipe:
		yield(Wipe, "complete")
	p.spr_easy.show = true
	
	yield(get_tree().create_timer(1.2), "timeout")
	Cam.target_node = p
	yield(get_tree().create_timer(0.2), "timeout")
	
	Cutscene.is_playing = false
