tool
extends KinematicBody2D
class_name Box

onready var collision_shape : CollisionShape2D = $CollisionShape2D
onready var standing_area : Area2D = $StandingArea
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
var is_floor := false
var move_clock := 0.0
var move_time := 0.2
var move_from := Vector2.ZERO
var move_to := Vector2.ZERO

var turn_from := 0.0
var turn_to := 0.0
var turn_clock := 0.0
var turn_time := 0.2

var is_push := false
var push_clock := 0.0
var push_time := 0.2

var start_dir := 0
var start_pos := Vector2.ZERO
var is_respawn := false
var respawn_clock := 0.0
var respawn_time := 0.4

var is_hold := false
var push_x := -1
var is_turn := false

var pickup_clock := 0.0
var pickup_time := 0.2
var pickup_angle := 12.0


func _enter_tree():
	if Engine.editor_hint: return
	Shared.boxes.append(self)

func _exit_tree():
	if Engine.editor_hint: return
	Shared.boxes.erase(self)

func _ready():
	set_sprite()
	if Engine.editor_hint: return
	
	turn_clock = 99
	
	# snap to grid
	position = (Vector2.ONE * tile / 2) + (position / tile).floor() * tile
	
	# vars for respawn
	start_dir = dir
	start_pos = position
	
	# check floor
	is_floor = test_tile(dir, 1)
	move_clock = move_time

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if is_respawn:
		respawn_clock = min(respawn_clock + delta, respawn_time)
		
		var s = smoothstep(0, 1, respawn_clock / respawn_time)
		sprite.scale = Vector2.ONE * s
		
		if respawn_clock == respawn_time and area_respawn.get_overlapping_bodies().size() == 0:
			is_respawn = false
			
			collision_shape.set_deferred("disabled", false)
			area.set_deferred("monitorable", true)
			
			audio_respawn.play()
			sprite.modulate.a = 1.0
		return
	
	
	# on floor
	is_floor = test_tile(dir, 1)
	
	# move clock
	var target = push_time if is_push else move_time
	if move_clock < target:
		move_clock = min(move_clock + delta, target)
		var smooth = smoothstep(0, 1, move_clock / target)
		# lerp sprite and update collision_sprite
		sprite.position = move_from.linear_interpolate(Vector2.ZERO, smooth)
		collision_sprite.position = sprite.position
		
		if is_hold:
			sprite.rotation = lerp_angle(turn_to + deg2rad(12 * -push_x), turn_to, abs(0.5 - smooth) * 2.0)
			
			#sprite.scale = Vector2.ONE *  lerp(0.9, 1.0, smooth)
		
		if move_clock == target and !is_hold and is_floor:
			audio_land.pitch_scale = rand_range(0.7, 1.3)
			audio_land.play()
	
	# turn clock
	elif turn_clock != turn_time:
		turn_clock = min(turn_clock + delta, turn_time)
		var smooth = smoothstep(0, 1, turn_clock / turn_time)
		sprite.rotation = lerp_angle(turn_from, turn_to, smooth)
		sprite.scale = Vector2.ONE * lerp(0.8, 1.0, smooth)
		
		if turn_clock == turn_time:
			is_turn = false
	
	# pickup clock
	if pickup_clock != pickup_time:
		pickup_clock = min(pickup_clock + delta, pickup_time)
		var smooth = smoothstep(0, 1, pickup_clock / pickup_time)
		sprite.scale = Vector2.ONE * lerp(1.1, 1.0, smooth)
	
	# movement
	if move_clock == target:
		if is_push:
			is_push = false
		
		# move down
		if !is_hold and !is_floor:
			move_tile(dir, 1)
			
			audio_move.pitch_scale = rand_range(0.7, 1.3)
			audio_move.play()
			
			#if test_tile(dir, 1):
			#	pickup_clock = 0.0

func set_dir(arg := dir):
	dir_last = dir
	dir = posmod(arg, 4)
	
	if is_instance_valid(sprite):
		turn_from = sprite.rotation
	turn_to = deg2rad(dir * 90)
	turn_clock = 0.0
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
	# jump player
	for i in standing_area.get_overlapping_bodies():
		if i.is_in_group("player"):
			i.has_jumped = true
			if i.velocity.y > 0:
				i.velocity.y = 0
	
	# move
	var last_pos = position
	position += rot(Vector2.DOWN * distance * tile, move_dir)
	position = Vector2(stepify(position.x, 50), stepify(position.y, 50))
	
	print(name, ": ", last_pos, " - ", position)
	
	# move sprite
	sprite.position -= position - last_pos
	move_from = sprite.position
	
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
		
		# bring box behind
		var behind = push_areas[posmod(push_dir + 2, 4)].get_overlapping_bodies()
		if behind.size() > 0:
			if behind[0] != self and behind[0].is_in_group("box"):
				get_parent().move_child(behind[0], get_index() + 1)
	
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
		turn_clock = 0
		move_clock = move_time
		respawn_clock = 0.0
		
		collision_shape.set_deferred("disabled", true)
		area.set_deferred("monitorable", false)
		
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


