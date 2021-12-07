tool
extends KinematicBody2D
class_name Player

onready var sprites : Node2D = $Sprites
onready var areas : Node2D = $Areas
onready var hit_area : Area2D = $Areas/HitArea
onready var push_area : Area2D = $Areas/PushArea
onready var body_area : Area2D = $BodyArea
onready var audio_slap : AudioStreamPlayer2D = $AudioSlap
onready var audio_punch : AudioStreamPlayer2D = $AudioPunch
onready var anim : AnimationPlayer = $AnimationPlayer
onready var anim_eyes : AnimationPlayer = $AnimationEyes
onready var line : Line2D = $Line2D
onready var wand_origin : Node2D = $Sprites/Wand/WandOrigin

var camera : Camera2D

export var dir := 0 setget set_dir

var velocity := Vector2.ZERO
var move_velocity := Vector2.ZERO

export var walk_speed := 350.0
export var air_speed := 250.0

var floor_accel := 12
var air_accel := 7

var is_jump := false
var has_jumped := true
export var jump_height := 350.0 setget set_jump_height
export var jump_time := 0.7 setget set_jump_time
var jump_speed := 0.0
var jump_gravity := 0.0
var fall_gravity := 0.0
#var jump_start := 0.0

var is_floor := false
var dir_x := 1

onready var label : Label = $DebugCanvas/Labels/Label
var readout = []

var sprite_weight := 6.0
var target_angle := 0.0

onready var blink_clock := rand_range(2, 15)

var push_clock := 0.0
var push_time := 0.3

var is_hold := false
var held_box
var hold_pos := Vector2.ZERO


var turn_clock := 0.0
var turn_time := 0.1

var is_input := true
var joy_last := Vector2.ZERO
var joy := Vector2.ZERO
var btnp_jump := false
var btn_jump := false
var btnp_action := false
var btn_action := false

export var is_debug := false

var is_move := true
var is_walk := true

var is_exit := false
var exit_node

var is_dead := false

func _ready():
	if Engine.editor_hint: return
	
	solve_jump()
	
	readout.resize(4)
	if is_debug:
		label.visible = true
	
	# snap to floor
	var test = rot(Vector2.DOWN * 75)
	if test_move(transform, test):
		move_and_collide(test)
	
	# find camera in the same viewport
	for i in get_tree().get_nodes_in_group("game_camera"):
		if i.get_viewport() == get_viewport():
			camera = i
			camera.target_node = self
#			if camera.is_moving:
#				camera.position = position
#				camera.reset_smoothing()
			set_dir()
			camera.rotation_degrees = camera.target_angle
			sprites.rotation_degrees = target_angle
			break
	
	# face left or right
	randomize()
	set_dir_x(1 if randf() > 0.5 else -1)
	
	# disable input if inside level select
	if Shared.is_level_select:
		#print("player in WorldSelect")
		#is_input = false
		#camera.zoom = Vector2.ONE * 1.5
		set_physics_process(false)

