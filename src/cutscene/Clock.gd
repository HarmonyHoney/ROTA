extends Node

func act():
	var p = Shared.player
	var d = Shared.door_in
	for i in [p, d]:
		if !is_instance_valid(i): return
	
	Cutscene.is_playing = true
	Cam.target_node = d
	
	d.gem.visible = true
	d.clock.visible = true
	d.clock.scale = Vector2.ZERO
	
	if Wipe.is_wipe:
		yield(Wipe, "complete")
	if !p.spr_easy.is_complete:
		yield(p, "show_up")
	
	if abs(d.to_local(p.global_position).x) < 50.0:
		p.joy.x = [-1, 1][randi() % 2]
		yield(get_tree().create_timer(0.27), "timeout")
		p.joy.x = 0.0
		p.dir_x *= -1
		yield(get_tree().create_timer(0.2), "timeout")
	
	d.is_clock = true
	Audio.play("clock_collect", 0.9, 1.1)
	UI.down.show = true
	yield(get_tree().create_timer(1.0), "timeout")
	
	UI.rank_text(Shared.clock_rank)
	yield(get_tree().create_timer(0.8), "timeout")
	UI.down.show = false
	
	Cam.target_node = p
	Cutscene.is_playing = false
