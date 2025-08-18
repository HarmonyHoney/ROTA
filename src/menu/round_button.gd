tool
extends TouchScreenButton

export var angle := 0.0 setget set_angle
export var radius := 60.0 setget set_radius
export var points := 5 setget set_points
export var deadzone := 3.0 setget set_deadzone
export var dead_points := 5 setget set_dead_points

export var poly_path : NodePath = ""
onready var poly : Polygon2D = get_node_or_null(poly_path)
export var poly_offset := 5.0 setget set_poly_offset
export var poly_radius := 50.0 setget set_poly_radius
export var poly_points := 5 setget set_poly_points
export var poly_deadzone := 3.0 setget set_poly_deadzone
export var poly_dead_points := 5 setget set_poly_dead_points

export var secondary_action := ""

func set_radius(arg := radius):
	radius = arg
	act()

func set_points(arg := points):
	points = arg
	act()

func set_angle(arg := angle):
	angle = arg
	act()

func set_deadzone(arg := deadzone):
	deadzone = arg
	act()

func set_dead_points(arg := dead_points):
	dead_points = arg
	act()

func set_poly_radius(arg := poly_radius):
	poly_radius = arg
	poly_act()

func set_poly_offset(arg := poly_offset):
	poly_offset = arg
	poly_act()

func set_poly_deadzone(arg := poly_deadzone):
	poly_deadzone = arg
	poly_act()

func set_poly_points(arg := poly_points):
	poly_points = arg
	poly_act()

func set_poly_dead_points(arg := poly_dead_points):
	poly_dead_points = arg
	poly_act()

func _ready():
	act()
	poly_act()
	connect("pressed", self, "press")
	connect("released", self, "release")

func press():
	if secondary_action != "":
		Input.action_press(secondary_action)

func release():
	if secondary_action != "":
		Input.action_release(secondary_action)

func act():
	shape = ConvexPolygonShape2D.new()
	shape.points = make_shape()

func poly_act():
	if is_instance_valid(poly):
		poly.polygon = make_shape(poly_radius, poly_points, poly_deadzone, poly_dead_points)
		poly.position = Vector2(poly_offset, 0).rotated(deg2rad(angle))

func make_shape(_radius := radius, _points := points, _deadzone := deadzone, _dead_points := dead_points, _angle := angle):
	var vec = PoolVector2Array()
	
	for x in [[_dead_points, _deadzone, -1], [_points, _radius, 1]]:
		for y in x[0]:
			var f = y / float(x[0] - 1)
			vec.append(Vector2(x[1], 0).rotated(deg2rad(_angle + (lerp(-45, 45, f) * x[2]))))
	
	return vec
