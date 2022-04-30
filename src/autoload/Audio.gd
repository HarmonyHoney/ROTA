extends Node

onready var menu_cursor := $Menu/Cursor
onready var menu_accept := $Menu/Accept
onready var menu_cancel := $Menu/Cancel
onready var menu_pause := $Menu/Pause

onready var gem_collect := $Gem/Collect
onready var gem_show := $Gem/Show

func play(arg : AudioStreamPlayer, from := 1.0, to := -1):
	if !is_instance_valid(arg): return
	
	if to == -1:
		arg.pitch_scale = from
	else:
		arg.pitch_scale = rand_range(from, to)
	
	arg.play()
