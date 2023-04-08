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
export var is_stiff := false
export var dir_x := 1
export var offset_angle := 0.0

var gons = []
var last_pos := Vector2.ZERO
var hair_end := Vector2.ZERO

func _ready():
	u()
	
	if Engine.editor_hint: return
	
	if !is_stiff: is_stiff = abs(sitting_angle) > 90.0

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

func _process(delta):
	# angle
	var a = deg2rad((sitting_angle * dir_x)) + offset_angle
	if is_stiff: a += global_rotation - offset_angle
	
	# movement + gravity
	hair_end = to_local(last_pos + (Vector2.DOWN.rotated(a) * gravity * delta))
	
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
	if is_scale_x: dir_x = arg

func turn_angle(arg):
	offset_angle = arg
