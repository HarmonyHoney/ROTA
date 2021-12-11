tool
extends KinematicBody2D
class_name Box

onready var collision_shape : CollisionShape2D = $CollisionShape2D
onready var standing_area : Area2D = $StandingArea
onready var push_areas : Array = $PushAreas.get_children()
onready var sprite : Sprite = $Sprite
onready var arrow : Sprite = $Sprite/Arrow
onready var collision_sprite : CollisionShape2D = $Area2D/CollisionSprite
onready var audio_push : AudioStreamPlayer2D = $AudioPush

export var dir := 0 setget set_dir

var tile := 100.0
var is_floor := false
var move_clock := 0.0
var move_time := 0.3
onready var last_pos := position
var move_weight := 5.0

var arrow_weight := 6.0
var arrow_angle := 0.0

var is_push := false
var push_time := 0.5

var push_frames := 0
var last_push := 0

export var is_regenerate := false
var start_dir := 0
var start_pos := Vector2.ZERO
var passhthrough_scene = load("res://src/actor/Passthrough.tscn")

export var easing : Curve

func _ready():
	set_dir()
	arrow.rotation_degrees = arrow_angle
	# snap to every 100 + 50
	position = Vector2(50, 50) + (position / 100).floor() * 100
	start_dir = dir
	start_pos = position

#func _input(event):
#	if event is InputEventKey and event.pressed:
#		if event.scancode == KEY_Q:
#			set_dir(dir - 1)
#		elif event.scancode == KEY_E:
#			set_dir(dir + 1)

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# push frames
	push_frames = max(0, push_frames - 1)
	if push_frames > 0:
		move(rot(Vector2.DOWN, last_push))
	
	# on floor
	shrink_shape()
	is_floor = test_move(transform, rot(Vector2(0, tile)))
	shrink_shape(false)
	
	var target = push_time if is_push else move_time
	
	move_clock = min(move_clock + delta, target)
	# lerp sprite
	sprite.position = sprite.position.linear_interpolate(Vector2.ZERO, easing.interpolate(move_clock / target))
	# update collision_sprite
	collision_sprite.position = sprite.position
	
	if move_clock == target:
		if is_push:
			is_push = false
		
		# move down
		if !is_floor:
			move(rot(Vector2(0, 1)))
	
	# lerp arrow
	arrow.rotation = lerp_angle(arrow.rotation, deg2rad(arrow_angle), delta * arrow_weight)

func set_dir(arg := dir):
	dir = posmod(arg, 4)
	arrow_angle = dir * 90
	if Engine.editor_hint:
		if !arrow: arrow = $Sprite/Arrow
		arrow.rotation_degrees = arrow_angle

func rot(arg : Vector2, _dir := dir, backwards := false):
	return arg.rotated(deg2rad((-_dir if backwards else _dir) * 90))

func spinner(right := false):
	set_dir(dir + (1 if right else 3))

func arrow(arg):
	if arg != dir:
		set_dir(arg)

func portal(pos):
	position = pos
	sprite.position = Vector2.ZERO

func shrink_shape(shrink := true):
	collision_shape.shape.extents = Vector2(49, 49) if shrink else Vector2(50, 50)

func move(vector := Vector2.ZERO):
	var is_move := false
	
	shrink_shape()
	# is space open
	if !test_move(transform, vector * tile):
		last_pos = position
		move_and_collide(vector * tile)
		# keep box on grid (:
		var step = Vector2(stepify(position.x, 50), stepify(position.y, 50)) - position
		if step != Vector2.ZERO:
			move_and_collide(step)
		
		# move sprite
		sprite.position -= position - last_pos
		
		# jump player
		for i in standing_area.get_overlapping_bodies():
			if i.is_in_group("player"):
				i.has_jumped = true
		print(name + ".position: ", position, " stepify: ", step)
		
		push_frames = 0
		move_clock = 0
		
		is_move = true
	shrink_shape(false)
	return is_move

func push(push_dir := 0):
	push_dir = posmod(push_dir, 4)
	
	for i in push_areas[push_dir].get_overlapping_bodies():
		#print("push_areas[push_dir] ", push_areas[push_dir].name)
		if i != self and i.is_in_group("box"):
			i.push(push_dir)
	
	if move(rot(Vector2.DOWN, push_dir)):
		is_push = true
	else:
		last_push = push_dir
		push_frames = 20

func outside_boundary():
	if is_regenerate:
		set_physics_process(false)
		
		set_dir(start_dir)
		sprite.position = Vector2.ZERO
		arrow.rotation = deg2rad(arrow_angle)
		
		var p = passhthrough_scene.instance()
		p.position = start_pos
		p.is_spawn_box = true
		p.box_to_move = self
		get_parent().add_child(p)
		p.set_physics_process(true)
	else:
		queue_free()
