tool
extends CanvasItem

var gon := PoolVector2Array()

export var size := Vector2.ONE * 50 setget set_size
export var offset := Vector2.ZERO setget set_offset
export var radius := Plane() setget set_radius
export var points := 8 setget set_points

export var poly_path : NodePath setget set_poly
onready var poly := get_node_or_null(poly_path)
export var is_baked := false


func u():
	if is_baked: return
	gon = []
	
	var vec = [Vector2.ONE, Vector2(-1, 1), -Vector2.ONE, Vector2(1, -1)]
	var rad = [radius.x, radius.y, radius.z, radius.d]
	
	for i in 4:
		var r = rad[0] if rad[i] < 0 else rad[i]
		
		if points > 1 and r > 0:
			var v = vec[i] * size - (vec[i] * r)
			
			for p in points:
				var a = ((PI*.5) * i) + ((PI*.5) * (float(p) / (points - 1)))
				gon.append(offset + v + Vector2(r, 0).rotated(a))
		else:
			gon.append(offset + vec[i] * size)
	
	if !poly: poly = get_node_or_null(poly_path)
	if poly and "polygon" in poly:
		poly.polygon = gon
	
	if Engine.editor_hint:
		property_list_changed_notify()
	update()

func _draw():
	if !poly: draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)
 
func set_offset(arg := offset):
	offset = arg
	u()

func set_points(arg := points):
	points = max(arg, 1)
	u()

func set_size(arg := size):
	size = arg.abs()
	u()

func set_radius(arg := radius):
	radius = arg
	u()

func set_poly(arg := poly_path):
	poly_path = arg
	u()

func get_rect():
	return Rect2(offset - size, size * 2.0)
