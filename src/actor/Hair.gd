tool
extends Node2D

export var width := 50.0 setget set_width
export var end_scale := 0.75 setget set_end
export var length = 25.0
export var sitting_angle = 15.0
export var point_count := 3 setget set_points
export var gravity = 190.0

var points = []
var sizes = []
var last_pos := Vector2.ZERO
var hair_end = Vector2(-150, 150)

onready var start_x := scale.x
export var is_scale_x := true

func _ready():
	set_points()

func _draw():
	# set sprites
	for i in points.size():
		draw_circle(points[i], sizes[i], Color.white)

func _physics_process(delta):
	# move end
	hair_end -= hair_end - to_local(last_pos)
	
	# gravity
	hair_end += Vector2.DOWN.rotated(deg2rad(sitting_angle)) * gravity * delta
	
	# keep length
	if hair_end.length() > length:
		hair_end = hair_end.normalized() * length
	
	# set points
	for i in points.size():
		points[i] = hair_end.normalized() * hair_end.length() * (float(i) / (points.size() - 1))
	
	last_pos = to_global(hair_end)
	update()

func set_points(arg := point_count):
	point_count = max(2, arg)
	points = []
	for i in point_count:
		points.append(Vector2.ZERO)
	sprite_scale()

func sprite_scale():
	sizes = []
	for i in points.size():
		sizes.append(width * 0.5 * lerp(1.0, end_scale, i / float(point_count - 1)))
	update()

func set_width(arg := width):
	width = arg
	sprite_scale()

func set_end(arg := end_scale):
	end_scale = arg
	sprite_scale()

func scale_x(arg):
	if is_scale_x:
		scale.x = start_x * arg
