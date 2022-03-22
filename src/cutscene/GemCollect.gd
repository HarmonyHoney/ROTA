extends Node

onready var audio_collect := $Collect

var step := 0
var time := 0.0

var camera : Camera2D
var door_dest
var door_goal
var player

var goal_gem

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	time += delta
	
	match step:
		0:
			if time > 0.15:
				next_step()
				door_dest.gem.fade_color()
				audio_collect.pitch_scale = rand_range(0.8, 1.2)
				audio_collect.play()
		1:
			if time > 0.75:
				next_step()
				camera.target_node = door_goal
				HUD.gem_label.text = str(Shared.gem_count)
		2:
			if camera.global_position.distance_to(camera.target_node.global_position) < 100:
				next_step()
				if door_goal.gems_collected <= door_goal.gem_count:
					goal_gem.fade_color()
					audio_collect.pitch_scale = rand_range(0.9, 1.3)
					audio_collect.play()
		3:
			if  time > 0.75:
				next_step()
				camera.target_node = player
				door_dest.arrow.visible = true
				door_dest.arrow_clock = 0.0
		4:
			var limit = 0.5
			var t = min(time, limit)
			var s = smoothstep(0, 1, t / limit)
			player.visible = true
			player.modulate.a = s
			
			if time > limit and camera.global_position.distance_to(camera.target_node.global_position) < 100:
				next_step()
				player.set_physics_process(true)
				set_physics_process(false)
				door_dest.set_process_input(true)

func next_step():
	time = 0.0
	step += 1

func begin():
	player = Shared.player
	camera = Shared.camera
	door_dest = Shared.door_destination
	door_goal = Shared.door_goal
	
	if door_goal.gems_collected > door_goal.gems.get_child_count():
		return
	
	goal_gem = door_goal.gems.get_child(door_goal.gems_collected - 1)
	
	for i in [player, camera, door_dest, door_goal, goal_gem]:
		if !is_instance_valid(i):
			return
	
	set_physics_process(true)
	time = 0.0
	step = 0
	
	player.set_physics_process(false)
	player.visible = false
	door_dest.gem.set_color(false)
	door_dest.arrow.visible = false
	door_dest.set_process_input(false)
	if door_goal.gems_collected <= door_goal.gem_count:
		goal_gem.set_color(false)
