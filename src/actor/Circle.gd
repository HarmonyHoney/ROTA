tool
extends CanvasItem

export var radius := 50.0 setget set_radius
export var circle_offset := Vector2.ZERO setget set_offset

var gon := PoolVector2Array()
export var points := 16 setget set_points

export var poly_path : NodePath setget set_poly
onready var poly := get_node_or_null(poly_path)

func u():
	gon = []
	
	for i in points:
		gon.append(circle_offset + (radius * Vector2.RIGHT.rotated(TAU * (float(i) / points))))
	
	if !poly: poly = get_node_or_null(poly_path)
	if poly:
		poly.polygon = gon
	
	if Engine.editor_hint:
		property_list_changed_notify()
	
	update()

func _draw():
	if !poly: draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)

func set_radius(arg := radius):
	radius = abs(arg)
	u()

func set_offset(arg := circle_offset):
	circle_offset = arg
	u()

func set_points(arg := points):
	points = max(arg, 3)
	u()

func set_poly(arg := poly_path):
	poly_path = arg
	u()
