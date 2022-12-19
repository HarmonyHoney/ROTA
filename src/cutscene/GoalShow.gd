extends Node

func act():
	if !is_instance_valid(Shared.goal): return
	
	Cutscene.is_playing = true
	Cam.target_node = null
	yield(Wipe, "complete")
	
	Cam.pan(Shared.goal.global_position)
	yield(Cam, "pan_complete")
	
	Shared.goal.shine()
	yield(get_tree().create_timer(0.8), "timeout")
	
	Cam.pan(Shared.player.position)
	yield(Cam, "pan_complete")
	
	Cam.target_node = Shared.player
	Cutscene.is_playing = false
