extends Node

func act():
	var p = Shared.player
	var g = Shared.goal
	for i in [p, g]:
		if !is_instance_valid(i): return
	
	Cutscene.is_playing = true
	
	Cam.target_node = null
	if Wipe.is_wipe:
		yield(Wipe, "complete")
	
	Cam.pan(g.global_position)
	yield(Cam, "pan_complete")
	
	g.shine()
	yield(get_tree().create_timer(0.8), "timeout")
	
	Cam.pan(p.global_position)
	yield(Cam, "pan_complete")
	
	Cam.target_node = p
	Cutscene.is_playing = false
