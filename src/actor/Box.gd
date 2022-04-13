tool
extends KinematicBody2D
class_name Box

onready var collision_shape : CollisionShape2D = $CollisionShape2D
onready var push_areas : Array = $PushAreas.get_children()
onready var area_respawn := $RespawnArea
onready var area := $Area2D
onready var collision_sprite : CollisionShape2D = $Area2D/CollisionSprite

onready var sprite : Node2D = $Sprites
onready var box_sprite : Sprite = $Sprites/Box

onready var audio_move := $Audio/Move
onready var audio_land := $Audio/Land
onready var audio_fallout := $Audio/Fallout
onready var audio_respawn := $Audio/Respawn

export var dir := 0 setget set_dir
var dir_last := 0

var can_push := true setget set_can_push
export var can_spin := true setget set_can_spin

var tex_push = preload("res://media/image/box/box_push.png")
var tex_both = preload("res://media/image/box/box_both.png")

var tile := 100.0
var move_from := Vector2.ZERO

var turn_from := 0.0
var turn_to := 0.0

var start_dir := 0
var start_pos := Vector2.ZERO

var is_floor := false
var last_floor := false
var is_respawn := false
var is_push := false
var push_x := -1
var is_hold := false
var is_turn := false

var pickup_angle := 12.0

onready var push_ease := EaseMover.new(null, 0.2)
onready var turn_ease := EaseMover.new(null, 0.2)
onready var respawn_ease := EaseMover.new(null, 1.0)
onready var pickup_ease := EaseMover.new(null, 0.2)

var velocity := 0.0
export var start_velocity := 100.0
export var gravity := 200.0
var is_move := false

func _enter_tree():
	if Engine.editor_hint: return
	Shared.boxes.append(self)

func _exit_tree():
	if Engine.editor_hint: return
	Shared.boxes.erase(self)

func _ready():
	set_sprite()
	if Engine.editor_hint: return
	
	turn_ease.clock = 99
	
	# snap to grid
	position = (Vector2.ONE * tile / 2) + (position / tile).floor() * tile
	
	# vars for respawn
	start_dir = dir
	start_pos = position
	
	# check floor
	is_floor = test_tile(dir, 1)
	last_floor = is_floor

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if is_respawn:
		sprite.scale = Vector2.ONE * respawn_ease.count(delta)
		
		if respawn_ease.is_complete and area_respawn.get_overlapping_bodies().size() == 0:
			is_respawn = false
			
			collision_shape.set_deferred("disabled", false)
			area.set_deferred("monitorable", true)
			
			audio_respawn.play()
			sprite.modulate.a = 1.0
		return
	
	elif is_push:
		var s = push_ease.count(delta)
		# lerp sprite and update collision_sprite
		sprite.position = move_from.linear_interpolate(Vector2.ZERO, s)
		collision_sprite.position = sprite.position
		sprite.rotation = lerp_angle(turn_to + deg2rad(12 * -push_x), turn_to, abs(0.5 - s) * 2.0)
		
		if push_ease.is_complete:
			is_push = false
	
	# turn clock
	elif is_turn:
		var s = turn_ease.count(delta)
		sprite.rotation = lerp_angle(turn_from, turn_to, s)
		sprite.scale = Vector2.ONE * lerp(0.8, 1.0, s)
		
		if turn_ease.is_complete:
			is_turn = false
	
	# pickup clock
	elif pickup_ease.clock < pickup_ease.time:
		sprite.scale = Vector2.ONE * lerp(1.1, 1.0, pickup_ease.count(delta))
	
	# movement
	elif is_move:
		velocity += gravity * delta
		sprite.position = sprite.position.move_toward(Vector2.ZERO, velocity * delta)
		collision_sprite.position = sprite.position
		
		if sprite.position == Vector2.ZERO:
			is_move = false
			
			if Boundary.is_outside(global_position):
				outside_boundary()
			else:
				audio_land.pitch_scale = rand_range(0.7, 1.3)
				audio_land.play()
	
	# start movement
	elif !is_move:
		# get floor
		last_floor = is_floor
		is_floor = test_tile()
		
		if !is_floor and !is_hold:
			var move_count := 0
			while !test_tile() and !Boundary.is_outside(global_position):
				move_tile()
				move_count += 1
			
			is_move = true
			velocity = start_velocity
			
			audio_move.pitch_scale = rand_range(0.7, 1.3)
			audio_move.play()

func set_dir(arg := dir):
	dir_last = dir
	dir = posmod(arg, 4)
	
	if is_instance_valid(sprite):
		turn_from = sprite.rotation
	turn_to = deg2rad(dir * 90)
	if turn_ease:
		turn_ease.clock = 0.0
	is_turn = true
	
	if Engine.editor_hint:
		$Sprites.rotation = turn_to

func rot(arg : Vector2, _dir := dir, backwards := false):
	return arg.rotated(deg2rad((-_dir if backwards else _dir) * 90))

func shrink_shape(shrink := true):
	collision_shape.shape.extents = Vector2(49, 49) if shrink else Vector2(50, 50)

func test_tile(check_dir := dir, distance := 1) -> bool:
	var vec = rot(Vector2.DOWN * distance * tile, check_dir)
	
	shrink_shape()
	var result = test_move(transform, vec)
	shrink_shape(false)
	
	if !result:
		var check_pos = position + vec
		check_pos = Vector2(stepify(check_pos.x, 50), stepify(check_pos.y, 50))
		
		for i in Shared.boxes:
			if i != self:
				if check_pos == i.position:
					result = true
					break
	
	return result

func move_tile(move_dir := dir, distance := 1):
	var last_pos = position
	position += rot(Vector2.DOWN * distance * tile, move_dir)
	position = Vector2(stepify(position.x, 50), stepify(position.y, 50))
	
	#print(name, ": ", last_pos, " - ", position)
	
	# move sprite
	sprite.position -= position - last_pos
	move_from = sprite.position

# start push at first box in line
func start_push(push_dir := 0, _push_x := 1):
	push_dir = posmod(push_dir, 4)
	var result = false
	
	var b = push_areas[posmod(push_dir + 2, 4)].get_overlapping_bodies()
	if b.size() > 0 and b[0].is_floor and b[0].dir == push_dir:
		result = b[0].start_push(push_dir, _push_x)
	else:
		result = push(push_dir, _push_x)
	
	return result

# move boxes in line
func push(push_dir := 0, _push_x := 1):
	push_dir = posmod(push_dir, 4)
	push_x = _push_x
	var result = false
	
	var b = push_areas[push_dir].get_overlapping_bodies()
	if b.size() == 0:
		if !test_tile(push_dir, 1):
			result = true
	elif b[0] != self and b[0].is_in_group("box") and b[0].push(push_dir, _push_x):
		result = true
	
	if result:
		move_tile(push_dir, 1)
		is_push = true
		push_ease.clock = 0.0
	
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
	
	if !is_respawn:
		is_respawn = true
		
		set_dir(start_dir)
		position = start_pos
		sprite.position = Vector2.ZERO
		turn_ease.clock = 0.0
		respawn_ease.clock = 0.0
		
		collision_shape.set_deferred("disabled", true)
		area.set_deferred("monitorable", false)
		
		sprite.scale = Vector2.ZERO
		sprite.modulate.a = 0.5
		audio_fallout.play()

func set_can_push(arg):
	can_push = arg
	set_sprite()

func set_can_spin(arg):
	can_spin = arg
	set_sprite()

func set_sprite():
	if box_sprite:
		box_sprite.texture = tex_both if can_spin else tex_push

func pickup():
	pickup_ease.clock = 0.0

