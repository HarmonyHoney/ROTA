extends KinematicBody2D

onready var area := $Area2D
onready var image := $Sprites
var spr_list := []

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO
var btnp_jump := false
var btn_jump := false

export var move_speed := 100.0
export var move_accel := 0.3
export var move_damp := 0.2
export var jump_speed := 100.0

export var room_size := Vector2(600, 600)

export var gravity := 100.0

var vel := Vector2.ZERO
var is_floor := false
var walk_clock = 0.0
var dir_x := 1.0

func _ready():
	spr_list = []
	for i in 8:
		var s = image.duplicate()
		add_child(s)
		spr_list.append(s)

func _physics_process(delta):
	joy_last = joy
	joy.x = round(Input.get_axis("left", "right"))
	joy.y = round(Input.get_axis("up", "down"))
	
	btnp_jump = Input.is_action_just_pressed("jump")
	btn_jump = Input.is_action_pressed("jump")
	is_floor = test_move(transform, Vector2(0, 3))
	
	if joy.x == 0:
		vel.x = lerp(vel.x, 0.0, delta * 21.0)
		
	else:
		vel.x = clamp(vel.x + (move_speed * move_accel * joy.x), -move_speed, move_speed)
		dir_x = joy.x
	
	vel.y += gravity * delta
	
	if btn_jump and is_floor:
		vel.y = -jump_speed
	
	for i in area.get_overlapping_bodies():
		i.die()
		vel.y = -jump_speed# * (1.0 if btn_jump else 0.7)
	
	vel = move_and_slide(vel)
	
	
	position.x = wrapf(position.x, -room_size.x, room_size.x)
	position.y = wrapf(position.y, -room_size.y, room_size.y)
	
	
	
	
	# body
	walk_clock = 0.0 if joy.x != joy_last.x else walk_clock + (delta * dir_x)
	
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
	
	
	# mirrors
	
	var sg = image.global_position
	var add = Vector2(room_size.x, room_size.y) * 2.0
	
	var vec = []
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if !(x == 0 and y == 0):
				vec.append(Vector2(x, y))
	
	for i in spr_list.size():
		spr_list[i].scale = image.scale
		spr_list[i].rotation = image.rotation
		spr_list[i].global_position = sg + (add * vec[i])
	
