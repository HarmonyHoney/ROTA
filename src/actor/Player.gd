tool
extends KinematicBody2D
class_name Player

onready var body_area : Area2D = $BodyArea
onready var areas : Node2D = $Areas
onready var hit_area : Area2D = $Areas/HitArea
onready var collider_size : Vector2 = $CollisionShape2D.shape.extents

onready var anim : AnimationPlayer = $AnimationPlayer
onready var sprites := $Sprites
onready var spr_root := $Sprites/Root
onready var spr_body := $Sprites/Root/Body

onready var spr_hand_l := $Sprites/HandL
onready var spr_hand_r := $Sprites/HandR
onready var spr_hands := [spr_hand_l, spr_hand_r]
onready var hand_start : Vector2 = spr_hand_r.position

onready var debug_label : Label = $DebugCanvas/Labels/Label
export var is_debug := false setget set_debug
var readout = []

onready var audio_pickup := $Audio/Pickup
onready var audio_drop := $Audio/Drop
onready var audio_push := $Audio/Push
onready var audio_turn := $Audio/Turn
onready var audio_jump := $Audio/Jump
onready var audio_land := $Audio/Land
onready var audio_fallout := $Audio/FallOut
onready var audio_spike := $Audio/Spike
onready var audio_around := $Audio/Around
onready var audio_peek := $Audio/Peek

onready var cam_target := $CamTarget
var peek_clock := 0.0
var peek_time := 0.2

export var is_input := true
var joy := Vector2.ZERO
var joy_last := Vector2.ZERO
var joy_q := Vector2.ZERO
var btn_jump := false
var btnp_jump := false
var holding_jump := 0.0
var btn_push := false
var btnp_push := false

var camera : Camera2D

export var dir := 0 setget set_dir

var is_move := true
var is_walk := true
var is_floor := false

var velocity := Vector2.ZERO
var move_velocity := Vector2.ZERO
var dir_x := 1

var walk_speed := 350.0
#export var air_speed := 250.0
var floor_accel := 12
var air_accel := 7

var is_jump := false
var has_jumped := true
var jump_height := 240.0 setget set_jump_height
var jump_time := 0.6 setget set_jump_time
var jump_minimum := 0.12
var jump_speed := 0.0
var jump_gravity := 0.0
var fall_gravity := 0.0
var jump_clock := 0.0
var air_clock := 0.0

var is_dead := false
var is_fall_out := false

var turn_clock := 0.0
var turn_time := 0.2
var turn_from := 0.0
var turn_to := 0.0

var is_hold := false
var is_release := false
var box 
var hold_pos := Vector2.ZERO
var push_clock := 0.0
var push_time := 0.2
var push_from := Vector2.ZERO
var push_dir := 1
var box_turn := 1

var hold_clock := 0.0
var hold_cooldown := 0.2

onready var start_pos = position
onready var last_pos = position

var is_goal := false
var goal
var goal_clock := 0.0
var goal_times := [0.2, 0.3, 0.5]
var goal_step := 0
var hand_positions := [Vector2.ZERO, Vector2.ZERO]
var goal_start := Vector2.ZERO

var squish_from := Vector2.ONE
var squish_clock := 0.0
var squish_time := 0.5

func _enter_tree():
	if Engine.editor_hint: return
	Shared.player = self

func _ready():
	if Engine.editor_hint: return
	
	CheatCode.connect("activate", self, "cheat_code")
	
	solve_jump()
	
	# go to last door
	if is_instance_valid(Shared.door_destination):
		var d = Shared.door_destination
		position = d.position
		dir = d.dir
	
	# snap to floor
	var test = rot(Vector2.DOWN * 150)
	if test_move(transform, test):
		move_and_collide(test)
	
	# face left or right
	randomize()
	set_dir_x(1 if randf() > 0.5 else -1)
	
	# set camera
	camera = Cam
	camera.target_node = cam_target
	#camera.current = true
	
	# turn
	set_dir()
	sprites.rotation = turn_to
	turn_clock = turn_time
	
	camera.turn_from = turn_to
	camera.turn_to = turn_to
	camera.rotation = turn_to
	camera.turn_clock = 99
	camera.position = position
	#camera.zoom_in()
	camera.reset_smoothing()
	camera.force_update_scroll()
	camera.force_update_transform()
	
	set_physics_process(false)
	yield(get_tree(), "idle_frame")
	set_physics_process(true)
	
	if Cutscene.is_show_goal:
		if is_instance_valid(Shared.goal):
			Cutscene.goal_show.begin()
		Cutscene.is_show_goal = false
	
	elif Cutscene.is_collect:
		if is_instance_valid(Shared.door_destination):
			Cutscene.gem_collect.begin()
		Cutscene.is_collect = false

