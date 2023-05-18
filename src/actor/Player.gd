tool
extends KinematicBody2D
class_name Player

onready var areas : Node2D = $Areas
onready var hit_area : Area2D = $Areas/HitArea
onready var collider_size : Vector2 = $CollisionShape2D.shape.extents

onready var anim : AnimationPlayer = $AnimationPlayer
onready var sprites := $Sprites
onready var spr_root := $Sprites/Root
onready var spr_body := $Sprites/Root/Body
onready var spr_eyes := $Sprites/Root/Body/Eyes

var spr_easy := EaseMover.new()
signal show_up
var door_exit
var difference := Vector2.ZERO
var last_pos := Vector2.ZERO
var target_pos := Vector2.ZERO

onready var spr_hands_parent := $Sprites/Hands
onready var spr_hand_l := $Sprites/Hands/Left
onready var spr_hand_r := $Sprites/Hands/Right
onready var spr_hands := [spr_hand_l, spr_hand_r]

onready var audio_walk := $Audio/Walk
onready var audio_land := $Audio/Land

export var dir := 0 setget set_dir
onready var start_dir := dir
onready var start_pos = global_position
signal turn
signal turn_angle
signal turn_cam
export var is_input := false
var joy := Vector2.ZERO
var joy_last := Vector2.ZERO
var joy_q := Vector2.ZERO
var joy_buffer := 0.1
var hold_x := 0.0
var hold_y := 0.0
var btn_jump := false
var btnp_jump := false
var hold_jump := 0.0
var jump_buffer := 0.3
var btn_push := false
var btnp_push := false

var is_move := true
var is_walk := true
var is_floor := false

var velocity := Vector2.ZERO
var dir_x := 1 setget set_dir_x
signal scale_x
signal scale_y
var idle_dir := "idle"
export var idle_anim := "idle"
export var is_idle_flip := false

var walk_speed := 350.0
var floor_accel := 12.0
var air_accel := 7.0

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
var dead_clock := 0.0
var dead_time := 0.7

var turn_ease := EaseMover.new(0.2)
var turn_from := 0.0
var turn_to := 0.0

var is_hold := false
var is_release := false
var box
var push_ease := EaseMover.new(0.2)
var push_from := Vector2.ZERO
var push_dir := 1

var hold_clock := 0.0
var hold_cooldown := 0.2

var is_goal := false
var goal
var goal_step := 0
var goal_times := [0.2, 0.3, 0.5]
var goal_easy := EaseMover.new()
var hand_positions := [Vector2.ZERO, Vector2.ZERO]
var goal_start := Vector2.ZERO
var goal_grab := Vector2.ZERO

var squish_from := Vector2.ONE
var squish_ease := EaseMover.new(0.5)

var is_unpause := false
var unpause_tick := 0

var release_clock := 0.0
var release_time := 0.2

onready var colors := {"hair": [$Sprites/Root/Body/HairBack, $Sprites/Root/Body/HairFront,], "skin": [$Sprites/Root/Body/Head, $Sprites/Hands],
"fit": [$Sprites/Root/Body/Fit], "eye": [$Sprites/Root/Body/Eyes]}
export(Array, Color) var palette := []
export var dye := {"hair": 0, "skin": 0, "fit": 0, "eye": 0} setget set_dye

onready var hair_back := $Sprites/Root/Body/HairBack
onready var hair_front := $Sprites/Root/Body/HairFront
export (Array, String, FILE) var hair_backs := []
export (Array, String, FILE) var hair_fronts := []

export var hairstyle_back := 0 setget set_hair_back
export var hairstyle_front := 0 setget set_hair_front

onready var hat_node := $Sprites/Root/Body/Hat
export (Array, String, FILE) var hats := []
export var hat := 0 setget set_hat

var blink_ease := EaseMover.new(0.2)
var blink_clock := 0.0
var blink_time := 10.0
var blink_range := Vector2(1, 20)

export var is_npc := false
export (Array, String, MULTILINE) var lines := ["Hello (=", "Lovely weather!", "I do adore the flowers"]
export var greeting := -1
export var greeting_wait := Vector2(30, 45)
var greeting_clock := 0.0
export (String, MULTILINE) var queue_write := ""
export var chat_offset := Vector2(0, -110) setget set_chat_offset
onready var arrow := get_node_or_null("Arrow")
export var ready_z_index := 50
export var ready_dir_x := 0

