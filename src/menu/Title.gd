extends Node2D


var cursor := 0
onready var cursor_node : Node2D = $MenuLayer/Menu/Cursor

onready var items : Array = $MenuLayer/Menu/Items.get_children()

var lerp_weight = 6.0

func _input(event):
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	var left = event.is_action_pressed("left")
	var right = event.is_action_pressed("right")
	
	var accept = event.is_action_pressed("jump")
	
	if up or down or left or right:
		items[cursor].scale = Vector2.ONE * 0.2
		cursor = clamp(cursor + (-1 if left or up else 1), 0, 2)
	
	if accept:
		pick()

func _process(delta):
	cursor_node.position = cursor_node.position.linear_interpolate(items[cursor].position, lerp_weight * delta)
	
	for i in items:
		i.scale = i.scale.linear_interpolate(Vector2.ONE, lerp_weight * delta)

func pick():
	match cursor:
		0:
			set_process_input(false)
			Shared.wipe_scene(Shared.scene_select)
		1:
			set_process_input(false)
			Shared.wipe_scene(Shared.scene_options)
		2:
			get_tree().quit()
