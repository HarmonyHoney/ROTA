tool
extends CanvasItem

var gon := PoolVector2Array()

export var width := 8.5 setget set_width
export var length := 17.0 setget set_length
export var points := 5 setget set_points
export var offset := Vector2.ZERO setget set_offset

export var poly_path : NodePath setget set_poly
onready var poly := get_node_or_null(poly_path)


func u():
	gon = []
	
	
	for i in 4:
		var r = (float(i) / 4.0) * TAU
		
		gon.append((Vector2(1,-1) * width).rotated(r))
		
		var s = Vector2(length, 0).rotated(r)
		for y in points + 1:
			gon.append(s + Vector2(width, 0).rotated(r + lerp(-PI*.5, PI*.5, float(y) / points)))
	
	if !poly: poly = get_node_or_null(poly_path)
	if poly:
		poly.polygon = gon
	
	if Engine.editor_hint:
		property_list_changed_notify()
	update()

func _draw():
	if !poly: draw_colored_polygon(gon, Color.white, PoolVector2Array(), null, null, true)
 
func set_width(arg := width):
	width = arg
	u()

func set_length(arg := length):
	length = arg
	u()

func set_offset(arg := offset):
	offset = arg
	u()

func set_points(arg := points):
	points = max(arg, 1)
	u()

func set_poly(arg := poly_path):
	poly_path = arg
	u()