func _physics_process(delta):
	if Engine.editor_hint: return
	
	#last pos
	last_pos = position
	
	if is_dead:
		sprites.position += rot(velocity) * delta
		sprites.rotate(deg2rad(-dir_x * 240) * delta)
		velocity.y += fall_gravity * delta
		return
	
	# input
	if is_input:
		joy_last = joy
		joy = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")).round()
		
		btn_jump = Input.is_action_pressed("jump")
		btnp_jump = Input.is_action_just_pressed("jump")
		btn_push = Input.is_action_pressed("grab")
		btnp_push = Input.is_action_just_pressed("grab")
		
		# jump hold time
		holding_jump = (holding_jump + delta) if btn_jump else 0.0
	
	# check floor
	is_floor = !is_jump and test_move(transform, rot(Vector2.DOWN * (50 if is_hold else 1)))
	if is_floor:
		if air_clock > 0.4:
			audio_land.pitch_scale = rand_range(0.7, 1.1)
			audio_land.play()
			
			squish_from = Vector2(1.3, 0.7)
			squish_clock = 0.0
		
		air_clock = 0.0
		has_jumped = false
	else:
		air_clock += delta

	# pickup goal
	if is_goal:
		
		var offset = Vector2(20, 20)
		var p1 = goal.sprites.to_global(offset * Vector2(-1, 1))
		var p2 = goal.sprites.to_global(offset)
		
		if goal_step < goal_times.size():
			var limit = goal_times[goal_step]
			goal_clock = min(goal_clock + delta, limit)
			var s = smoothstep(0, 1, goal_clock / limit)
			
			match goal_step:
				0:
					spr_hand_l.global_position = hand_positions[0].linear_interpolate(p1, s)
					spr_hand_r.global_position = hand_positions[1].linear_interpolate(p2, s)
					
					var move_to = goal_start.linear_interpolate(goal.start_pos, s)
					var diff = move_to - position
					
					move_and_collide(Vector2(diff.x, 0))
					move_and_collide(Vector2(0, diff.y))
				1:
					goal.position = goal.start_pos.linear_interpolate(position + rot(Vector2(0, -100)), s)
					spr_hand_l.global_position = p1
					spr_hand_r.global_position = p2
				2:
					goal.gem.scale = Vector2.ONE * lerp(2.0, 1.0, s)
			
			# next step
			if goal_clock == limit:
				goal_step += 1
				goal_clock = 0.0
				
				if goal_step == 2:
					goal.audio_coin.play()
				
				# finished
				if goal_step > 2:
					is_goal = false
					goal.gem.z_as_relative = false
					goal.is_follow = true
					release_anim()
					
					has_jumped = true
					is_floor = false
	
	# holding box
	elif is_hold:
		
		if !is_release:
			# joy queue
			if joy.x != 0 and joy_last.x == 0:
				joy_q.x = joy.x
			elif joy.y != 0 and joy_last.y == 0:
				joy_q.y = joy.y
			
			# during push
			if push_clock < push_time:
				push_clock = min(push_clock + delta, push_time)
				
				hold_pos = box.position + rot(Vector2(88 * -dir_x, 49 - collider_size.y))
				var smooth = smoothstep(0, 1, push_clock / push_time)
				var move_to = push_from.linear_interpolate(hold_pos, smooth)
				var diff = move_to - position
				
				move_and_collide(Vector2(diff.x, 0))
				move_and_collide(Vector2(0, diff.y))
				
				# wobble body
				spr_root.rotation = lerp_angle(deg2rad(12 * -push_dir), 0, abs(0.5 - smooth) * 2.0)
			
			# during box turn
			elif box.is_turn:
				pass
			
			# not pushing or turning
			else:
				# check floor
				if !is_floor:
					walk_around(push_dir == 1)
					is_release = true
				
				# check distance
				elif position.distance_to(box.position) > 125:
					is_release = true
				
				# release button
				elif !btn_push:
					is_release = true
				
				# push / pull
				elif box.can_push and joy_q.x != 0:
					if dir_x == joy_q.x or !box.test_tile(dir - joy_q.x, 2):
						if box.start_push(dir - joy_q.x, joy_q.x):
							push_from = position
							push_clock = 0
							push_dir = joy_q.x
							
							audio_push.pitch_scale = rand_range(0.7, 1.3)
							audio_push.play()
							#print("push successful")
						#else:
						#	print("push failed")
				
				# turn box
				elif box.can_spin and joy_q.y != 0:
					box_turn = joy_q.y * -dir_x
					box.dir += box_turn
					
					audio_turn.pitch_scale = rand_range(0.9, 1.3)
					audio_turn.play()
				
				joy_q = Vector2.ZERO
		
		# hold animation
		if !is_release:
			# hands
			var box_angle = turn_to
			var smooth = 0.2
			if box.is_turn or box.is_push:
				box_angle += box.sprite.rotation - (box.turn_from if box.is_turn else box.turn_to)
				smooth = 1.0
			
			var box_edge = box.sprite.global_position - Vector2(50 * dir_x, 0).rotated(box_angle)
			# move hands
			for i in 2:
				var offset = Vector2(0, 20  * (-1 if sign(dir_x + 1) == i else 1))
				var goto = box_edge + offset.rotated(box_angle)
				spr_hands[i].global_position = spr_hands[i].global_position.linear_interpolate(goto, smooth)
			
			# body
			spr_body.rotation = lerp_angle(spr_body.rotation, 0, 0.1)
			spr_body.position.y = lerp(spr_body.position.y, 0, 0.1)
		
		# release box
		if is_release:
			is_hold = false
			is_release = false
			is_move = true
			has_jumped = true
			hold_clock = 0.0
			
			remove_collision_exception_with(box)
			box.remove_collision_exception_with(self)
			box.is_hold = false
			box.pickup()
			
			Guide.set_box(null)
			
			release_anim()
			
			audio_pickup.pitch_scale = rand_range(0.7, 1.3)
			audio_pickup.play()
	
	# not holding
	else:
		# turning
		if turn_clock < turn_time:
			turn_clock = min(turn_clock + delta, turn_time)
			sprites.rotation = lerp_angle(turn_from, turn_to, smoothstep(0, 1, turn_clock / turn_time))
		
		# in control
		else:
			
