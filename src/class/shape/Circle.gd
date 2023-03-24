tool
extends PolyShape

export var radius := 50.0 setget set_radius
export var circle_offset := Vector2.ZERO setget set_offset
export var points := 16 setget set_points

func _draw():
	if !is_poly and gon.size() > 2: draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)

func shape():
	gon = []
	for i in points:
		gon.append(circle_offset + (radius * Vector2.RIGHT.rotated(TAU * (float(i) / points))))

func set_radius(arg := radius):
	radius = abs(arg)
	u()

func set_offset(arg := circle_offset):
	circle_offset = arg
	u()

func set_points(arg := points):
	points = max(arg, 3)
	u()
