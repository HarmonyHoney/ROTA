extends Node

func act():
	var p = Shared.player
	var d = Shared.door_in
	for i in [p, d]:
		if !is_instance_valid(i): return
	
	Cutscene.is_playing = true
	Cam.target_node = d
	
	d.clock.visible = false
	d.gem.visible = true
	d.gem_color()
	
	if Wipe.is_wipe:
		yield(Wipe, "complete")
	if !p.spr_easy.is_complete:
		yield(p, "show_up")
	
	p.joy.x = [-1, 1][randi() % 2]
	yield(get_tree().create_timer(0.27), "timeout")
	p.joy.x = 0.0
	p.dir_x *= -1
	yield(get_tree().create_timer(0.2), "timeout")
	
	d.gem_fade()
	Audio.play("gem_collect", 0.8)
	UI.up.show = true
	yield(get_tree().create_timer(1.0), "timeout")
	
	UI.gem_text(Shared.gem_count)
	yield(get_tree().create_timer(0.8), "timeout")
	UI.up.show = false
	
	Cam.target_node = p
	Cutscene.is_playing = false
	Cutscene.scene_changed()