var line := -1
var queue := []

var snowball_scene : PackedScene = preload("res://src/actor/Snowball.tscn")
var snowballs = []

func _enter_tree():
	if Engine.editor_hint: return
	if get_parent() == Shared:
		Shared.player = self
	get_tree().connect("physics_frame", self, "physics_frame")
	MenuPause.connect("opened", self, "pause")
	Shared.connect("scene_changed", self, "scene")
	Wipe.connect("start", self, "wipe_start")
	Cutscene.connect("playing", self, "cutscene_playing")

func _ready():
	set_hair_back()
	set_hair_front()
	set_dye()
	set_hat()
	set_chat_offset()
	if Engine.editor_hint: return
	
	solve_jump()
	if arrow:
		connect("turn", arrow, "set_dir")
		arrow.connect("open", self, "arrow_open")
	
	# create idle animiations facing left
	var l = anim.get_animation("idle").duplicate()
	for i in 3:
		l.bezier_track_set_key_value(2, i, -l.bezier_track_get_key_value(2, i))
	anim.add_animation("idle_left", l)
	
	if !anim.has_animation(idle_anim): idle_anim = "idle"
	anim_flip(idle_anim)
#	randomize()
#	anim.play(idle_anim, 0.0)
#	anim.seek(2.0, true)
	
	if is_npc:
		z_index = min(ready_z_index, 45)
		spr_easy.clock = spr_easy.time
		var coy = chat_offset.y
		if hat == 1:
			coy = min(coy, -160)
		elif hairstyle_back in [6, 7] or hairstyle_front in [7]:
			coy = min(coy, -130)
		elif hairstyle_front == 10:
			coy = min(coy, -115)
		
		if idle_anim == "bench":
			coy -= 17
		elif idle_anim == "tree_behind":
			coy = min(coy, -160)
		
		self.chat_offset.y = coy
	else:
		if arrow:
			arrow.is_locked = true
			arrow.monitoring = false
			arrow.monitorable = false

func wipe_start(arg):
	if !is_npc:
		door_exit = null
		spr_easy.show = arg
		if arg: spr_easy.clock = 0.0

