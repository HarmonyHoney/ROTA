tool
extends KinematicBody2D
class_name Player

onready var sprites : Node2D = $Sprites
onready var areas : Node2D = $Areas
onready var hit_area : Area2D = $Areas/HitArea
onready var push_area : Area2D = $Areas/PushArea
onready var audio_slap : AudioStreamPlayer2D = $AudioSlap
onready var audio_punch : AudioStreamPlayer2D = $AudioPunch
onready var anim : AnimationPlayer = $AnimationPlayer
onready var anim_blink : AnimationPlayer = $AnimationBlink

var camera : Camera2D

export var dir := 0 setget set_dir

var velocity := Vector2.ZERO
var move_velocity := Vector2.ZERO

var walk_speed = 250
var gravity = 1300
var jump_speed = 460
var jump_clock := 0.0
var jump_time := 0.5

var is_floor := false
var has_jumped := true
var dir_x := 1

onready var label : Label = $DebugCanvas/Labels/Label
var readout = []

var sprite_weight := 6.0
var target_angle := 0.0

var blink_clock := 0.0

var push_clock := 0.0
var push_time := 0.4

var punch_clock := 0.0
var punch_time := 0.4
var is_punch := false

var turn_clock := 0.0
var turn_time := 0.1

var is_input := true
var joy := Vector2.ZERO
var btn_jump := false
var btnp_jump := false
var btnp_action := false

export var is_debug := false

var is_move := true

func _ready():
	if Engine.editor_hint: return
	
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
			camera.position = position
			camera.reset_smoothing()
			set_dir()
			camera.rotation_degrees = camera.target_angle
			sprites.rotation_degrees = target_angle
			break
	
	# disable input if inside level select
	if Shared.is_level_select:
		#print("player in WorldSelect")
		is_input = false
		camera.zoom = Vector2.ONE * 1.5
	
	# face left or right
	randomize()
	set_dir_x(1 if randf() > 0.5 else -1)

func rot(arg : Vector2, backwards := false):
	return arg.rotated(deg2rad((-dir if backwards else dir) * 90))

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

func spin(right := false):
	set_dir(dir + (1 if right else 3))
	
	velocity.x = walk_speed if right else -walk_speed
	turn_clock = turn_time

func hit_effector(pos : Vector2):
	move_and_collide(pos - position)
	velocity = Vector2.ZERO
	is_floor = false
	has_jumped = true
	jump_clock = 0

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
	jump_clock = 0
	
	position = pos

func _input(event):
	if is_input and event.is_action_pressed("reset"):
		Shared.reset()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# input
	if is_input:
		joy = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")).round()
		
		btnp_jump = Input.is_action_just_pressed("jump")
		btn_jump = Input.is_action_pressed("jump")
		btnp_action = Input.is_action_just_pressed("action")
	
	# dir_x
	if joy.x != 0 and anim.current_animation != "punch":
		set_dir_x(joy.x)
	
	# on floor
	is_floor = test_move(transform, rot(Vector2.DOWN))
	if is_floor:
		has_jumped = false
	
	# gravity
	velocity.y += gravity * delta
	
	# walking
	turn_clock = max(0, turn_clock - delta)
	
	if turn_clock == 0 and anim.current_animation != "punch":
		velocity.x = joy.x * walk_speed
	
	# jump
	if is_floor and btnp_jump:
		has_jumped = true
		jump_clock = jump_time
		is_floor = false
		if anim.current_animation != "punch":
			anim.play("jump")
	
	if (jump_clock > 0 and btn_jump) or jump_clock > jump_time - 0.1:
		velocity.y = -jump_speed
		jump_clock -= delta
		
		if test_move(transform, rot(Vector2(0, -1))):
			jump_clock = 0
	else:
		jump_clock = 0
	
	# spin
	if !has_jumped and !is_floor:
		spin(test_move(transform, rot(Vector2(-5, 5))))
		has_jumped = true
		is_floor = false
	
	# hit box
	if btnp_action:
		is_punch = true
	
	punch_clock = max(0, punch_clock - delta)
	if is_punch and punch_clock == 0:
		is_punch = false
		punch_clock = 0.25
		#audio_slap.play()
		anim.play("punch")
		anim.seek(0)
		velocity.x = 0
		for i in hit_area.get_overlapping_areas():
			var o = i.owner
			if o is Box:
				var d = 0 if joy.y == 1 else 2 if joy.y == -1 else 3 if dir_x == 1 else 1
				o.set_dir(dir + d)
				o.move_clock = 0
				#audio_punch.play()
				print(o.name, " hit, dir: ", o.dir)
				break
	
	# push box
	if is_floor and joy.x != 0 and test_move(transform, rot(Vector2(1 if joy.x == 1 else -1, 0))):
		push_clock += delta
		if push_clock > push_time:
			push_clock = 0.001
			for i in push_area.get_overlapping_bodies():
				if i.is_in_group("box") and i.is_floor and i.dir % 2 == dir % 2:
					i.push((dir_x == 1) if i.dir == dir else (dir_x == -1))
					break
	else:
		push_clock = 0
	
	# apply movement
	if is_move:
		move_velocity = move_and_slide(rot(velocity))
		velocity = rot(move_velocity, true)
	
	# camera
	if camera:
		camera.position = position
	
	# animation
	if anim.current_animation != "punch":
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
	
	# blink
	blink_clock -= delta
	if blink_clock < delta:
		anim_blink.play("blink")
		blink_clock = rand_range(2, 15)
	
	# sprite
	sprites.rotation = lerp_angle(sprites.rotation, deg2rad(target_angle), delta * sprite_weight)
	
	# debug label
	readout[0] = "dir: " + str(dir)
	readout[1] = "is_floor: " + str(is_floor)
	readout[2] = "has_jumped: " + str(has_jumped)
	readout[3] = "dir_x: " + str(dir_x)
	
	label.text = ""
	for i in readout:
		label.text += str(i) + "\n"

func _on_BodyArea_area_entered(area):
	if area.get_parent().is_in_group("spike"):
		print("hit spike")
		die()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "punch":
		if is_floor:
			anim.play("idle")
		else:
			anim.play("jump")

func win():
	is_input = false
	is_move = false
	Shared.complete_level()

func die():
	Shared.reset()
