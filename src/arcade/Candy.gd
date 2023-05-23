extends KinematicBody2D

var dir_x := 0.0

export var speed := 100.0

var room_size := Vector2(600, 600)

onready var image := $Sprites
var spr_list := []

var walk_clock := 0.0
var is_dead := false
var dead_ease := EaseMover.new()
var is_floor := false

var arcade

var image_rot := 0.0
var delta_scale := 1.0

func _ready():
	for i in get_tree().get_nodes_in_group("arcade"):
		arcade = i
	arcade.candies.append(self)
	delta_scale = arcade.delta_scale
	
	randomize()
	speed *=  1.0 + rand_range(-0.1, 0.1)
	if dir_x == 0.0:
		dir_x = -1.0 if randf() < 0.5 else 1.0
	
	if test_move(transform, Vector2(0, 100)):
		move_and_collide(Vector2(0, 100))

func _exit_tree():
	arcade.candies.erase(self)

func _physics_process(delta):
	delta *= delta_scale
	#print(delta_scale)
	is_floor = test_move(transform, Vector2(0, 2.0))
	
	if !is_dead:
		move_and_collide(Vector2(speed * dir_x, 0.0) * delta)
		if !is_floor:
			move_and_collide(Vector2(0, 10.0))
	
	var tf = Transform2D(0.0, position + Vector2(dir_x * 20, 0.0))
	
	if test_move(transform, Vector2(dir_x, 0.0)) or !test_move(tf, Vector2(0, 50)):
		dir_x = -dir_x
	
	
	# animation
	if is_dead:
		var e = ease(dead_ease.count(delta, true, false), 0.5)
		image.scale = Vector2.ONE * lerp(1.0, 0.0, e)
		image.rotation_degrees = image_rot + lerp(0.0, 240.0 * dir_x, e)
	else:
		walk_clock += delta
		
		image_rot = sin(walk_clock * 8.0) * 10.0
		image.rotation_degrees = image_rot
		image.position.y = -abs(cos(walk_clock * 8.0) * 10.0)
	
	# wrap
	position.x = wrapf(position.x, -room_size.x, room_size.x)
	position.y = wrapf(position.y, -room_size.y, room_size.y)

func die():
	is_dead = true
	collision_layer = 0
	arcade.candies.erase(self)
	arcade.win()
	dir_x = -1.0 if randf() < 0.5 else 1.0