func scene():
	door_exit = Shared.door_in if is_instance_valid(Shared.door_in) else null
	
	# move npc
	if is_npc:
		global_position = start_pos
		self.dir = start_dir
		
	# go to last door
	elif door_exit:
		global_position = door_exit.global_position
		self.dir = door_exit.dir
	
	#print(name, " pos: ", global_position, " dir: ", dir)
	
	velocity = Vector2.ZERO
	joy_last = Vector2.ZERO
	joy = Vector2.ZERO
	
	is_floor = false
	is_jump = true
	has_jumped = true
	air_clock = 0.0
	
	is_dead = false
	sprites.position = Vector2.ZERO
	sprites.rotation = turn_to
	emit_signal("turn_angle", turn_to)
	turn_ease.clock = turn_ease.time
	
	# face left or right
	randomize()
	self.dir_x = sign(ready_dir_x) if ready_dir_x != 0 else  1 if randf() > 0.5 else -1
	
	# snap to floor
	var v = Vector2.DOWN * 150
	if test_move(transform, rot(v)):
		move(v)
		anim.play(idle_dir, 0.0)
		anim.seek(rand_range(0, anim.current_animation_length), true)
	else:
		anim.play("jump")
	

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if is_dead or (spr_easy.is_less or !spr_easy.show):
		return
	
	# input
	release_clock = max(release_clock - delta, 0)
	
	if is_input and !MenuPause.is_paused and !Cutscene.is_playing and !Wipe.is_wipe:
		joy_last = joy
		joy.x = round(Input.get_axis("left", "right"))
		joy.y = round(Input.get_axis("up", "down"))
		
		btnp_jump = Input.is_action_just_pressed("jump")
		btnp_push = Input.is_action_just_pressed("grab")
		
		# avoid jumping or grabbing when exiting menu
		if is_unpause:
			unpause_tick += 1
			if unpause_tick > 1 and (btnp_jump or btnp_push):
				is_unpause = false
		
		if !is_unpause:
			btn_jump = Input.is_action_pressed("jump") and release_clock == 0
			btn_push = Input.is_action_pressed("grab")
	
	# holding input
	hold_x = (hold_x + delta) if joy.x == joy_last.x and joy.x != 0 else 0.0
	hold_y = (hold_y + delta) if joy.y == joy_last.y and joy.y != 0 else 0.0
	hold_jump = (hold_jump + delta) if btn_jump else 0.0
	
	# pickup goal
	if is_goal and is_instance_valid(goal):
		if goal_step == 0:
			move(goal_start.linear_interpolate(goal_grab, goal_easy.smooth()) - global_position, 0)
			
		# next step
		if goal_easy.is_complete:
			goal_easy.clock = 0.0
			goal_step += 1
			
			if goal_step < goal_times.size():
				goal_easy.time = goal_times[goal_step]
			
			if goal_step == 2:
				goal.shine(false)
			# finished
			elif goal_step > 2:
				is_goal = false
				is_floor = false
				has_jumped = true
				release_anim()
				
				goal.z_index = 0
				goal.target = self
				goal.turn_easy.clock = goal.turn_easy.time * 0.5
	
	# holding box
	elif is_hold:
		
		if !is_release:
			# joy queue
			if joy.x != 0 and hold_x < joy_buffer:
				joy_q.x = joy.x
				hold_x = 1
			elif joy.y != 0 and hold_y < joy_buffer:
				joy_q.y = joy.y
				hold_y = 1
			
			# during push
			if push_ease.is_less:
				var smooth = push_ease.count(delta)
				
				var hold_pos = box.global_position + rot(Vector2(88 * -dir_x, 50 - collider_size.y))
				var move_to = push_from.linear_interpolate(hold_pos, smooth)
				var diff = move_to - global_position
				
				move(diff, 0)
			
			# during box turn
			elif box.is_turn:
				pass
			
			# not pushing or turning
			else:
				# check floor
				is_floor = test_move(transform, rot(Vector2.DOWN * 50))
				if !is_floor:
					walk_around(push_dir == 1)
					is_release = true
				
				# check distance
				elif global_position.distance_to(box.global_position) > 125:
					is_release = true
				
				# release button
				elif !btn_push:
					is_release = true
				
				# push / pull
				elif box.can_push and joy_q.x != 0:
					if dir_x == joy_q.x or !box.test_tile(dir - joy_q.x, 2):
						if box.start_push(dir - joy_q.x, joy_q.x):
							push_from = global_position
							push_ease.clock = 0
							push_dir = joy_q.x
							
							
							Audio.play("player_push", 0.7, 1.3)
							#print("push successful")
						#else:
						#	print("push failed")
				
				# turn box
				elif box.can_spin and joy_q.y != 0:
					box.dir += joy_q.y * -dir_x
					
					Audio.play("player_turn", 0.9, 1.3)
				
				joy_q = Vector2.ZERO
		
		# release box
		if is_release:
			box_release()
	
	# not holding
	else:
		
		# done turning and in control
		if turn_ease.is_complete:
			# dir_x
			if joy.x != 0:
				self.dir_x = joy.x
			
			# walking
			if is_walk:
				var target = joy.x * walk_speed 
				var weight = floor_accel if is_floor else air_accel
				velocity.x = lerp(velocity.x, target, weight * delta)
			
			# on the floor
			if is_floor:
				
				# animation
				anim.playback_speed = 1.0 if joy.x == 0 else dir_x
				anim.play(idle_dir if joy.x == 0 else "walk")
				
				# hold cooldown
				if hold_clock < hold_cooldown:
					hold_clock = min(hold_clock + delta, hold_cooldown)
				
				# start jump
				if btn_jump and hold_jump < jump_buffer:
					is_floor = false
					anim.play("jump")
					if dir_x > 0:
						anim.advance(anim.current_animation_length / 2.0)
					
					is_jump = true
					has_jumped = true
					velocity.y = jump_speed
					jump_clock = 0.0
					
					
					Audio.play("player_jump", 0.9, 1.1)
					
					squish_from = Vector2(0.7, 1.3)
					squish_ease.clock = 0.0
				
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
						
						# dir_x double check
						var check_x = sprites.to_local(box.global_position).x > 0
						self.dir_x = 1 if check_x else -1
						
						push_from = global_position
						push_ease.clock = 0
						push_dir = dir_x
						
						Shared.guide.set_box(box)
						
						# move box to first child
						var p = box.get_parent()
						p.move_child(box, 0)
						
						anim.stop()
						
						Audio.play("player_grab", 0.7, 1.3)
				
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
			
			# move
			move(velocity * delta)
	
	# check boundary
	if !Wipe.is_wipe and Shared.is_outside_boundary(global_position):
		print(name, " outside boundary")
		die()
	
	# air clock
	if is_floor:
		if air_clock > 0.4:
			Audio.play(audio_land, 0.7, 1.1)
			
			squish_from = Vector2(1.3, 0.7)
			squish_ease.clock = 0.0
		
		air_clock = 0.0
	else:
		air_clock += delta
	
	if is_npc:
		if greeting_clock > 0:
			greeting_clock = max(0, greeting_clock - delta)

