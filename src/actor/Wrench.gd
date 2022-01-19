extends Node2D

onready var sprite : Sprite = $Sprite

var box : Box
var player # player

var is_hold := false
var is_turn := false

#var wrench_target := Vector2.ZERO
#var wrench_angle := 0.0
#var wrench_turn := 0.0
#var wrench_clock := 0.0
#var wrench_time := 0.2

var target := Vector2.ZERO
var angle := 0.0

var turn_clock := 0.0
var turn_time := 0.2
var turn_from := 0.0
var turn_to := 0.0

var hand_offset := Vector2(0, -58)

var is_swing := false
var swing_clock := 0.0
var swing_time := 0.5
var swing_from := 0.0
var swing_to := 0.0
var swing_angle := 90.0
var is_swing_check := false

signal swing_check

func _ready():
	sprite.position = hand_offset

func _physics_process(delta):
	if !is_instance_valid(player): return
	
	
	if is_hold:
		target = box.sprite.global_position
		angle = deg2rad((player.dir + player.dir_x) * 90)
	else:
		if is_swing:
			target = player.position + player.rot(Vector2(50 * player.dir_x, -30))
		else:
			target = player.position + player.rot(Vector2(-50 * player.dir_x, -10))
		
		angle = deg2rad(player.dir * 90)
		var walk = player.velocity.x / player.walk_speed
		angle += lerp(0, deg2rad(-45), walk)
	
	position = position.linear_interpolate(target, 0.1)
	
	if is_hold and box.is_push:
		position = target
	
	if is_swing:
		swing_clock = min(swing_clock + delta, swing_time)
		rotation = lerp(swing_from, swing_to, smoothstep(0, 1, swing_clock / swing_time))
		
		if is_swing_check:
			if abs(rotation_degrees - (player.dir * 90)) > 80:
				emit_signal("swing_check")
				is_swing_check = false
				print("swing check ", rotation_degrees)
		
		if swing_clock == swing_time:
			is_swing = false
	
	elif is_turn:
		turn_clock = min(turn_clock + delta, turn_time)
		rotation = lerp_angle(turn_from, turn_to, smoothstep(0, 1, turn_clock / turn_time))
		if turn_clock == turn_time:
			is_turn = false
	else:
		rotation = lerp_angle(rotation, angle, 0.1)

func set_box(b):
	box = b
	is_hold = is_instance_valid(box)
	
	position += (sprite.global_position - position) * 2
	sprite.position = -hand_offset if is_hold else hand_offset
	
	z_index = player.z_index + (1 if is_hold else -1)
	#z_index = (29 if is_hold else player.z_index -1)

func turn(radians):
	is_turn = true
	turn_clock = 0.0
	turn_from = angle
	turn_to = angle + radians

func swing():
	is_swing = true
	is_swing_check = true
	swing_clock = 0.0
	swing_from = angle
	swing_to = angle + (deg2rad(360) * player.dir_x)
