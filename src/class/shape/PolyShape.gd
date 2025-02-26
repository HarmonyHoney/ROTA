@tool
extends CanvasItem
class_name PolyShape

var gon := PackedVector2Array()
var is_poly := false

@export var poly_path : NodePath = ".": set = set_poly
@onready var poly := get_node_or_null(poly_path)
@export var is_baked := true: set = set_baked

func u():
	if !poly: poly = get_node_or_null(poly_path)
	is_poly = poly and "polygon" in poly
	if is_baked and is_poly: return
	
	shape()
	if is_poly: poly.polygon = gon
	
	if Engine.is_editor_hint():
		notify_property_list_changed()
	queue_redraw()

func shape():
	pass

func set_poly(arg := poly_path):
	poly_path = arg
	poly = null
	u()

func set_baked(arg := is_baked):
	is_baked = arg
	if !arg: u()