func physics_frame():
	last_pos = target_pos
	target_pos = global_position
	difference = last_pos - target_pos

func _process(delta):
	if Engine.editor_hint: return
	
	if is_dead:
		sprites.position += rot(velocity) * delta
		sprites.rotate(deg2rad(240) * -dir_x * delta)
		velocity.y += fall_gravity * delta
		
		if dead_clock < dead_time:
			dead_clock += delta
			if dead_clock > dead_time:
				Cutscene.is_playing = false
				Shared.reset()
		
		return
	
	if spr_easy.is_less or !spr_easy.show:
		var sec = spr_easy.count(delta, spr_easy.show and !Wipe.is_intro)
		var dp = to_local(door_exit.global_position) if is_instance_valid(door_exit) else rot(Vector2(0, -25))
		sprites.position = dp.linear_interpolate(Vector2.ZERO, sec)
		for i in [spr_hands_parent, spr_root]:
			i.rotation = lerp(TAU * 0.15 * -dir_x, 0.0, sec)
			i.scale = Vector2.ONE * lerp(0.0, 1.0, sec)
		
		if sec < 1.0:
			return
		else:
			emit_signal("show_up")
	
	# interpolate
	sprites.position = difference.linear_interpolate(Vector2.ZERO, Engine.get_physics_interpolation_fraction()) if Shared.is_interpolate else Vector2.ZERO
	
	if is_goal and is_instance_valid(goal):
		var s = goal_easy.count(delta)
		
		var offset = Vector2(20, 20) * goal.sprites.scale
		var p1 = goal.to_global(offset * Vector2(-1, 1))
		var p2 = goal.to_global(offset)
		
		spr_hand_l.global_position = p1
		spr_hand_r.global_position = p2
		
		match goal_step:
			0:
				spr_hand_l.global_position = hand_positions[0].linear_interpolate(p1, s)
				spr_hand_r.global_position = hand_positions[1].linear_interpolate(p2, s)
			1:
				goal.global_position = goal_grab.linear_interpolate(global_position + rot(Vector2(0, -100)), s)
		
		return
	
	# hold animation
	if is_hold:
		# during push
		if push_ease.is_less:
			# wobble body
			var s = abs(0.5 - push_ease.smooth()) * 2.0
			spr_root.rotation = lerp_angle(deg2rad(12 * -push_dir), 0, s)
		
		# body
		var s = 6.0 * delta
		spr_body.rotation = lerp_angle(spr_body.rotation, 0, s)
		spr_body.position.y = lerp(spr_body.position.y, 0, s)
		
		# hands
		var box_angle = turn_to
		var smooth = 12.0 * delta
		if box.is_turn or box.is_push:
			box_angle += box.sprite.rotation - (box.turn_from if box.is_turn else box.turn_to)
			smooth = 1.0
		
		var box_edge = box.sprite.global_position - Vector2(50 * dir_x, 0).rotated(box_angle)
		# move hands
		for i in 2:
			var offset = Vector2(0, 20  * (-1 if sign(dir_x + 1) == i else 1))
			var goto = box_edge + offset.rotated(box_angle)
			spr_hands[i].global_position = spr_hands[i].global_position.linear_interpolate(goto, smooth)
		
	else:
		if turn_ease.is_less:
			var s = turn_ease.count(delta)
			var r = lerp_angle(turn_from, turn_to, s)
			sprites.rotation = r
			emit_signal("turn_angle", r)
	
	# squash squish and stretch
	sprites.scale = squish_from.linear_interpolate(Vector2.ONE, squish_ease.count(delta))
	
	# blink anim
	if blink_clock < blink_time:
		blink_clock += delta
	else:
		var be = blink_ease.count(delta)
		spr_eyes.scale.y = lerp(1.0, 0.1, be)
		if be == 1.0:
			blink_ease.show = false
		elif be == 0.0:
			blink_ease.show = true
			blink_clock = 0.0
			blink_time = rand_range(blink_range.x, blink_range.y)

