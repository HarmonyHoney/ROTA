extends Node

var step := 0
var time := 0.0

var camera : Camera2D
var player
var goal
var return_door

var focal := false

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	time += delta
	
	match step:
		0:
			if time > 0.3:
				next_step()
				camera.target_node = goal
		1:
			if camera.global_position.distance_to(camera.target_node.global_position) < 100:
				next_step()
		2:
			if time > 0.1:
				next_step()
				goal.audio_coin.play()
		3:
			var limit = 0.8
			var t = min(time, limit)
			var s = smoothstep(0, 1, t / limit)
			goal.scale = Vector2.ONE * lerp(1.8, 1.0, s)
			
			if time > limit:
				next_step()
				camera.target_node = player
		4:
			if camera.global_position.distance_to(camera.target_node.global_position) < 100:
				next_step()
				player.set_physics_process(true)
				set_physics_process(false)
				camera.is_focal_point = focal
				return_door.arrow.visible = true
				return_door.arrow_clock = 0.0
				return_door.set_process_input(true)

func next_step():
	time = 0.0
	step += 1

func begin():
	
	camera = Shared.camera
	player = Shared.player
	goal = Shared.goal
	return_door = Shared.door_destination
	
	for i in [camera, player, goal, return_door]:
		if !is_instance_valid(i):
			return
	
	set_physics_process(true)
	time = 0.0
	step = 0
	
	focal = camera.is_focal_point
	
	player.set_physics_process(false)
	camera.is_focal_point = false
	return_door.arrow.visible = false
	return_door.set_process_input(false)
	
