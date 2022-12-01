extends Node

var is_playing := false
var step := 0
var clock := 0.0

var player
var goal

var cam_from := Vector2.ZERO
var cam_to := Vector2.ZERO
var cam_time := 1.0

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	clock += delta
	
	match step:
		0:
			if clock > 0.3:
				next_step()
				cam_target(goal.global_position)
		1:
			cam_move()
			if clock > cam_time:
				next_step()
		2:
			if clock > 0.1:
				next_step()
				Audio.play(Audio.gem_show)
		3:
			var limit = 0.8
			var t = min(clock, limit)
			var s = smoothstep(0, 1, t / limit)
			goal.scale = Vector2.ONE * lerp(1.8, 1.0, s)
			
			if clock > limit:
				next_step()
				cam_target(player.global_position)
		4:
			cam_move()
			if clock > cam_time:
				end()

func next_step():
	clock = 0.0
	step += 1

func begin():
	player = Shared.player
	goal = Shared.goal
	
	for i in [player, goal]:
		if !is_instance_valid(i):
			return
	
	is_playing = true
	Cutscene.start()
	Cam.set_process(false)
	
	set_physics_process(true)
	clock = 0.0
	step = 0

func end():
	is_playing = false
	Cutscene.end()
	Cam.set_process(true)
	set_physics_process(false)

func cam_target(target):
	cam_from = Cam.global_position
	cam_to = target
	
	var d = cam_from.distance_to(cam_to) / 100.0
	cam_time = lerp(0.3, 1.0, clamp(d, 0, 20) / 20)

func cam_move():
	var s = smoothstep(0, 1, min(clock, cam_time) / cam_time)
	Cam.global_position = cam_from.linear_interpolate(cam_to, s)