### Set Get

func set_dir(arg := dir):
	dir = posmod(arg, 4)
	turn_to = deg2rad(dir * 90)
	
	turn_ease.clock = 0
	turn_from = sprites.rotation if sprites else 0
	
	if Engine.editor_hint:
		$Sprites.rotation = turn_to
	
	if areas:
		areas.rotation = turn_to
	
	emit_signal("turn", dir)
	emit_signal("turn_cam", turn_to)

func set_dir_x(arg := dir_x):
	dir_x = -1.0 if arg < 0 else 1.0
	areas.scale.x = dir_x
	var l = idle_anim + "_left"
	idle_dir = idle_anim if (dir_x < 0 if is_idle_flip else dir_x > 0) else (l if anim.has_animation(l) else "idle")
	emit_signal("scale_x", dir_x)

func set_jump_height(arg):
	jump_height = arg
	solve_jump()

func set_jump_time(arg):
	jump_time = arg
	solve_jump()

# Sebastian Lague's formula
func solve_jump():
	jump_gravity = (2 * jump_height) / pow(jump_time, 2)
	jump_speed = -jump_gravity * jump_time
	fall_gravity = jump_gravity * 2.0

func set_dye(arg := dye):
	dye = arg
	for i in dye.keys():
		dye[i] = posmod(dye[i], palette.size())
		
		if colors and colors.has(i):
			for y in colors[i]:
				y.modulate = palette[dye[i]]

func set_hair_back(arg := hairstyle_back):
	hairstyle_back = posmod(arg, hair_backs.size())
	hairdo(hair_back, hair_backs, hairstyle_back)

func set_hair_front(arg := hairstyle_front):
	hairstyle_front = posmod(arg, hair_fronts.size())
	hairdo(hair_front, hair_fronts, hairstyle_front)

func hairdo(node, array, style):
	if node:
		for i in node.get_children():
			i.queue_free()
		
		if style > 0:
			var h = load(array[style]).instance()
			node.add_child(h)
			for i in h.get_children():
				for c in ["scale_x", "turn_angle"]:
					if i.has_method(c) and !is_connected(c, i, c):
						connect(c, i, c)
						match c:
							"scale_x": i.scale_x(dir_x)
							"turn_angle": i.turn_angle(sprites.rotation)

func set_hat(arg := hat):
	hat = posmod(arg, hats.size())
	hairdo(hat_node, hats, hat)

func set_chat_offset(arg := chat_offset):
	chat_offset = arg
	if arrow: arrow.image_pos = chat_offset

### Movement

func rot(vec : Vector2, _dir := dir) -> Vector2:
	_dir = posmod(_dir, 4)
	match _dir:
		1:
			return Vector2(-vec.y, vec.x)
		2:
			return Vector2(-vec.x, -vec.y)
		3:
			return Vector2(vec.y, -vec.x)
	
	return vec

func move(_vel := Vector2.ZERO, _dir := dir):
	# Move X
	var move_x = rot(_vel * Vector2(1, 0), _dir)
	var is_x = test_move(transform, move_x)
	move_and_collide(move_x)
	
	# Wall
	if is_x:
		velocity.x = 0.0
	
	# Move Y
	var move_y = rot(_vel * Vector2(0, 1), _dir)
	var is_y = test_move(transform, move_y)
	move_and_collide(move_y)
	
	if is_y:
		velocity.y = 0.0
	
	# Floor
	is_floor = is_y and _vel.y > 0
	if is_floor:
		has_jumped = false

func walk_around(right := false):
	move_and_collide(rot(Vector2.DOWN))
	self.dir += 1 if right else 3
	velocity.x = (walk_speed if right else -walk_speed) * 0.72
	
	Audio.play("player_around", 0.9, 1.3)

### Area