#			# camera peek
#			if joy.x == 0 and joy.y != 0 and joy.y == joy_last.y:
#				peek_clock = min(peek_clock + delta, peek_time)
#			else:
#				peek_clock = 0.0
#				cam_target.position = Vector2.ZERO
#
#			if peek_clock == peek_time and cam_target.position == Vector2.ZERO:
#				audio_peek.pitch_scale = rand_range(0.9, 1.3)
#				audio_peek.play()
#				if joy.y == 1:
#					cam_target.global_position = sprites.to_global(Vector2.DOWN * 250)
#				elif joy.y == -1:
#					cam_target.global_position = sprites.to_global(Vector2.UP * 250)
			
			
			# dir_x
			if joy.x != 0:
				set_dir_x(joy.x)
			
			# walking
			if is_walk:
				var target = joy.x * walk_speed 
				var weight = floor_accel if is_floor else air_accel
				velocity.x = lerp(velocity.x, target, weight * delta)
			
			# on the floor
			if is_floor:
				
				# animation
				#var anim_last = anim.current_animation
				anim.play("idle" if joy.x == 0 else "walk")
				
				# hold cooldown
				if hold_clock < hold_cooldown:
					hold_clock = min(hold_clock + delta, hold_cooldown)
				
				# start jump
				if btn_jump and holding_jump < 0.3:
					is_floor = false
					anim.play("jump")
					
					is_jump = true
					has_jumped = true
					velocity.y = jump_speed
					jump_clock = 0.0
					
					audio_jump.pitch_scale = rand_range(0.9, 1.1)
					audio_jump.play()
					
					squish_from = Vector2(0.7, 1.3)
					squish_clock = 0.0
				
				# start hold
				elif btn_push and hold_clock == hold_cooldown:
					var hb = hit_area.get_overlapping_bodies()
					if hb.size() > 0 and hb[0].is_in_group("box") and hb[0].is_floor:
						box = hb[0]
						print(name, " holding: ", box.name)
						is_hold = true
						is_release = false
						is_move = false
						velocity = Vector2.ZERO
						
						add_collision_exception_with(box)
						box.add_collision_exception_with(self)
						box.is_hold = true
						box.pickup()
						
						push_from = position
						push_clock = 0
						
						Guide.set_box(box)
						
						# move to first child
						var p = box.get_parent()
						p.move_child(box, 0)
						
						#anim.play("RESET")
						anim.stop()
						
						audio_pickup.pitch_scale = rand_range(0.7, 1.3)
						audio_pickup.play()
						
						# dir_x double check
						var check_x = sprites.to_local(box.global_position).x > 0
						set_dir_x(1 if check_x else -1)
				
			# in the air
			else:
				
				# during jump
				if is_jump:
					jump_clock += delta
					if btn_jump:
						# keep jump gravity if bonk head on ceiling
						if velocity.y >= -1.0 and jump_clock > (jump_time / 2.0):
							is_jump = false
							#print("jump start: ", jump_start, " / jump end: ", position.y + velocity.y, " / distance: ", position.y - jump_start)
					# short jump
					elif jump_clock > jump_minimum:
						is_jump = false
						velocity.y *= 0.8
				
				# not jumping
				else:
					# spin
					if !has_jumped:
						walk_around(test_move(transform, rot(Vector2(-25, 25))))
						has_jumped = true
						is_floor = false
		
		# movement
		if is_move:
			# gravity
			velocity.y += (jump_gravity if is_jump else fall_gravity) * delta
			
			# move body
			move_velocity = move_and_slide(rot(velocity))
			velocity = rot(move_velocity, -dir)
	
	# check boundary
	if !is_fall_out and Boundary.is_outside(global_position):
		outside_boundary()
		is_fall_out = true
	
	
	# squash squish and stretch
	squish_clock = min(squish_clock + delta, squish_time)
	var s = smoothstep(0, 1, squish_clock / squish_time)
	sprites.scale = squish_from.linear_interpolate(Vector2.ONE, s)
	
	
	# debug label
	if is_debug:
		readout.resize(10)
		readout[0] = "dir: " + str(dir)
		readout[1] = "is_floor: " + str(is_floor)
		readout[2] = "has_jumped: " + str(has_jumped)
		readout[3] = "dir_x: " + str(dir_x)
		readout[4] = "spr_root degrees: " + str(spr_root.rotation_degrees)
		readout[5] = "spr_body degrees: " + str(spr_body.rotation_degrees)
		
		debug_label.text = ""
		for i in readout:
			if i != null:
				debug_label.text += str(i) + "\n"

