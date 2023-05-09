extends KinematicBody2D

var dir_x := 1.0

export var speed := 100.0

export var room_size := Vector2(1200, 1200)


func _ready():
	move_and_collide(Vector2(0, 100))

	if randf() > 0.5:
		dir_x = -dir_x


func _physics_process(delta):
	move_and_slide(Vector2(speed * dir_x, 0.0))
	
	var tf = Transform2D(0.0, position + Vector2(dir_x * 20, 0.0))
	
	if test_move(transform, Vector2(dir_x, 0.0)) or !test_move(tf, Vector2(0, 50)):
		dir_x = -dir_x
	
	
	position.x = wrapf(position.x, 0.0, room_size.x)
	position.y = wrapf(position.y, 0.0, room_size.y)
