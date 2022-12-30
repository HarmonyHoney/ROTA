tool
extends CanvasItem

export var leaves := 8 setget set_leaves
export var dist := 130.0 setget set_dist
export var radius := 70.0 setget set_radius
export var points := 8 setget set_points
export var draw_offset := Vector2.ZERO setget set_offset

var gon := PoolVector2Array()
export var poly_path : NodePath setget set_poly
onready var poly := get_node_or_null(poly_path)

export var is_draw_debug := false setget set_debug
var _draw_me := Vector2.ZERO
var _draw_circle := Vector2.ZERO

func u():
	gon = []
	
	var s = Vector2(dist, 0)
	var r = PI*(1.0/leaves)
	var line = Vector2(dist * 3.0, 0).rotated(r)
	radius = max(radius, Vector2(dist, 0).distance_to(Vector2(dist, 0).rotated(r)))
	
	var seg = Geometry.segment_intersects_circle(line, Vector2.ZERO, s, radius)
	var l = line * (1.0 - seg)
	var ang = (l - s).angle()
	
	#print("r: ", rad2deg(r), " leaves: ", leaves, " line: ", line, "seg: ", seg, " l: ", l, " ang: ", rad2deg(ang))
	_draw_me = l
	_draw_circle = s
	
	for i in leaves:
		var a = (float(i) / leaves) * TAU
		for y in points:
			gon.append(draw_offset + s.rotated(a) + Vector2(radius, 0).rotated(a + lerp(-ang, ang, float(y) / points)))
	
	if !poly: poly = get_node_or_null(poly_path)
	if poly and "polygon" in poly:
		poly.polygon = gon
	
	if Engine.editor_hint:
		property_list_changed_notify()
	update()

func _draw():
	if !poly: draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)
	if is_draw_debug:
		var c = Color(0,0,0, 0.5)
		draw_line(Vector2.ZERO, Vector2(dist * 2, 0), c, 5.0)
		draw_line(Vector2.ZERO, _draw_me, c, 5.0)
		draw_circle(_draw_me, 10, c)
		draw_circle(_draw_circle, radius, c)

func set_leaves(arg := leaves):
	leaves = max(1, arg)
	u()

func set_dist(arg := dist):
	dist = abs(arg)
	u()

func set_radius(arg := radius):
	radius = arg
	u()

func set_points(arg := points):
	points = max(arg, 1)
	u()

func set_offset(arg := draw_offset):
	draw_offset = arg
	u()

func set_poly(arg := poly_path):
	poly_path = arg
	u()

func set_debug(arg := is_draw_debug):
	is_draw_debug = arg
	u()