func set_dir_x(arg := dir_x):
	#if dir_x != sign(arg):
	#	print("set_dir_x: ", sign(arg))
	
	dir_x = sign(arg)
	areas.scale.x = dir_x
	spr_body.scale.x = dir_x
	#spr_root.scale.x = dir_x
	
	
	anim.playback_speed = dir_x
	
	# hand depth
	#for i in 2:
	#	spr_hands[i].show_behind_parent = sign(i - 0.5) == dir_x

func set_jump_height(arg):
	jump_height = arg
	solve_jump()

func set_jump_time(arg):
	jump_time = arg
	solve_jump()

func solve_jump():
	# Sebastian Lague's formula
	#gravity = -(2 * jumpHeight) / Mathf.Pow (timeToJumpApex, 2);
	#jumpVelocity = Mathf.Abs(gravity) * timeToJumpApex;
	
	jump_gravity = (2 * jump_height) / pow(jump_time, 2)
	jump_speed = -jump_gravity * jump_time
	fall_gravity = jump_gravity * 2.0
	#print("jump_speed: ", jump_speed, " / jump_gravity: ", jump_gravity, " / fall_gravity: ", fall_gravity)

func set_debug(arg : bool):
	is_debug = arg
	if Engine.editor_hint: return
	if !debug_label: debug_label = $DebugCanvas/Labels/Label
	if debug_label:
		debug_label.visible = is_debug

