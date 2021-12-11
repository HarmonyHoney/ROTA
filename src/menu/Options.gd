extends Node2D

func _input(event):
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	var left = event.is_action_pressed("left")
	var right = event.is_action_pressed("right")
	
	var accept = event.is_action_pressed("jump")
	var back = event.is_action_pressed("action")
	
	if back:
		set_process_input(false)
		Shared.change_scene(Shared.scene_title)
