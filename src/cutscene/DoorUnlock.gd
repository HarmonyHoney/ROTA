extends Node

func act(d):
	if !is_instance_valid(d): return
	
	Cutscene.is_playing = true
	d.arrow.is_locked = true
	d.is_fade = true
	d.is_cutscene = false
	UI.up.show = false
	print(d, d.arrow, d.arrow.is_locked)
	
	Audio.play("gem_collect", 0.6, 0.8)
	yield(get_tree().create_timer(1.0), "timeout")
	
	d.arrow.is_locked = false
	Cutscene.is_playing = false