func rot(arg : Vector2, _dir := dir):
	return arg.rotated(deg2rad(_dir * 90))

func set_dir(arg := dir):
	dir = posmod(arg, 4)
	turn_to = deg2rad(dir * 90)
	
	turn_clock = 0
	turn_from = sprites.rotation if sprites else 0
	
	if Engine.editor_hint:
		$Sprites.rotation = turn_to
	elif camera:
		camera.turn(turn_to)
	
	if areas:
		areas.rotation = turn_to

func walk_around(right := false):
	move_and_collide(rot(Vector2.DOWN))
	set_dir(dir + (1 if right else 3))
	velocity.x = (walk_speed if right else -walk_speed) * 0.72
	
	audio_around.pitch_scale = rand_range(0.9, 1.3)
	audio_around.play()

func hit_effector(pos : Vector2):
	move_and_collide(pos - position)
	velocity = Vector2.ZERO
	is_floor = false
	has_jumped = true
	is_jump = false

func spinner(right := false, pos := Vector2.ZERO):
	set_dir(dir + (1 if right else -1))
	hit_effector(pos)

func arrow(arg, pos):
	if dir != arg:
		set_dir(arg)
		hit_effector(pos)

func portal(pos):
	velocity = Vector2.ZERO
	is_floor = false
	has_jumped = true
	is_jump = false
	
	position = pos

func _on_BodyArea_area_entered(area):
	var p = area.get_parent()
	
	# pickup goal
	if !is_goal and p.is_in_group("goal") and !p.is_collected:
		goal = p
		goal.pickup(self)
		
		is_goal = true
		has_jumped = true
		is_floor = false
		velocity = Vector2.ZERO
		goal_start = position
		
		#anim.play("idle")
		anim.stop()
		
		for i in spr_hands.size():
			hand_positions[i] = spr_hands[i].global_position

func _on_BodyArea_body_entered(body):
	if body.is_in_group("spike"):
		print("hit spike")
		die()

func die():
	if is_dead: return
	is_dead = true
	if is_hold:
		release_anim()
		Guide.set_box(null)
	anim.play("jump")
	velocity = Vector2(-350 * dir_x, -800)
	
	audio_spike.play()
	audio_fallout.play()

	yield(get_tree().create_timer(0.7), "timeout")
	Shared.reset()

func outside_boundary():
	print(name, " outside boundary")
	fall_out()

func fall_out():
	audio_fallout.play()
	
	Shared.reset()
	is_input = false

func release_anim():
	# set animation keys
	var rel = anim.get_animation("release")
	
	rel.bezier_track_set_key_value(0, 0, spr_body.position.x)
	rel.bezier_track_set_key_value(1, 0, spr_body.position.y)
	rel.bezier_track_set_key_value(2, 0, spr_body.rotation_degrees)
	
	var diff = spr_hand_l.position - spr_hand_r.position
	var is_left = (diff.x < 0) if abs(diff.x) > 1 else (diff.y > 0) == (dir_x > 0)
	var lh = 3 if is_left else 5
	var rh = 5 if is_left else 3
	
	rel.bezier_track_set_key_value(lh, 0, spr_hand_l.position.x)
	rel.bezier_track_set_key_value(lh + 1, 0, spr_hand_l.position.y)
	rel.bezier_track_set_key_value(rh, 0, spr_hand_r.position.x)
	rel.bezier_track_set_key_value(rh + 1, 0, spr_hand_r.position.y)
	
	anim.add_animation("release", rel)
	anim.play("release")

func cheat_code(cheat):
	if "big hair" in cheat:
		$Sprites/Root/Body/HairBack.scale = Vector2.ONE * 2
		$Sprites/Root/Body/HairFront.scale = Vector2.ONE * 2
	elif "moon jump" in cheat:
		jump_height = 500.0
		jump_time = 1.5
		solve_jump()

func enter_door():
	set_physics_process(false)
	anim.play("idle")
