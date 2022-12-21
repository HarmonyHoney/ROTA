tool
extends CanvasItem

export var radius := 50.0 setget set_radius
export var offset := Vector2.ZERO setget set_offset

var gon := PoolVector2Array()
export var points := 16 setget set_points

func u():
	gon = []
	
	for i in points:
		gon.append(offset + (radius * Vector2.RIGHT.rotated(TAU * (float(i) / points))))
	
	update()

func _draw():
	draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)

func set_radius(arg := radius):
	radius = abs(arg)
	u()

func set_offset(arg := offset):
	offset = arg
	u()

func set_points(arg := points):
	points = max(arg, 3)
	u()
