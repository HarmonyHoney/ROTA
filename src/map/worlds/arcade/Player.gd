extends KinematicBody2D

onready var area := $Area2D

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO
var btnp_jump := false
var btn_jump := false

export var move_speed := 100.0
export var move_accel := 0.3
export var move_damp := 0.2
export var jump_speed := 100.0

export var room_size := Vector2(1200, 1200)

export var gravity := 100.0

var vel := Vector2.ZERO
var is_floor := false

func _physics_process(delta):
	joy_last = joy
	joy.x = round(Input.get_axis("left", "right"))
	joy.y = round(Input.get_axis("up", "down"))
	
	btnp_jump = Input.is_action_just_pressed("jump")
	btn_jump = Input.is_action_pressed("jump")
	is_floor = test_move(transform, Vector2(0, 3))
	
	if joy.x == 0:
		var vx = vel.x < 0
		var sx = sign(vel.x)
		
		#vel.x = clamp(vel.x + (move_speed * move_damp * -sx), -move_speed if vx else 0.0, 0.0 if vx else move_speed)
		vel.x = lerp(vel.x, 0.0, delta * 30.0)
		
	else:
		vel.x = clamp(vel.x + (move_speed * move_accel * joy.x), -move_speed, move_speed)
	
	vel.y += gravity * delta
	
	if btn_jump and is_floor:
		vel.y = -jump_speed
	
	for i in area.get_overlapping_bodies():
		vel.y = -jump_speed
	
	vel = move_and_slide(vel)
	
	
	position.x = wrapf(position.x, 0.0, room_size.x)
	position.y = wrapf(position.y, 0.0, room_size.y)
