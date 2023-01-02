extends Node

func act():
	Cutscene.is_playing = true
	Shared.player.spr_easy.show = false
	var d = Shared.door_in
	d.gem.visible = true
	d.clock.visible = true
	d.clock.scale = Vector2.ZERO
	
	if Wipe.is_wipe:
		yield(Wipe, "complete")
	
	d.is_clock = true
	Audio.play("clock_collect", 0.9, 1.1)
	UI.down.show = true
	yield(get_tree().create_timer(1.0), "timeout")
	
	UI.clock_label.text = str(Shared.clock_rank)
	yield(get_tree().create_timer(0.5), "timeout")
	
	Shared.player.spr_easy.show = true
	UI.down.show = false
	Cutscene.is_playing = false
