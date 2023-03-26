tool
extends PolyShape

export var size := Vector2.ONE * 50 setget set_size
export var rect_offset := Vector2.ZERO setget set_offset
export var radius := Plane(0, -1, -1, -1) setget set_radius
export var points := 8 setget set_points

var vertex_merge := 0.05

func _draw():
	if !is_poly and gon.size() > 2: draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)
 
func shape():
	gon = []
	
	var vec = [Vector2.ONE, Vector2(-1, 1), -Vector2.ONE, Vector2(1, -1)]
	var rad = [radius.x, radius.y, radius.z, radius.d]
	
	for i in 4:
		var r = rad[0] if rad[i] == -1 else rad[i]
		r = clamp(INF if r == -2 else r, 0, min(size.x, size.y))
		
		if points > 1 and r > 0:
			var v = vec[i] * size - (vec[i] * r)
			
			for p in points:
				var a = ((PI*.5) * i) + ((PI*.5) * (float(p) / (points - 1)))
				var vertex = rect_offset + v + Vector2(r, 0).rotated(a)
				var is_do = true
				
				if i > 0 and (p == 0 or (i == 3 and p == points - 1)):
					is_do = vertex.distance_to(gon[-1 if p == 0 else 0]) > vertex_merge
				
				if is_do:
					gon.append(vertex)
		else:
			gon.append(rect_offset + vec[i] * size)

func set_offset(arg := rect_offset):
	rect_offset = arg
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

func get_rect():
	return Rect2(rect_offset - size, size * 2.0)
