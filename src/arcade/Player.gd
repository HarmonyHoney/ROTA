extends KinematicBody2D

onready var area := $Area2D
onready var image := $Sprites
onready var image_root := $Sprites/Root

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO
var btn_jump := false
var jump_ease := EaseMover.new(0.15)
var is_jump := false

export var move_speed := 350.0
export var move_accel := 0.3
export var move_damp := 0.08
export var jump_speed := 620.0
export var hit_speed := 900.0
var room_size := Vector2(600, 600)
export var gravity := 1500.0
export var term_vel := 4000.0
export var squish_jump := Vector2(0.5, 1.5)
export var squish_land := Vector2(1.4, 0.6)
export var land_time := 0.25
export var land_vel := 250.0
var squish_ease := EaseMover.new(0.3)

var vel := Vector2.ZERO
var vel_last := Vector2.ZERO
var is_floor := false
var walk_clock = 0.0
var dir_x := 1.0
var air_clock := 0.0

var is_input = true
var is_dead := false
var arcade
var dead_ease := EaseMover.new()
var unpause_tick := 0.0
var is_unpause := false

func _ready():
	MenuPause.connect("opened", self, "pause")
	
	for i in get_tree().get_nodes_in_group("arcade"):
		arcade = i
	
	if arcade.map == 0:
		is_input = false
	
	image_root.scale = Vector2.ZERO
	squish_ease.to = Vector2.ONE

func _physics_process(delta):
	# input
	joy_last = joy
	if is_input and !MenuPause.is_paused:
		joy.x = round(Input.get_axis("left", "right"))
		joy.y = round(Input.get_axis("up", "down"))
		
		var j = Input.is_action_pressed("jump") or Input.is_action_pressed("grab")
		if !j: is_unpause = false
		if !is_unpause:
			btn_jump = j
	
	# is floor & air clock
	is_floor = test_move(transform, Vector2(0, 3))
	
	if is_floor and air_clock > 0.0:
		var s = min(vel_last.y, land_vel) / land_vel
		
		squish_ease.from = Vector2.ONE.linear_interpolate(squish_land, ease(s, 2.2))
		squish_ease.clock = 0.0
	
	air_clock = 0.0 if is_floor else air_clock + delta
	
	# walking
	
	if joy.x == 0:
		vel.x = lerp(vel.x, 0.0, delta * 21.0)
		
	else:
		vel.x = clamp(vel.x + (move_speed * move_accel * joy.x), -move_speed, move_speed)
		dir_x = joy.x
	
	# jumping and gravity
	
	vel.y = clamp(vel.y + (gravity * delta), -term_vel, term_vel)
	
	if btn_jump and is_floor and !is_jump:
		is_jump = true
		Audio.play("arcade_jump", 0.9, 1.3)
		jump_ease.clock = 0.0
		squish_ease.from = squish_jump
		squish_ease.clock = 0.0
	
	if is_jump:
		vel.y = -jump_speed
		var s = jump_ease.count(delta)
		
		jump_ease.time = .16
		is_jump = jump_ease.is_less and btn_jump
	
	if !is_dead:
		for i in area.get_overlapping_bodies():
			if is_floor or (position.y > i.position.y - 25 and vel.y < 0.0):
				die()
				break
			else:
				i.die()
				vel.y = -hit_speed
				Audio.play("arcade_bell", 0.5, 1.3)
				Audio.play("arcade_hit", 0.8, 1.2)
				squish_ease.from = squish_land
				squish_ease.clock = 0.0
	
	vel_last = vel
	vel = move_and_slide(vel)
	
	
	position.x = wrapf(position.x, -room_size.x, room_size.x)
	position.y = wrapf(position.y, -room_size.y, room_size.y)
	
	
	
	
	# body
	walk_clock = 0.0 if joy.x != joy_last.x else walk_clock + (delta * dir_x)
	
	
	
	if is_dead:
		var s = dead_ease.count(delta, true, false)
		image.scale = Vector2.ONE * lerp(1.5, 0.0, ease(s, 2.0))
		image.rotation_degrees = lerp(dir_x * 9.0, dir_x * 360.0, ease(s, 2.0))
		
	else:
		if is_floor:
			if joy.x == 0:
				image.rotation_degrees = sin(walk_clock * 4.0) * 5
				image.position.y = -abs(cos(walk_clock * 4.0) * 5)
			else:
				image.rotation_degrees = sin(walk_clock * 10.0) * 20
				image.position.y = -abs(sin(walk_clock * 10.0) * 20)
		else:
			image.rotation_degrees = (dir_x * 9) + sin(walk_clock * 9.0) * 3
			image.position.y = lerp(image.position.y, 0, 10 * delta)
	
	
	# squish ease
	image_root.scale = squish_ease.move(delta)

func die():
	is_dead = true
	is_input = false
	vel.y = -jump_speed
	vel.x = move_speed * -dir_x
	joy.x = -dir_x
	arcade.lose()
	#Audio.play(audio_die, 0.8, 1.2)
	Audio.play("arcade_owie", 0.7, 1.1)

func pause(arg := false):
	joy = Vector2.ZERO
	btn_jump = false
	is_unpause = !arg