func _on_BodyArea_area_entered(area):
	var p = area.get_parent()
	
	# pickup goal
	if !is_goal and p.is_in_group("goal") and !p.is_collected:
		area.set_deferred("monitorable", false)
		goal = p
		goal.is_collected = true
		goal.z_index = z_index + 1
		goal_grab = goal.global_position
		goal_start = global_position
		goal_step = 0
		goal_easy.time = goal_times[0]
		
		is_goal = true
		has_jumped = true
		is_floor = false
		velocity = Vector2.ZERO
		
		anim.stop()
		for i in spr_hands.size():
			hand_positions[i] = spr_hands[i].global_position
		Audio.play("gem_collect")

func _on_BodyArea_body_entered(body):
	if Wipe.is_wipe: return
	
	# hit spike
	if body.is_in_group("spike"):
		print("hit spike")
		die()

func die():
	if is_dead: return
	if is_npc:
		scene()
		return
	
	is_dead = true
	dead_clock = 0.0
	Cutscene.is_playing = true
	
	for i in [MenuRemap, MenuOptions, MenuPause]:
		if i.is_open: i.is_open = false
	
	velocity = Vector2(-350 * dir_x, -800)
	if is_hold:
		box_release()
	anim.play("jump")
	
	Audio.play("player_spike")
	Audio.play("player_fallout")

func box_release():
	is_hold = false
	is_release = false
	is_move = true
	has_jumped = true
	hold_clock = 0.0
	spr_root.rotation = 0
	
	remove_collision_exception_with(box)
	box.remove_collision_exception_with(self)
	box.is_hold = false
	box.pickup()
	
	Shared.guide.set_box(null)
	
	release_anim()
	
	Audio.play("player_grab", 0.7, 1.3)
	
	release_clock = release_time

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
	
	anim.play("release")

func anim_flip(_name := ""):
	if anim.has_animation(_name) and !anim.has_animation(_name + "_left"):
		var a = anim.get_animation(_name).duplicate()
		for t in a.get_track_count():
			var p = str(a.track_get_path(t))
			if "Left" in p: p = p.replace("Left", "Right")
			elif "Right" in p: p = p.replace("Right", "Left")
			a.track_set_path(t, p)
			
			if "position:x" in p or "rotation_degrees" in p:
				var c = a.track_get_key_count(t)
				#print(name , " ", p, " ", c)
				for k in c:
					a.bezier_track_set_key_value(t, k, -a.bezier_track_get_key_value(t, k))
		anim.add_animation(_name + "_left", a)

func throw_snowball():
	var s = null
	for i in snowballs:
		if i.is_out:
			s = i
			break
	
	if !is_instance_valid(s):
		s = snowball_scene.instance()
		var p = get_parent()
		p.add_child(s)
		s.owner = p
		snowballs.append(s)
	
	s.throw((spr_hand_l if dir_x > 0 else spr_hand_r).global_position, s.throw_vel * Vector2(dir_x, 1), dir)
	#print(name, " throw snowball ", s)

func enter_door(arg):
	door_exit = arg
	anim.stop()
	clear_input()
	
	if is_instance_valid(goal):
		goal.target = door_exit

func pause(arg := false):
	if Shared.player == self:
		clear_input()
		if !arg:
			is_unpause = true
			unpause_tick = 0

func clear_input():
	btn_jump = false
	btnp_jump = false
	btn_push = false
	btnp_push = false
	joy = Vector2.ZERO

func cutscene_playing(arg := false):
	if arg and Shared.player == self:
		clear_input()

func footstep_sound():
	if !audio_walk.playing and !audio_land.playing:
		Audio.play(audio_walk, 1.5, 3.0)

func arrow_open():
	if queue.size() == 0:
		queue = range(lines.size())
		queue.shuffle()
		queue.erase(line)
		greeting_clock = 0
		if queue_write != "":
			var qw = Array(queue_write.split_floats(",", false))
			for i in qw.size():
				var b = int(qw.pop_back())
				queue.erase(b)
				queue.push_front(b)
	
	if greeting_clock == 0 and line != greeting and greeting > -1 and greeting < lines.size():
		queue.erase(greeting)
		queue.push_front(greeting)
	
	line = posmod(int(queue.pop_front()), lines.size())
	Shared.chat.open(lines[line], arrow, Transform2D(dir * PI * 0.5, global_position + rot(chat_offset)))
	greeting_clock = rand_range(greeting_wait.x, greeting_wait.y)