func _input(event):
	if is_input and event.is_action_pressed("reset"):
		Shared.reset()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# alternate updates
	if is_exit:
		position = position.linear_interpolate(exit_node.position, 3 * delta)
		sprites.scale = sprites.scale.linear_interpolate(Vector2.ZERO, 0.9 * delta)
		sprites.rotate(deg2rad(dir_x * 240) * delta)
		return
	
	if is_dead:
		sprites.position += rot(velocity) * delta
		sprites.rotate(deg2rad(-dir_x * 240) * delta)
		velocity.y += fall_gravity * delta
		return
	# end alternate updates
	
	# input
	if is_input:
		joy_last = joy
		joy = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")).round()
		
		btnp_jump = Input.is_action_just_pressed("jump")
		btn_jump = Input.is_action_pressed("jump")
		btnp_action = Input.is_action_just_pressed("action")
		btn_action = Input.is_action_pressed("action")
	# end input code
	
	# movement code
	if is_move:
		# dir_x
		if joy.x != 0:
			set_dir_x(joy.x)
		
		# on floor
		is_floor = !is_jump and test_move(transform, rot(Vector2.DOWN))
		if is_floor:
			has_jumped = false
		
		# walking
		turn_clock = max(0, turn_clock - delta)
		if is_walk and turn_clock == 0:
			var target = joy.x * (walk_speed if is_floor else air_speed)
			var weight = floor_accel if is_floor else air_accel
			velocity.x = lerp(velocity.x, target, weight * delta)
		
		# start jump
		if is_floor and btnp_jump:
			is_floor = false
			anim.play("jump")
			
			is_jump = true
			has_jumped = true
			velocity.y = jump_speed
			#jump_start = position.y
		
		# gravity
		velocity.y += (jump_gravity if is_jump else fall_gravity) * delta
		
		# during jump
		if is_jump:
			if btn_jump:
				if velocity.y >= 0.0 or test_move(transform, rot(Vector2(0, -1))):
					is_jump = false
					#print("jump start: ", jump_start, " / jump end: ", position.y + velocity.y, " / distance: ", position.y - jump_start)
			else:
				is_jump = false
				velocity.y *= 0.8
		
		# apply movement
		if is_move:
			move_velocity = move_and_slide(rot(velocity))
			velocity = rot(move_velocity, dir, true)
		
		# spin
		if !has_jumped and !is_floor:
			spin(test_move(transform, rot(Vector2(-25, 25))))
			has_jumped = true
			is_floor = false
	# end movement code
	
	# block direction
	if btnp_action and is_floor:
		if !is_hold:
			for i in hit_area.get_overlapping_areas():
				var o = i.owner
				if o is Box:
					held_box = o
					is_hold = true
					is_move = false
					velocity = Vector2.ZERO
					line.visible = true
	
	if is_hold:
		held_box.move_clock = 1.0
		
		var t = wand_origin.get_relative_transform_to_parent(self)
		
		line.points[0] = wand_origin.global_position - global_position
		line.points[1] = held_box.sprite.global_position - global_position
		
		# spin box
		if joy.x != 0 and joy_last.x == 0:
			held_box.dir += joy.x
		
		# lift box
		if joy.y != 0 and joy_last.y == 0:
			held_box.move(rot(Vector2.DOWN * joy.y))
		
		# let go
		if !btn_action:
			is_hold = false
			held_box.move_clock = held_box.move_time
			is_move = true
			line.visible = false
	# end block direction code
	
	# block push
	if is_floor and joy.x != 0 and test_move(transform, rot(Vector2(1 if joy.x == 1 else -1, 0))):
		push_clock += delta
		if push_clock > push_time:
			push_clock = 0.001
			for i in push_area.get_overlapping_bodies():
				if i.is_in_group("box") and i.is_floor:
					i.push(dir - dir_x)
					break
	else:
		push_clock = 0
	# end push code
	
	# animation
	if !is_hold:
		if is_floor:
			var t = anim.current_animation_position
			var last_anim = anim.current_animation
			
			if push_clock > 0:
				anim.play("push")
			elif joy.x != 0:
				anim.play("run")
			else:
				anim.play("idle")
			
			if anim.current_animation != last_anim and last_anim != "idle":
				anim.seek(t)
	
	# blink anim
	blink_clock -= delta
	if blink_clock < 0:
		anim_eyes.play("blink")
		blink_clock = rand_range(2, 15)
	
	# sprite rotation
	sprites.rotation = lerp_angle(sprites.rotation, deg2rad(target_angle), delta * sprite_weight)
	# end animation code
	
	# debug label
	if is_debug:
		readout[0] = "dir: " + str(dir)
		readout[1] = "is_floor: " + str(is_floor)
		readout[2] = "has_jumped: " + str(has_jumped)
		readout[3] = "dir_x: " + str(dir_x)
		
		label.text = ""
		for i in readout:
			label.text += str(i) + "\n"

func set_dir(arg := dir):
	dir = posmod(arg, 4)
	target_angle = dir * 90
	
	if Engine.editor_hint:
		if !sprites: sprites = $Sprites
		sprites.rotation_degrees = target_angle
	elif camera:
		camera.target_angle = target_angle
	
	if areas:
		areas.rotation_degrees = target_angle

func set_dir_x(arg := dir_x):
	dir_x = sign(arg)
	areas.scale.x = dir_x
	sprites.scale.x = dir_x

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
	print("jump_speed: ", jump_speed, " / jump_gravity: ", jump_gravity, " / fall_gravity: ", fall_gravity)

func rot(arg : Vector2, _dir = 0, backwards := false):
	return arg.rotated(deg2rad((-dir if backwards else dir) * 90))

func spin(right := false):
	set_dir(dir + (1 if right else 3))
	
	velocity.x = walk_speed if right else -walk_speed
	turn_clock = turn_time

func hit_effector(pos : Vector2):
	move_and_collide(pos - position)
	velocity = Vector2.ZERO
	is_floor = false
	has_jumped = true
	is_jump = false

func spinner(right := false, pos := Vector2.ZERO):
	spin(right)
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
	pass

func _on_BodyArea_body_entered(body):
	if body.is_in_group("spike"):
		print("hit spike")
		die()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "punch":
		if is_floor:
			anim.play("idle")
		else:
			anim.play("jump")

func exit(arg):
	if is_exit: return
	is_exit = true
	exit_node = arg
	anim.play("jump")
	
	yield(get_tree().create_timer(0.7), "timeout")
	Shared.complete_level()

func die():
	if is_dead: return
	is_dead = true
	anim.play("jump")
	anim_eyes.play("die")
	velocity = Vector2(-350 * dir_x, -800)
	
	yield(get_tree().create_timer(0.7), "timeout")
	Shared.reset()




