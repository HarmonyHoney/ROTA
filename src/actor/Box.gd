extends KinematicBody2D
class_name Box

export var dir := 0 setget set_dir

onready var sprite : Sprite = $Sprite
onready var collision_shape : CollisionShape2D = $CollisionShape2D
onready var standing_area : Area2D = $StandingArea

var is_floor := false

var move_clock := 0.0
export var move_time := 0.4
onready var last_pos := position
var next_move := Vector2.ZERO

var can_move := true

var tile := 100.0

func _ready():
	pass

func rot(arg : Vector2, backwards := false):
	return arg.rotated(deg2rad((-dir if backwards else dir) * 90))

func set_dir(arg):
	if arg > 3: dir = 0
	elif arg < 0: dir = 3
	else: dir = arg
	
	sprite.rotation_degrees = dir * 90

#func _input(event):
#	if event is InputEventKey and event.pressed:
#		if event.scancode == KEY_Q:
#			set_dir(dir - 1)
#		elif event.scancode == KEY_E:
#			set_dir(dir + 1)

func push(right := false):
	move(Vector2(1 if right else -1, 0))

func move(vector := Vector2.ZERO):
	shrink_shape()
	move_and_collide(rot(vector) * tile)
	
	# keep box on grid (:
	var step = Vector2(stepify(position.x, 50), stepify(position.y, 50)) - position
	print("box step: ", step)
	if step != Vector2.ZERO:
		move_and_collide(step)
	
	sprite.position -= position - last_pos
	shrink_shape(false)
	
	for i in standing_area.get_overlapping_bodies():
		if i.is_in_group("player"):
			i.has_jumped = true
			break
	
	print("box.position: ", position)

func shrink_shape(shrink := true):
	collision_shape.shape.extents = Vector2(49, 49) if shrink else Vector2(50, 50)

func _physics_process(delta):
	if Engine.editor_hint: return
	last_pos = position
	
	# on floor
	shrink_shape()
	is_floor = test_move(transform, rot(Vector2(0, tile)))
	shrink_shape(false)
	
	# move down
	if !is_floor:
		move_clock -= delta
		if move_clock < 0:
			move_clock = move_time
			move(Vector2(0, 1))
	
	# lerp sprite
	sprite.position = sprite.position.linear_interpolate(Vector2.ZERO, delta * 5.0)
