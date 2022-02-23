extends Node

var step := 0
var time := 0.0

var camera : Camera2D
var return_door
var big_door
var player

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	time += delta
	
	match step:
		0:
			player.set_physics_process(false)
			player.visible = false
			return_door.gem.set_color(false)
			return_door.arrow.visible = false
			return_door.set_process_input(false)
			big_door.gems.get_child(big_door.gems_collected - 1).set_color(false)
			next_step()
		1:
			if time > 0.3:
				next_step()
				return_door.gem.fade_color()
		2:
			if time > 1.0:
				next_step()
				camera.target_node = big_door
		3:
			if camera.global_position.distance_to(camera.target_node.global_position) < 100:
				next_step()
				big_door.gems.get_child(big_door.gems_collected - 1).fade_color()
		4:
			if  time > 1.0:
				next_step()
				camera.target_node = player
				return_door.arrow.visible = true
				return_door.arrow_clock = 0.0
		5:
			var limit = 0.5
			var t = min(time, limit)
			var s = smoothstep(0, 1, t / limit)
			player.visible = true
			player.modulate.a = s
			
			if time > limit and camera.global_position.distance_to(camera.target_node.global_position) < 100:
				next_step()
				player.set_physics_process(true)
				set_physics_process(false)
				return_door.set_process_input(true)

func next_step():
	time = 0.0
	step += 1

func begin():
	set_physics_process(true)
	time = 0.0
	step = 0
	
	camera = Shared.camera
	return_door = Shared.door_destination
	big_door = Shared.door_goal
	player = Shared.player
