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
onready var audio_slap : AudioStreamPlayer2D = $AudioSlap
onready var audio_punch : AudioStreamPlayer2D = $AudioPunch

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

func spinny(arg := 1):
	if arg == 0: return
	dir += arg
	
	pass

func spin(right := false, repeat := 0):
	for i in clamp(repeat, 0, 3) + 1:
		dir += 1 if right else 3
		camera.target_angle += 90 if right else -90
	dir %= 4
	
	sprite.rotation_degrees = dir * 90
	update_areas()

func spinner(right := false, pos := Vector2.ZERO):
	spin(right)
	hit_effector(pos)

func arrow(arg, pos):
	if dir == arg: return
	elif (dir + 1) % 4 == arg: spin(true)
	elif (dir + 3) % 4 == arg: spin(false)
	elif (dir + 2) % 4 == arg: spin(randf() > 0.5, 1)
	hit_effector(pos)

func hit_effector(pos : Vector2):
	move_and_collide(pos - position)
	velocity = Vector2.ZERO
	is_floor = false
	has_jumped = true
	jump_clock = 0

func update_areas():
	hit_area.position = rot(Vector2(50 * dir_x, 0))
	hit_area.rotation_degrees = dir * 90
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
		audio_slap.play()
		for i in hit_area.get_overlapping_areas():
			var o = i.owner
			if o is Box:
				o.set_dir(dir + (0 if joy.y == 1 else 2 if joy.y == -1 else -dir_x))
				o.move_clock = 0
				audio_punch.play()
				break
			
			print(i.owner.name, "hit")
	
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
	if is_floor and body.is_in_group("box") and body.is_floor and body.dir % 2 == dir % 2:
		body.push(dir_x == 1)

func _on_BodyArea_area_entered(area):
	if area.get_parent().is_in_group("spike"):
		print("hit spike")
		get_tree().reload_current_scene()
