extends KinematicBody2D
class_name Player

var velocity := Vector2.ZERO
var move_velocity := Vector2.ZERO

var walk_speed = 250
var gravity = 600
var jump_speed = 400

var jump_clock := 0.0
var jump_time := 0.5

export var dir := 0

onready var sprite : Sprite = $Sprite
onready var hit_area : Area2D = $HitArea
onready var push_area : Area2D = $PushArea

var is_floor := false
var has_jumped := true
var dir_x := 1

onready var label : Label = $DebugCanvas/Labels/Label
var readout = []

var camera : Camera2D

func _ready():
	readout.resize(4)
	
	for i in get_tree().get_nodes_in_group("game_camera"):
		camera = i
		break

func rot(arg : Vector2, backwards := false):
	return arg.rotated(deg2rad((-dir if backwards else dir) * 90))

func spin(right := false):
	dir += 1 if right else -1
	if dir > 3: dir = 0
	elif dir < 0: dir = 3
	
	sprite.rotation_degrees = dir * 90
	camera.target_angle += 90 if right else -90
	update_areas()

func update_areas():
	hit_area.position = rot(Vector2(50 * dir_x, 0))
	push_area.position = rot(Vector2(40 * dir_x, 0))
	push_area.rotation_degrees = dir * 90

func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	walk_speed = 250
	gravity = 1300
	jump_speed = 460
	
	# input
	var joy = Vector2(btn.d("right") - btn.d("left"), btn.d("down") - btn.d("up"))
	
	if joy.x != 0:
		dir_x = joy.x
		update_areas()
	
	# on floor
	is_floor = test_move(transform, rot(Vector2.DOWN))
	if is_floor:
		has_jumped = false
	
	# gravity
	velocity.y += gravity * delta
	
	# walking
	velocity.x = joy.x * walk_speed
	
	# spin
	if !has_jumped and !is_floor:
		spin(test_move(transform, rot(Vector2(-5, 5))))
		has_jumped = true
		is_floor = false
	
	# jump
	if is_floor and btn.p("jump"):
		has_jumped = true
		jump_clock = jump_time
	
	if (jump_clock > 0 and btn.d("jump")) or jump_clock > jump_time - 0.1:
		velocity.y = -jump_speed
		jump_clock -= delta
		
		if test_move(transform, rot(Vector2(0, -1))):
			jump_clock = 0
	else:
		jump_clock = 0
	
	# hit box
	if btn.p("action"):
		for i in hit_area.get_overlapping_bodies():
			if i is Box:
				i.set_dir(dir - dir_x)
				i.move_clock = 0
				break
	
	# apply movement
	move_velocity = move_and_slide(rot(velocity))
	velocity = rot(move_velocity, true)
	
	# camera
	camera.position = position
	
	# debug label
	readout[0] = "dir: " + str(dir)
	readout[1] = "is_floor: " + str(is_floor)
	readout[2] = "has_jumped: " + str(has_jumped)
	readout[3] = "dir_x: " + str(dir_x)
	
	label.text = ""
	for i in readout:
		label.text += str(i) + "\n"

func _on_PushArea_body_entered(body):
	if is_floor and body is Box:
		body.push(dir_x == 1)
