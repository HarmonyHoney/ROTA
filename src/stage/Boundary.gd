extends Area2D

onready var shapes = get_children()
onready var shapes_size : int = shapes.size()
var active_shapes := 0

var margin = 10.0

func _ready():
	Shared.connect("scene_changed", self, "scene_changed")

func scene_changed():
	active_shapes = 0

func add_shape(rect, cell):
	var half = rect.size / 2.0
	shapes[active_shapes].global_position = (rect.position + half) * cell
	shapes[active_shapes].shape.extents = (half + (Vector2.ONE * margin)) * cell
	active_shapes = clamp(active_shapes + 1, 0, shapes_size)

func _on_Boundary_body_exited(body):
	var check = 0
	for i in shapes_size:
		if i > active_shapes:
			check += 1
			#print(shapes[i].name, ": inactive")
		else:
			var p = shapes[i].to_local(body.global_position)
			var s = shapes[i].shape.extents
			if abs(p.x) > s.x or abs(p.y) > s.y:
				check += 1
				#print(shapes[i].name, ": out")
	
	if check == shapes_size:
		if body.has_method("outside_boundary"):
			body.outside_boundary()
		#print(name, ": all out")
