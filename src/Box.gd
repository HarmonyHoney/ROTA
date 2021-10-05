extends KinematicBody2D

export var dir := 0 setget _set_dir

onready var sprite : Sprite = $Sprite
onready var collision_shape : CollisionShape2D = $CollisionShape2D
onready var standing_area : Area2D = $StandingArea

var is_floor := false

var move_clock := 0.0
export var move_time := 0.4

var can_move := true

var tile := 100.0

func _ready():
	pass

func rot(arg : Vector2, backwards := false):
	return arg.rotated(deg2rad((-dir if backwards else dir) * 90))

func _set_dir(arg):
	if arg > 3: dir = 0
	elif arg < 0: dir = 3
	else: dir = arg
	
	sprite.rotation_degrees = dir * 90

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_Q:
			_set_dir(dir - 1)
		elif event.scancode == KEY_E:
			_set_dir(dir + 1)

func _physics_process(delta):
	if Engine.editor_hint: return
	var last_pos = position
	
	collision_shape.shape.extents = Vector2(49, 49)
	
	# on floor
	is_floor = test_move(transform, rot(Vector2(0, tile)))
	
	# move
	if !is_floor:
		move_clock -= delta
		if move_clock < 0:
			move_clock = move_time
			move_and_collide(rot(Vector2(0, tile)))
			sprite.position -= position - last_pos
			
			for i in standing_area.get_overlapping_bodies():
				if i.is_in_group("player"):
					i.has_jumped = true
			
	collision_shape.shape.extents = Vector2(50, 50)
	
	# lerp sprite
	sprite.position = sprite.position.linear_interpolate(Vector2.ZERO, delta * 5.0)
	
	if position != last_pos:
		print("box.position: ", position)

