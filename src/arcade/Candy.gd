extends KinematicBody2D

var dir_x := 1.0

export var speed := 100.0

var room_size := Vector2(600, 600)

onready var image := $Sprites
var spr_list := []

var walk_clock := 0.0
var is_dead := false
var dead_ease := EaseMover.new()

var arcade

func _ready():
	for i in get_tree().get_nodes_in_group("arcade"):
		arcade = i
	arcade.candies.append(self)
	
	move_and_collide(Vector2(0, 500))

	if randf() > 0.5:
		dir_x = -dir_x
	
	
	spr_list = []
	for i in 3:
		var s = image.duplicate()
		add_child(s)
		spr_list.append(s)

func _physics_process(delta):
	if !is_dead:
		move_and_slide(Vector2(speed * dir_x, 0.0))
	
	var tf = Transform2D(0.0, position + Vector2(dir_x * 20, 0.0))
	
	if test_move(transform, Vector2(dir_x, 0.0)) or !test_move(tf, Vector2(0, 50)):
		dir_x = -dir_x
	
	
	# animation
	if is_dead:
		var s = dead_ease.count(delta)
		image.scale = Vector2.ONE * lerp(1.0, 0.0, s)
	else:
		walk_clock += delta
		
		image.rotation_degrees = sin(walk_clock * 8.0) * 8.0
		image.position.y = -abs(cos(walk_clock * 8.0) * 10.0)
	
	# wrap
	position.x = wrapf(position.x, -room_size.x, room_size.x)
	position.y = wrapf(position.y, -room_size.y, room_size.y)
	
	var sg = image.global_position
	var add = Vector2(room_size.x * -sign(sg.x), room_size.y * -sign(sg.y)) * 2.0
	
	for i in 3:
		spr_list[i].rotation = image.rotation
		spr_list[i].scale = image.scale
		spr_list[i].global_position = sg + (add * [Vector2.RIGHT, Vector2.DOWN, Vector2.ONE][i])

func die():
	is_dead = true
	collision_layer = 0
	arcade.candies.erase(self)
	arcade.win()






