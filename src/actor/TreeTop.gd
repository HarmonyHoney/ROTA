tool
extends CanvasItem

export var start_dist := 170.0 setget set_start
export var distance := 130.0 setget set_distance
export var circle_offset := Vector2.ZERO setget set_offset

export var gon := PoolVector2Array()
export var points := 16 setget set_points

export var poly_path : NodePath setget set_poly
onready var poly := get_node_or_null(poly_path)

func u():
	gon = []
	
	for i in 8:
		var start = Vector2(start_dist, 0).rotated(deg2rad((i * 45) - 22.5))
		var end = Vector2(start_dist, 0).rotated(deg2rad((i * 45) + 22.5))
		
		var center = start.linear_interpolate(end, 0.5).normalized() * distance
		var r = center.distance_to(start)
		var a1 = center.angle_to_point(start)
		var a2 = center.angle_to_point(end)
		#print("a1: ", rad2deg(a1), " a2: ", rad2deg(a2), " r: ", r)
		
		for y in points:
			gon.append(circle_offset + center + Vector2(r, 0).rotated(lerp_angle(a2 + deg2rad(45), a1 + deg2rad(45), -float(y) / points)))
	
	if !poly: poly = get_node_or_null(poly_path)
	if poly:
		poly.polygon = gon
	
	if Engine.editor_hint:
		property_list_changed_notify()
	
	update()

func _draw():
	if !poly: draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)

func set_start(arg := start_dist):
	start_dist = arg
	u()

func set_distance(arg := distance):
	distance = abs(arg)
	u()

func set_offset(arg := circle_offset):
	circle_offset = arg
	u()

func set_points(arg := points):
	points = max(arg, 1)
	u()

func set_poly(arg := poly_path):
	poly_path = arg
	u()
