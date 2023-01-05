tool
extends Node2D

export var width := 50.0 setget set_width
export var end_scale := 0.75 setget set_end
export var length = 25.0
export var sitting_angle = 15.0
export var point_count := 3 setget set_points
export var vertices := 16 setget set_vertices
export var gravity = 190.0
export var is_scale_x := true

var gons = []
var last_pos := Vector2.ZERO
var hair_end = Vector2(-150, 150)

func _ready():
	u()

func u():
	for i in get_children():
		i.queue_free()
	gons = []
	
	for p in point_count:
		var s = width * 0.5 * lerp(1.0, end_scale, p / float(point_count - 1))
		var a = []
		for i in vertices:
			a.append(s * Vector2.RIGHT.rotated(TAU * (float(i) / vertices)))
		
		var g = Polygon2D.new()
		g.polygon = a
		add_child(g)
		gons.append(g)

func _physics_process(delta):
	# move end
	hair_end -= hair_end - to_local(last_pos)
	
	# gravity
	hair_end += Vector2.DOWN.rotated(deg2rad(sitting_angle)) * gravity * delta
	
	# keep length
	if hair_end.length() > length:
		hair_end = hair_end.normalized() * length
	last_pos = to_global(hair_end)
	
	# set points
	for i in gons.size():
		gons[i].position = hair_end.normalized() * hair_end.length() * (float(i) / (gons.size() - 1))

func set_points(arg := point_count):
	point_count = max(2, arg)
	u()

func set_vertices(arg := vertices):
	vertices = max(3, arg)
	u()

func set_width(arg := width):
	width = arg
	u()

func set_end(arg := end_scale):
	end_scale = arg
	u()

func scale_x(arg):
	if is_scale_x: scale.x = arg
