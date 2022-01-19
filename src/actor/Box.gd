tool
extends KinematicBody2D
class_name Box

onready var collision_shape : CollisionShape2D = $CollisionShape2D
onready var standing_area : Area2D = $StandingArea
onready var push_areas : Array = $PushAreas.get_children()
onready var sprite : Sprite = $Sprite
onready var arrow : Sprite = $Sprite/Arrow
onready var collision_sprite : CollisionShape2D = $Area2D/CollisionSprite

export var dir := 0 setget set_dir

var tile := 100.0
var is_floor := false
var move_clock := 0.0
var move_time := 0.2

var arrow_from := 0.0
var arrow_to := 0.0
var turn_clock := 0.0
var turn_time := 0.2

var is_push := false
var push_clock := 0.0
var push_time := 0.5

export var is_regenerate := true
var start_dir := 0
var start_pos := Vector2.ZERO
var passhthrough_scene = load("res://src/actor/Passthrough.tscn")

var is_hold := false

onready var actors = get_parent()

func _ready():
	turn_clock = 99
	
	# snap to grid
	position = (Vector2.ONE * tile / 2) + (position / tile).floor() * tile
	
	# vars for regeneration
	start_dir = dir
	start_pos = position

#func _input(event):
#	if event is InputEventKey and event.pressed:
#		if event.scancode == KEY_Q:
#			self.dir -= 1
#		elif event.scancode == KEY_E:
#			set_dir(dir + 1)

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# on floor
	is_floor = test_tile(dir, 1)
	
	# move clock
	var target = push_time if is_push else move_time
	move_clock = min(move_clock + delta, target)
	
	# lerp sprite and update collision_sprite
	sprite.position = sprite.position.linear_interpolate(Vector2.ZERO, smoothstep(0, 1, move_clock / target))
	collision_sprite.position = sprite.position
	
	# turn arrow
	turn_clock = min(turn_clock + delta, turn_time)
	arrow.rotation = lerp_angle(arrow_from, arrow_to, smoothstep(0, 1, turn_clock / turn_time))
	
	if move_clock == target:
		if is_push:
			is_push = false
		
		# move down
		if !is_hold and !is_floor:
			move_tile(dir, 1)

func set_dir(arg := dir):
	dir = posmod(arg, 4)
	
	if is_instance_valid(arrow):
		arrow_from = arrow.rotation
	arrow_to = deg2rad(dir * 90)
	turn_clock = 0.0
	
	if Engine.editor_hint:
		$Sprite/Arrow.rotation = arrow_to

func rot(arg : Vector2, _dir := dir, backwards := false):
	return arg.rotated(deg2rad((-_dir if backwards else _dir) * 90))

func shrink_shape(shrink := true):
	collision_shape.shape.extents = Vector2(49, 49) if shrink else Vector2(50, 50)

func test_tile(check_dir := dir, distance := 1) -> bool:
	var vec = rot(Vector2.DOWN * distance * tile, check_dir)
	
	shrink_shape()
	var result = test_move(transform, vec)
	shrink_shape(false)
	
	if !result and is_instance_valid(actors):
		var check_pos = position + vec
		check_pos = Vector2(stepify(check_pos.x, 50), stepify(check_pos.y, 50))
		
		for i in actors.boxes:
			if i != self:
				if check_pos == i.position:
					result = true
					break
	
	return result

func move_tile(move_dir := dir, distance := 1):
	# jump player
	for i in standing_area.get_overlapping_bodies():
		if i.is_in_group("player"):
			i.has_jumped = true
			if i.velocity.y > 0:
				i.velocity.y = 0
	
	# move
	var move_from = position
	position += rot(Vector2.DOWN * distance * tile, move_dir)
	position = Vector2(stepify(position.x, 50), stepify(position.y, 50))
	
	print(name, ": ", move_from, " - ", position)
	
	# move sprite
	sprite.position -= position - move_from
	
	# reset clock
	move_clock = 0

func push(push_dir := 0):
	var result = false
	push_dir = posmod(push_dir, 4)
	
	var b = push_areas[push_dir].get_overlapping_bodies()
	if b.size() == 0:
		if !test_tile(push_dir, 1):
			result = true
	else:
		if b[0] != self and b[0].is_in_group("box"):
			if b[0].is_floor and b[0].push(push_dir):
				result = true
	
	if result:
		move_tile(push_dir, 1)
		is_push = true
	
	return result

func spinner(right := false):
	set_dir(dir + (1 if right else 3))

func arrow(arg):
	if arg != dir:
		set_dir(arg)

func portal(pos):
	position = pos
	sprite.position = Vector2.ZERO

func outside_boundary():
	print(name, " outside boundary")
	
	if is_regenerate:
		set_physics_process(false)
		
		set_dir(start_dir)
		sprite.position = Vector2.ZERO
		turn_clock = 99
		
		var p = passhthrough_scene.instance()
		p.position = start_pos
		p.is_spawn_box = true
		p.box_to_move = self
		get_parent().add_child(p)
		p.set_physics_process(true)
	else:
		remove()

func remove():
	if is_instance_valid(actors):
		actors.boxes.erase(self)
	queue_free()
